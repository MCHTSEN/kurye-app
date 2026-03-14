import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../auth/application/auth_controller.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  UserRole? _selectedRole;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestAsync = ref.watch(myRoleRequestProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Durumu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request == null) {
            return _buildRoleSelectionForm(theme);
          }
          return _buildRequestStatus(theme, request);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }

  Widget _buildRequestStatus(ThemeData theme, RoleRequest request) {
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        const SizedBox(height: AppSpacing.xl),
        if (request.status == RoleRequestStatus.beklemede) ...[
          Icon(Icons.hourglass_top, size: 80, color: Colors.orange.shade400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Talebiniz İnceleniyor',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Rol talebiniz operasyon ekibine iletildi.\n'
            'Onaylandığında otomatik olarak yönlendirileceksiniz.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoCard(
            label: 'Talep Edilen Rol',
            value: _roleDisplayName(request.requestedRole),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoCard(label: 'Ad', value: request.displayName),
          if (request.createdAt != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _InfoCard(
              label: 'Talep Tarihi',
              value: _formatDate(request.createdAt!),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () =>
                ref.read(myRoleRequestProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Durumu Kontrol Et'),
          ),
        ] else if (request.status == RoleRequestStatus.onaylandi) ...[
          Icon(Icons.check_circle, size: 80, color: Colors.green.shade400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Talebiniz Onaylandı!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Yönlendiriliyorsunuz...',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Devam Et',
            onPressed: () {
              ref.invalidate(currentUserProfileProvider);
              ref.read(myRoleRequestProvider.notifier).refresh();
            },
          ),
        ] else if (request.status == RoleRequestStatus.reddedildi) ...[
          Icon(Icons.cancel, size: 80, color: Colors.red.shade400),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Talebiniz Reddedildi',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          if (request.rejectReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Sebep: ${request.rejectReason}',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppPrimaryButton(
            label: 'Tekrar Talep Oluştur',
            onPressed: () {
              // Son talebi temizle, form göster
              ref.invalidate(myRoleRequestProvider);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoleSelectionForm(ThemeData theme) {
    return ListView(
      padding: ProjectPadding.all.normal,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Hoş Geldiniz!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Sistemi kullanmak için rolünüzü seçin.\n'
          'Talebiniz operasyon ekibi tarafından incelenecektir.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Rol seçimi
        _RoleOptionCard(
          icon: Icons.business,
          title: 'Müşteri Personeli',
          description: 'Firma adına sipariş oluşturma ve takip',
          isSelected: _selectedRole == UserRole.musteriPersonel,
          onTap: () => setState(() => _selectedRole = UserRole.musteriPersonel),
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleOptionCard(
          icon: Icons.delivery_dining,
          title: 'Kurye',
          description: 'Sipariş teslim ve konum paylaşımı',
          isSelected: _selectedRole == UserRole.kurye,
          onTap: () => setState(() => _selectedRole = UserRole.kurye),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Form alanları
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad *',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            labelText: 'Not (opsiyonel)',
            prefixIcon: Icon(Icons.note),
            hintText: 'Ör: X firmasında çalışıyorum',
          ),
          maxLines: 2,
        ),

        const SizedBox(height: AppSpacing.xl),

        AppPrimaryButton(
          label: 'Talep Gönder',
          isLoading: _isSubmitting,
          onPressed: _selectedRole == null ||
                  _nameController.text.trim().isEmpty
              ? null
              : _submitRequest,
        ),
      ],
    );
  }

  Future<void> _submitRequest() async {
    final session = await ref.read(authRepositoryProvider).currentSession();
    if (session == null) return;

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(roleRequestRepositoryProvider);
      await repo.createRequest(
        RoleRequest(
          id: '',
          userId: session.user.id,
          requestedRole: _selectedRole!,
          status: RoleRequestStatus.beklemede,
          displayName: _nameController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      if (mounted) {
        ref.read(myRoleRequestProvider.notifier).refresh();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _roleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.musteriPersonel:
        return 'Müşteri Personeli';
      case UserRole.operasyon:
        return 'Operasyon';
      case UserRole.kurye:
        return 'Kurye';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
