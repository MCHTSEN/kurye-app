import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/musteri_siparis/presentation/musteri_siparis_page.dart';
import 'package:bursamotokurye/product/musteri_personel/musteri_personel_providers.dart';
import 'package:bursamotokurye/product/siparis/siparis_providers.dart';
import 'package:bursamotokurye/product/ugrama/ugrama_providers.dart';
import 'package:bursamotokurye/product/user_profile/user_profile_providers.dart';
import 'package:bursamotokurye/product/widgets/typeahead_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../helpers/fakes/fake_musteri_personel_repository.dart';
import '../../helpers/fakes/fake_siparis_repository.dart';
import '../../helpers/fakes/fake_ugrama_repository.dart';
import '../../helpers/widgets/test_app.dart';

const _testUserId = 'test-user-id';
const _testMusteriId = 'test-musteri-id';

const _testProfile = AppUserProfile(
  id: _testUserId,
  role: UserRole.musteriPersonel,
  displayName: 'Test Kullanıcı',
  musteriId: _testMusteriId,
);

final _testUgramalar = [
  const Ugrama(
    id: 'ugrama-1',
    ugramaAdi: 'Merkez Ofis',
  ),
  const Ugrama(
    id: 'ugrama-2',
    ugramaAdi: 'Şube A',
  ),
  const Ugrama(
    id: 'ugrama-3',
    ugramaAdi: 'Şube B',
  ),
];

const _testPersonel = MusteriPersonel(
  id: 'personel-1',
  musteriId: _testMusteriId,
  ad: 'Test Kullanıcı',
  userId: _testUserId,
);

void main() {
  group('MusteriSiparisPage', () {
    late FakeSiparisRepository fakeSiparisRepo;
    late FakeUgramaRepository fakeUgramaRepo;
    late FakeMusteriUgramaRepository fakeMusteriUgramaRepo;
    late FakeMusteriPersonelRepository fakePersonelRepo;

    setUp(() async {
      fakeSiparisRepo = FakeSiparisRepository();
      fakeUgramaRepo = FakeUgramaRepository(seed: _testUgramalar);
      fakeMusteriUgramaRepo = FakeMusteriUgramaRepository()
        ..ugramaRepo = fakeUgramaRepo;
      // Assign all test uğramalar to the test müşteri
      for (final u in _testUgramalar) {
        await fakeMusteriUgramaRepo.assign(_testMusteriId, u.id);
      }
      fakePersonelRepo = FakeMusteriPersonelRepository(seed: [_testPersonel]);
    });

    Future<void> pumpPage(WidgetTester tester) async {
      // Force mobile breakpoint to avoid NavigationRail consuming space.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        const MusteriSiparisPage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => _testProfile,
          ),
          ugramaRepositoryProvider.overrideWithValue(fakeUgramaRepo),
          musteriUgramaRepositoryProvider.overrideWithValue(
            fakeMusteriUgramaRepo,
          ),
          siparisRepositoryProvider.overrideWithValue(fakeSiparisRepo),
          musteriPersonelRepositoryProvider.overrideWithValue(fakePersonelRepo),
        ],
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders all 5 form fields (4 dropdowns + 1 text)', (
      tester,
    ) async {
      await pumpPage(tester);

      // 4 dropdown fields
      expect(find.text('Çıkış *'), findsOneWidget);
      expect(find.text('Uğrama *'), findsOneWidget);
      expect(find.text('Uğrama1'), findsOneWidget);
      expect(find.text('Not'), findsOneWidget);

      // 1 text field
      expect(find.text('Not1'), findsOneWidget);

      // Submit button (AppPrimaryButton)
      expect(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
        findsOneWidget,
      );

      // Active orders section — may require scroll to see
      await tester.dragUntilVisible(
        find.textContaining('Aktif Siparişler'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      expect(find.textContaining('Aktif Siparişler'), findsOneWidget);
    });

    testWidgets('validation rejects empty required fields', (tester) async {
      await pumpPage(tester);

      // Scroll to the submit button first.
      await tester.dragUntilVisible(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );

      // Tap submit without selecting required dropdowns.
      await tester.tap(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
      );
      await tester.pumpAndSettle();

      // Should show snackbar validation error.
      expect(
        find.text('Lütfen zorunlu alanları doldurunuz'),
        findsOneWidget,
      );

      // No order created.
      expect(fakeSiparisRepo.store, isEmpty);
    });

    testWidgets('successful submit creates order with correct data', (
      tester,
    ) async {
      await pumpPage(tester);

      // Programmatically select Çıkış = ugrama-1 (Merkez Ofis).
      await tester.enterText(
        find.byKey(const Key('cikis_typeahead')),
        'Merkez Ofis',
      );
      await tester.pumpAndSettle();

      final ugramaField = tester.widget<TypeaheadField<String>>(
        find.byKey(const Key('ugrama_typeahead')),
      );
      ugramaField.onChanged('ugrama-2');
      await tester.pumpAndSettle();

      // Scroll to reveal Not1 and submit.
      await tester.dragUntilVisible(
        find.widgetWithText(TextFormField, 'Not1'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );

      // Enter Not1 text.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Not1'),
        'Acil gönderim',
      );

      // Scroll to submit button.
      await tester.dragUntilVisible(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );

      // Submit.
      await tester.tap(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
      );
      await tester.pumpAndSettle();

      // Order should be created in the fake repo.
      expect(fakeSiparisRepo.store.length, 1);

      final created = fakeSiparisRepo.store.values.first;
      expect(created.musteriId, _testMusteriId);
      expect(created.cikisId, 'ugrama-1');
      expect(created.ugramaId, 'ugrama-2');
      expect(created.not1, 'Acil gönderim');
      expect(created.personelId, 'personel-1');
      expect(created.olusturanId, _testUserId);
      expect(created.durum, SiparisDurum.kuryeBekliyor);
    });

    testWidgets(
      'unknown stop shows confirmation, creates new stop, and submits order',
      (tester) async {
        await pumpPage(tester);

        await tester.enterText(
          find.byKey(const Key('cikis_typeahead')),
          'Yeni Çıkış Noktası',
        );
        await tester.enterText(
          find.byKey(const Key('ugrama_typeahead')),
          'Şube A',
        );
        await tester.pump();

        await tester.dragUntilVisible(
          find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
          find.byType(ListView).first,
          const Offset(0, -200),
        );
        await tester.tap(find.widgetWithText(ShadButton, 'Sipariş Oluştur'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(find.text('Yeni Uğrama'), findsOneWidget);
        await tester.tap(find.widgetWithText(FilledButton, 'Evet'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));

        expect(fakeSiparisRepo.store.length, 1);
        expect(
          fakeUgramaRepo.store.values.any(
            (u) => u.ugramaAdi == 'Yeni Çıkış Noktası',
          ),
          isTrue,
        );
      },
    );

    testWidgets('allows same stop for cikis and ugrama', (tester) async {
      await pumpPage(tester);

      await tester.enterText(
        find.byKey(const Key('cikis_typeahead')),
        'Merkez Ofis',
      );
      await tester.pump();
      await tester.tap(find.text('Merkez Ofis').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('ugrama_typeahead')),
        'Merkez Ofis',
      );
      await tester.pump();
      await tester.tap(find.text('Merkez Ofis').last);
      await tester.pumpAndSettle();

      await tester.dragUntilVisible(
        find.widgetWithText(ShadButton, 'Sipariş Oluştur'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.tap(find.widgetWithText(ShadButton, 'Sipariş Oluştur'));
      await tester.pumpAndSettle();

      final created = fakeSiparisRepo.store.values.last;
      expect(created.cikisId, created.ugramaId);
      expect(created.cikisId, 'ugrama-1');
    });

    testWidgets('shows error when profile has no musteriId', (tester) async {
      const profileWithoutMusteri = AppUserProfile(
        id: _testUserId,
        role: UserRole.musteriPersonel,
        displayName: 'Test',
        // musteriId is null
      );

      await tester.pumpApp(
        const MusteriSiparisPage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => profileWithoutMusteri,
          ),
          ugramaRepositoryProvider.overrideWithValue(fakeUgramaRepo),
          musteriUgramaRepositoryProvider.overrideWithValue(
            fakeMusteriUgramaRepo,
          ),
          siparisRepositoryProvider.overrideWithValue(fakeSiparisRepo),
          musteriPersonelRepositoryProvider.overrideWithValue(fakePersonelRepo),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Müşteri bilgisi bulunamadı.'), findsOneWidget);
    });
  });
}
