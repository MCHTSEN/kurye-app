import 'dart:ui';

import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../application/auth_controller.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final bool _isRegisterMode = false;
  bool _showPassword = false;

  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset('assets/sounds/kurye.mp4');
    await _videoController!.initialize();
    _videoController!.setLooping(true);
    _videoController!.setVolume(0);
    _videoController!.play();
    setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final authError = ref.watch(
      authControllerProvider.select((state) => state.error),
    );
    final authController = ref.read(authControllerProvider.notifier);
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedOpacity(
            opacity: (_videoController != null && _videoController!.value.isInitialized)
                ? 1.0
                : 0.0,
            duration: const Duration(milliseconds: 500),
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController?.value.size.width ?? 1,
                height: _videoController?.value.size.height ?? 1,
                child: _videoController != null
                    ? VideoPlayer(_videoController!)
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                

                    // Auth Card
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.background.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.border.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isRegisterMode ? l10n.authRegister : l10n.authTitle,
                                style: theme.textTheme.h3.copyWith(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              // Register: name field
                              if (_isRegisterMode) ...[
                                Text(l10n.authName, style: theme.textTheme.small),
                                const SizedBox(height: 6),
                                ShadInput(
                                  controller: _nameController,
                                  placeholder: Text(l10n.authName),
                                  enabled: !isLoading,
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              // Email
                              Text(l10n.authEmail, style: theme.textTheme.small),
                              const SizedBox(height: 6),
                              ShadInput(
                                controller: _emailController,
                                placeholder: Text(l10n.authEmail),
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                leading: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.email_outlined, size: 16),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Password
                              Text(l10n.authPassword, style: theme.textTheme.small),
                              const SizedBox(height: 6),
                              ShadInput(
                                controller: _passwordController,
                                placeholder: Text(l10n.authPassword),
                                obscureText: !_showPassword,
                                enabled: !isLoading,
                                leading: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(Icons.lock_outline, size: 16),
                                ),
                                trailing: ShadButton.ghost(
                                  width: 24,
                                  height: 24,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(
                                      () => _showPassword = !_showPassword,
                                    );
                                  },
                                  leading: Icon(
                                    _showPassword ? Icons.visibility_off : Icons.visibility,
                                    size: 16,
                                  ),
                                ),
                                onSubmitted: (_) async => _handleEmailSignIn(authController),
                              ),

                              // Error
                              if (authError != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                _buildErrorBanner(authError, theme),
                              ],

                              const SizedBox(height: AppSpacing.lg),

                              // Submit
                              ShadButton(
                                enabled: !isLoading,
                                onPressed: isLoading
                                    ? null
                                    : () => _handleEmailSignIn(authController),
                                leading: isLoading
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : null,
                                size: ShadButtonSize.lg,
                                child: Text(
                                  _isRegisterMode ? l10n.authRegister : l10n.authSignInWithEmail,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (kDebugMode) ...[
                      const SizedBox(height: AppSpacing.xl),
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.background.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.border.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Hızlı Giriş (Kısayollar)',
                                  style: theme.textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _QuickLoginButtons(
                                  emailController: _emailController,
                                  passwordController: _passwordController,
                                  onLogin: () => _handleEmailSignIn(authController),
                                  isLoading: isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(Object error, ShadThemeData theme) {
    final isConfirmation = error is EmailConfirmationRequiredException;
    return ShadAlert(
      icon: const Icon(LucideIcons.circleAlert),
      title: Text(isConfirmation ? 'E-posta Onayı' : 'Hata'),
      description: Text(_friendlyError(error)),
    );
  }

  Future<void> _handleEmailSignIn(AuthController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    if (_isRegisterMode) {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      await controller.register(
        email: email,
        password: password,
        name: name,
      );
    } else {
      await controller.signInWithEmail(email: email, password: password);
    }
  }

  String _friendlyError(Object error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('email not confirmed')) {
      return 'E-posta adresiniz henüz onaylanmamış. Gelen kutunuzu kontrol edin.';
    }
    if (msg.contains('user not found')) {
      return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
    }
    if (msg.contains('email already registered') || msg.contains('user already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';
    }
    if (msg.contains('network') || msg.contains('socket') || msg.contains('connection')) {
      return 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    }
    if (msg.contains('weak password') || msg.contains('password')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
  }
}

// ---------------------------------------------------------------------------
// Quick-login buttons (debug only)
// ---------------------------------------------------------------------------

class _QuickLoginButtons extends StatelessWidget {
  const _QuickLoginButtons({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
    required this.isLoading,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;
  final bool isLoading;

  static const _accounts =
      <
        ({
          String label,
          IconData icon,
          String email,
        })
      >[
        (
          label: 'Operasyon',
          icon: Icons.admin_panel_settings,
          email: 'ops@test.com',
        ),
        (
          label: 'Müşteri',
          icon: Icons.storefront,
          email: 'musteri@test.com',
        ),
        (
          label: 'Kurye',
          icon: Icons.two_wheeler,
          email: 'kurye@test.com',
        ),
      ];

  static const _password = 'Test1234!';

  void _fillAndLogin(String email) {
    emailController.text = email;
    passwordController.text = _password;
    onLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final account in _accounts)
          ShadButton.outline(
            enabled: !isLoading,
            onPressed: isLoading ? null : () => _fillAndLogin(account.email),
            leading: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(account.icon, size: 16),
            ),
            size: ShadButtonSize.sm,
            child: Text(account.label),
          ),
      ],
    );
  }
}
