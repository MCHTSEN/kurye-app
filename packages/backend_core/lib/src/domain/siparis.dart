/// Sipariş durumu — `siparis_durum` DB enum.
enum SiparisDurum {
  kuryeBekliyor('kurye_bekliyor'),
  devamEdiyor('devam_ediyor'),
  tamamlandi('tamamlandi'),
  iptal('iptal');

  const SiparisDurum(this.value);

  /// Supabase/DB'deki string değeri.
  final String value;

  static SiparisDurum fromValue(String raw) {
    for (final durum in SiparisDurum.values) {
      if (durum.value == raw) return durum;
    }
    throw ArgumentError('Unknown SiparisDurum value: $raw');
  }
}

/// Sipariş domain modeli — `siparisler` tablosu.
class Siparis {
  const Siparis({
    required this.id,
    required this.musteriId,
    required this.cikisId,
    required this.ugramaId,
    this.personelId,
    this.kuryeId,
    this.ugrama1Id,
    this.notId,
    this.not1,
    this.durum = SiparisDurum.kuryeBekliyor,
    this.ucret,
    this.cikisSaat,
    this.ugramaSaat,
    this.ugrama1Saat,
    this.atanmaSaat,
    this.bitisSaat,
    this.olusturanId,
    this.createdAt,
    this.updatedAt,
  });

  factory Siparis.fromJson(Map<String, dynamic> json) {
    return Siparis(
      id: json['id'] as String,
      musteriId: json['musteri_id'] as String,
      personelId: json['personel_id'] as String?,
      kuryeId: json['kurye_id'] as String?,
      cikisId: json['cikis_id'] as String,
      ugramaId: json['ugrama_id'] as String,
      ugrama1Id: json['ugrama1_id'] as String?,
      // not_id: uğrama referansı — "Not" dropdown'undan seçilen uğrama kaydı.
      notId: json['not_id'] as String?,
      not1: json['not1'] as String?,
      durum: SiparisDurum.fromValue(json['durum'] as String),
      ucret: (json['ucret'] as num?)?.toDouble(),
      cikisSaat: json['cikis_saat'] != null
          ? DateTime.parse(json['cikis_saat'] as String)
          : null,
      ugramaSaat: json['ugrama_saat'] != null
          ? DateTime.parse(json['ugrama_saat'] as String)
          : null,
      ugrama1Saat: json['ugrama1_saat'] != null
          ? DateTime.parse(json['ugrama1_saat'] as String)
          : null,
      atanmaSaat: json['atanma_saat'] != null
          ? DateTime.parse(json['atanma_saat'] as String)
          : null,
      bitisSaat: json['bitis_saat'] != null
          ? DateTime.parse(json['bitis_saat'] as String)
          : null,
      olusturanId: json['olusturan_id'] as String?,
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
  final String? personelId;
  final String? kuryeId;
  final String cikisId;
  final String ugramaId;
  final String? ugrama1Id;

  /// "Not" dropdown — uğrama referansı.
  final String? notId;
  final String? not1;
  final SiparisDurum durum;
  final double? ucret;
  final DateTime? cikisSaat;
  final DateTime? ugramaSaat;
  final DateTime? ugrama1Saat;
  final DateTime? atanmaSaat;
  final DateTime? bitisSaat;
  final String? olusturanId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'musteri_id': musteriId,
        'personel_id': personelId,
        'kurye_id': kuryeId,
        'cikis_id': cikisId,
        'ugrama_id': ugramaId,
        'ugrama1_id': ugrama1Id,
        'not_id': notId,
        'not1': not1,
        'durum': durum.value,
        'ucret': ucret,
        'cikis_saat': cikisSaat?.toIso8601String(),
        'ugrama_saat': ugramaSaat?.toIso8601String(),
        'ugrama1_saat': ugrama1Saat?.toIso8601String(),
        'atanma_saat': atanmaSaat?.toIso8601String(),
        'bitis_saat': bitisSaat?.toIso8601String(),
        'olusturan_id': olusturanId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
