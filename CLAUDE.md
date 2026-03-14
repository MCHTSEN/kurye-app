# eipat — Reusable Flutter Skeleton

Multi-backend mobile app skeleton with monorepo architecture.

## Project Architecture

```
eipat/                          → Main Flutter app
packages/
  backend_core/                 → Interfaces, domain models, logging (pure Dart)
  backend_firebase/             → Firebase implementation
  backend_supabase/             → Supabase implementation
  backend_custom/               → Custom REST API implementation (default)
```

## Backend Selection (Compile-Time)

Backend is selected via entry point, not runtime config:

```bash
flutter run                                    # Custom API (default)
flutter run -t lib/main_firebase.dart          # Firebase
flutter run -t lib/main_supabase.dart          # Supabase
flutter run -t lib/main_custom.dart            # Custom API (explicit)
```

Only the selected backend's SDK is included in the final binary.

## Logging System

Tag-based logging via `AppLogger` from `backend_core`:

```dart
static final _log = AppLogger('ClassName', tag: LogTag.auth);
_log.i('message');
_log.e('failed', error: e, stackTrace: st);
```

Tags: `auth`, `network`, `router`, `onboarding`, `credit`, `analytics`, `ui`, `notification`, `general`

Configure in bootstrap:
```dart
logConfig = AppLogConfig(auth: true, network: false, router: false);
```

Master switch in release mode: `logConfig = AppLogConfig(enabled: false);`

## Provider Wiring

`BackendModule` is provided via `backendModuleProvider` override in `bootstrap()`. Auth, token refresh, and credit services are created from the module:

```dart
// auth_providers.dart
AuthGateway authGateway(Ref ref) =>
    ref.watch(backendModuleProvider).createAuthGateway();
```

## Sentry (Crash Reporting & Performance)

Sentry is initialized in `bootstrap()` before everything else. It works automatically — no manual setup needed per feature.

**When to use:**
- Error handlers already report uncaught exceptions automatically
- Dio HTTP requests are traced as performance spans automatically via `sentry_dio`
- Use `SentryService.captureException()` only for **caught** exceptions that should still be reported
- Use `SentryService.addBreadcrumb()` before risky operations (payment flows, file operations, complex state transitions) to provide context when crashes happen
- Call `SentryService.setUser()` after login and `SentryService.clearUser()` after logout

**When NOT to use:**
- Don't capture expected errors (validation failures, 404s, user cancellations)
- Don't add breadcrumbs for routine operations (every button tap, every navigation)

```dart
// After successful login:
SentryService.setUser(id: user.id, email: user.email);

// Before a risky operation:
SentryService.addBreadcrumb(
  message: 'Starting payment',
  category: 'payment',
  data: {'productId': id, 'amount': amount},
);

// Caught exception that should still be reported:
try {
  await riskyOperation();
} on Exception catch (e, st) {
  SentryService.captureException(e, stackTrace: st);
  // show user-friendly error
}
```

**Config:** Set `SENTRY_DSN` in the env file (see Environment Config below). Empty DSN = Sentry disabled (safe for local dev).

## Local Notifications

`NotificationService` interface in `backend_core`, implemented by `LocalNotificationService`. Access via `notificationServiceProvider`.

**When to use:**
- Background task completion (download finished, sync complete)
- Scheduled reminders
- Local alerts that don't come from a server

**When NOT to use:**
- Don't show notifications for in-app events while user is already looking at the screen — use SnackBar/Dialog instead
- Don't show notifications without requesting permission first

```dart
// Request permission (do this once, e.g., in onboarding or first relevant action):
final granted = await ref.read(notificationServiceProvider).requestPermission();

// Show a notification:
await ref.read(notificationServiceProvider).show(
  NotificationMessage(title: 'Download complete', body: 'Your file is ready'),
);

// Listen to notification taps for navigation:
ref.listen(notificationServiceProvider, (_, service) {
  service.onMessageTapped.listen((message) {
    // Navigate based on message.data
  });
});
```

## Image Caching & Shimmer Loading

**Widgets:** `AppCachedImage`, `AppShimmerBox`, `AppShimmerListTile`

**When to use `AppCachedImage`:**
- Every network image in the app — never use `Image.network()` directly
- Profile pictures, feed images, product thumbnails, banners

```dart
AppCachedImage(
  imageUrl: user.avatarUrl,
  width: 48,
  height: 48,
  borderRadius: BorderRadius.circular(24), // circular avatar
)

AppCachedImage(
  imageUrl: item.coverUrl,
  height: 200, // full-width banner
)
```

**When to use `AppShimmerBox` / `AppShimmerListTile`:**
- Loading states for any content area — replace `CircularProgressIndicator` with shimmer skeletons
- Use `AppShimmerListTile()` for list loading states
- Use `AppShimmerBox.card()` for card loading states
- Use `AppShimmerBox(width: 120, height: 14)` for inline text loading

```dart
// List loading state:
asyncValue.when(
  data: (items) => ListView.builder(...),
  loading: () => Column(
    children: List.generate(5, (_) => const AppShimmerListTile()),
  ),
  error: (e, st) => AppErrorState(...),
)

// Card loading:
isLoading ? const AppShimmerBox.card() : ActualCard(...)
```

**When NOT to use shimmer:**
- Very short loading times (<200ms) — shimmer flash is worse than nothing
- Full-page loading where a single centered spinner is more appropriate (e.g., splash)

## Adding a New Feature

1. Define interface in `backend_core` if it's backend-specific
2. Implement in each backend package that supports it
3. Add factory method to `BackendModule`
4. Wire up provider in the main app
5. Add logging with appropriate `LogTag`

## Environment Config (API Keys, DSNs)

Per-environment `.env` files with `--dart-define-from-file`:

```
.env.example    → Template (committed to git)
.env.dev        → Local development (gitignored)
.env.staging    → Staging (gitignored)
.env.prod       → Production (gitignored)
```

**New project setup:**
1. Copy `.env.example` to `.env.dev`
2. Fill in real values for your project
3. Create `.env.staging` and `.env.prod` when ready

**Available keys** (defined in `AppEnvironmentKeys`):

| Key | Example | Purpose |
|-----|---------|---------|
| `APP_ENV` | `dev` / `staging` / `prod` | App flavor |
| `BACKEND_PROVIDER` | `mock` / `custom` / `firebase` / `supabase` | Backend selection |
| `CREDIT_ACCESS_PROVIDER` | `navigationSignal` / `backend` / `revenueCat` | Credit strategy |
| `CUSTOM_API_BASE_URL` | `https://api.example.com` | REST API base URL |
| `SUPABASE_URL` | `https://xxx.supabase.co` | Supabase project URL |
| `SUPABASE_ANON_KEY` | `eyJ...` | Supabase anon key |
| `MIXPANEL_TOKEN` | `abc123` | Mixpanel project token |
| `ANALYTICS_ENABLED` | `true` / `false` | Enable analytics |
| `SENTRY_DSN` | `https://xxx@sentry.io/123` | Sentry DSN (empty = disabled) |

**CI/CD:** Generate `.env.prod` from secrets in your CI pipeline before build.

## Key Commands

```bash
flutter run --dart-define-from-file=.env.dev                          # Run with dev config
flutter run --dart-define-from-file=.env.staging                      # Run with staging config
flutter build apk --dart-define-from-file=.env.prod                   # Production build
flutter run -t lib/main_firebase.dart --dart-define-from-file=.env.dev  # Firebase backend + dev config
flutter pub get                    # Resolve workspace dependencies
dart run build_runner build --delete-conflicting-outputs  # Regenerate Riverpod code
flutter analyze                    # Static analysis (must be 0 issues)
flutter test                       # Run all tests
```

## Conventions

- Riverpod with code generation (`@riverpod` annotations)
- `very_good_analysis` lint rules
- Turkish-first localization (template: `app_tr.arb`)
- auto_route for navigation with `CustomRoute` enum
