# backend_firebase

Firebase SDK integration for eipat.

## Purpose

Provides Firebase-based implementations of auth, token refresh, and credit access services. Only included in the final binary when building with `flutter run -t lib/main_firebase.dart`.

## File Structure

```
lib/
  backend_firebase.dart                      → Barrel export
  src/
    firebase_auth_gateway.dart               → Firebase Auth sign-in/sign-out
    firebase_backend_module.dart             → BackendModule factory + Firebase.initializeApp()
    firebase_claims_credit_access_service.dart → Credit check via custom claims
    firebase_token_refresh_service.dart      → Token refresh via getIdToken(true)
```

## BackendModule Pattern

`FirebaseBackendModule.initialize()` calls `Firebase.initializeApp()`. Factory methods create gateway instances using `FirebaseAuth.instance`.

## Adding a New Auth Method (e.g., Google Sign-In)

1. Add the method to `AuthGateway` in `backend_core`
2. Implement in `FirebaseAuthGateway` using the Firebase SDK
3. Add `_log.i(...)` calls for observability
4. Update tests

## Adding a New Firebase Feature (e.g., Firestore)

1. Add dependency to `pubspec.yaml` (e.g., `cloud_firestore`)
2. Create service class in `lib/src/`
3. Add factory method to `FirebaseBackendModule`
4. Export from barrel file
5. Wire up in the main app's providers

## Test Pattern

Mock `FirebaseAuth` for unit tests. Use `firebase_auth_mocks` or manual fakes.

## Dependency Rules

- Only `firebase_*` packages and `backend_core`
- Never import from the main `eipat` package
