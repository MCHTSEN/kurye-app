import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/core/utils/app_time.dart';

void main() {
  group('AppTime', () {
    test('UTC 08:00 → TR 11:00', () {
      final utc = DateTime.utc(2026, 5, 20, 8);
      expect(AppTime.hm(utc), '11:00');
    });

    test('UTC 23:30 → TR ertesi gün 02:30', () {
      final utc = DateTime.utc(2026, 5, 20, 23, 30);
      expect(AppTime.hm(utc), '02:30');
      expect(AppTime.dmy(utc), '21.05.2026');
    });

    test('local DateTime de UTC üzerinden hesaplanır', () {
      final local = DateTime(2026, 5, 20, 12);
      final expected = AppTime.toTr(local.toUtc());
      expect(AppTime.hm(local), '${expected.hour.toString().padLeft(2, '0')}:00');
    });

    test('null → placeholder', () {
      expect(AppTime.hm(null), '--:--');
      expect(AppTime.dmy(null), '-');
      expect(AppTime.dmyHm(null), '-');
    });

    test('dmyHm formatı doğru', () {
      final utc = DateTime.utc(2026, 5, 20, 6, 5);
      expect(AppTime.dmyHm(utc), '20.05.2026 09:05');
    });

    test('tek haneli gün/ay/saat sıfırla doldurulur', () {
      final utc = DateTime.utc(2026, 1, 3, 0, 5);
      expect(AppTime.dmy(utc), '03.01.2026');
      expect(AppTime.hm(utc), '03:05');
    });
  });
}
