---
id: T02
parent: S05
milestone: M001
provides:
  - Full courier main screen (KuryeAnaPage) with active/passive toggle and timestamp punching
  - 6 widget tests covering toggle, order list, timestamp punch, disabled state, ugrama1 hidden, null kurye
key_files:
  - lib/feature/kurye/presentation/kurye_ana_page.dart
  - test/feature/kurye/kurye_ana_page_test.dart
key_decisions:
  - Used ConsumerStatefulWidget for the toggle card to manage local _isOnline state with optimistic update + revert on failure, avoiding extra providers for simple local toggle
  - Client-side filter to devamEdiyor (stream returns all orders for kurye, filter in UI) — keeps stream setup simple, matches ops panel pattern
  - Timestamp buttons use Key('cikis_btn_${order.id}') pattern for testability
  - overrideWith on currentKuryeProvider for tests — simpler than wiring auth + fake repo chain
patterns_established:
  - _TimestampButton widget pattern — reusable for punch-style buttons with enabled/disabled + formatted time display
  - Kurye screen test pattern using currentKuryeProvider.overrideWith + repository overrideWithValue
observability_surfaces:
  - Kurye toggle calls kuryeRepository.updateOnlineStatus — grep SupabaseKuryeRepo logs to trace
  - Timestamp punch calls siparisRepository.update with field name — grep SupabaseSiparisRepo + update for write traces
  - Null kurye record renders "Kurye kaydı bulunamadı" — visible in UI, no crash
duration: 15m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Build courier main screen with active/passive toggle and timestamp punching

**Replaced placeholder KuryeAnaPage with full courier screen — active/passive toggle, realtime devam_ediyor order list, and çıkış/uğrama/uğrama1 timestamp punching with disabled state for already-set times.**

## What Happened

Rewrote `KuryeAnaPage` to consume `currentKuryeProvider`. Shows loading spinner while resolving, "Kurye kaydı bulunamadı" when null, real screen when resolved.

Top section: `_OnlineToggleCard` (ConsumerStatefulWidget) with optimistic local state — reads `Kurye.isOnline`, toggles via `kuryeRepository.updateOnlineStatus()`, reverts on exception. Shows "Aktif"/"Pasif" text.

Body: `_OrderListSection` consumes `siparisStreamByKuryeProvider(kuryeId)`, client-side filters to `devamEdiyor`. Each `_OrderCard` displays route info (`cikisId → ugramaId [→ ugrama1Id]`) and three `_TimestampButton` widgets. Each button: if `*_saat` is null → enabled `ElevatedButton`, tap calls `siparisRepository.update(id, {field: DateTime.now().toIso8601String()})`. If set → disabled `OutlinedButton` showing formatted time (HH:mm via `intl` DateFormat). Uğrama1 button conditionally hidden when `ugrama1Id` is null.

Wrote 6 widget tests (exceeds the required 4): toggle state + updateOnlineStatus call, order list with client-side filter, timestamp punch via update(), disabled state with formatted time, ugrama1 hidden, null kurye error state.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (24 info-level, none from new files)
- `flutter test` — 92/92 pass, including 6 new tests in `test/feature/kurye/kurye_ana_page_test.dart`
- Slice-level checks:
  - ✅ `flutter analyze` — clean
  - ✅ `flutter test` — all pass including kurye_ana_page widget tests
  - ⏳ Realtime stream integration against live Supabase — deferred to S08

## Diagnostics

- Toggle: grep `SupabaseKuryeRepo` for `updateOnlineStatus` calls; query `kuryeler.is_online` to confirm persistence
- Timestamp: grep `SupabaseSiparisRepo` + `update` for timestamp writes; query `siparisler.cikis_saat / ugrama_saat / ugrama1_saat`
- Null kurye: UI renders "Kurye kaydı bulunamadı" — no crash path

## Deviations

- Added 6 tests instead of 4 — extra tests for ugrama1 hidden condition and null kurye error state, both explicitly listed as must-haves
- Used `intl` DateFormat for HH:mm formatting — already a dependency, cleaner than manual string formatting

## Known Issues

None.

## Files Created/Modified

- `lib/feature/kurye/presentation/kurye_ana_page.dart` — full rewrite replacing placeholder with courier screen
- `test/feature/kurye/kurye_ana_page_test.dart` — 6 widget tests covering all must-haves
