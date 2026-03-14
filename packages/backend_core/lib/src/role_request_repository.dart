import 'domain/role_request.dart';

/// Rol talep sistemi kontratı.
abstract class RoleRequestRepository {
  /// Kullanıcının aktif (beklemede) talebini getirir.
  Future<RoleRequest?> getMyPendingRequest(String userId);

  /// Kullanıcının son talebini getirir (onaylı/reddedilmiş dahil).
  Future<RoleRequest?> getMyLatestRequest(String userId);

  /// Yeni rol talebi oluşturur.
  Future<RoleRequest> createRequest(RoleRequest request);

  /// Beklemedeki tüm talepleri getirir (operasyon için).
  Future<List<RoleRequest>> getPendingRequests();

  /// Talebi onayla → app_users'a kayıt oluşturur.
  /// [musteriId] müşteri_personel rolü için zorunlu — kullanıcıyı müşteriye bağlar.
  Future<void> approveRequest({
    required String requestId,
    required String reviewerId,
    String? musteriId,
  });

  /// Talebi reddet.
  Future<void> rejectRequest({
    required String requestId,
    required String reviewerId,
    String? reason,
  });

  /// Beklemedeki talepleri realtime dinle.
  Stream<List<RoleRequest>> watchPendingRequests();
}
