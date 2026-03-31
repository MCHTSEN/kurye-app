import 'package:backend_core/backend_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import 'ugrama_providers.dart';

final ugramaResolutionRepositoryProvider =
    Provider<UgramaResolutionRepository?>((ref) {
      try {
        return ref
            .read(backendModuleProvider)
            .createUgramaResolutionRepository();
      } on Object {
        return null;
      }
    });

final ugramaResolutionServiceProvider = Provider<UgramaResolutionService>(
  (ref) {
    return UgramaResolutionService(
      resolutionRepo: ref.read(ugramaResolutionRepositoryProvider),
      ugramaRepo: ref.read(ugramaRepositoryProvider),
      musteriUgramaRepo: ref.read(musteriUgramaRepositoryProvider),
    );
  },
);

class UgramaResolutionService {
  const UgramaResolutionService({
    required UgramaResolutionRepository? resolutionRepo,
    required UgramaRepository ugramaRepo,
    required MusteriUgramaRepository musteriUgramaRepo,
  }) : _resolutionRepo = resolutionRepo,
       _ugramaRepo = ugramaRepo,
       _musteriUgramaRepo = musteriUgramaRepo;

  final UgramaResolutionRepository? _resolutionRepo;
  final UgramaRepository _ugramaRepo;
  final MusteriUgramaRepository _musteriUgramaRepo;

  Future<UgramaResolutionResult> resolveForMusteri({
    required String musteriId,
    required String ugramaAdi,
    String? adres,
    UgramaResolutionStrategy strategy = UgramaResolutionStrategy.auto,
    String? preferredUgramaId,
  }) async {
    if (_resolutionRepo != null) {
      try {
        return await _resolutionRepo.resolveForMusteri(
          musteriId: musteriId,
          ugramaAdi: ugramaAdi,
          adres: adres,
          strategy: strategy,
          preferredUgramaId: preferredUgramaId,
        );
      } on Exception {
        // If remote resolver is unavailable (e.g. RPC not migrated yet),
        // keep order creation usable via local repository fallback.
      }
    }

    return _resolveFallback(
      musteriId: musteriId,
      ugramaAdi: ugramaAdi,
      adres: adres,
      strategy: strategy,
      preferredUgramaId: preferredUgramaId,
    );
  }

  Future<UgramaResolutionResult> _resolveFallback({
    required String musteriId,
    required String ugramaAdi,
    required UgramaResolutionStrategy strategy,
    String? adres,
    String? preferredUgramaId,
  }) async {
    final normalizedName = _normalize(ugramaAdi);
    if (normalizedName.isEmpty) {
      return const UgramaResolutionResult(
        resolutionType: UgramaResolutionType.notFound,
      );
    }
    final normalizedAddress = _normalize(adres ?? '');
    final allStops = await _ugramaRepo.getAll();

    if (strategy == UgramaResolutionStrategy.useExisting) {
      if (preferredUgramaId == null || preferredUgramaId.isEmpty) {
        throw ArgumentError(
          'preferredUgramaId is required for useExisting strategy.',
        );
      }
      await _musteriUgramaRepo.assign(musteriId, preferredUgramaId);
      return UgramaResolutionResult(
        resolutionType: UgramaResolutionType.existingSelected,
        resolvedUgramaId: preferredUgramaId,
      );
    }

    if (strategy == UgramaResolutionStrategy.createNew) {
      final created = await _ugramaRepo.create(
        Ugrama(
          id: '',
          ugramaAdi: ugramaAdi.trim(),
          adres: _emptyToNull(adres?.trim()),
        ),
      );
      await _musteriUgramaRepo.assign(musteriId, created.id);
      return UgramaResolutionResult(
        resolutionType: UgramaResolutionType.createdNew,
        resolvedUgramaId: created.id,
      );
    }

    final exactMatch = allStops.where((item) {
      return _normalize(item.ugramaAdi) == normalizedName &&
          _normalize(item.adres ?? '') == normalizedAddress;
    });

    if (exactMatch.isNotEmpty) {
      final first = exactMatch.first;
      await _musteriUgramaRepo.assign(musteriId, first.id);
      return UgramaResolutionResult(
        resolutionType: UgramaResolutionType.existingExact,
        resolvedUgramaId: first.id,
      );
    }

    final nameCandidates = allStops
        .where((item) => _normalize(item.ugramaAdi) == normalizedName)
        .map(
          (item) => UgramaResolutionCandidate(
            id: item.id,
            ugramaAdi: item.ugramaAdi,
            adres: item.adres,
          ),
        )
        .toList();

    if (nameCandidates.isNotEmpty) {
      return UgramaResolutionResult(
        resolutionType: UgramaResolutionType.ambiguousName,
        candidates: nameCandidates,
      );
    }

    return const UgramaResolutionResult(
      resolutionType: UgramaResolutionType.notFound,
    );
  }
}

String _normalize(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

String? _emptyToNull(String? value) {
  if (value == null || value.isEmpty) return null;
  return value;
}
