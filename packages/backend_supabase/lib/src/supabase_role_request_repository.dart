import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRoleRequestRepository implements RoleRequestRepository {
  SupabaseRoleRequestRepository({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;
  static final _log = AppLogger('SupabaseRoleRequestRepo', tag: LogTag.auth);

  @override
  Future<RoleRequest?> getMyPendingRequest(String userId) async {
    final data = await _client
        .from('role_requests')
        .select()
        .eq('user_id', userId)
        .eq('status', 'beklemede')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return RoleRequest.fromJson(data);
  }

  @override
  Future<RoleRequest?> getMyLatestRequest(String userId) async {
    final data = await _client
        .from('role_requests')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return RoleRequest.fromJson(data);
  }

  @override
  Future<RoleRequest> createRequest(RoleRequest request) async {
    _log.i(
      'Creating role request: ${request.requestedRole.value} '
      'for ${request.userId}',
    );
    try {
      final result = await _client.rpc(
        'create_role_request_with_provisioning',
        params: {
          'p_display_name': request.displayName,
          'p_phone': request.phone,
          'p_note': request.note,
          'p_account_type': request.accountType?.value,
          'p_company_name': request.companyName,
          'p_musteri_id': request.musteriId,
        },
      );

      final data = result as Map<String, dynamic>;
      _log.i('Role request + provisioning created for ${request.userId}');
      return RoleRequest.fromJson(data);
    } on PostgrestException catch (e, st) {
      if (_isMissingProvisioningFunction(e)) {
        _log.w(
          'Provisioning RPC missing; falling back for compatible flows. error: ${e.message}\nstackTrace: $st   ',
        );
        return _createRequestWithoutRpc(request);
      }

      _log.e('createRequest failed', error: e, stackTrace: st);
      rethrow;
    } on Object catch (e, st) {
      _log.e('createRequest failed', error: e, stackTrace: st);
      rethrow;
    }
  }

  bool _isMissingProvisioningFunction(PostgrestException e) {
    return e.code == 'PGRST202' && e.message.contains('create_role_request_with_provisioning');
  }

  Future<RoleRequest> _createRequestWithoutRpc(RoleRequest request) async {
    if (request.accountType == RoleRequestAccountType.newCustomer) {
      throw StateError(
        'Yeni müşteri kaydı için veritabanı migration eksik. '
        'Lütfen `supabase db push` çalıştırın.',
      );
    }

    final data = await _client
        .from('role_requests')
        .insert(request.toInsertJson())
        .select()
        .single();
    _log.i('Role request row created without RPC for ${request.userId}');

    final existingProfile = await _client
        .from('app_users')
        .select('id')
        .eq('id', request.userId)
        .maybeSingle();

    if (existingProfile == null) {
      await _client.from('app_users').insert({
        'id': request.userId,
        'role': request.requestedRole.value,
        'display_name': request.displayName,
        'phone': request.phone,
        'is_active': false,
        'musteri_id': request.musteriId,
      });
      _log.i(
        'Pending app_users profile created without RPC for ${request.userId}',
      );
    }

    return RoleRequest.fromJson(data);
  }

  @override
  Future<List<RoleRequest>> getPendingRequests() async {
    final data = await _client
        .from('role_requests')
        .select()
        .eq('status', 'beklemede')
        .order('created_at');

    return data.map(RoleRequest.fromJson).toList();
  }

  @override
  Future<void> approveRequest({
    required String requestId,
    required String reviewerId,
    String? musteriId,
  }) async {
    _log.i(
      'Approving request $requestId'
      '${musteriId != null ? ' (musteriId: $musteriId)' : ''}',
    );

    // Talebi getir
    final requestData = await _client.from('role_requests').select().eq('id', requestId).single();

    final request = RoleRequest.fromJson(requestData);

    // app_users'a kayıt oluştur
    final upsertData = <String, dynamic>{
      'id': request.userId,
      'role': request.requestedRole.value,
      'display_name': request.displayName,
      'phone': request.phone,
      'is_active': true,
    };
    final resolvedMusteriId = musteriId ?? request.musteriId;
    if (resolvedMusteriId != null) {
      upsertData['musteri_id'] = resolvedMusteriId;
    }
    await _client.from('app_users').upsert(upsertData);

    // Müşteri personeli ise musteri_personelleri tablosuna da ekle
    if (request.requestedRole == UserRole.musteriPersonel && resolvedMusteriId != null) {
      await _client.from('musteri_personelleri').insert({
        'musteri_id': resolvedMusteriId,
        'user_id': request.userId,
        'ad': request.displayName,
        'telefon': request.phone,
        'is_active': true,
      });
      _log.i('musteri_personelleri record created for ${request.userId}');
    }

    if (request.accountType == RoleRequestAccountType.newCustomer && resolvedMusteriId != null) {
      await _client.from('musteriler').update({'is_active': true}).eq('id', resolvedMusteriId);
      _log.i('Pending musteri activated for ${request.userId}');
    }

    // Talebi onayla
    await _client
        .from('role_requests')
        .update({
          'status': 'onaylandi',
          'reviewed_by': reviewerId,
          'reviewed_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', requestId);

    _log.i('Request approved and user profile created');
  }

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reviewerId,
    String? reason,
  }) async {
    _log.i('Rejecting request $requestId');

    await _client
        .from('role_requests')
        .update({
          'status': 'reddedildi',
          'reviewed_by': reviewerId,
          'reviewed_at': DateTime.now().toUtc().toIso8601String(),
          'reject_reason': reason,
        })
        .eq('id', requestId);
  }

  @override
  Stream<List<RoleRequest>> watchPendingRequests() {
    return _client
        .from('role_requests')
        .stream(primaryKey: ['id'])
        .eq('status', 'beklemede')
        .order('created_at')
        .map(
          (rows) => rows.map(RoleRequest.fromJson).toList(),
        );
  }
}
