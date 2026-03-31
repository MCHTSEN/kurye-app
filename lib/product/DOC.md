# Product Layer Doc

## Purpose
- Compose reusable application services via Riverpod.
- Bridge `core` contracts with concrete adapters used by features.

## Scope
- `analytics`: `AnalyticsService` provider composition.
- `auth`: multi-backend auth gateway/repository strategy.
- `credit`: central credit access strategy for route guard decisions.
- `environment`: runtime environment provider.
- `initialization`: startup SDK initialization by backend selection.
- `navigation`: mutable app access signals and route reevaluation.
- `network`: `ApiClient` provider and interceptor wiring.
- `onboarding`: onboarding persistence adapter and providers.
- `runtime`: providers and adapters for secure storage, connectivity,
  feature flags, crash reporting, permissions, cache policy, and retry
  policy.
- `ugrama`: müşteri bağlamında uğrama çözümleme/atama/oluşturma orchestrator'ı.
- `riverpod`: provider observer and Riverpod runtime utilities.
- `widgets`: reusable UI components with doc contract.

## Riverpod Best Practices Applied
- Keep providers at composition boundaries (`product`), not in `core`.
- Use `ref.mounted` checks after async transitions in notifiers.
- Use `select` on UI consumers for targeted rebuilds.
- Use `ProviderObserver` for centralized provider error visibility.
- Keep external SDKs behind provider-driven adapters/contracts.

## Credit Guard Strategy
- `CreditAccessService` decides if user can proceed without buy-credit redirect.
- Select strategy with `CREDIT_ACCESS_PROVIDER`:
  - `navigationSignal`: use centralized network signal (`402/403`).
  - `firebaseClaims`: read Firebase custom claims.
  - `revenueCat`: override `revenueCatCreditAvailabilityCheckerProvider`.
- Guard reads credit access provider directly; decision is not forced to Dio.

## Rules
- Feature modules must depend on `product` contracts/providers, not SDKs.
- New reusable service modules must include local docs and tests.
- Mock/test-only adapters are allowed when they stay behind the same
  contracts used by production providers.

## Last Updated
- 2026-03-31
