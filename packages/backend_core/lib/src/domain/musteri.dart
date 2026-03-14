/// Müşteri (firma) domain modeli — `musteriler` tablosu.
class Musteri {
  const Musteri({
    required this.id,
    required this.firmaKisaAd,
    this.firmaTamAd,
    this.telefon,
    this.adres,
    this.email,
    this.vergiNo,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Musteri.fromJson(Map<String, dynamic> json) {
    return Musteri(
      id: json['id'] as String,
      firmaKisaAd: json['firma_kisa_ad'] as String,
      firmaTamAd: json['firma_tam_ad'] as String?,
      telefon: json['telefon'] as String?,
      adres: json['adres'] as String?,
      email: json['email'] as String?,
      vergiNo: json['vergi_no'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String firmaKisaAd;
  final String? firmaTamAd;
  final String? telefon;
  final String? adres;
  final String? email;
  final String? vergiNo;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'firma_kisa_ad': firmaKisaAd,
        'firma_tam_ad': firmaTamAd,
        'telefon': telefon,
        'adres': adres,
        'email': email,
        'vergi_no': vergiNo,
        'is_active': isActive,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
