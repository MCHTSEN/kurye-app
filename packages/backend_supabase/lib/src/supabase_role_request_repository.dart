import 'package:backend_core/backend_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRoleRequestRepository implements RoleRequestRepository {
  SupabaseRoleRequestRepository({required SupabaseClient client})
      : _client = client;

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

    final data = await _client
        .from('role_requests')
        .insert(request.toInsertJson())
        .select()
        .single();

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
  }) async {
    _log.i('Approving request $requestId');

    // Talebi getir
    final requestData = await _client
        .from('role_requests')
        .select()
        .eq('id', requestId)
        .single();

    final request = RoleRequest.fromJson(requestData);

    // app_users'a kayıt oluştur
    await _client.from('app_users').upsert({
      'id': request.userId,
      'role': request.requestedRole.value,
      'display_name': request.displayName,
      'phone': request.phone,
      'is_active': true,
    });

    // Talebi onayla
    await _client.from('role_requests').update({
      'status': 'onaylandi',
      'reviewed_by': reviewerId,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', requestId);

    _log.i('Request approved and user profile created');
  }

  @override
  Future<void> rejectRequest({
    required String requestId,
    required String reviewerId,
    String? reason,
  }) async {
    _log.i('Rejecting request $requestId');

    await _client.from('role_requests').update({
      'status': 'reddedildi',
      'reviewed_by': reviewerId,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'reject_reason': reason,
    }).eq('id', requestId);
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
