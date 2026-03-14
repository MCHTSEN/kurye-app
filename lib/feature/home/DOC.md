# Home Feature Doc

## Purpose
Default authenticated landing area for the skeleton.

## Routes
- `CustomRoute.home.path`

## State and Providers
- `authControllerProvider` (sign-out action)
- `appNavigationStateProvider` (guard re-evaluation source)

## Dependencies
- `product/widgets`
- `product/auth`
- `app/router` guard policies
- `feature/example_feed` route entry point

## Extension Points
- Feature modules dashboard.
- Personalized recommendations.
- Entry points for notifications and experiments.

## Open Tasks
- Add home data source contract.
- Add loading and empty states.
- Add "credit required" CTA scenario hooks.
- Keep template feature shortcuts discoverable but lightweight.

## Last Updated
- 2026-03-08
