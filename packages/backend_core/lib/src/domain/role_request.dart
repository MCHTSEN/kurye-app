import 'user_role.dart';

enum RoleRequestStatus {
  beklemede('beklemede'),
  onaylandi('onaylandi'),
  reddedildi('reddedildi');

  const RoleRequestStatus(this.value);
  final String value;

  static RoleRequestStatus fromValue(String raw) {
    for (final s in RoleRequestStatus.values) {
      if (s.value == raw) return s;
    }
    throw ArgumentError('Unknown RoleRequestStatus: $raw');
  }
}

class RoleRequest {
  const RoleRequest({
    required this.id,
    required this.userId,
    required this.requestedRole,
    required this.status,
    required this.displayName,
    this.phone,
    this.note,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectReason,
    this.createdAt,
  });

  factory RoleRequest.fromJson(Map<String, dynamic> json) {
    return RoleRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      requestedRole: UserRole.fromValue(json['requested_role'] as String),
      status: RoleRequestStatus.fromValue(json['status'] as String),
      displayName: json['display_name'] as String,
      phone: json['phone'] as String?,
      note: json['note'] as String?,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectReason: json['reject_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String userId;
  final UserRole requestedRole;
  final RoleRequestStatus status;
  final String displayName;
  final String? phone;
  final String? note;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectReason;
  final DateTime? createdAt;

  Map<String, dynamic> toInsertJson() => {
    'user_id': userId,
    'requested_role': requestedRole.value,
    'display_name': displayName,
    'phone': phone,
    'note': note,
  };
}
