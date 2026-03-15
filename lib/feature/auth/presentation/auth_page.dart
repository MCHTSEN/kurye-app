import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/environment/environment_provider.dart';
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
  bool _isRegisterMode = false;
  bool _showPassword = false;

  @override
  void dispose() {
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
    final environment = ref.watch(appEnvironmentProvider);
    final supportedSocial = ref.watch(supportedSocialLoginsProvider);
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / Title
                Icon(
                  Icons.two_wheeler,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Moto Kurye',
                  style: theme.textTheme.h2,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.authDescription,
                  style: theme.textTheme.muted,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Auth Card
                ShadCard(
                  title: Text(
                    _isRegisterMode ? l10n.authRegister : l10n.authTitle,
                    style: theme.textTheme.h4,
                  ),
                  description: Text(
                    'Backend: ${environment.backendProvider.name}',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Social login
                        if (supportedSocial
                            .contains(SocialLoginMethod.google)) ...[
                          ShadButton.outline(
                            onPressed:
                                isLoading
                                    ? null
                                    : () => _handleGoogleSignIn(
                                      authController,
                                    ),
                            leading: const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            size: ShadButtonSize.lg,
                            child: Text(l10n.authSignInWithGoogle),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildDivider(l10n.authOrDivider, theme),
                          const SizedBox(height: AppSpacing.lg),
                        ],

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
                              _showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 16,
                            ),
                          ),
                          onSubmitted: (_) async =>
                              _handleEmailSignIn(authController),
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
                            _isRegisterMode
                                ? l10n.authRegister
                                : l10n.authSignInWithEmail,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Toggle register/login
                ShadButton.link(
                  onPressed: isLoading
                      ? null
                      : () => setState(
                            () => _isRegisterMode = !_isRegisterMode,
                          ),
                  child: Text(
                    _isRegisterMode
                        ? l10n.authSignInWithEmail
                        : l10n.authRegister,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                ShadButton.outline(
                  onPressed:
                      isLoading ? null : authController.signInAnonymously,
                  size: ShadButtonSize.sm,
                  child: Text(l10n.authSignInAnonymous),
                ),

                // Quick-login (debug only)
                if (kDebugMode) ...[
                  const SizedBox(height: AppSpacing.xl),
                  _buildDivider('Hızlı Giriş (Dev)', theme),
                  const SizedBox(height: AppSpacing.md),
                  _QuickLoginButtons(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onLogin: () => _handleEmailSignIn(authController),
                    isLoading: isLoading,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(String label, ShadThemeData theme) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(label, style: theme.textTheme.muted),
        ),
        const Expanded(child: Divider()),
      ],
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
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('email not confirmed')) {
      return 'E-posta adresiniz henüz onaylanmamış. Gelen kutunuzu kontrol edin.';
    }
    if (msg.contains('user not found')) {
      return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (msg.contains('too many requests') || msg.contains('rate limit')) {
      return 'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    }
    if (msg.contains('weak password') || msg.contains('password')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
  }

  Future<void> _handleGoogleSignIn(AuthController controller) async {
    // TODO(dev): integrate google_sign_in package
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

  static const _accounts = <({
    String label,
    IconData icon,
    String email,
  })>[
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
