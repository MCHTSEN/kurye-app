/// Uğrama talep durumu — `ugrama_talep_durum` DB enum.
enum UgramaTalepDurum {
  beklemede('beklemede'),
  onaylandi('onaylandi'),
  reddedildi('reddedildi');

  const UgramaTalepDurum(this.value);

  final String value;

  static UgramaTalepDurum fromValue(String raw) {
    for (final durum in UgramaTalepDurum.values) {
      if (durum.value == raw) return durum;
    }
    throw ArgumentError('Unknown UgramaTalepDurum value: $raw');
  }
}

/// Uğrama talebi domain modeli — `ugrama_talepleri` tablosu.
/// Müşteri personeli yeni uğrama talebi gönderir,
/// operasyon kabul veya reddeder.
class UgramaTalebi {
  const UgramaTalebi({
    required this.id,
    required this.musteriId,
    required this.talepEdenId,
    required this.ugramaAdi,
    this.adres,
    this.durum = UgramaTalepDurum.beklemede,
    this.redNotu,
    this.islemYapanId,
    this.onaylananUgramaId,
    this.createdAt,
    this.updatedAt,
  });

  factory UgramaTalebi.fromJson(Map<String, dynamic> json) {
    return UgramaTalebi(
      id: json['id'] as String,
      musteriId: json['musteri_id'] as String,
      talepEdenId: json['talep_eden_id'] as String,
      ugramaAdi: json['ugrama_adi'] as String,
      adres: json['adres'] as String?,
      durum: UgramaTalepDurum.fromValue(json['durum'] as String),
      redNotu: json['red_notu'] as String?,
      islemYapanId: json['islem_yapan_id'] as String?,
      onaylananUgramaId: json['onaylanan_ugrama_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String musteriId;
  final String talepEdenId;
  final String ugramaAdi;
  final String? adres;
  final UgramaTalepDurum durum;
  final String? redNotu;
  final String? islemYapanId;
  final String? onaylananUgramaId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteri_id': musteriId,
        'talep_eden_id': talepEdenId,
        'ugrama_adi': ugramaAdi,
        'adres': adres,
        'durum': durum.value,
        'red_notu': redNotu,
        'islem_yapan_id': islemYapanId,
        'onaylanan_ugrama_id': onaylananUgramaId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
