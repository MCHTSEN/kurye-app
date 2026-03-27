# S01: iPhone 17 Runtime Readiness

**Goal:** Establish the requested runtime surface on iPhone 17 simulator and verify the app can boot, authenticate, and be inspected reliably with supporting local browser access.
**Demo:** the app can be launched and interacted with on iPhone 17 simulator, and the supporting local browser path is usable for debugging the same system.

## Must-Haves

- The app launches on iPhone 17 simulator using the intended live runtime entrypoint.
- Core entry navigation and login paths for test roles can be reached and observed.
- A local browser path is available for the same app system where it helps diagnose runtime issues.
- Runtime blockers discovered here are captured with concrete evidence for the next slice.

## Proof Level

- This slice proves: Operational proof on target simulator plus supporting local browser evidence.

## Integration Closure

Simulator runtime and browser support path are both ready to feed the live cross-role loop slice.

## Verification

- Creates baseline evidence for launchability, interaction reliability, and runtime failure surfaces.

## Tasks

- [ ] **T01: Inspect runtime entrypoints and verification prerequisites** `est:45m`
  Read the live runtime entrypoint, auth quick-login surfaces, and existing verification artifacts to confirm the exact app start path, role accounts, and known preconditions for iPhone 17 simulator verification. Record any missing prerequisites before launch attempts.
  - Files: `lib/main_supabase.dart`, `lib/app/bootstrap.dart`, `lib/feature/auth/presentation/auth_page.dart`, `UAT-CHECKLIST.md`, `uat-recordings/UAT-FULL-TEST-PLAN.md`
  - Verify: Artifact and source inspection completed; launch prerequisites listed in task summary.

- [ ] **T02: Prove iPhone 17 simulator launch and basic interaction path** `est:90m`
  Launch the app on the iPhone 17 simulator, verify it boots into the live Supabase runtime, and drive the first reliable interaction path through auth/landing surfaces. Capture concrete evidence for what works and what fails.
  - Files: `ios/Runner.xcodeproj/project.pbxproj`, `lib/main_supabase.dart`, `lib/feature/auth/presentation/auth_page.dart`
  - Verify: Live simulator launch evidence plus observed UI interaction path recorded in task summary.

- [ ] **T03: Stand up browser-supported local verification path** `est:60m`
  Run the local browser-accessible app path, confirm it targets the same system, and capture where browser verification helps diagnosis without replacing mobile proof. Leave a concrete local URL and usage notes for later slices.
  - Files: `lib/main_supabase.dart`, `web/index.html`, `integration_test/app_smoke_test.dart`
  - Verify: Local browser runtime reachable and supporting verification notes captured.

## Files Likely Touched

- lib/main_supabase.dart
- lib/app/bootstrap.dart
- lib/feature/auth/presentation/auth_page.dart
- UAT-CHECKLIST.md
- uat-recordings/UAT-FULL-TEST-PLAN.md
- ios/Runner.xcodeproj/project.pbxproj
- web/index.html
- integration_test/app_smoke_test.dart
