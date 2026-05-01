import 'domain/ugrama_resolution.dart';

abstract class UgramaResolutionRepository {
  Future<UgramaResolutionResult> resolveForMusteri({
    required String musteriId,
    required String ugramaAdi,
    String? adres,
    UgramaResolutionStrategy strategy = UgramaResolutionStrategy.auto,
    String? preferredUgramaId,
  });
}
