---
id: S04
parent: M001
milestone: M001
provides:
  - 3-panel operations dispatch screen (order creation, kurye bekleyenler, devam edenler)
  - SiparisRepository.update() for partial field updates (courier assignment, timestamps, pricing)
  - SiparisRepository.getRecentPricing() for auto-pricing from historical orders
  - SiparisLog domain model + SiparisLogRepository contract + Supabase implementation
  - Courier assignment flow with checkbox selection, courier dropdown, and SiparisLog audit trail
  - Order finish flow with auto-pricing lookup and manual pricing fallback dialog
  - FakeKuryeRepository and FakeSiparisLogRepository for test isolation
  - Composite index migration for auto-pricing query performance
requires:
  - slice: S01
    provides: currentUserProfileProvider (olusturanId for order creation)
  - slice: S02
    provides: Musteri, Ugrama, Kurye models and list providers (dropdowns)
  - slice: S03
    provides: Siparis model, SiparisRepository.create(), siparisStreamActiveProvider (realtime feed)
affects:
  - S05
  - S06
  - S07
  - S08
key_files:
  - lib/feature/operasyon/presentation/operasyon_ekran_page.dart
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - packages/backend_core/lib/src/domain/siparis_log.dart
  - packages/backend_core/lib/src/siparis_log_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart
  - lib/product/siparis/siparis_log_providers.dart
  - test/feature/operasyon/operasyon_ekran_page_test.dart
  - test/helpers/fakes/fake_siparis_repository.dart
  - test/helpers/fakes/fake_kurye_repository.dart
  - test/helpers/fakes/fake_siparis_log_repository.dart
  - test/domain/siparis_log_test.dart
  - supabase/migrations/20260315000200_pricing_index.sql
key_decisions:
  - "D018: Partial update via Map<String,dynamic> — avoids overwriting courier-set timestamps from other roles"
  - "D019: Single stream, client-side split — one siparisStreamActiveProvider feeds both panels, filtered by durum"
  - "D020: Clear selection sets on stream emission — prevents stale checkbox state from concurrent edits"
  - "D021: SiparisLog created client-side after status update — simpler than DB trigger, acceptable for MVP"
  - "D022: Snapshot selection before async iteration — copy Set before for-loop to avoid ConcurrentModificationError"
patterns_established:
  - "Partial update pattern: update(id, fields) with Map<String,dynamic> for any table needing concurrent multi-role writes"
  - "Auto-pricing pattern: getRecentPricing() queries same musteri+cikis+ugrama with tamamlandi status, most recent first"
  - "Selection snapshot pattern: copy selection Set before async iteration when stream listeners can mutate it"
  - "FakeSiparisLogRepository follows established in-memory fake pattern"
observability_surfaces:
  - "SupabaseSiparisLogRepo — .i() on create, .d() on getBySiparisId"
  - "SupabaseSiparisRepo — .i() on update(), .d() on getRecentPricing(), .w() on auto-pricing miss"
  - "SnackBar on assignment success/failure and finish success/failure"
  - "siparis_log table — query to see all status transitions with timestamps and actor IDs"
drill_down_paths:
  - .gsd/milestones/M001/slices/S04/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S04/tasks/T02-SUMMARY.md
duration: ~35min
verification_result: passed
completed_at: 2026-03-15
---

# S04: Operations Dispatch Screen

**3-panel dispatch screen with order creation, courier assignment from waiting queue, and order completion with auto-pricing — all fed from a single realtime stream.**

## What Happened

**T01 — Data layer extensions:** Extended `SiparisRepository` with `update(id, fields)` for partial field updates and `getRecentPricing(musteriId, cikisId, ugramaId)` for auto-pricing lookup. Created `SiparisLog` domain model and `SiparisLogRepository` contract + Supabase implementation, wired into `BackendModule`. Updated `FakeSiparisRepository` with both new methods, created `FakeKuryeRepository` for widget test isolation. Applied composite index migration for pricing query performance. 5 domain model tests added.

**T02 — Dispatch screen UI:** Replaced placeholder `OperasyonEkranPage` with a full 3-panel dispatch screen (~400 lines). Top panel: order creation form with müşteri dropdown cascading into stop dropdowns. Bottom panels: "Kurye Bekleyenler" (checkbox selection + courier dropdown + "Ata" button) and "Devam Edenler" (checkbox selection + "Bitir" button). Both panels fed from `siparisStreamActiveProvider`, split client-side by `durum`. Assign flow sets `kurye_id`, `atanma_saat`, transitions to `devam_ediyor`, creates `SiparisLog`. Finish flow calls `getRecentPricing()` — auto-populates price or shows manual entry dialog — then sets `ucret`, `bitis_saat`, transitions to `tamamlandi`, creates `SiparisLog`. Selection sets cleared on stream emission, snapshot-copied before async iteration. 5 widget tests cover all flows. Created `FakeSiparisLogRepository`.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (21 pre-existing infos)
- `flutter test` — 86/86 pass
  - `test/domain/siparis_log_test.dart` — 5 SiparisLog roundtrip tests
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` — 5 tests: panel rendering, assignment, auto-pricing finish, manual pricing fallback
- `flutter build ios --simulator` — succeeds

## Requirements Advanced

- R009 — 3-panel dispatch screen fully implemented with order creation, waiting queue, and in-progress panels
- R010 — Manual courier assignment via checkbox selection + courier dropdown + "Ata" button
- R012 — Auto-pricing queries most recent matching completed order; manual fallback dialog when no match
- R018 — SiparisLog created on every status transition (kurye_bekliyor→devam_ediyor, devam_ediyor→tamamlandi)
- R008 — Realtime stream feeds both dispatch panels without refresh

## Requirements Validated

- R009 — Widget tests prove 3-panel rendering with seeded order data split by status
- R010 — Widget test proves assignment flow: select orders + courier → tap Ata → orders updated with kurye_id and atanma_saat
- R012 — Widget tests prove both auto-pricing (match found → ucret populated) and manual pricing fallback (no match → dialog → manual entry)
- R018 — Widget tests verify SiparisLog creation on assign and finish flows

## New Requirements Surfaced

- None

## Requirements Invalidated or Re-scoped

- None

## Deviations

- Composite index migration could not be applied via Supabase MCP (project not linked). File written locally at `supabase/migrations/20260315000200_pricing_index.sql` — will apply during next `supabase db push`.

## Known Limitations

- Route labels in dispatch panels display raw ugrama IDs instead of human-readable stop names. Functional but not user-friendly — a display improvement for polish.
- `DropdownButtonFormField.value` deprecation infos (Flutter 3.33+) consistent across codebase — codebase-wide migration task, not S04-specific.
- SiparisLog created client-side after status update (D021) — if update succeeds but log insert fails, the status change is unlogged. Acceptable for MVP; DB trigger would be more reliable.

## Follow-ups

- None blocking. Polish items (ugrama name resolution, DropdownButton migration) are codebase-wide concerns.

## Files Created/Modified

- `packages/backend_core/lib/src/siparis_repository.dart` — added update() and getRecentPricing() contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — implemented both methods
- `packages/backend_core/lib/src/domain/siparis_log.dart` — new SiparisLog domain model
- `packages/backend_core/lib/src/siparis_log_repository.dart` — new repository contract
- `packages/backend_supabase/lib/src/supabase_siparis_log_repository.dart` — Supabase implementation
- `packages/backend_core/lib/src/backend_module.dart` — added createSiparisLogRepository()
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — override with SupabaseSiparisLogRepository
- `packages/backend_core/lib/backend_core.dart` — barrel export updates
- `packages/backend_supabase/lib/backend_supabase.dart` — barrel export updates
- `lib/product/siparis/siparis_log_providers.dart` — siparisLogRepositoryProvider
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — full 3-panel dispatch screen
- `test/helpers/fakes/fake_siparis_repository.dart` — added update() + getRecentPricing()
- `test/helpers/fakes/fake_kurye_repository.dart` — new in-memory fake
- `test/helpers/fakes/fake_siparis_log_repository.dart` — new in-memory fake
- `test/domain/siparis_log_test.dart` — 5 domain model tests
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — 5 widget tests
- `supabase/migrations/20260315000200_pricing_index.sql` — composite index for auto-pricing

## Forward Intelligence

### What the next slice should know
- `SiparisRepository.update(id, fields)` takes a raw `Map<String, dynamic>` — caller is responsible for field names matching the DB columns. Don't include `updated_at` (BEFORE UPDATE trigger handles it).
- The dispatch screen uses `siparisStreamActiveProvider` which filters to non-terminal statuses. S05 (courier workflow) should use the same stream or a courier-specific filtered version.
- `FakeKuryeRepository` and `FakeSiparisLogRepository` are ready for use in downstream widget tests.

### What's fragile
- Selection state clearing on stream emission (D020) — aggressive but safe. If future UX needs persistent selection across updates, the reconciliation logic will need rework.
- SiparisLog client-side insertion (D021) — a network failure between status update and log insert leaves an unlogged transition. Low risk for MVP but worth migrating to a DB trigger if audit reliability becomes important.

### Authoritative diagnostics
- Query `siparis_log` table to see all status transitions with timestamps and actor IDs — this is the primary audit surface.
- Grep console for `SupabaseSiparisRepo` to see update() and getRecentPricing() activity; `.w()` lines indicate auto-pricing misses.

### What assumptions changed
- No assumptions changed. The data layer and UI both followed the plan closely.
