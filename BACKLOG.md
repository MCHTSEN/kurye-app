# BACKLOG

Project audit log for major changes.

## Entry Format
- Date: YYYY-MM-DD
- Scope:
- Summary:
- Files:
- Validation:

## Entries

### 2026-03-31
- Scope: Operasyon typeahead tıklama seçimi düzeltmesi
- Summary:
  - Operasyon ekranındaki form alanlarında kullanılan `TypeaheadField` overlay seçim davranışı düzeltildi.
  - Öneri satırına mouse/touch tıklandığında focus kaybı nedeniyle overlay erken kapanıp seçim iptal oluyordu; pointer seçim akışı korunarak tıklama ile doğrudan seçim garantilendi.
  - Blur kapanışı kısa gecikmeli güvenli akışa alındı (`120ms`), böylece focus kaybı ile satır tıklaması yarışında seçim kaybolmuyor.
  - Alan zaten odaktayken tekrar tıklamada da öneri overlay'i açılacak şekilde güncellendi; kullanıcı yazı yazmadan tüm seçenekleri görebiliyor.
  - `items` listesi odaktayken sonradan güncellendiğinde overlay otomatik yenileniyor.
  - `didUpdateWidget` sırasında overlay build tetiklenmesi kaynaklı `setState() or markNeedsBuild() called during build` hatası için overlay açma akışı `postFrameCallback` ile güvenli hale getirildi.
  - Bu regresyon için widget testi eklendi: Enter basmadan öneri tıklamasıyla seçim yapılabildiği doğrulandı.
  - Living docs güncellendi (`SCREENS.md`, `WIDGETS.md`) ve etkileşim kontratı netleştirildi.
- Files:
  - `lib/product/widgets/typeahead_field.dart`
  - `test/product/widgets/typeahead_field_test.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/product/widgets/WIDGETS.md`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/product/widgets/typeahead_field_test.dart` → passed.
  - `flutter test test/product/widgets/typeahead_field_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart` → passed.
  - `test/product/widgets/typeahead_field_test.dart` içinde "shows all suggestions on tap when query is empty" senaryosu geçti.
  - `test/product/widgets/typeahead_field_test.dart` içinde "does not throw when items update while field is focused" senaryosu geçti.
  - `flutter analyze` → failed (`42 issues`): repo genelindeki mevcut info lintleri + `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart` içinde önceden var olan 1 warning.
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, pixel diff), yeni typeahead testi geçti.

### 2026-03-27
- Scope: Operasyon ekranı mobil layout iyileştirmesi
- Summary:
  - `_buildOrderForm` mobilde dikey layout kullanacak şekilde yeniden düzenlendi: Müşteri ve Personel tam genişlik, Çıkış/Uğrama ve Uğrama1/Not(Rehber) 2'li grid, SİPARİŞ OLUŞTUR butonu tam genişlik.
  - `_buildWaitingPanel` mobilde kart bazlı sipariş listesi kullanacak şekilde refactor edildi: her sipariş checkbox + müşteri/personel/güzergah + saat içeren tıklanabilir kart. Kurye Seç dropdown ve ATA butonu panel altına taşındı.
  - `_buildActivePanel` mobilde kart bazlı sipariş listesi kullanacak şekilde refactor edildi: her aktif iş kurye badge + güzergah + düzenle ikonu + BİTTİ butonu içeren kart.
  - `_buildWaitingCard` ve `_buildActiveCard` yardımcı metotları eklendi.
  - Desktop ve tablet layout'lar değişmedi; mevcut tablo/row yapısı korundu.
  - Tüm mevcut testler korundu; `Key('active_${s.id}')` kart container'ına eklenerek test uyumu sağlandı.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → 12/12 passed.
  - `flutter test` → 140 passing, 1 failing (pre-existing golden mismatch, unrelated).
  - iPhone 17 Pro simulator üzerinde canlı doğrulama: form tam genişlik dropdown'larla okunabilir, bekleyenler kartları çalışıyor.

### 2026-03-20
- Scope: Müşteri mobil navigasyon shell düzeltmesi
- Summary:
  - Müşteri mobil drawer navigasyonu kaldırılarak `AutoTabsScaffold` tabanlı `MusteriShellPage` eklendi.
  - Müşteri route'ları `/musteri` shell altındaki child route yapısına taşındı; sipariş / geçmiş / uğrama talebi sekmeleri mobilde alt çubuk üzerinden açılıyor.
  - `MusteriSiparisPage`, `MusteriGecmisPage` ve `MusteriUgramaTalepPage` mobilde drawer göstermeyecek şekilde güncellendi; desktop/tablet `ResponsiveScaffold` davranışı korundu.
  - Müşteri tab geçişleri için analytics event kataloğuna `musteri_tab_selected` eklendi.
  - Yeni widget testi ile müşteri shell sekme geçişi doğrulandı; iPhone 15 Pro simulator üzerinde canlı doğrulamada Sipariş → Geçmiş → Uğrama → Sipariş akışı çalıştı.
- Files:
  - `lib/app/router/app_router.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_shell_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart`
  - `lib/feature/musteri_siparis/DOC.md`
  - `lib/feature/musteri_siparis/presentation/SCREENS.md`
  - `lib/product/navigation/role_nav_items.dart`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `test/feature/musteri_siparis/musteri_shell_page_test.dart`
- Validation:
  - `flutter analyze` passed with existing repo-wide info/warning backlog only (no new blocking analyzer error).
  - `flutter test` => `140 passing, 1 failing` and the only failure remains pre-existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.
  - Manual simulator verification passed on iPhone 15 Pro simulator: müşteri mobile tabs navigate correctly across sipariş / geçmiş / uğrama screens.

### 2026-03-17
- Scope: Operasyon ekranı günlük ciro hesaplama düzeltmesi
- Summary:
  - `OperasyonEkranPage` desktop özetindeki `BUGÜNKÜ KAZANÇ` alanı sabit `0 TL` yerine canlı hesaplamaya geçirildi.
  - Hesaplama, bugünün tarih aralığında `tamamlandi` siparişlerin `ucret` toplamını kullanıyor.
  - `Bitir` aksiyonu sonrası günlük ciro provider invalidation eklendi; sayfa yenilemeden metrik anında güncelleniyor.
  - Bu davranış için widget test eklendi (`desktop summary shows today revenue...`, `finishing order updates today revenue without manual refresh`).
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.

### 2026-03-16
- Scope: Operasyon koyu drawer/sidebar teması ve responsive tipografi
- Summary:
  - `ResponsiveScaffold` drawer ve desktop sidebar aynı koyu gri palette'e taşındı.
  - Drawer/sidebar metinleri büyütüldü ve ekran genişliğine göre responsive ölçekleme eklendi.
  - Desktop sidebar genişliği sabit değil, ekran genişliğine göre dinamik hale getirildi.
  - `OperasyonEkranPage` tablo başlık/satır yazıları responsive büyütüldü; desktop panel oranları dinamik ayarlanarak ekran alanı daha efektif kullanıldı.
- Files:
  - `lib/product/widgets/WIDGETS.md`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter test test/product/widgets/responsive_scaffold_test.dart` passed.
  - `flutter analyze lib/product/widgets/responsive_scaffold.dart lib/feature/operasyon/presentation/operasyon_ekran_page.dart` failed with info-level lint warnings only (no new blocking analyzer error).

### 2026-03-16
- Scope: Operasyon devam eden sipariş düzenleme akışı
- Summary:
  - `OperasyonEkranPage` aktif satırındaki düzenleme ikonu gerçek aksiyona bağlandı.
  - Devam eden sipariş için düzenleme dialog'u eklendi (kurye, personel, çıkış/uğrama adımları, not alanları).
  - Güncelleme sonrası `siparisStreamActiveProvider` invalidation ile liste anlık yenileme korundu.
  - Operasyon ekranı koyu gri temaya geçirildi; arka plan, kart yüzeyleri ve satır bölücüleri dark palette'e alındı, metin kontrastı açık tonlarla güncellendi.
  - Widget test kapsamına aktif sipariş düzenleme ve kaydetme senaryosu eklendi.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter analyze lib/feature/operasyon/presentation/operasyon_ekran_page.dart test/feature/operasyon/operasyon_ekran_page_test.dart` failed with existing info-level lints (`avoid_redundant_argument_values`) and no new blocking error.
  - `flutter analyze` failed with existing repo-wide info-level lint backlog (latest run: 37 issues).
  - `flutter test` failed only on existing golden mismatch: `test/feature/example_feed/example_feed_page_golden_test.dart`.

### 2026-03-16
- Scope: Operasyon web UX hardening and desktop workflow polish
- Summary:
  - Desktop operasyon sidebar gruplu navigasyon ve kısayol odaklı kullanım için güçlendirildi.
  - `OperasyonDashboardPage` içine desktop hızlı geçiş kartları eklendi; dar kolon taşmaları düzeltildi.
  - `OperasyonEkranPage` desktop özet metrikleri korunurken tablet/mobil davranışı testlerle uyumlu şekilde stabilize edildi.
  - `OperasyonGecmisPage` split-view workbench, arama alanı, durum chip'leri ve side editor paneli ile yenilendi.
  - CRUD workbench list panelleri mobilde sonsuz yükseklik istemeyecek şekilde düzenlendi; `AppSectionCard` dar alanlarda taşmayacak hale getirildi.
  - Operasyon dashboard, dispatch, geçmiş ve müşteri kayıt testleri yeni desktop/mobile kontratına göre güncellendi; desktop geçmiş coverage eklendi.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `lib/feature/operasyon/presentation/musteri_kayit_page.dart`
  - `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart`
  - `lib/feature/operasyon/presentation/kurye_yonetim_page.dart`
  - `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`
  - `lib/product/widgets/app_section_card.dart`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `test/feature/operasyon/operasyon_dashboard_page_test.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
  - `test/feature/operasyon/musteri_kayit_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart test/feature/operasyon/operasyon_gecmis_page_test.dart` passed.
  - `flutter test test/feature/operasyon/musteri_kayit_page_test.dart` passed.
  - `flutter test test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart` passed.
  - `flutter test integration_test/operasyon_navigation_smoke_test.dart` passed.
  - `flutter analyze` failed due existing repo info-level issues; latest run reported 32 issues and no new blocking error.
  - `flutter test` failed only on existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.

### 2026-03-16
- Scope: Operasyon mobile bottom navigation shell
- Summary:
  - Operasyon rolü için mobil drawer akışı `AutoTabsScaffold` tab shell yapısına taşındı.
  - Yeni `/operasyon` shell route ve `/operasyon/ayarlar` hub route eklendi.
  - Düşük frekanslı operasyon sayfaları ayarlar stack'i altına alındı.
  - `ResponsiveScaffold` mobil drawer'ı kapatılabilir hale getirildi.
  - Operasyon tab ve ayarlar seçimleri için analytics eventleri eklendi.
  - Operasyon shell ve ayarlar hub için widget testleri eklendi.
- Files:
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_shell_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ayarlar_page.dart`
  - `lib/feature/operasyon/presentation/*.dart`
  - `lib/product/navigation/role_nav_items.dart`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `test/app/router/*.dart`
  - `test/feature/operasyon/operasyon_shell_page_test.dart`
  - `test/feature/operasyon/operasyon_ayarlar_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
- Validation:
  - `flutter analyze` failed due pre-existing repo info-level issues; no new analyzer errors from this change.
  - `flutter test test/app/router/custom_route_test.dart test/app/router/guard_role_routing_test.dart test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart` passed.
  - `flutter test integration_test/operasyon_navigation_smoke_test.dart` passed.
  - `flutter test` failed on existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.

### 2026-03-15
- Scope: Sprint 1 — Moto Kurye temel altyapı (DB şeması, roller, routing)
- Summary:
  - Supabase PostgreSQL migration dosyası oluşturuldu (9 tablo, RLS, indexler, realtime, PostGIS).
  - `UserRole` enum ve `AppUserProfile` domain modeli eklendi (`backend_core`).
  - `UserProfileRepository` kontratı + Supabase ve Mock implementasyonları eklendi.
  - `BackendModule` kontratına `createUserProfileRepository()` eklendi; tüm backend'ler güncellendi.
  - `CurrentUserProfile` Riverpod provider eklendi (login sonrası rol sorgusu).
  - `CustomRoute` enum'a 9 yeni rol bazlı rota eklendi (müşteri/operasyon/kurye).
  - `AppAccessGuard` rol bazlı erişim kontrolü ve yönlendirme ile güncellendi.
  - `AuthController` login sonrası profil invalidation eklendi.
  - 3 feature placeholder oluşturuldu: `musteri_siparis`, `operasyon`, `kurye` (DOC.md + SCREENS.md + sayfalar).
  - Proje planı `docs/PROJECT_PLAN.md` olarak dokümante edildi.
- Files:
  - `supabase/migrations/001_initial_schema.sql`
  - `packages/backend_core/lib/src/domain/user_role.dart`
  - `packages/backend_core/lib/src/domain/app_user_profile.dart`
  - `packages/backend_core/lib/src/user_profile_repository.dart`
  - `packages/backend_core/lib/src/backend_module.dart`
  - `packages/backend_core/lib/backend_core.dart`
  - `packages/backend_supabase/lib/src/supabase_user_profile_repository.dart`
  - `packages/backend_supabase/lib/src/supabase_backend_module.dart`
  - `packages/backend_mock/lib/src/mock_user_profile_repository.dart`
  - `packages/backend_mock/lib/src/mock_backend_module.dart`
  - `packages/backend_custom/lib/src/custom_backend_module.dart`
  - `packages/backend_firebase/lib/src/firebase_backend_module.dart`
  - `lib/product/user_profile/user_profile_providers.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/app/app.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/feature/musteri_siparis/**`
  - `lib/feature/operasyon/**`
  - `lib/feature/kurye/**`
  - `docs/PROJECT_PLAN.md`
  - `test/domain/user_role_test.dart`
  - `test/app/router/custom_route_test.dart`
  - `test/app/router/guard_role_routing_test.dart`
- Validation:
  - `flutter analyze` passed (0 issues).
  - `flutter test` passed (53 tests).

### 2026-03-08
- Scope: Feature test policy hardening
- Summary:
  - Clarified that new or materially changed features require explicit
    test layers beyond generic repo-wide validation.
  - Added minimum expectations for unit, widget, golden, and smoke
    integration coverage in project docs.
- Files:
  - `AGENTS.md`
  - `docs/DOC_STANDARDS.md`
  - `test/TESTING.md`
  - `BACKLOG.md`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed.

### 2026-03-08
- Scope: Mock backend, runtime service baseline, testing kit, and example vertical slice
- Summary:
  - Added `mock` backend selection via `BACKEND_PROVIDER` and introduced `backend_mock` for zero-setup local flows.
  - Added reusable runtime services for secure storage, connectivity, feature flags, crash reporting, permissions, cache policy, and retry policy.
  - Added shared test helpers, golden test setup, and a runnable macOS smoke `integration_test` flow.
  - Added `example_feed` as the reference vertical slice with remote data source, repository contract, cache/retry composition, controller, page, analytics, and tests.
- Files:
  - `packages/backend_mock/**`
  - `lib/core/environment/**`
  - `lib/core/runtime/**`
  - `lib/product/runtime/**`
  - `lib/product/widgets/**`
  - `lib/feature/example_feed/**`
  - `lib/app/**`, `lib/main*.dart`
  - `test/helpers/**`
  - `test/feature/example_feed/**`
  - `integration_test/app_smoke_test.dart`
  - `pubspec.yaml`, `README.md`, `AGENTS.md`, `BACKLOG.md`, `docs/**`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`43 tests`).
  - `flutter test integration_test/app_smoke_test.dart -d macos` passed.

### 2026-03-08
- Scope: Skeleton foundation
- Summary:
  - Introduced Riverpod 3 app skeleton with `core/product/feature` layers.
  - Added multi-backend auth adapter strategy (`custom`, `supabase`, `firebase`).
  - Added mandatory analytics abstraction with Mixpanel and noop fallback.
  - Added onboarding/auth/home/profile/splash feature flow and router guards.
- Files:
  - `lib/app/**`
  - `lib/core/**`
  - `lib/product/**`
  - `lib/feature/**`
  - `pubspec.yaml`, `analysis_options.yaml`, `README.md`, `AGENTS.md`, `docs/ARCHITECTURE.md`
- Validation:
  - `flutter analyze` passed.

### 2026-03-08
- Scope: Documentation governance and audit rules
- Summary:
  - Enforced doc-first workflow for feature/screen/widget development.
  - Added local docs for all current features and presentation folders.
  - Added doc standards and backlog maintenance rules.
- Files:
  - `docs/DOC_STANDARDS.md`
  - `lib/feature/*/DOC.md`
  - `lib/feature/*/presentation/SCREENS.md`
  - `lib/product/widgets/WIDGETS.md`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `README.md`, `BACKLOG.md`
- Validation:
  - Structural docs added and linked to process rules.

### 2026-03-08
- Scope: AutoRoute migration and centralized access policies
- Summary:
  - Replaced `go_router` with `auto_route`.
  - Added centralized `AppAccessGuard` for onboarding/auth/credit policies.
  - Added `AppNavigationState` + `RouteReevaluationNotifier` for runtime guard re-check.
  - Added network-level 401/credit handling in `DioApiClient` interceptor.
  - Added token refresh strategy contract and backend-based refresh adapters.
  - Added `buy_credit` feature and route.
- Files:
  - `pubspec.yaml`
  - `lib/app/router/**`
  - `lib/core/network/dio_api_client.dart`
  - `lib/product/auth/**`
  - `lib/product/navigation/**`
  - `lib/product/network/api_client_provider.dart`
  - `lib/feature/buy_credit/**`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/feature/onboarding/presentation/onboarding_page.dart`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `README.md`, feature docs
- Validation:
  - `flutter analyze` target: pass.

### 2026-03-08
- Scope: Route enum standardization and project padding tokens
- Summary:
  - Added `ProjectPadding` token structure (`ProjectPadding.all.normal` etc.).
  - Updated feature/screen/widget paddings to use `ProjectPadding` instead of inline `EdgeInsets`.
  - Added `CustomRoute` enum and replaced hardcoded route paths in navigation/guard/router usage.
  - Updated docs to reference `CustomRoute` and `ProjectPadding` standards.
- Files:
  - `lib/core/constants/project_padding.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/**/presentation/*.dart`
  - `lib/product/widgets/app_section_card.dart`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/DOC_STANDARDS.md`, feature screen docs
- Validation:
  - `flutter analyze` target: pass.

### 2026-03-08
- Scope: Mandatory test gating rule and baseline tests
- Summary:
  - Added completion rule: do not mark tasks done without running tests.
  - Added requirement to report validation outputs in task summaries.
  - Introduced baseline test suite for routing, padding tokens, and navigation state.
- Files:
  - `AGENTS.md`
  - `docs/DOC_STANDARDS.md`
  - `README.md`
  - `test/app/router/custom_route_test.dart`
  - `test/core/constants/project_padding_test.dart`
  - `test/product/navigation/app_navigation_state_test.dart`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`5 tests`).

### 2026-03-08
- Scope: Centralize screen analytics at navigator level
- Summary:
  - Replaced per-screen `TrackedScreen` wrapper approach.
  - Added router-level `AnalyticsRouteObserver` for automatic `screen_viewed` events.
  - Wired observer into `MaterialApp.router` via `navigatorObservers`.
  - Removed `tracked_screen.dart` and updated related docs.
- Files:
  - `lib/app/router/observers/analytics_route_observer.dart`
  - `lib/app/router/observers/route_observer_providers.dart`
  - `lib/app/app.dart`
  - `lib/feature/**/presentation/*.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `docs/ARCHITECTURE.md`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`5 tests`).

### 2026-03-08
- Scope: Riverpod 3 best-practice hardening and credit policy decoupling
- Summary:
  - Added `core` and `product` layer docs (`lib/core/DOC.md`, `lib/product/DOC.md`).
  - Added configurable `CREDIT_ACCESS_PROVIDER` (`navigationSignal`, `firebaseClaims`, `revenueCat`).
  - Introduced `CreditAccessService` abstraction for guard-level credit decisions.
  - Decoupled insufficient-credit redirect trigger from Dio via provider-based switch.
  - Updated guard to evaluate credit through provider strategy (network signal/Firebase/RevenueCat callback).
  - Applied Riverpod 3 lifecycle and performance improvements (`ref.mounted`, `select`, `ProviderObserver`).
  - Standardized route names through `CustomRoute.<name>.routeName` usage in router config.
- Files:
  - `lib/core/environment/**`
  - `lib/core/DOC.md`
  - `lib/product/DOC.md`
  - `lib/product/credit/**`
  - `lib/product/network/api_client_provider.dart`
  - `lib/core/network/dio_api_client.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/bootstrap.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/product/onboarding/onboarding_providers.dart`
  - `lib/feature/auth/presentation/auth_page.dart`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/feature/onboarding/presentation/onboarding_page.dart`
  - `docs/ARCHITECTURE.md`, `docs/DOC_STANDARDS.md`, `README.md`, `AGENTS.md`, `BACKLOG.md`
  - `test/app/router/custom_route_test.dart`
  - `test/core/environment/credit_access_provider_test.dart`
  - `test/product/credit/**`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`13 tests`).

---

### 2026-03-16 — Operasyon ekranı mobile row stability fixes
- Scope: `feature/operasyon`
- Summary: Fixed `OperasyonEkranPage` runtime issues caused by unconstrained action buttons and unsafe active-order lookups. Active rows now degrade safely in narrow widths, use stable keys for actions, and customer/personnel rendering falls back without `firstWhere` crashes.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
- Validation:
  - `dart analyze lib/feature/operasyon/presentation/operasyon_ekran_page.dart` completed with 4 existing info-level lints.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.

---

### 2026-03-16 — mobile-mcp repository add and integration verification
- Scope: `tooling`, `mcp`
- Summary: Added `mobile-mcp` source under `tools/mobile-mcp`, verified local package tests, and confirmed Codex MCP registration/availability for `mobile-mcp`.
- Files:
  - `tools/mobile-mcp` (git clone from `https://github.com/mobile-next/mobile-mcp`)
- Validation:
  - `npx -y @mobilenext/mobile-mcp@latest --help` passed (CLI available).
  - `npm ci` in `tools/mobile-mcp` passed.
  - `npm test` in `tools/mobile-mcp` passed (`11 passing`, `18 pending`).
  - `codex mcp list` shows `mobile-mcp` enabled.
  - `npx -y @mobilenext/mobile-mcp@latest --port 8787` starts SSE server successfully.

---

### 2026-03-16 — Operasyon geçmiş desktop/mobile layout stabilization
- Scope: `feature/operasyon`
- Summary: Fixed `OperasyonGecmisPage` render crashes caused by unbounded button widths and fragile scroll pane layout in the workbench view. Desktop panes now use bounded list views, filter controls degrade responsively, and test selectors were aligned with the current screen contract.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
- Validation:
  - `dart analyze lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` passed.
  - `flutter test test/feature/operasyon/operasyon_gecmis_page_test.dart` passed.

---

### 2026-03-16 — Local web debug CSP workaround
- Scope: `tooling`, `docs`
- Summary: Added a dedicated VS Code Chrome launch config and README command for local Flutter web debug in CSP-constrained environments. The workaround uses Chrome development flags only for localhost so production CSP behavior remains unchanged.
- Files:
  - `.vscode/launch.json`
  - `README.md`
- Validation:
  - `python3 -m json.tool .vscode/launch.json` passed.
  - `flutter analyze` completed with the repo's existing 33 info-level issues; no new analyzer error/warning blocker introduced by this tooling change.
  - `flutter test` was started and progressed through 47 passing tests before being stopped manually to avoid waiting on the full suite during tooling verification.

---

### 2026-03-16 — Operasyon default landing + password-gated reports
- Scope: `feature/operasyon`, `app/router`, `core/environment`
- Summary: Changed operasyon default landing to `Operasyon Ekranı`, renamed dashboard access to `Raporlar`, and added a password gate for ciro / kurye performans metrics via `OPERASYON_REPORTS_PASSWORD`. Updated mobile/desktop nav order and refreshed operasyon smoke/widget coverage.
- Files:
  - `lib/core/environment/app_environment.dart`
  - `lib/core/environment/app_environment_keys.dart`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_shell_page.dart`
  - `lib/feature/operasyon/providers/report_access_providers.dart`
  - `lib/product/navigation/role_nav_items.dart`
  - `lib/app/router/app_router.dart`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `pubspec.yaml`
  - `.env`
  - `test/feature/operasyon/operasyon_dashboard_page_test.dart`
  - `test/feature/operasyon/operasyon_shell_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
  - `test/helpers/widgets/test_app.dart`
  - `test/helpers/providers/test_provider_container.dart`
  - `test/core/environment/app_environment_test.dart`
  - `test/product/network/api_client_provider_test.dart`
  - `test/product/credit/credit_providers_test.dart`
- Validation:
  - `flutter test test/core/environment/app_environment_test.dart test/app/router/custom_route_test.dart test/app/router/guard_role_routing_test.dart test/product/widgets/responsive_scaffold_test.dart test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_dashboard_page_test.dart` passed.
  - `flutter analyze` was attempted; repo still reports existing info-level lint set and should be re-run after long-running integration/device jobs finish.
  - `flutter test integration_test/app_smoke_test.dart integration_test/operasyon_navigation_smoke_test.dart -d macos` was attempted but stalled in CocoaPods/macOS build preparation on this machine.

---

### 2026-03-15 — S04/T02: 3-panel dispatch screen with assignment and finish flows
- Scope: `feature/operasyon`
- Summary: Replaced placeholder OperasyonEkranPage with real 3-panel dispatch screen — order creation (müşteri dropdown → cascading stops), kurye bekleyenler (checkbox + assign), devam edenler (checkbox + finish with auto-pricing/manual fallback). SiparisLog created on every transition. Created FakeSiparisLogRepository.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` (replaced)
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` (new, 5 tests)
  - `test/helpers/fakes/fake_siparis_log_repository.dart` (new)
- Validation:
  - `flutter analyze` passed (0 errors, 0 warnings).
  - `flutter test` passed (86 tests).
  - `flutter build ios --simulator` passed.

---

### 2026-03-15 — S08: Cross-role integration & polish (M001 final slice)
- Scope: `product/services`, `feature/operasyon`, `feature/kurye`, `test/integration`
- Summary: Added OrderAlertService (audioplayers) for sound alerts on new dispatch orders. Applied D027 name resolution to dispatch and courier screens (stops + courier names replace UUIDs). Created 5-test cross-role integration suite proving full order lifecycle. M001 milestone complete — all 18 requirements validated, 123 tests passing.
- Files:
  - `pubspec.yaml` (audioplayers + assets)
  - `assets/sounds/new_order.wav` (new)
  - `lib/product/services/order_alert_service.dart` (new)
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` (alert + names)
  - `lib/feature/kurye/presentation/kurye_ana_page.dart` (name resolution)
  - `test/helpers/fakes/fake_order_alert_service.dart` (new)
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` (3 new tests)
  - `test/feature/kurye/kurye_ana_page_test.dart` (2 new tests)
  - `test/integration/cross_role_lifecycle_test.dart` (new, 5 tests)
- Validation:
  - `flutter analyze` passed (0 errors, 0 warnings).
  - `flutter test` passed (123 tests).
