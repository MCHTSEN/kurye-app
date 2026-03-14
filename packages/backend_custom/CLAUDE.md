# backend_custom

Custom REST API (Dio) backend implementation for eipat.

## Purpose

Provides auth via a custom REST API. Used when no BaaS (Firebase/Supabase) is needed. Default backend for development. Build with `flutter run -t lib/main_custom.dart` or `flutter run` (default).

## File Structure

```
lib/
  backend_custom.dart             → Barrel export
  src/
    custom_api_auth_gateway.dart  → Auth via REST endpoints (/auth/anonymous, /auth/login)
    custom_backend_module.dart    → BackendModule factory (no initialization needed)
    noop_token_refresh_service.dart → No-op (custom APIs handle tokens differently)
```

## Why Its Own Dio Instance

`CustomApiAuthGateway` creates its own simple `Dio` instance for auth-only calls. This is separate from the app-level `DioApiClient` (which has interceptors for token refresh, unauthorized handling, and credit checking). This avoids circular dependencies: the app's `DioApiClient` depends on `TokenRefreshService`, which comes from `BackendModule`, which creates `CustomApiAuthGateway`.

## API Contract

- `POST /auth/anonymous` → `{ "userId": "..." }` (optional, falls back to local guest ID)
- `POST /auth/login` → `{ "userId": "..." }` (required)

## Adding a New Auth Method

1. Add the method to `AuthGateway` in `backend_core`
2. Implement in `CustomApiAuthGateway` with appropriate API call
3. Add logging

## Dependency Rules

- Only `dio` and `backend_core`
- Never import from the main `eipat` package
