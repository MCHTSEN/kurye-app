# Buy Credit Feature Doc

## Purpose
Handles upsell/paywall flow when user account has insufficient credit.

## Routes
- `CustomRoute.buyCredit.path`

## State and Providers
- `creditAccessServiceProvider` for guard-level credit decision
- `appNavigationStateProvider` for network-driven `requiresCreditPurchase` signal

## Dependencies
- `app/router` credit guard and redirects
- Payment integrations (future)

## Extension Points
- In-app purchase providers.
- Subscription and credit packages.
- Campaign and offer experiments.

## Open Tasks
- Add checkout domain model and repository.
- Add payment adapter abstraction.

## Last Updated
- 2026-03-08
