# S03: Order Creation & Customer Tracking

**Goal:** Customer can create orders with cascading dropdowns and see live status updates. Operations sees new orders arrive via Supabase Realtime.
**Demo:** A müşteri_personel user creates an order → it appears in the active orders list with realtime status → operations stream picks up the new order without page refresh. Completed orders appear on the history page with date filtering.

## Must-Haves

- `Siparis` domain model with all DB columns mapped (Geography-free, `ucret` as `double?`)
- `SiparisDurum` enum with 4 values matching DB enum exactly
- `SiparisRepository` abstract contract with `create()`, `getByMusteriId()`, `getByDurum()`, `streamByMusteriId()`, `streamActive()`, `updateDurum()`
- `SupabaseSiparisRepository` using `stream()` API for realtime subscriptions
- `MusteriPersonelRepository.getByUserId()` added to contract + Supabase impl
- BackendModule factory method + barrel exports for Siparis
- Riverpod providers: repo (keepAlive), stream (autoDispose), list (autoDispose)
- Customer order creation page with cascading dropdowns (çıkış, uğrama, uğrama1, not from customer's stops)
- Active orders list below form with realtime updates via `streamByMusteriId`
- Customer history page with date filter showing completed orders
- Domain model unit tests for `Siparis` (fromJson/toJson roundtrip, nullable fields, durum mapping)
- Widget test for `MusteriSiparisPage` covering form render and order creation flow
- `FakeSiparisRepository` in shared test helpers

## Proof Level

- This slice proves: integration (Supabase Realtime stream pattern established)
- Real runtime required: yes (Realtime subscription must work against live Supabase)
- Human/UAT required: no (can be verified via tests + simulator observation)

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all tests pass including new:
  - `test/domain/siparis_test.dart` — fromJson/toJson roundtrip, nullable fields, durum enum
  - `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — form renders with dropdowns, validation rejects empty required fields, submit creates order
- `flutter build ios --simulator` — builds successfully

## Observability / Diagnostics

- Runtime signals: `LogTag.data` in `SupabaseSiparisRepository` for all CRUD and stream lifecycle events
- Inspection surfaces: grep `SupabaseSiparisRepo` in console for all order operations
- Failure visibility: stream connection errors logged at `.e()`, order creation failures surface via `AsyncValue.error` in UI
- Redaction constraints: none (no secrets in order data)

## Integration Closure

- Upstream surfaces consumed: `Musteri`/`Ugrama`/`MusteriPersonel` models and repos from S02, `AppUserProfile.musteriId` from S01, `currentUserProfileProvider` from S01
- New wiring introduced in this slice: `SiparisRepository` on BackendModule, `stream()` realtime pattern (first use), `getByUserId()` on MusteriPersonelRepository
- What remains before the milestone is truly usable end-to-end: S04 (dispatch), S05 (courier workflow), S06-S08

## Tasks

- [ ] **T01: Siparis data layer with realtime stream support** `est:45m`
  - Why: Foundation for all order features — domain model, repository contract, Supabase implementation with stream(), providers, and test infrastructure
  - Files: `packages/backend_core/lib/src/domain/siparis.dart`, `packages/backend_core/lib/src/siparis_repository.dart`, `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`, `packages/backend_core/lib/src/musteri_personel_repository.dart`, `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart`, `packages/backend_core/lib/src/backend_module.dart`, `packages/backend_supabase/lib/src/supabase_backend_module.dart`, `lib/product/siparis/siparis_providers.dart`, `test/domain/siparis_test.dart`, `test/helpers/fakes/fake_siparis_repository.dart`
  - Do: Create `Siparis` model + `SiparisDurum` enum following existing pattern. Add `SiparisRepository` contract with stream methods. Implement Supabase version using `stream(primaryKey: ['id'])` + `.eq()` filters. Add `getByUserId()` to MusteriPersonelRepository contract + impl. Wire BackendModule + barrel exports. Create Riverpod providers (stream providers must be autoDispose). Build domain model tests + `FakeSiparisRepository`.
  - Verify: `flutter analyze` clean, `flutter test` passes including `test/domain/siparis_test.dart`
  - Done when: Siparis model, repo, Supabase impl, providers, and domain tests all exist and pass

- [ ] **T02: Customer order creation and history pages** `est:45m`
  - Why: Replace both placeholder müşteri pages with real functionality — order form with cascading dropdowns + realtime active list, history page with date filter
  - Files: `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`, `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`, `test/feature/musteri_siparis/musteri_siparis_page_test.dart`
  - Do: Replace `MusteriSiparisPage` with: form (çıkış/uğrama/uğrama1/not dropdowns loaded by customer's musteriId, not1 text field), submit handler resolving personel_id via `getByUserId(auth.uid)` and calling `SiparisRepository.create()`, active orders StreamBuilder below form using `streamByMusteriId`. Replace `MusteriGecmisPage` with completed orders list + date range picker filter. Write widget test with `FakeSiparisRepository` covering form render, validation, and order creation.
  - Verify: `flutter analyze` clean, `flutter test` passes including widget test, `flutter build ios --simulator` succeeds
  - Done when: Both pages functional with real data flow, widget test passes, full build succeeds

## Files Likely Touched

- `packages/backend_core/lib/src/domain/siparis.dart`
- `packages/backend_core/lib/src/siparis_repository.dart`
- `packages/backend_core/lib/src/musteri_personel_repository.dart`
- `packages/backend_core/lib/backend_core.dart`
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart`
- `packages/backend_supabase/lib/src/supabase_backend_module.dart`
- `packages/backend_supabase/lib/backend_supabase.dart`
- `lib/product/siparis/siparis_providers.dart`
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`
- `test/domain/siparis_test.dart`
- `test/feature/musteri_siparis/musteri_siparis_page_test.dart`
- `test/helpers/fakes/fake_siparis_repository.dart`
