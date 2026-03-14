import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../product/navigation/navigation_providers.dart';
import 'router/app_router.dart';
import 'router/observers/route_observer_providers.dart';

class BursamotoKuryeApp extends ConsumerWidget {
  const BursamotoKuryeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final reevaluateListenable = ref.watch(
      appRouteReevaluationProvider,
    );
    final navigatorObserversBuilder = ref.watch(
      appNavigatorObserversBuilderProvider,
    );

    return KeyboardDismissWrapper(
      child: MaterialApp.router(
        title: 'bursamotokurye',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router.config(
          navigatorObservers: navigatorObserversBuilder,
          reevaluateListenable: reevaluateListenable,
          deepLinkBuilder: (deepLink) {
            if (deepLink.path.startsWith('/home') ||
                deepLink.path.startsWith('/example-feed') ||
                deepLink.path.startsWith('/profile') ||
                deepLink.path.startsWith('/buy-credit') ||
                deepLink.path.startsWith('/role-selection') ||
                deepLink.path.startsWith('/musteri') ||
                deepLink.path.startsWith('/operasyon') ||
                deepLink.path.startsWith('/kurye')) {
              return deepLink;
            }
            return DeepLink.defaultPath;
          },
        ),
      ),
    );
  }
}

class KeyboardDismissWrapper extends StatelessWidget {
  const KeyboardDismissWrapper({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: child,
    );
  }
}
