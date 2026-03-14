# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Multi-backend Flutter mobile app skeleton (monorepo). Backend is selected at compile time via entry point — only the chosen SDK is included in the binary.

## Architecture

```
lib/
  app/              → Bootstrap, MaterialApp, router (auto_route + guards)
  core/             → Pure infrastructure: environment, network (Dio), Sentry, notifications, theme, constants
  product/          → Riverpod providers wiring core + backend: auth, credit, navigation, analytics, runtime, widgets
  feature/          → Vertical slices: domain/ → data/ → application/ → presentation/
  l10n/             → ARB files (Turkish-first: app_tr.arb template)

packages/
  backend_core/     → Interfaces + domain models (pure Dart, no SDK deps)
  backend_firebase/ → Firebase implementation
  backend_supabase/ → Supabase implementation
  backend_custom/   → Custom REST API implementation
  backend_mock/     → Zero-setup mock for tests and demos
```

**Layer flow:** `backend_core` (contracts) → `core` (infra) → `product` (Riverpod composition) → `feature` (user-facing)

## Key Commands

```bash
flutter run --dart-define-from-file=.env.dev                            # Run with dev config (default backend from env)
flutter run -t lib/main_firebase.dart --dart-define-from-file=.env.dev  # Force Firebase backend
flutter run -t lib/main_supabase.dart --dart-define-from-file=.env.dev  # Force Supabase backend
flutter run -t lib/main_custom.dart --dart-define-from-file=.env.dev    # Force Custom API backend
flutter build apk --dart-define-from-file=.env.prod                     # Production build

flutter pub get                                                         # Resolve workspace dependencies
dart run build_runner build --delete-conflicting-outputs                 # Regenerate Riverpod (.g.dart) code
flutter gen-l10n                                                        # Regenerate localization files
flutter analyze                                                         # Static analysis (must be 0 issues)
flutter test                                                            # Run all tests
flutter test test/feature/example_feed/                                 # Run tests for a specific feature
flutter test --name "returns remote items"                              # Run a single test by name
```

## Backend Selection (Compile-Time)

Entry point determines backend. `main.dart` reads `BACKEND_PROVIDER` from dart-define. Explicit entry points (`main_firebase.dart`, etc.) override it.

`BackendModule` is the abstract factory — each backend implements it. Provided via `backendModuleProvider` override in `bootstrap()`.

```dart
// How providers consume backend services:
AuthGateway authGateway(Ref ref) => ref.watch(backendModuleProvider).createAuthGateway();
```

**Custom backend uses its own Dio instance** (not the app's `DioApiClient`) to avoid circular dependency: app Dio depends on `TokenRefreshService`, which comes from `BackendModule`.

## Bootstrap Flow

`main()` → `AppEnvironment.fromDartDefine()` → `createBackendModule(env)` → `bootstrap(module, env)`:
1. Disable logging in release mode
2. Initialize Sentry (before anything that can throw)
3. Set up error handlers + `ErrorWidget.builder`
4. Initialize backend module (`Firebase.initializeApp()`, etc.)
5. Wrap app in `ProviderScope` with environment + backend module overrides

## Router & Guard System

`AppAccessGuard` runs on every navigation and enforces this priority:
1. Onboarding incomplete → redirect to `/onboarding`
2. Not authenticated → redirect to `/auth`
3. Insufficient credit → redirect to `/buy-credit`
4. Already authenticated accessing auth routes → redirect to `/home`

`RouteReevaluationNotifier` (ChangeNotifier) watches auth state + `AppNavigationState` and triggers guard re-evaluation when either changes.

Routes are defined as `CustomRoute` enum in `app_router.dart`. Deeplinks whitelist: `/home`, `/example-feed`, `/profile`, `/buy-credit`.

## Feature Vertical Slice Pattern

Each feature follows this structure (see `example_feed` as reference):

```
feature/{name}/
  domain/       → Repository interface + domain models
  data/         → Repository impl (with cache/retry/connectivity), remote data source, local cache
  application/  → Riverpod AsyncNotifier controller (build → load, refresh, track)
  presentation/ → ConsumerWidget page using AppAsyncView
```

**Repository pattern:** Inject `CachePolicy`, `RetryPolicy`, `ConnectivityService`, `CrashReportingService`. Check cache freshness → check connectivity → retry remote fetch → fallback to stale cache on error → report to crash service.

**Controller pattern:** `@Riverpod(keepAlive: true)` AsyncNotifier. Check `ref.mounted` after every async gap.

**Page pattern:** Use `AppPageScaffold` + `AppAsyncView<T>` for consistent loading/error/empty states.

## Provider Wiring

- `@Riverpod(keepAlive: true)` for long-lived deps: auth, navigation, environment, backend module, runtime services
- `backendModuleProvider` is overridden in `bootstrap()`, not wired directly
- Credit access strategy chosen by `CreditAccessProvider` env key: `navigationSignal` (reads 402/403 from Dio), `backend` (Firebase claims), or `revenueCat`
- Analytics: Mixpanel if token + enabled, otherwise Noop

## Logging System

Tag-based logging via `AppLogger` from `backend_core`:

```dart
static final _log = AppLogger('ClassName', tag: LogTag.auth);
_log.i('message');
_log.e('failed', error: e, stackTrace: st);
```

Tags: `auth`, `network`, `router`, `onboarding`, `credit`, `analytics`, `ui`, `notification`, `general`

Configure per-tag in bootstrap: `logConfig = AppLogConfig(auth: true, network: false);`
Master switch: `logConfig = AppLogConfig(enabled: false);`

## Network Layer

`DioApiClient` (implements `ApiClient` from backend_core):
- Intercepts 401 → attempts token refresh → retries; on failure calls `navigationState.requireLogin()`
- Intercepts 402/403 → calls `navigationState.requireCreditPurchase()` (when using navigationSignal credit strategy)
- Auto-traces HTTP requests via `sentry_dio`

## Sentry

Initialized in `bootstrap()` before everything. Works automatically for uncaught exceptions and Dio traces.

- `SentryService.captureException()` — only for **caught** exceptions worth reporting
- `SentryService.addBreadcrumb()` — before risky operations (payments, file ops)
- `SentryService.setUser()` / `clearUser()` — after login/logout
- Don't capture expected errors (validation, 404s, cancellations)

## Notifications

`NotificationService` interface in backend_core → `LocalNotificationService` implementation. Access via `notificationServiceProvider`. Request permission before showing. Use SnackBar/Dialog for in-app events, not notifications.

## UI Widgets

- `AppCachedImage` — use for ALL network images (never `Image.network()`)
- `AppShimmerBox` / `AppShimmerListTile` — loading skeletons (replace `CircularProgressIndicator`)
- `AppAsyncView<T>` — standard data/loading/error/empty handler for `AsyncValue`
- `AppErrorState` / `AppEmptyState` — consistent error/empty UI with retry
- `AppPageScaffold` — standard page wrapper with AppBar
- `ProjectPadding` — semantic padding constants (`.all`, `.horizontal`, `.vertical`)

## Testing

Test helpers in `test/helpers/`:

```dart
// Widget tests — pumps app with ProviderScope, theme, localization:
await tester.pumpApp(
  const ExampleFeedPage(),
  analyticsService: FakeAnalyticsService(),
  overrides: [apiClientProvider.overrideWithValue(FakeApiClient(...))],
);

// Unit tests — container without widgets:
final container = createTestProviderContainer(backendModule: MockBackendModule());
```

**Fakes** (`test/helpers/fakes/`): `FakeApiClient` (configurable responses), `FakeAnalyticsService` (records `trackedEvents`), `FakeConnectivityService`, `FakeSecureStorageService` (in-memory), `FakePermissionService`, `FakeCrashReportingService`.

**Screen Robots** (`test/helpers/robots/`): Encapsulate finders and actions per page. Example:
```dart
final robot = ExampleFeedRobot(tester);
expect(robot.title, findsOneWidget);
await robot.tapRefresh();
```

**Integration tests** in `integration_test/` — smoke flow with MockBackendModule.

## Environment Config

`.env.example` → copy to `.env.dev` (gitignored). Keys defined in `AppEnvironmentKeys`:

| Key | Purpose |
|-----|---------|
| `APP_ENV` | dev / staging / prod |
| `BACKEND_PROVIDER` | mock / custom / firebase / supabase |
| `CREDIT_ACCESS_PROVIDER` | navigationSignal / backend / revenueCat |
| `CUSTOM_API_BASE_URL` | REST API base URL |
| `SUPABASE_URL` / `SUPABASE_ANON_KEY` | Supabase config |
| `MIXPANEL_TOKEN` / `ANALYTICS_ENABLED` | Analytics |
| `SENTRY_DSN` | Sentry (empty = disabled) |

## Conventions

- Riverpod with code generation (`@riverpod` annotations)
- `very_good_analysis` lint rules (excludes `*.g.dart`, `*.freezed.dart`)
- Turkish-first localization (template: `app_tr.arb`, also `app_en.arb`)
- auto_route for navigation with `CustomRoute` enum
- Analytics tracking happens in repositories/controllers, not views
- `rename.sh` script renames the project across all platform configs (bundle IDs, package names)

## Adding a New Feature

1. Define interface in `backend_core` if backend-specific
2. Implement in relevant backend packages
3. Add factory method to `BackendModule`
4. Create feature vertical slice: domain → data → application → presentation
5. Wire up Riverpod providers
6. Add route to `CustomRoute` enum and `app_router.dart`
7. Add localization strings to `app_tr.arb` + `app_en.arb`
8. Add logging with appropriate `LogTag`
9. Write tests: unit (repository), widget (page + robot), update smoke test
