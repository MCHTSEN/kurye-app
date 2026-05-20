/// Türkiye saat dilimine (UTC+3) sabit dönüşüm yapan formatter.
///
/// Veritabanı `TIMESTAMPTZ` UTC saklıyor; cihazın yerel saatine güvenmek
/// yerine sabit +3 offset uyguluyoruz. Türkiye 2016'dan beri sürekli
/// UTC+3'te, DST yok.
class AppTime {
  AppTime._();

  static const Duration _trOffset = Duration(hours: 3);

  /// UTC veya local DateTime'ı TR (UTC+3) DateTime'a çevirir.
  static DateTime toTr(DateTime dt) => dt.toUtc().add(_trOffset);

  /// `HH:mm` formatı. Null ise `--:--`.
  static String hm(DateTime? dt) {
    if (dt == null) return '--:--';
    final tr = toTr(dt);
    return '${_pad(tr.hour)}:${_pad(tr.minute)}';
  }

  /// `dd.MM.yyyy` formatı. Null ise `-`.
  static String dmy(DateTime? dt) {
    if (dt == null) return '-';
    final tr = toTr(dt);
    return '${_pad(tr.day)}.${_pad(tr.month)}.${tr.year}';
  }

  /// `dd.MM.yyyy HH:mm` formatı. Null ise `-`.
  static String dmyHm(DateTime? dt) {
    if (dt == null) return '-';
    return '${dmy(dt)} ${hm(dt)}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
