import 'package:backend_core/backend_core.dart';
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
    final theme = Theme.of(context);
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
            Text(
              authError.toString(),
              style: TextStyle(color: theme.colorScheme.error),
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
