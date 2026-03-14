---
estimated_steps: 6
estimated_files: 12
---

# T03: Role approval screen, approval flow fix, and test coverage

**Slice:** S02 — Master Data CRUD
**Milestone:** M001

## Description

Complete the slice with the role request approval screen (the fifth S02 deliverable), fix the `approveRequest` flow to handle `musteri_id` for müşteri_personel role, and add unit/widget tests that prove the data layer contracts work correctly.

## Steps

1. Extend `RoleRequestRepository.approveRequest()` in `backend_core`:
   - Add optional `String? musteriId` parameter
   - Update abstract contract

2. Update `SupabaseRoleRequestRepository.approveRequest()`:
   - When `musteriId` is provided, include `'musteri_id': musteriId` in the `app_users` upsert
   - Log the musteriId assignment

3. Create `RolOnayPage` (`lib/feature/operasyon/presentation/rol_onay_page.dart`):
   - `ConsumerWidget` watching `pendingRoleRequestsProvider` (already exists)
   - Show each pending request as a card with: displayName, phone, requestedRole, createdAt
   - Approve button + reject button per request
   - For `musteri_personel` requests: show a müşteri `DropdownButtonFormField` (from `musteriListProvider`) — required before approval
   - On approve: call `roleRequestRepository.approveRequest(requestId: ..., reviewerId: currentUserId, musteriId: selectedMusteriId)`
   - On reject: call `roleRequestRepository.rejectRequest(...)` with optional reason dialog

4. Add role approval access to the dashboard:
   - Add a drawer item "Rol Onayları" with `Icons.how_to_reg` pointing to `RolOnayPage`
   - Add the route to `CustomRoute` enum (`rolOnay('/operasyon/rol-onay')`) and register in `app_router.dart`
   - Or embed pending request count badge on the drawer item

5. Write domain model unit tests:
   - `test/domain/musteri_test.dart` — fromJson roundtrip, toJson output, required field validation, optional fields null
   - `test/domain/ugrama_test.dart` — fromJson roundtrip, lokasyon not in model (Geography skipped gracefully)
   - `test/domain/musteri_personel_test.dart` — fromJson roundtrip, userId nullable
   - `test/domain/kurye_test.dart` — fromJson roundtrip, isOnline defaults

6. Create fake repositories and write one widget test:
   - `test/helpers/fakes/fake_musteri_repository.dart` — in-memory CRUD implementation
   - `test/feature/operasyon/musteri_kayit_page_test.dart` — test that page renders list when data is loaded (pumps page with fake repository override, verifies list items appear)

## Must-Haves

- [ ] `approveRequest` accepts optional `musteriId` — contract + Supabase impl updated
- [ ] `RolOnayPage` shows pending requests, approve/reject works
- [ ] Müşteri_personel approval requires müşteri selection
- [ ] Route and drawer item for role approval added
- [ ] 4 domain model test files with fromJson/toJson roundtrip assertions
- [ ] At least one fake repository for test infra
- [ ] At least one widget test for a CRUD page
- [ ] `flutter analyze` clean, `flutter test` all pass

## Verification

- `flutter analyze` — 0 issues
- `flutter test` — all tests pass (existing + new)
- `flutter test test/domain/` — 4+ new model tests pass
- `flutter test test/feature/operasyon/` — widget test passes

## Inputs

- `packages/backend_core/lib/src/role_request_repository.dart` — existing contract to extend
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — existing impl to modify
- `lib/product/role_request/role_request_providers.dart` — `pendingRoleRequestsProvider` already exists
- `lib/product/musteri/musteri_providers.dart` — T01 output, for müşteri dropdown in approval screen
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — T02 output, widget test target
- `test/helpers/providers/test_provider_container.dart` — test infrastructure for provider overrides
- `test/domain/user_role_test.dart` — existing test pattern to follow

## Expected Output

- `packages/backend_core/lib/src/role_request_repository.dart` — `approveRequest` has `musteriId` parameter
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — handles `musteriId` in upsert
- `lib/feature/operasyon/presentation/rol_onay_page.dart` — new approval screen
- `lib/app/router/custom_route.dart` — `rolOnay` route added
- `lib/app/router/app_router.dart` — route registered
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — drawer item for rol onay
- `test/domain/musteri_test.dart` — Musteri model tests
- `test/domain/ugrama_test.dart` — Ugrama model tests
- `test/domain/musteri_personel_test.dart` — MusteriPersonel model tests
- `test/domain/kurye_test.dart` — Kurye model tests
- `test/helpers/fakes/fake_musteri_repository.dart` — fake for test infra
- `test/feature/operasyon/musteri_kayit_page_test.dart` — widget test
