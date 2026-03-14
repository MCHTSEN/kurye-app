/// Kurye domain modeli — `kuryeler` tablosu.
class Kurye {
  const Kurye({
    required this.id,
    required this.ad,
    this.userId,
    this.telefon,
    this.plaka,
    this.isActive = true,
    this.isOnline = false,
    this.createdAt,
    this.updatedAt,
  });

  factory Kurye.fromJson(Map<String, dynamic> json) {
    return Kurye(
      id: json['id'] as String,
      userId: json['user_id'] as String?,
      ad: json['ad'] as String,
      telefon: json['telefon'] as String?,
      plaka: json['plaka'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isOnline: json['is_online'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String? userId;
  final String ad;
  final String? telefon;
  final String? plaka;
  final bool isActive;
  final bool isOnline;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'ad': ad,
        'telefon': telefon,
        'plaka': plaka,
        'is_active': isActive,
        'is_online': isOnline,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
