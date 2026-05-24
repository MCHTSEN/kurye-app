import 'package:auto_route/auto_route.dart' hide CustomRoute, RouteType;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../core/theme/app_colors.dart';
import '../../../product/auth/auth_providers.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/app_access_snapshot.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/searchable_dropdown.dart';
import '../../auth/application/auth_controller.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  RoleRequestAccountType? _selectedAccountType;
  String? _selectedMusteriId;
  String? _selectedMusteriLabel;
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;
  bool _isRedirecting = false;

  bool get _canSubmit =>
      !_isSubmitting &&
      _selectedAccountType != null &&
      _nameController.text.trim().isNotEmpty &&
      switch (_selectedAccountType) {
        RoleRequestAccountType.newCustomer =>
          _companyNameController.text.trim().isNotEmpty,
        RoleRequestAccountType.existingCustomerEmployee =>
          _selectedMusteriId != null,
        null => false,
      };

  void _handleFormChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleFormChanged);
    _companyNameController.addListener(_handleFormChanged);
    _phoneController.addListener(_handleFormChanged);
    _noteController.addListener(_handleFormChanged);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleFormChanged);
    _companyNameController.removeListener(_handleFormChanged);
    _phoneController.removeListener(_handleFormChanged);
    _noteController.removeListener(_handleFormChanged);
    _nameController.dispose();
    _companyNameController.dispose();
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
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: requestAsync.when(
        data: (request) {
          if (request?.status == RoleRequestStatus.beklemede) {
            _redirectToHomeIfNeeded();
            return const Center(child: CircularProgressIndicator());
          }

          if (request == null) {
            return _buildRoleSelectionForm(theme);
          }

          if (request.status == RoleRequestStatus.onaylandi) {
            _redirectToHomeIfNeeded();
            return const Center(child: CircularProgressIndicator());
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
          const Icon(Icons.hourglass_top, size: 80, color: AppColors.secondary),
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
            onPressed: () async {
              invalidateAppAccessCaches(ref);
              await ref.read(myRoleRequestProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Durumu Kontrol Et'),
          ),
        ] else if (request.status == RoleRequestStatus.onaylandi) ...[
          const Icon(Icons.check_circle, size: 80, color: AppColors.secondary),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Talebiniz Onaylandı!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
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
            onPressed: () async {
              invalidateAppAccessCaches(ref);
              await ref.read(myRoleRequestProvider.notifier).refresh();
            },
          ),
        ] else if (request.status == RoleRequestStatus.reddedildi) ...[
          const Icon(Icons.cancel, size: 80, color: AppColors.primaryDark),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Talebiniz Reddedildi',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
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
              invalidateAppAccessCaches(ref);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoleSelectionForm(ThemeData theme) {
    final musteriListAsync = ref.watch(musteriListProvider);

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
          'Başvurunuzu nasıl açacağınızı seçin.\n'
          'Onay beklerken de uygulama içinde ilerleyebileceksiniz.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        _RoleOptionCard(
          icon: Icons.add_business,
          title: 'Yeni Müşteri Oluştur',
          description: 'Firmanızı kaydedip hemen işlem yapmaya başlayın',
          isSelected:
              _selectedAccountType == RoleRequestAccountType.newCustomer,
          onTap: () => setState(() {
            _selectedAccountType = RoleRequestAccountType.newCustomer;
            _selectedMusteriId = null;
            _selectedMusteriLabel = null;
          }),
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleOptionCard(
          icon: Icons.groups_2,
          title: 'Var Olan Müşteriye Katıl',
          description: 'Mevcut firmanızın personeli olarak giriş yapın',
          isSelected:
              _selectedAccountType ==
              RoleRequestAccountType.existingCustomerEmployee,
          onTap: () => setState(() {
            _selectedAccountType =
                RoleRequestAccountType.existingCustomerEmployee;
            _companyNameController.clear();
          }),
        ),

        const SizedBox(height: AppSpacing.xl),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad *',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        if (_selectedAccountType == RoleRequestAccountType.newCustomer) ...[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Firma Adı *',
              prefixIcon: Icon(Icons.business),
            ),
          ),
        ],
        if (_selectedAccountType ==
            RoleRequestAccountType.existingCustomerEmployee) ...[
          const SizedBox(height: AppSpacing.md),
          musteriListAsync.when(
            data: (musteriler) => SearchableDropdown<String>(
              key: const Key('existing_customer_dropdown'),
              value: _selectedMusteriId,
              label: 'Firma *',
              placeholder: 'Firmanızı seçin',
              searchPlaceholder: 'Firma ara...',
              items: musteriler
                  .map((m) => (value: m.id, label: m.firmaKisaAd))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMusteriId = value;
                  _selectedMusteriLabel = musteriler
                      .where((m) => m.id == value)
                      .map((m) => m.firmaKisaAd)
                      .firstOrNull;
                });
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Firma listesi yüklenemedi: $e'),
          ),
        ],
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
          decoration: InputDecoration(
            labelText: 'Not (opsiyonel)',
            prefixIcon: const Icon(Icons.note),
            hintText: _selectedAccountType == RoleRequestAccountType.newCustomer
                ? 'Ör: Vergi bilgisi, özel talep, operasyon notu'
                : 'Ör: Hangi ekipte çalıştığınız veya operasyon notu',
          ),
          maxLines: 2,
        ),

        const SizedBox(height: AppSpacing.xl),

        AppPrimaryButton(
          label: 'Talep Gönder',
          isLoading: _isSubmitting,
          onPressed: _canSubmit ? _submitRequest : null,
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
          requestedRole: UserRole.musteriPersonel,
          status: RoleRequestStatus.beklemede,
          displayName: _nameController.text.trim(),
          accountType: _selectedAccountType,
          companyName:
              _selectedAccountType == RoleRequestAccountType.newCustomer
              ? _companyNameController.text.trim()
              : _selectedMusteriLabel,
          musteriId:
              _selectedAccountType ==
                  RoleRequestAccountType.existingCustomerEmployee
              ? _selectedMusteriId
              : null,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );

      if (mounted) {
        invalidateAppAccessCaches(ref);
        await context.router.replacePath(CustomRoute.home.path);
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _redirectToHomeIfNeeded() {
    if (_isRedirecting) {
      return;
    }

    _isRedirecting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _isRedirecting = false;
        return;
      }

      await context.router.replacePath(CustomRoute.home.path);
      if (mounted) {
        _isRedirecting = false;
      }
    });
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

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
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
