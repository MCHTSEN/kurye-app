---
id: T03
parent: S02
milestone: M001
provides:
  - RolOnayPage — approval screen for pending role requests with müşteri selection for personel role
  - approveRequest contract extended with optional musteriId parameter
  - FakeMusteriRepository shared test helper
  - rolOnay route and drawer navigation
key_files:
  - lib/feature/operasyon/presentation/rol_onay_page.dart
  - packages/backend_core/lib/src/role_request_repository.dart
  - packages/backend_supabase/lib/src/supabase_role_request_repository.dart
  - test/helpers/fakes/fake_musteri_repository.dart
key_decisions:
  - "Used initialValue instead of deprecated value for DropdownButtonFormField (Flutter 3.41+)"
  - "Extracted FakeMusteriRepository from inline test class to shared helper at test/helpers/fakes/"
  - "Reject flow uses dialog for optional reason — null cancels, empty string means no reason"
patterns_established:
  - "Approval screen pattern: ConsumerStatefulWidget with _musteriSelections map tracking per-request dropdown state; _RequestCard as ConsumerWidget for individual cards with approve/reject actions"
  - "Role-specific approval logic: müşteri_personel requires müşteri dropdown selection before approval — enforced in _approve with early return + SnackBar message"
observability_surfaces:
  - "AppLogger with LogTag.auth logs musteriId in approval (SupabaseRoleRequestRepository)"
  - "SnackBar feedback on approve/reject success and failure"
duration: 20min
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T03: Role approval screen, approval flow fix, and test coverage

**Built RolOnayPage with approve/reject for pending role requests, extended approveRequest contract with musteriId, extracted shared fake repository, and verified all 65 tests pass.**

## What Happened

Extended `RoleRequestRepository.approveRequest()` to accept optional `musteriId` — updates both the abstract contract in `backend_core` and the Supabase implementation to include `musteri_id` in the `app_users` upsert when provided.

Created `RolOnayPage` as a `ConsumerStatefulWidget` that watches `pendingRoleRequestsProvider` (realtime stream). Each pending request renders as an `AppSectionCard` with display name, phone, role, note, and date. For `musteri_personel` requests, a `DropdownButtonFormField` populated from `musteriListProvider` is shown — selection is required before approval. Reject shows a dialog for an optional reason.

Added `rolOnay` route to `CustomRoute` enum and `app_router.dart`. Added "Rol Onayları" drawer item with `Icons.how_to_reg` to the operasyon dashboard.

Domain model tests (musteri, ugrama, musteri_personel, kurye) already existed from T02. Extracted `FakeMusteriRepository` from the inline private class in the widget test to `test/helpers/fakes/fake_musteri_repository.dart` and updated the widget test to use it.

## Verification

- `flutter analyze` — 6 issues (all pre-existing, none from T03)
- `flutter test` — 65/65 pass
- `flutter test test/domain/` — 14 tests pass (4 model files + user_role)
- `flutter test test/feature/operasyon/` — 4 widget tests pass
- Slice-level verification: all checks pass

## Diagnostics

- `AppLogger` with `LogTag.auth` logs approval with musteriId context
- SnackBar messages surface approve/reject outcomes
- Supabase exceptions propagate through `AsyncValue.error` for the pending requests stream
- Dropdown validation enforced client-side before calling repository

## Deviations

- Domain model tests (step 5) already existed from T02 — no new test files created, only verified they pass
- Widget test (step 6) also existed from T02 — extracted the inline fake to shared helper and updated imports

## Known Issues

None.

## Files Created/Modified

- `packages/backend_core/lib/src/role_request_repository.dart` — added optional `musteriId` to `approveRequest`
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — handles `musteriId` in `app_users` upsert
- `lib/feature/operasyon/presentation/rol_onay_page.dart` — new approval screen (created)
- `lib/app/router/custom_route.dart` — added `rolOnay` route
- `lib/app/router/app_router.dart` — registered `RolOnayPage` route, fixed import ordering
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — added Rol Onayları drawer item
- `test/helpers/fakes/fake_musteri_repository.dart` — extracted shared fake (created)
- `test/feature/operasyon/musteri_kayit_page_test.dart` — updated to use shared `FakeMusteriRepository`
