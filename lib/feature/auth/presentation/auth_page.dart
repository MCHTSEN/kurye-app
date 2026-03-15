import 'package:backend_core/backend_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../l10n/app_localizations.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/environment/environment_provider.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
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

    return Scaffold(
      appBar: AppBar(title: Text(l10n.authTitle)),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          AppSectionCard(
            title: l10n.authBackendSelection,
            child: Text(
              l10n.authBackendLabel(environment.backendProvider.name),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppSectionCard(
            title: l10n.authTitle,
            child: Text(l10n.authDescription),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Social login buttons (only if backend supports them)
          if (supportedSocial.contains(SocialLoginMethod.google))
            _GoogleSignInButton(
              isLoading: isLoading,
              onPressed: () => _handleGoogleSignIn(authController),
              label: l10n.authSignInWithGoogle,
            ),

          if (supportedSocial.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _OrDivider(label: l10n.authOrDivider),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Register mode: name field
          if (_isRegisterMode) ...[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.authName),
              textInputAction: TextInputAction.next,
              enabled: !isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Email & Password
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.authEmail),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: l10n.authPassword),
            obscureText: true,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            onSubmitted: (_) async => _handleEmailSignIn(authController),
          ),

          if (authError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            if (authError is EmailConfirmationRequiredException)
              _MessageBanner(
                icon: Icons.mark_email_read,
                message: authError.toString(),
                color: Colors.green,
              )
            else
              _MessageBanner(
                icon: Icons.error_outline,
                message: _friendlyError(authError),
                color: Colors.red,
              ),
          ],

          const SizedBox(height: AppSpacing.lg),

          AppPrimaryButton(
            label: _isRegisterMode
                ? l10n.authRegister
                : l10n.authSignInWithEmail,
            isLoading: isLoading,
            onPressed: () => _handleEmailSignIn(authController),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Toggle register/login
          TextButton(
            onPressed: isLoading
                ? null
                : () => setState(() => _isRegisterMode = !_isRegisterMode),
            child: Text(
              _isRegisterMode
                  ? l10n.authSignInWithEmail
                  : l10n.authRegister,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          OutlinedButton(
            onPressed: isLoading ? null : authController.signInAnonymously,
            child: Text(l10n.authSignInAnonymous),
          ),

          // Quick-login buttons for dev/debug mode only.
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.xl),
            const _OrDivider(label: 'Hızlı Giriş (Dev)'),
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
    );
  }

  Future<void> _handleEmailSignIn(AuthController controller) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      return;
    }

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
      return 'E-posta adresiniz henüz onaylanmamış. '
          'Gelen kutunuzu kontrol edin.';
    }
    if (msg.contains('user not found')) {
      return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
    }
    if (msg.contains('email already registered') ||
        msg.contains('user already registered')) {
      return 'Bu e-posta adresi zaten kayıtlı. Giriş yapmayı deneyin.';
    }
    if (msg.contains('too many requests') ||
        msg.contains('rate limit')) {
      return 'Çok fazla deneme yaptınız. Lütfen biraz bekleyin.';
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Bağlantı hatası. İnternet bağlantınızı kontrol edin.';
    }
    if (msg.contains('weak password') ||
        msg.contains('password')) {
      return 'Şifre en az 6 karakter olmalıdır.';
    }
    return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
  }

  Future<void> _handleGoogleSignIn(AuthController controller) async {
    // TODO(dev): integrate google_sign_in package to get idToken
    // For now, this is a placeholder that shows the button
    // when the backend supports it.
    // final googleUser = await GoogleSignIn().signIn();
    // final auth = await googleUser?.authentication;
    // if (auth?.idToken != null) {
    //   await controller.signInWithGoogle(idToken: auth!.idToken!);
    // }
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const Text(
          'G',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: theme.colorScheme.outlineVariant)),
      ],
    );
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

  static const _accounts = <({String label, IconData icon, Color color, String email})>[
    (
      label: 'Operasyon',
      icon: Icons.admin_panel_settings,
      color: Colors.indigo,
      email: 'ops@test.com',
    ),
    (
      label: 'Müşteri Personel',
      icon: Icons.storefront,
      color: Colors.teal,
      email: 'musteri@test.com',
    ),
    (
      label: 'Kurye',
      icon: Icons.two_wheeler,
      color: Colors.orange,
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
          FilledButton.tonalIcon(
            onPressed: isLoading ? null : () => _fillAndLogin(account.email),
            icon: Icon(account.icon, size: 18),
            label: Text(account.label),
            style: FilledButton.styleFrom(
              backgroundColor: account.color.withValues(alpha: 0.12),
              foregroundColor: account.color,
            ),
          ),
      ],
    );
  }
}
