# New Project Checklist

Use this checklist when starting a new project from this skeleton.

## 1. Rename the project

```bash
./rename.sh com.yourcompany.appname "App Display Name"
```

This updates: package name, bundle ID, app display name, and Dart package references.

## 2. Choose your backend

Delete unused backend packages and entry points:

| Backend | Keep | Delete |
|---------|------|--------|
| Firebase | `packages/backend_firebase/`, `lib/main_firebase.dart` | `packages/backend_supabase/`, `packages/backend_custom/`, other `main_*.dart` |
| Supabase | `packages/backend_supabase/`, `lib/main_supabase.dart` | `packages/backend_firebase/`, `packages/backend_custom/`, other `main_*.dart` |
| Custom API | `packages/backend_custom/`, `lib/main_custom.dart` | `packages/backend_firebase/`, `packages/backend_supabase/`, other `main_*.dart` |

Update `pubspec.yaml` workspace list and dependencies accordingly.

## 3. Configure environment

Edit `lib/core/environment/app_environment.dart`:
- Set default `customApiBaseUrl`
- Configure `creditAccessProvider`
- Set `mixpanelToken` or disable analytics

## 4. Set up authentication

- [ ] Configure your backend's auth (Firebase Console / Supabase Dashboard / API server)
- [ ] If using Google Sign-In: add `google_sign_in` to pubspec, configure OAuth client IDs
- [ ] Update `AuthPage` to wire up `_handleGoogleSignIn` with real `google_sign_in` calls

## 5. Set up payments (if needed)

- [ ] Choose payment provider: RevenueCat or native IAP
- [ ] Add SDK dependency (`purchases_flutter` or `in_app_purchase`)
- [ ] Replace stub in `RevenueCatPaymentService` or `IapPaymentService`
- [ ] Override `createPaymentService()` in your `BackendModule`

## 6. Configure analytics

- [ ] Set Mixpanel token in dart-define or environment
- [ ] Review `AppEvents` catalog and add project-specific events
- [ ] Remove unused events from `app_events.dart`

## 7. Customize UI

- [ ] Update `app_theme.dart` with brand colors
- [ ] Replace app icon (use `flutter_launcher_icons`)
- [ ] Replace splash screen (use `flutter_native_splash`)
- [ ] Update localization files (`lib/l10n/app_tr.arb`, `app_en.arb`)

## 8. Clean up

- [ ] Remove this checklist file
- [ ] Remove `e-ipat-web-doc/` if not relevant
- [ ] Update `CLAUDE.md` with project-specific info
- [ ] Remove unused routes from `CustomRoute` enum
- [ ] Run `flutter analyze` and fix any issues
- [ ] Run `flutter test` and verify all tests pass

## 9. Platform setup

### iOS
- [ ] Set deployment target in `ios/Podfile` (minimum 13.0)
- [ ] Configure signing in Xcode
- [ ] Add required capabilities (push notifications, etc.)

### Android
- [ ] Set `minSdkVersion` in `android/app/build.gradle`
- [ ] Configure signing keys
- [ ] Add required permissions in `AndroidManifest.xml`
