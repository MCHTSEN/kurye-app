# Home Feature Doc

## Purpose
Default authenticated landing area for the skeleton.
Also hosts the in-app onboarding state for authenticated users whose role
request is still pending approval.

Pending customer-personnel users land here first even when they already have a
linked `musteri_id`. This gives the app a usable post-signup experience before
operational approval.

## Routes
- `CustomRoute.home.path`

## State and Providers
- `authControllerProvider` (sign-out action)
- `appNavigationStateProvider` (guard re-evaluation source)
- `currentUserProfileProvider` (profile state, including provisional users)
- `myRoleRequestProvider` (latest role request summary)
- `MusteriRepository` / customer-by-id provider (firm setup for new-customer signup)

## Dependencies
- `product/widgets`
- `product/auth`
- `app/router` guard policies
- `feature/example_feed` route entry point

## Extension Points
- Feature modules dashboard.
- Personalized recommendations.
- Entry points for notifications and experiments.
- Pending-account in-app messaging and support actions.
- Provisional customer setup card for self-serve company onboarding.

## Open Tasks
- Add home data source contract.
- Add loading and empty states.
- Add "credit required" CTA scenario hooks.
- Keep template feature shortcuts discoverable but lightweight.
- Consider a dedicated self-serve onboarding step if home grows further.

## Last Updated
- 2026-04-12
