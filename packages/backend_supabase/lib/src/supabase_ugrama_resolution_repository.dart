import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUgramaResolutionRepository implements UgramaResolutionRepository {
  SupabaseUgramaResolutionRepository({required SupabaseClient client})
    : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger(
    'SupabaseUgramaResolutionRepo',
    tag: LogTag.data,
  );

  @override
  Future<UgramaResolutionResult> resolveForMusteri({
    required String musteriId,
    required String ugramaAdi,
    String? adres,
    UgramaResolutionStrategy strategy = UgramaResolutionStrategy.auto,
    String? preferredUgramaId,
  }) async {
    _log.i(
      'resolveForMusteri: musteri=$musteriId strategy=${strategy.value} '
      'name=$ugramaAdi',
    );

    final result = await _client.rpc<Map<String, dynamic>>(
      'resolve_or_create_ugrama_for_musteri',
      params: {
        'p_musteri_id': musteriId,
        'p_ugrama_adi': ugramaAdi,
        'p_adres': adres,
        'p_strategy': strategy.value,
        'p_preferred_ugrama_id': preferredUgramaId,
      },
    );

    return UgramaResolutionResult.fromJson(result);
  }
}
