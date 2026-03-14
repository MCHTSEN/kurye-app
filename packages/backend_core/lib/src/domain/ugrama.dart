/// Uğrama (güzergah noktası) domain modeli — `ugramalar` tablosu.
/// Not: `lokasyon` (Geography) alanı kasıtlı olarak dahil edilmedi.
class Ugrama {
  const Ugrama({
    required this.id,
    required this.musteriId,
    required this.ugramaAdi,
    this.adres,
    this.isActive = true,
    this.createdAt,
  });

  factory Ugrama.fromJson(Map<String, dynamic> json) {
    return Ugrama(
      id: json['id'] as String,
      musteriId: json['musteri_id'] as String,
      ugramaAdi: json['ugrama_adi'] as String,
      adres: json['adres'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String musteriId;
  final String ugramaAdi;
  final String? adres;
  final bool isActive;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteri_id': musteriId,
        'ugrama_adi': ugramaAdi,
        'adres': adres,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
      };
}
