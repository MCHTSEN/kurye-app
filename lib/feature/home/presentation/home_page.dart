import 'package:auto_route/auto_route.dart' hide CustomRoute;
import 'package:backend_core/backend_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/custom_route.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/project_padding.dart';
import '../../../product/musteri/musteri_providers.dart';
import '../../../product/navigation/account_delete_helper.dart';
import '../../../product/role_request/role_request_providers.dart';
import '../../../product/user_profile/user_profile_providers.dart';
import '../../../product/widgets/app_primary_button.dart';
import '../../../product/widgets/app_section_card.dart';
import '../../auth/application/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      authControllerProvider.select((state) => state.isLoading),
    );
    final authController = ref.read(authControllerProvider.notifier);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final requestAsync = ref.watch(myRoleRequestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Moto Kurye')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: [
          profileAsync.when(
            data: (profile) {
              if (profile != null) {
                if (profile.role == UserRole.musteriPersonel &&
                    !profile.isActive) {
                  return requestAsync.when(
                    data: (request) => Column(
                      children: [
                        AppSectionCard(
                          title: 'Hesabınız Kullanıma Açıldı',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request?.accountType ==
                                        RoleRequestAccountType.newCustomer
                                    ? 'Firmanız için ön kayıt oluşturuldu. '
                                          'Aşağıdaki bilgileri tamamlayıp müşteri '
                                          'paneline geçebilirsiniz.'
                                    : 'Başvurunuz operasyon incelemesinde. '
                                          'Bu sırada bağlı olduğunuz müşteri için '
                                          'temel işlemleri kullanabilirsiniz.',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text('Kullanıcı: ${profile.displayName}'),
                              if (request?.companyName != null &&
                                  request!.companyName!.isNotEmpty)
                                Text('Firma: ${request.companyName}'),
                              const SizedBox(height: AppSpacing.lg),
                              AppPrimaryButton(
                                label: 'Müşteri Panelini Aç',
                                onPressed: profile.musteriId == null
                                    ? null
                                    : () => context.router.pushPath(
                                        CustomRoute.musteriSiparis.path,
                                      ),
                              ),
                            ],
                          ),
                        ),
                        if (request?.accountType ==
                                RoleRequestAccountType.newCustomer &&
                            profile.musteriId != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          _PendingMusteriSetupCard(
                            musteriId: profile.musteriId!,
                          ),
                        ],
                      ],
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => AppSectionCard(
                      title: 'Hesap Durumu',
                      child: Text('Başvuru bilgisi alınamadı: $e'),
                    ),
                  );
                }

                return AppSectionCard(
                  title: 'Hoş geldiniz, ${profile.displayName}',
                  child: Text('Rol: ${profile.role.value}'),
                );
              }

              return requestAsync.when(
                data: (request) {
                  final requestedRole = request == null
                      ? null
                      : switch (request.requestedRole) {
                          UserRole.musteriPersonel => 'Müşteri Personeli',
                          UserRole.operasyon => 'Operasyon',
                          UserRole.kurye => 'Kurye',
                        };

                  return AppSectionCard(
                    title: 'Hesap İnceleniyor',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rol talebiniz alındı. Operasyon ekibi hesabınızı '
                          'onayladığında uygulamadaki yetkileriniz açılacak.',
                        ),
                        if (request != null) ...[
                          const SizedBox(height: AppSpacing.md),
                          Text('Ad: ${request.displayName}'),
                          if (requestedRole != null)
                            Text('Talep edilen rol: $requestedRole'),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                              ..invalidate(currentUserProfileProvider)
                              ..invalidate(myRoleRequestProvider);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Durumu Yenile'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => AppSectionCard(
                  title: 'Hesap Beklemede',
                  child: Text(
                    'Rol talebiniz kontrol edilemedi. '
                    'Lütfen biraz sonra tekrar deneyin.\n\nHata: $e',
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => AppSectionCard(
              title: 'Profil Hatası',
              child: Text('$e'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Çıkış Yap',
            isLoading: isLoading,
            onPressed: authController.signOut,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            key: const Key('home_delete_account_btn'),
            onPressed: isLoading
                ? null
                : () => confirmAndDeleteAccount(context, ref),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}

class _PendingMusteriSetupCard extends ConsumerStatefulWidget {
  const _PendingMusteriSetupCard({required this.musteriId});

  final String musteriId;

  @override
  ConsumerState<_PendingMusteriSetupCard> createState() =>
      _PendingMusteriSetupCardState();
}

class _PendingMusteriSetupCardState
    extends ConsumerState<_PendingMusteriSetupCard> {
  final _shortNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxNumberController = TextEditingController();
  final _addressController = TextEditingController();
  String? _syncedMusteriId;
  bool _isSaving = false;

  @override
  void dispose() {
    _shortNameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _taxNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _syncFields(Musteri musteri) {
    if (_syncedMusteriId == musteri.id) {
      return;
    }

    _shortNameController.text = musteri.firmaKisaAd;
    _fullNameController.text = musteri.firmaTamAd ?? '';
    _phoneController.text = musteri.telefon ?? '';
    _emailController.text = musteri.email ?? '';
    _taxNumberController.text = musteri.vergiNo ?? '';
    _addressController.text = musteri.adres ?? '';
    _syncedMusteriId = musteri.id;
  }

  Future<void> _save(Musteri current) async {
    setState(() => _isSaving = true);
    try {
      final repo = ref.read(musteriRepositoryProvider);
      await repo.update(
        Musteri(
          id: current.id,
          firmaKisaAd: _shortNameController.text.trim(),
          firmaTamAd: _fullNameController.text.trim().isEmpty
              ? null
              : _fullNameController.text.trim(),
          telefon: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          adres: _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          vergiNo: _taxNumberController.text.trim().isEmpty
              ? null
              : _taxNumberController.text.trim(),
          isActive: current.isActive,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        ),
      );
      ref.invalidate(musteriByIdProvider(widget.musteriId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firma bilgileri kaydedildi')),
        );
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firma bilgileri kaydedilemedi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final musteriAsync = ref.watch(musteriByIdProvider(widget.musteriId));

    return musteriAsync.when(
      data: (musteri) {
        if (musteri == null) {
          return const AppSectionCard(
            title: 'Firma Bilgileri',
            child: Text('Firma kaydı bulunamadı.'),
          );
        }

        _syncFields(musteri);
        return AppSectionCard(
          title: 'Firma Bilgilerini Tamamla',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Operasyon onayını beklerken firma kayıt bilgilerinizi '
                'tamamlayabilirsiniz.',
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _shortNameController,
                decoration: const InputDecoration(
                  labelText: 'Firma Kısa Adı *',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Firma Tam Adı'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Firma Telefonu'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Firma E-posta'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _taxNumberController,
                decoration: const InputDecoration(labelText: 'Vergi No'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adres'),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.md),
              AppPrimaryButton(
                label: 'Firma Bilgilerini Kaydet',
                isLoading: _isSaving,
                onPressed: _shortNameController.text.trim().isEmpty
                    ? null
                    : () => _save(musteri),
              ),
            ],
          ),
        );
      },
      loading: () => const AppSectionCard(
        title: 'Firma Bilgileri',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => AppSectionCard(
        title: 'Firma Bilgileri',
        child: Text('Firma bilgileri yüklenemedi: $e'),
      ),
    );
  }
}
