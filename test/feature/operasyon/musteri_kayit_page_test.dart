import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/operasyon/presentation/musteri_kayit_page.dart';
import 'package:bursamotokurye/product/musteri/musteri_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_musteri_repository.dart';
import '../../helpers/widgets/test_app.dart';

void main() {
  group('MusteriKayitPage', () {
    testWidgets('renders form fields and empty list', (tester) async {
      final fakeRepo = FakeMusteriRepository();

      await tester.pumpApp(
        const MusteriKayitPage(),
        overrides: [
          musteriRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Form section
      expect(find.text('Yeni Müşteri'), findsOneWidget);
      expect(find.text('Firma Kısa Ad *'), findsOneWidget);
      expect(find.text('Firma Tam Ad'), findsOneWidget);
      expect(find.text('Telefon'), findsOneWidget);
      expect(find.text('Adres'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Vergi No'), findsOneWidget);
      expect(find.text('Kaydet'), findsOneWidget);

      // Empty list
      expect(find.text('Müşteriler (0)'), findsOneWidget);
      expect(find.text('Henüz müşteri yok.'), findsOneWidget);
    });

    testWidgets('validates required field before submit', (tester) async {
      final fakeRepo = FakeMusteriRepository();

      await tester.pumpApp(
        const MusteriKayitPage(),
        overrides: [
          musteriRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Tap save without filling required field
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      expect(find.text('Zorunlu alan'), findsOneWidget);
      // No record created
      expect(fakeRepo.store, isEmpty);
    });

    testWidgets('creates a record and shows it in list', (tester) async {
      final fakeRepo = FakeMusteriRepository();

      await tester.pumpApp(
        const MusteriKayitPage(),
        overrides: [
          musteriRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      await tester.pumpAndSettle();

      // Fill required field
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Firma Kısa Ad *'),
        'Test Firma',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefon'),
        '555-1234',
      );

      // Submit
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();

      // Record should be in store
      expect(fakeRepo.store.length, 1);
      expect(fakeRepo.store.values.first.firmaKisaAd, 'Test Firma');

      // List should update
      expect(find.text('Müşteriler (1)'), findsOneWidget);
      expect(find.text('Test Firma'), findsOneWidget);
    });

    testWidgets('tapping list item populates form for editing', (tester) async {
      final fakeRepo = FakeMusteriRepository();
      // Pre-populate a record
      await fakeRepo.create(
        const Musteri(
          id: '',
          firmaKisaAd: 'Acme',
          telefon: '555-0000',
        ),
      );

      await tester.pumpApp(
        const MusteriKayitPage(),
        overrides: [
          musteriRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      await tester.pumpAndSettle();

      // List should show the record
      expect(find.text('Acme'), findsOneWidget);

      // Scroll down to make the list item visible, then tap
      await tester.dragUntilVisible(
        find.text('Acme'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acme'));
      await tester.pumpAndSettle();

      // Form should switch to edit mode
      expect(find.text('Müşteri Düzenle'), findsOneWidget);
      expect(find.text('Güncelle'), findsOneWidget);
      expect(find.text('İptal'), findsOneWidget);

      // Field should be populated
      final firmaField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Firma Kısa Ad *'),
      );
      expect(firmaField.controller?.text, 'Acme');
    });
  });
}
