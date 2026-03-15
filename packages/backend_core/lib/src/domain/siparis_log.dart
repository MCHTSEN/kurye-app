import 'siparis.dart';

/// Sipariş durum değişiklik logu — `siparis_log` tablosu.
class SiparisLog {
  const SiparisLog({
    required this.id,
    required this.siparisId,
    required this.yeniDurum,
    this.eskiDurum,
    this.degistirenId,
    this.aciklama,
    this.createdAt,
  });

  factory SiparisLog.fromJson(Map<String, dynamic> json) {
    return SiparisLog(
      id: json['id'] as String,
      siparisId: json['siparis_id'] as String,
      eskiDurum: json['eski_durum'] != null
          ? SiparisDurum.fromValue(json['eski_durum'] as String)
          : null,
      yeniDurum: SiparisDurum.fromValue(json['yeni_durum'] as String),
      degistirenId: json['degistiren_id'] as String?,
      aciklama: json['aciklama'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String siparisId;
  final SiparisDurum? eskiDurum;
  final SiparisDurum yeniDurum;
  final String? degistirenId;
  final String? aciklama;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'siparis_id': siparisId,
        'eski_durum': eskiDurum?.value,
        'yeni_durum': yeniDurum.value,
        'degistiren_id': degistirenId,
        'aciklama': aciklama,
        'created_at': createdAt?.toIso8601String(),
      };
}
