# Auth Feature Doc

## Purpose
Provides authentication entry flow for the app skeleton.
Current default path is anonymous sign-in for quick project bootstrapping.

## Routes
- `CustomRoute.auth.path`

## State and Providers
- `authControllerProvider`
- `authStateProvider`
- `authRepositoryProvider`
- `tokenRefreshServiceProvider`

## Dependencies
- `product/auth` contracts and adapters
- `product/analytics` for auth events
- `product/navigation` for unauthorized handling

## Extension Points
- Add email/password and social providers.
- Add MFA and session refresh policy.
- Add backend-specific error mapping.

## Open Tasks
- Add form validation flow.
- Add auth error presentation model.
- Implement custom API refresh contract with token store.

## Last Updated
- 2026-03-08
