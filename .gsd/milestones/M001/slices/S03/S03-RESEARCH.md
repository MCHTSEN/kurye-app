# S03: Order Creation & Customer Tracking — Research

**Date:** 2026-03-15

## Summary

This slice is substantially pre-built. The domain model (`Siparis`, `SiparisDurum`), abstract repository (`SiparisRepository` with CRUD + realtime streams), Supabase implementation (`SupabaseSiparisRepository`), Riverpod providers (repository, stream-by-müşteri, stream-active, list-by-müşteri), and even the customer-facing UI pages (`MusteriSiparisPage` with cascading dropdowns and active order list, `MusteriGecmisPage` with date filtering) are all implemented and tested. 76 tests pass including 7 sipariş-specific tests (domain model roundtrip + widget tests). The `BackendModule` factory method and `SupabaseBackendModule` override are wired. Routes are registered. The `FakeSiparisRepository` with stream support exists for widget testing.

The remaining work is small but important: (1) fix 3 deprecated `value:` → `initialValue:` warnings on `DropdownButtonFormField`, (2) add customer-side navigation between sipariş and geçmiş pages (currently no way to reach `MusteriGecmisPage`), (3) verify realtime works end-to-end against live Supabase (the core risk for this slice), and (4) ensure test coverage meets the feature validation bar (the existing widget tests are solid but a `MusteriGecmisPage` widget test is missing).

## Recommendation

Treat this as a **polish + verification** slice rather than a build-from-scratch slice. The main risk — Supabase Realtime pushing order changes to the customer screen — needs live verification on the iOS simulator with two role sessions. The code is already structured correctly (`stream(primaryKey: ['id']).eq('musteri_id', ...)` and `stream(primaryKey: ['id']).inFilter('durum', [...])`), but the stream API combining Postgrest initial fetch + Realtime subscription needs proof against real data.

Tasks should be:
1. **T01: Fix deprecations & add customer navigation** — Fix `value:` → `initialValue:` on dropdowns, add BottomNavigationBar or drawer to müşteri pages for sipariş ↔ geçmiş navigation.
2. **T02: MusteriGecmisPage widget test + realtime verification** — Add widget test for geçmiş page, then do live integration test on simulator: create order as müşteri, verify it appears in active list via realtime stream, verify operasyon sees it via `streamActive()`.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Sipariş domain model | `packages/backend_core/lib/src/domain/siparis.dart` | Already complete with fromJson/toJson, all DB fields mapped |
| Sipariş CRUD + streams | `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` | Full implementation: create, getByMusteriId, getByDurum, updateDurum, streamByMusteriId, streamActive |
| Riverpod providers | `lib/product/siparis/siparis_providers.dart` | Repository + 3 derived providers (stream-by-müşteri, stream-active, list-by-müşteri) |
| Customer order form | `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` | Complete: cascading dropdowns from uğrama list, form validation, submit, active orders display |
| Customer history | `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` | Complete: date range picker, completed order list, uğrama name resolution |
| Widget test fakes | `test/helpers/fakes/fake_siparis_repository.dart` | In-memory store with stream support, emitForMusteri/emitActive for test scenarios |
| Other fakes | `fake_ugrama_repository.dart`, `fake_musteri_personel_repository.dart` | Already used by existing widget tests |

## Existing Code and Patterns

- `packages/backend_core/lib/src/siparis_repository.dart` — Abstract contract with 4 CRUD methods + 2 stream methods. S04 will likely need `update()` for general field updates (not just durum), but that's S04 scope.
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Uses `_client.from(_table).stream(primaryKey: ['id'])` for realtime. The `streamActive()` uses `.inFilter('durum', [...])` which is the correct Supabase Realtime filter API. Has `_log` with `LogTag.data`. Omits `updated_at` from create payload (has BEFORE UPDATE trigger). Note: does NOT omit `updated_at` from update — but `updateDurum()` only sends `{'durum': durum.value}` so it's fine.
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — Follows S02's `ConsumerStatefulWidget` pattern. Uses `_formKey`, `_selectedXxxId` state vars for dropdowns, `_clearForm()` after submit. Resolves `personel_id` via `musteriPersonelRepository.getByUserId()`. Shows active orders below form via `siparisStreamByMusteriProvider`, filtered client-side to kuryeBekliyor + devamEdiyor.
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — Uses `siparisListByMusteriProvider` (one-shot fetch, not stream). Filters to `tamamlandi` only. Date range picker for filtering. No navigation back to sipariş page.
- `lib/app/router/guards/app_access_guard.dart` — müşteri_personel users are routed to `musteriSiparis` as home. Route access enforced by path prefix (`/musteri/*` → musteriPersonel only).
- `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — 4 widget tests: renders form fields, validation rejects empty required, successful submit creates order, error when no musteriId. Uses `pumpApp` with provider overrides.
- `test/helpers/widgets/test_app.dart` — Standard `pumpApp` extension with mock backend, fake analytics, fake storage. Uses `ProviderScope.overrides`.

## Constraints

- **RLS on siparisler** — müşteri_personel can only SELECT where `musteri_id` matches their `app_users.musteri_id`, and INSERT with the same check. This means the customer can only see/create orders for their own company. The `olusturan_id` field is SET NULL on delete, not enforced by RLS.
- **`siparisler` has BEFORE UPDATE trigger** — `updated_at` is auto-set. Update payloads should not include `updated_at`.
- **Supabase Realtime publication** — `siparisler` is already in `supabase_realtime` publication. No migration needed.
- **`not_id` references `ugramalar`** — The "Not" dropdown is an uğrama reference, not a free-text note category. The existing implementation correctly uses the same uğrama dropdown items for all 4 dropdown fields (Çıkış, Uğrama, Uğrama1, Not).
- **`DropdownButtonFormField.value` deprecated** — Flutter SDK deprecated `value:` in favor of `initialValue:` after v3.33.0. The existing code triggers 3 `deprecated_member_use` info diagnostics. These should be fixed but may require testing — `initialValue` behaves slightly differently with form state.
- **No bottom navigation for müşteri** — The customer currently lands on `MusteriSiparisPage` with no way to navigate to `MusteriGecmisPage`. Needs either a BottomNavigationBar, drawer, or AppBar action button.
- **`streamByMusteriId` returns ALL orders for the müşteri** — The active orders section in `MusteriSiparisPage` filters client-side to `kuryeBekliyor + devamEdiyor`. This is correct but means completed/cancelled orders are also fetched and discarded on the client.

## Common Pitfalls

- **`initialValue` vs `value` on DropdownButtonFormField** — `initialValue` is set once when the form field is created. If you need to programmatically change the selected value (e.g., `_clearForm()`), you need to use a `FormField` key or `_formKey.currentState?.reset()`. The existing code uses `setState()` to update `_selectedXxxId` and passes it as `value:` — switching to `initialValue:` requires verifying that form reset still works correctly.
- **Supabase Realtime stream vs channel** — The `stream()` method on `SupabaseQueryBuilder` combines an initial Postgrest fetch with a Realtime subscription. It returns `Stream<List<Map<String, dynamic>>>` — the full current state after each change, not just the diff. This is correct for the current usage (rebuild full list on any change). The alternative `channel().onPostgresChanges()` gives individual change events — not needed here.
- **RLS blocking realtime** — Supabase Realtime respects RLS policies. The `stream()` method's initial fetch goes through RLS, and the realtime subscription also filters by RLS. This means a müşteri_personel user will only receive realtime events for their own company's orders. No additional client-side filtering needed for RLS — but the client-side durum filter is still needed.

## Open Risks

- **Realtime subscription reliability** — The `stream()` API combines Postgrest + Realtime. If the WebSocket disconnects or the Realtime service lags, the customer may not see order status changes promptly. The Supabase Flutter SDK handles reconnection automatically, but this needs live verification. This is the core risk for the milestone's proof strategy ("retire in S03 by proving customer order appears on ops screen without refresh").
- **`DropdownButtonFormField.value` deprecation fix** — May subtly change form behavior. The fix is low-risk but needs careful testing since the form relies on `setState` + `_clearForm()` interaction with dropdown state.
- **`not_id` field semantics** — The "Not" dropdown uses the same uğrama list as Çıkış/Uğrama/Uğrama1. This seems intentional from the DB schema (it references `ugramalar`), but the spec says "Not (dropdown)" without clarifying what values it should contain. Current implementation is consistent with the DB schema.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Supabase | `supabase/agent-skills@supabase-postgres-best-practices` (34K installs) | available — `npx skills add supabase/agent-skills@supabase-postgres-best-practices` |
| Flutter | `flutter/skills@flutter-layout` (1.2K installs) | available — not directly relevant to this slice |
| Flutter (Riverpod) | — | none found for Riverpod specifically |
| Mobile design | `mobile-design` | installed (in `<available_skills>`) |

## Sources

- Supabase Realtime `stream()` API supports `eq`, `inFilter`, and other filters on the stream builder — confirmed via Context7 docs (source: supabase.com/docs/reference/dart)
- `stream()` emits initial data and subsequent changes as `Stream<List<Map<String, dynamic>>>` using combined Postgrest + Realtime — not just diffs (source: supabase.com/docs/reference/dart)
- `DropdownButtonFormField.value` deprecated after Flutter v3.33.0-1.0.pre in favor of `initialValue` (source: flutter analyze output)
