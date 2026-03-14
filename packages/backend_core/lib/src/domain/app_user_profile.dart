import 'user_role.dart';

/// Supabase `app_users` tablosundan gelen kullanıcı profili.
class AppUserProfile {
  const AppUserProfile({
    required this.id,
    required this.role,
    required this.displayName,
    this.phone,
    this.isActive = true,
    this.musteriId,
  });

  factory AppUserProfile.fromJson(Map<String, dynamic> json) {
    return AppUserProfile(
      id: json['id'] as String,
      role: UserRole.fromValue(json['role'] as String),
      displayName: json['display_name'] as String,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      musteriId: json['musteri_id'] as String?,
    );
  }

  final String id;
  final UserRole role;
  final String displayName;
  final String? phone;
  final bool isActive;
  final String? musteriId;

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.value,
    'display_name': displayName,
    'phone': phone,
    'is_active': isActive,
    'musteri_id': musteriId,
  };
}
