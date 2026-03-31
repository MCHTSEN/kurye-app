import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/product/ugrama/ugrama_resolution_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_ugrama_repository.dart';

void main() {
  group('UgramaResolutionService fallback', () {
    late FakeUgramaRepository ugramaRepo;
    late FakeMusteriUgramaRepository musteriUgramaRepo;
    late UgramaResolutionService service;

    setUp(() {
      ugramaRepo = FakeUgramaRepository(
        seed: const [
          Ugrama(id: 'u1', ugramaAdi: 'Merkez Ofis', adres: 'Adres A'),
          Ugrama(id: 'u2', ugramaAdi: 'Merkez Ofis', adres: 'Adres B'),
          Ugrama(id: 'u3', ugramaAdi: 'Depo'),
        ],
      );
      musteriUgramaRepo = FakeMusteriUgramaRepository()
        ..ugramaRepo = ugramaRepo;
      service = UgramaResolutionService(
        resolutionRepo: null,
        ugramaRepo: ugramaRepo,
        musteriUgramaRepo: musteriUgramaRepo,
      );
    });

    test('returns exact match when name and address match', () async {
      final result = await service.resolveForMusteri(
        musteriId: 'm1',
        ugramaAdi: '  merkez ofis  ',
        adres: 'adres a',
      );

      expect(result.resolutionType, UgramaResolutionType.existingExact);
      expect(result.resolvedUgramaId, 'u1');
    });

    test('returns ambiguous candidates when only name matches', () async {
      final result = await service.resolveForMusteri(
        musteriId: 'm1',
        ugramaAdi: 'Merkez Ofis',
      );

      expect(result.resolutionType, UgramaResolutionType.ambiguousName);
      expect(
        result.candidates.map((item) => item.id),
        containsAll(['u1', 'u2']),
      );
      expect(result.resolvedUgramaId, isNull);
    });

    test('creates and assigns new stop with createNew strategy', () async {
      final result = await service.resolveForMusteri(
        musteriId: 'm1',
        ugramaAdi: 'Yeni Şube',
        strategy: UgramaResolutionStrategy.createNew,
      );

      expect(result.resolutionType, UgramaResolutionType.createdNew);
      expect(result.resolvedUgramaId, isNotNull);
      expect(
        ugramaRepo.store.values.any((item) => item.ugramaAdi == 'Yeni Şube'),
        isTrue,
      );
    });
  });
}
