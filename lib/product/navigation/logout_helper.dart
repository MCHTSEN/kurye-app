import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../feature/auth/application/auth_controller.dart';

/// Returns a [VoidCallback] that triggers sign-out via [AuthController].
/// Use this as the `onLogout` parameter for [ResponsiveScaffold].
VoidCallback logoutCallback(WidgetRef ref) {
  return () => ref.read(authControllerProvider.notifier).signOut();
}
