import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../product/navigation/navigation_providers.dart';
import 'router/app_router.dart';
import 'router/observers/route_observer_providers.dart';

class KuryemApp extends ConsumerWidget {
  const KuryemApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final reevaluateListenable = ref.watch(
      appRouteReevaluationProvider,
    );
    final navigatorObserversBuilder = ref.watch(
      appNavigatorObserversBuilderProvider,
    );

    return ShadApp.custom(
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        colorScheme: const ShadSlateColorScheme.light(),
        brightness: Brightness.light,
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadSlateColorScheme.dark(),
        brightness: Brightness.dark,
      ),
      appBuilder: (context) {
        return KeyboardDismissWrapper(
          child: MaterialApp.router(
            title: 'kuryem',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              return ShadToaster(
                child: child ?? const SizedBox.shrink(),
              );
            },
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
      },
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
