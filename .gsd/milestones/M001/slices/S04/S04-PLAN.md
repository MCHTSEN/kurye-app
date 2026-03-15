# S04: Operations Dispatch Screen

**Goal:** Operations can create orders, assign couriers from a waiting queue, and finish orders with auto-pricing — all on a single 3-panel dispatch screen with realtime updates.
**Demo:** Create an order as operasyon → it appears in "Kurye Bekleyenler" panel → select it with checkbox, pick a courier, assign → order moves to "Devam Edenler" panel → select it, press Bitir → order completes with auto-populated price from most recent matching historical order. All transitions happen in realtime without page refresh. Status change is logged in `siparis_log`.

## Must-Haves

- `SiparisRepository` extended with `update()` (partial field update for courier assignment, pricing, timestamps) and `getRecentPricing()` (auto-pricing query)
- `SiparisLog` domain model + `SiparisLogRepository` contract + Supabase implementation, wired into `BackendModule`
- Composite index migration `idx_siparisler_pricing` for auto-pricing query performance
- `FakeKuryeRepository` for test isolation
- 3-panel `OperasyonEkranPage`: order creation form (top), kurye bekleyenler (bottom-left/first), devam edenler (bottom-right/second)
- Order creation form with müşteri dropdown → cascading stop dropdowns (same pattern as customer form but with müşteri selector first)
- Checkbox selection + courier assignment dropdown + "Ata" button in kurye bekleyenler panel
- Checkbox selection + "Bitir" button in devam edenler panel with auto-pricing from `getRecentPricing()`
- Warning shown when auto-pricing finds no match — operasyon enters price manually
- `SiparisLog` created on every status change (kurye_bekliyor → devam_ediyor, devam_ediyor → tamamlandi)
- Both panels fed from single `siparisStreamActiveProvider`, split client-side by durum
- Domain model unit tests for `SiparisLog`
- Widget tests for the dispatch screen (panel rendering, courier assignment flow, finish flow)

## Proof Level

- This slice proves: integration (data layer ↔ UI ↔ realtime stream)
- Real runtime required: yes (Supabase Realtime for cross-role proof in S08, but widget tests prove UI logic)
- Human/UAT required: no (deferred to S08 cross-role integration)

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all tests pass including:
  - `test/domain/siparis_log_test.dart` — SiparisLog fromJson/toJson roundtrip
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` — 3-panel rendering, courier assignment, finish with auto-pricing, manual pricing fallback
- `flutter build ios --simulator` — succeeds
- `FakeSiparisRepository` supports `update()` and `getRecentPricing()` — used by widget tests

## Observability / Diagnostics

- Runtime signals: `LogTag.data` on `SupabaseSiparisLogRepo` for log inserts, `SupabaseSiparisRepo` for `update()` and `getRecentPricing()` calls
- Inspection surfaces: `siparis_log` table — query to see all status transitions with timestamps and actor IDs
- Failure visibility: auto-pricing miss logged at `.w()` level with musteri+cikis+ugrama context; assignment and finish failures surface via SnackBar + `.e()` log
- Redaction constraints: none

## Integration Closure

- Upstream surfaces consumed: `SiparisRepository` (S03), `Musteri/Ugrama/Kurye` models and providers (S02), `siparisStreamActiveProvider` (S03), `currentUserProfileProvider` (S01)
- New wiring introduced: `SiparisLogRepository` on `BackendModule`, `update()` and `getRecentPricing()` on `SiparisRepository`, kurye list provider for assignment dropdown
- What remains before milestone is truly usable end-to-end: S05 (courier workflow), S06 (order history), S07 (analytics), S08 (cross-role integration)

## Tasks

- [x] **T01: Extend data layer with update, auto-pricing, and SiparisLog** `est:45m` ✅
  - Why: The 3-panel UI needs `SiparisRepository.update()` for courier assignment fields, `getRecentPricing()` for auto-pricing, and `SiparisLogRepository` for audit trail. Also needs `FakeKuryeRepository` for widget test isolation and a composite index for pricing query performance.
  - Files: `packages/backend_core/lib/src/siparis_repository.dart`, `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`, `packages/backend_core/lib/src/domain/siparis_log.dart`, `packages/backend_core/lib/src/siparis_log_repository.dart`, `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart`, `packages/backend_core/lib/src/backend_module.dart`, `test/helpers/fakes/fake_siparis_repository.dart`, `test/helpers/fakes/fake_kurye_repository.dart`, `test/domain/siparis_log_test.dart`
  - Do: (1) Add `update()` and `getRecentPricing()` to `SiparisRepository` contract. (2) Implement in Supabase repo — `update()` takes a `Map<String, dynamic>` for partial field updates (avoids overwriting courier timestamps), `getRecentPricing()` queries same musteri+cikis+ugrama with durum=tamamlandi, ordered by created_at DESC, limit 1. (3) Create `SiparisLog` domain model with fromJson/toJson. (4) Create `SiparisLogRepository` contract with `create()` and `getBySimarisId()`. (5) Implement Supabase version. (6) Wire both into `BackendModule`. (7) Update barrel exports. (8) Add `update()` and `getRecentPricing()` to `FakeSiparisRepository`. (9) Create `FakeKuryeRepository`. (10) Add Riverpod provider for `SiparisLogRepository`. (11) Apply composite index migration. (12) Write `SiparisLog` domain model tests. Constraints: omit `updated_at` from update payloads (BEFORE UPDATE trigger), use explicit ugramalar column selection pattern if joining (D010).
  - Verify: `flutter analyze` clean, `flutter test` passes including new `siparis_log_test.dart`
  - Done when: `SiparisRepository` has `update()` + `getRecentPricing()`, `SiparisLogRepository` exists with Supabase impl, `FakeKuryeRepository` exists, composite index migration applied, domain model tests pass

- [x] **T02: Build 3-panel dispatch screen with assignment and finish flows** `est:1h` ✅
  - Why: This is the core deliverable — replace the placeholder `OperasyonEkranPage` with a real 3-panel dispatch screen that creates orders, assigns couriers, and finishes orders with auto-pricing. Covers R009, R010, R012, R018.
  - Files: `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`, `lib/product/siparis/siparis_log_providers.dart`, `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - Do: (1) Replace placeholder with `ConsumerStatefulWidget`. Top panel: order creation form with müşteri dropdown → cascading stop dropdowns (reuse customer form pattern, add müşteri selector first). (2) Bottom section: two panels fed from `siparisStreamActiveProvider`, split client-side — kurye_bekliyor list with checkboxes + courier `DropdownButtonFormField` (from `kuryeListProvider`, filter to isActive) + "Ata" button; devam_ediyor list with checkboxes + "Bitir" button. (3) "Ata" flow: update selected orders with kurye_id + atanma_saat + durum=devam_ediyor via `SiparisRepository.update()`, create `SiparisLog` entries. (4) "Bitir" flow: for each selected order call `getRecentPricing()` — if match found, auto-populate ucret; if not, show dialog for manual entry. Update order with ucret + bitis_saat + durum=tamamlandi, create `SiparisLog`. (5) Clear checkbox selection on stream emission to avoid stale state. (6) Mobile-first layout: vertical ListView with form, then two panels stacked. (7) Write widget tests: panel rendering with seeded data, courier assignment flow, finish with auto-pricing, manual pricing fallback when no match.
  - Verify: `flutter analyze` clean, `flutter test` passes including `operasyon_ekran_page_test.dart`, `flutter build ios --simulator` succeeds
  - Done when: 3-panel screen replaces placeholder, orders can be created/assigned/finished with auto-pricing, status logs created, widget tests cover primary flows

## Files Likely Touched

- `packages/backend_core/lib/src/siparis_repository.dart`
- `packages/backend_core/lib/src/domain/siparis_log.dart`
- `packages/backend_core/lib/src/siparis_log_repository.dart`
- `packages/backend_core/lib/src/backend_module.dart`
- `packages/backend_core/lib/backend_core.dart`
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
- `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart`
- `packages/backend_supabase/lib/src/supabase_backend_module.dart`
- `packages/backend_supabase/lib/backend_supabase.dart`
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- `lib/product/siparis/siparis_log_providers.dart`
- `test/helpers/fakes/fake_siparis_repository.dart`
- `test/helpers/fakes/fake_kurye_repository.dart`
- `test/domain/siparis_log_test.dart`
- `test/feature/operasyon/operasyon_ekran_page_test.dart`
- `supabase/migrations/20260315000200_pricing_index.sql`
