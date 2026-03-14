/// Müşteri personeli domain modeli — `musteri_personelleri` tablosu.
class MusteriPersonel {
  const MusteriPersonel({
    required this.id,
    required this.musteriId,
    required this.ad,
    this.userId,
    this.telefon,
    this.email,
    this.isActive = true,
    this.createdAt,
  });

  factory MusteriPersonel.fromJson(Map<String, dynamic> json) {
    return MusteriPersonel(
      id: json['id'] as String,
      musteriId: json['musteri_id'] as String,
      userId: json['user_id'] as String?,
      ad: json['ad'] as String,
      telefon: json['telefon'] as String?,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String musteriId;
  final String? userId;
  final String ad;
  final String? telefon;
  final String? email;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteri_id': musteriId,
        'user_id': userId,
        'ad': ad,
        'telefon': telefon,
        'email': email,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };
}
