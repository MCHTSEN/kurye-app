# backend_supabase

Supabase SDK integration for eipat.

## Purpose

Provides Supabase-based implementations of auth and token refresh. Only included in the final binary when building with `flutter run -t lib/main_supabase.dart`.

## File Structure

```
lib/
  backend_supabase.dart                → Barrel export
  src/
    supabase_auth_gateway.dart         → Supabase Auth sign-in/sign-out
    supabase_backend_module.dart       → BackendModule factory + Supabase.initialize()
    supabase_token_refresh_service.dart → Token refresh via refreshSession()
```

## BackendModule Pattern

`SupabaseBackendModule` receives `url` and `anonKey` via constructor. `initialize()` calls `Supabase.initialize(...)`. `createCreditAccessService()` returns `null` (no built-in credit mechanism).

## Note on AuthUser Import

Supabase SDK exports its own `AuthUser` class. The import uses `hide AuthUser` to avoid ambiguity with `backend_core`'s `AuthUser`.

## Adding a New Auth Method

1. Add the method to `AuthGateway` in `backend_core`
2. Implement in `SupabaseAuthGateway` using `_client.auth`
3. Add logging

## Dependency Rules

- Only `supabase_flutter` and `backend_core`
- Never import from the main `eipat` package
