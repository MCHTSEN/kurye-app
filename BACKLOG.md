# BACKLOG

Project audit log for major changes.

## Entry Format
- Date: YYYY-MM-DD
- Scope:
- Summary:
- Files:
- Validation:

## Entries

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
