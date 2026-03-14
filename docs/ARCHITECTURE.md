# Architecture

## Goals
- Reusable mobile skeleton for next projects.
- Multi-backend compatibility (`mock`, `custom`, `supabase`,
  `firebase`).
- Mandatory analytics instrumentation through an abstraction.
- Doc-first development flow to reduce repetitive implementation work.
- Auditable change history through `BACKLOG.md`.

## Layers
- `core`: environment, constants, theme, network and analytics primitives.
- `product`: reusable implementations and adapters shared by features.
- `feature`: user-facing app modules (auth, onboarding, home, profile).

## Documentation Flow
- Layer docs:
  - `lib/core/DOC.md`
  - `lib/product/DOC.md`
- Every feature folder contains `DOC.md`.
- Every presentation folder contains `SCREENS.md`.
- Shared widgets are documented in `product/widgets/WIDGETS.md`.
- Before widget implementation/refactor, read and update relevant docs first.

## Audit Flow
- Significant changes are appended to root `BACKLOG.md`.
- Backlog entries include date, scope, summary, touched files, and validation result.

## Runtime Composition
- `main.dart` -> `bootstrap()`
- `bootstrap()` reads environment and chooses a backend module.
- `ProviderScope` injects environment and all runtime dependencies.
- `auto_route` router with centralized guard enforces onboarding/auth/credit flows.

## Central Access Control
- `AppAccessGuard` is the single policy gate for:
  - unauthenticated access
  - onboarding completion
  - insufficient credit rerouting
- `AppNavigationState` receives centralized runtime signals (401/credit events).
- `RouteReevaluationNotifier` triggers router re-check when auth/nav state changes.
- Route names/paths are represented by `CustomRoute` enum for type-safe usage.
- `CreditAccessService` is selected by environment and can evaluate credit via:
  - network signal (`402/403` -> navigation flag)
  - Firebase claims
  - RevenueCat checker provider override

## UI Token Rule
- Screen and section paddings use `ProjectPadding` constants.
- Avoid direct `EdgeInsets.*` in feature widgets unless there is a documented exception.

## Backend Strategy
- `AuthGateway` contract isolates backend SDK details.
- Implementations:
  - `MockBackendModule`
  - `CustomApiAuthGateway`
  - `SupabaseAuthGateway`
  - `FirebaseAuthGateway`
- `BACKEND_PROVIDER` determines which backend stack is active.
- Mock mode is the zero-setup path for local demos, widget tests, and
  integration smoke tests.

## Analytics Strategy
- `AnalyticsService` contract is the only analytics entry point.
- `MixpanelAnalyticsService` and `NoopAnalyticsService` available.
- `AnalyticsRouteObserver` sends standardized screen events from navigator level.

## Runtime Services Strategy
- Runtime service contracts live in `core/runtime`.
- Concrete providers live in `product/runtime`.
- Default reusable services:
  - secure storage
  - connectivity state
  - feature flags
  - crash reporting
  - app permissions
  - cache policy
  - retry policy

## Testing Strategy
- Shared test helpers live under `test/helpers`.
- Prefer provider override helpers and fake builders over ad-hoc setup.
- Widget tests should use screen robots for critical flows.
- Keep at least one smoke `integration_test` flow wired to the mock backend.

## Example Vertical Slice
- `feature/example_feed` demonstrates the expected feature shape:
  remote data source -> repository -> controller -> page -> analytics ->
  tests.
- The slice also demonstrates cache/retry/runtime-service composition.

## Riverpod 3 Strategy
- Composition providers in `product`, pure contracts in `core`.
- `select` is used for targeted UI rebuilds.
- Async notifiers use `ref.mounted` before post-await state updates.
- `ProviderObserver` logs provider failures in debug runtime.
