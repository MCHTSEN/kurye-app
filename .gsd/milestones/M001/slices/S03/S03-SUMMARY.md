---
id: S03
parent: M001
milestone: M001
provides:
  - Siparis domain model + SiparisDurum enum (4 statuses matching DB)
  - SiparisRepository contract with Future + Stream methods
  - SupabaseSiparisRepository with stream() realtime subscriptions
  - MusteriPersonelRepository.getByUserId() for resolving logged-in personel
  - BackendModule wiring + barrel exports for Siparis
  - Riverpod providers (repo keepAlive, stream/list autoDispose)
  - Customer order creation form with 4 cascading dropdowns + text field
  - Active orders realtime list via streamByMusteriId
  - Completed orders history page with date range filtering
  - Domain model unit tests (7 cases) + widget tests (4 cases)
  - FakeSiparisRepository, FakeUgramaRepository, FakeMusteriPersonelRepository for test isolation
requires:
  - slice: S01
    provides: AppUserProfile with musteriId, currentUserProfileProvider
  - slice: S02
    provides: Musteri/Ugrama/MusteriPersonel models and repositories, ugramaListByMusteriProvider
affects:
  - S04
  - S05
  - S08
key_files:
  - packages/backend_core/lib/src/domain/siparis.dart
  - packages/backend_core/lib/src/siparis_repository.dart
  - packages/backend_supabase/lib/src/supabase_siparis_repository.dart
  - lib/product/siparis/siparis_providers.dart
  - lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart
  - lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart
  - test/domain/siparis_test.dart
  - test/feature/musteri_siparis/musteri_siparis_page_test.dart
  - test/helpers/fakes/fake_siparis_repository.dart
  - test/helpers/fakes/fake_ugrama_repository.dart
  - test/helpers/fakes/fake_musteri_personel_repository.dart
key_decisions:
  - "D015: Supabase stream() pattern — stream(primaryKey: ['id']) + filter + handleError, autoDispose to prevent channel leaks"
  - "D016: Controlled DropdownButtonFormField via value + setState, not initialValue"
  - "D017: musteriId resolved directly from AppUserProfile.musteriId — no separate lookup"
patterns_established:
  - "Supabase stream() for realtime subscriptions — reuse in S04/S05/S08"
  - "FakeSiparisRepository with StreamController.broadcast + startWithValue for test-driven stream emission"
  - "overrideWithBuild for Riverpod 3 AsyncNotifier providers in widget tests"
  - "Fake repos for UgramaRepository and MusteriPersonelRepository — reuse in S04+"
observability_surfaces:
  - "LogTag.data in SupabaseSiparisRepo — .i() mutations, .d() reads/stream events, .e() stream errors"
  - "SiparisDurum color-coded chips in active orders list — visual status inspection"
  - "SnackBar feedback on order creation success/failure"
drill_down_paths:
  - .gsd/milestones/M001/slices/S03/tasks/T01-SUMMARY.md
  - .gsd/milestones/M001/slices/S03/tasks/T02-SUMMARY.md
duration: 35m
verification_result: passed
completed_at: 2026-03-15
---

# S03: Order Creation & Customer Tracking

**Customer can create orders with cascading dropdowns and track them in realtime. Complete Siparis data layer with Supabase Realtime stream subscriptions, order creation form, active orders list, and history page with date filtering.**

## What Happened

Built the full order data layer in T01: `Siparis` model with `SiparisDurum` enum mapping 4 DB values, `SiparisRepository` contract with 4 Future methods and 2 Stream methods, and `SupabaseSiparisRepository` using `stream(primaryKey: ['id'])` for realtime — the first Supabase Realtime usage in the app. Added `getByUserId()` to `MusteriPersonelRepository` for resolving the logged-in customer staff member. Created Riverpod providers with `autoDispose` streams to prevent channel leaks, domain model tests (7 cases), and `FakeSiparisRepository` with broadcast stream support for widget testing.

In T02, replaced both placeholder müşteri pages with real implementations. `MusteriSiparisPage` has a form with 4 `DropdownButtonFormField`s (Çıkış, Uğrama, Uğrama1, Not) populated from the customer's uğramalar, plus a Not1 text field. The `musteriId` is auto-resolved from `AppUserProfile.musteriId` with a null guard. On submit, personel_id is resolved via `getByUserId()` and the order is created with `durum = kurye_bekliyor`. Below the form, active orders display as cards with color-coded durum chips, updating in realtime via stream provider. `MusteriGecmisPage` shows completed orders with date range filtering. Widget tests (4 cases) cover form render, validation, submit flow, and null musteriId guard.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (12 infos: 4 pre-existing, 4 deprecation on `DropdownButtonFormField.value`, 2 redundant argument, 2 misc)
- `flutter test` — 76/76 pass, 0 failures
  - `test/domain/siparis_test.dart` — 7 domain model tests (enum roundtrip, fromJson/toJson, nullable fields, int→double ucret)
  - `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — 4 widget tests (form render, validation, submit, null guard)
- `flutter build ios --simulator` — succeeds

## Requirements Advanced

- R007 (Order creation with cascading dropdowns) — Customer can create orders via form with 4 cascading dropdowns. Operations-side creation deferred to S04.
- R008 (Realtime order flow) — Stream pattern established; customer sees live order updates. Cross-role realtime proof continues in S04/S05.
- R013 (Customer order tracking) — Active orders list with realtime updates + history page with date range filtering fully implemented.

## Requirements Validated

- R007 — Widget tests verify form renders all fields, validates required fields, and creates order with correct data. Cascading dropdowns load from customer's uğramalar.
- R013 — Widget tests verify order creation flow end-to-end. Active orders stream and history page with date filtering implemented and buildable.

## New Requirements Surfaced

- None

## Requirements Invalidated or Re-scoped

- None

## Deviations

None.

## Known Limitations

- `DropdownButtonFormField.value` shows deprecation info in Flutter 3.33+ — the `initialValue` replacement breaks the controlled dropdown pattern. Info-level only, no functional impact.
- Operations-side order creation (part of R007) is deferred to S04's 3-panel dispatch screen.
- Full cross-role realtime proof (R008) requires S04 dispatch screen receiving customer-created orders without refresh.

## Follow-ups

- None — all planned work completed as specified.

## Files Created/Modified

- `packages/backend_core/lib/src/domain/siparis.dart` — Siparis model + SiparisDurum enum
- `packages/backend_core/lib/src/siparis_repository.dart` — abstract SiparisRepository contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase impl with stream() realtime
- `packages/backend_core/lib/src/musteri_personel_repository.dart` — added getByUserId()
- `packages/backend_supabase/lib/src/supabase_musteri_personel_repository.dart` — implemented getByUserId()
- `packages/backend_core/lib/src/backend_module.dart` — added createSiparisRepository()
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — override createSiparisRepository()
- `packages/backend_core/lib/backend_core.dart` — barrel exports for siparis
- `packages/backend_supabase/lib/backend_supabase.dart` — barrel export for supabase_siparis_repository
- `lib/product/siparis/siparis_providers.dart` — Riverpod providers (repo + streams + list)
- `lib/product/siparis/siparis_providers.g.dart` — generated provider code
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — order creation form + active orders list
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — completed orders + date filter
- `test/domain/siparis_test.dart` — 7 domain model tests
- `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — 4 widget tests
- `test/helpers/fakes/fake_siparis_repository.dart` — fake with stream emission support
- `test/helpers/fakes/fake_ugrama_repository.dart` — fake for widget tests
- `test/helpers/fakes/fake_musteri_personel_repository.dart` — fake for widget tests

## Forward Intelligence

### What the next slice should know
- `SiparisRepository` contract is ready for S04. The `create()`, `getByDurum()`, `streamActive()`, and `updateDurum()` methods are all implemented and tested.
- S04 needs to add `update()` (for courier assignment fields like `kurye_id`, `atanma_saat`, `ucret`) and `getRecentPricing()` (for auto-pricing query) to the repository contract.
- The `FakeUgramaRepository` and `FakeMusteriPersonelRepository` are in `test/helpers/fakes/` — reuse them in S04 widget tests.
- The `overrideWithBuild` pattern for `currentUserProfileProvider` is established in `musteri_siparis_page_test.dart` — copy it for any test needing a profile override.

### What's fragile
- `DropdownButtonFormField.value` deprecation — Flutter may eventually remove `value` parameter, which would require refactoring the controlled dropdown pattern. Monitor across Flutter upgrades.
- Stream providers are `autoDispose` — if a screen unmounts and remounts rapidly, the stream will reconnect. This is correct behavior but worth noting if latency spikes appear.

### Authoritative diagnostics
- Grep `SupabaseSiparisRepo` in console output — all order CRUD and stream lifecycle events are logged with LogTag.data
- Stream subscriptions log "subscribing" at `.d()` level, row counts on each emission, and errors at `.e()` level

### What assumptions changed
- No assumptions changed — the slice plan mapped cleanly to implementation.
