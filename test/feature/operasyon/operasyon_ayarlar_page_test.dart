import 'package:backend_core/backend_core.dart';
import 'package:bursamotokurye/feature/operasyon/presentation/operasyon_ayarlar_page.dart';
import 'package:bursamotokurye/product/user_profile/user_profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widgets/test_app.dart';

const _operasyonProfile = AppUserProfile(
  id: 'op-1',
  role: UserRole.operasyon,
  displayName: 'Operasyon Test',
);

void main() {
  group('OperasyonAyarlarPage', () {
    testWidgets('renders account summary and secondary navigation items',
        (tester) async {
      await tester.pumpApp(
        const OperasyonAyarlarPage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => _operasyonProfile,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Hesap'), findsOneWidget);
      expect(find.text('Operasyon Test'), findsOneWidget);
      expect(find.text('Rol: operasyon'), findsOneWidget);
      expect(find.textContaining('Çıkış'), findsOneWidget);
      expect(find.text('Yönetim'), findsOneWidget);
      expect(find.text('Müşteri Kayıt'), findsWidgets);
      expect(find.text('Personel Kayıt'), findsWidgets);
      expect(find.text('Kurye Yönetimi'), findsWidgets);
      expect(find.text('Rol Onayları'), findsWidgets);

      await tester.dragUntilVisible(
        find.text('Kayıt ve Talepler'),
        find.byType(ListView).first,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kayıt ve Talepler'), findsOneWidget);
      expect(find.text('Geçmiş Siparişler'), findsWidgets);
      expect(find.text('Uğrama Talepleri'), findsWidgets);
    });

    testWidgets('keeps drawer hidden on mobile', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        const OperasyonAyarlarPage(),
        overrides: [
          currentUserProfileProvider.overrideWithBuild(
            (ref, notifier) => _operasyonProfile,
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byType(Drawer), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Ayarlar'), findsOneWidget);
    });
  });
}
