---
estimated_steps: 5
estimated_files: 2
---

# T02: Build courier main screen with active/passive toggle and timestamp punching

**Slice:** S05 — Courier Workflow
**Milestone:** M001

## Description

Replace the placeholder `KuryeAnaPage` with the real courier screen. Top section: active/passive toggle switch backed by `KuryeRepository.updateOnlineStatus()`. Body: realtime list of `devam_ediyor` orders assigned to this courier, each with three timestamp buttons (Çıkış, Uğrama, Uğrama1). Already-set timestamps are displayed with formatted time and disabled. Handles missing `kuryeler` record gracefully. Widget tests cover all key interactions.

## Steps

1. Replace `KuryeAnaPage` scaffold. Consume `currentKuryeProvider` — show loading state while resolving, error message ("Kurye kaydı bulunamadı") if null. When resolved, build the real screen with `kuryeId`.
2. Build top section: active/passive `Switch` widget. Read initial state from `Kurye.isOnline`. On toggle, call `kuryeRepository.updateOnlineStatus(kuryeId, isOnline: newValue)`. Show current status text ("Aktif" / "Pasif").
3. Build order list section: consume `siparisStreamByKuryeProvider(kuryeId)`. Client-side filter to `durum == devamEdiyor`. Display as `ListView` of order cards showing route info (çıkış, uğrama, uğrama1 IDs — same display pattern as ops dispatch panels).
4. Build timestamp buttons on each order card. Three buttons: "Çıkış", "Uğrama", "Uğrama1". For each: if the corresponding `*_saat` field is null → enabled button, tap calls `siparisRepository.update(id, {'cikis_saat': DateTime.now().toIso8601String()})` (or equivalent field). If already set → show formatted time (HH:mm), button disabled. Uğrama1 button hidden if `ugrama1_id` is null on the order.
5. Write widget tests in `test/feature/kurye/kurye_ana_page_test.dart`:
   - Test 1: Toggle renders with correct initial state, toggling fires `updateOnlineStatus`
   - Test 2: Order list renders assigned orders with route info
   - Test 3: Tapping a timestamp button calls `update()` with the correct field
   - Test 4: Already-set timestamp shows formatted time, button is disabled

## Must-Haves

- [ ] Active/passive toggle updates `is_online` via repository
- [ ] Order list shows only `devam_ediyor` orders assigned to this courier
- [ ] Timestamp buttons set `*_saat` fields via `SiparisRepository.update()`
- [ ] Already-set timestamps are displayed and disabled
- [ ] Uğrama1 button hidden when order has no `ugrama1_id`
- [ ] Missing `kuryeler` record shows error, not crash
- [ ] 4+ widget tests pass

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all pass including 4+ new widget tests in `test/feature/kurye/kurye_ana_page_test.dart`

## Inputs

- `lib/product/kurye/kurye_providers.dart` — `currentKuryeProvider` from T01
- `lib/product/siparis/siparis_providers.dart` — `siparisStreamByKuryeProvider` from T01
- `test/helpers/fakes/fake_kurye_repository.dart` — `getByUserId()` + `updateOnlineStatus()` from T01/S02
- `test/helpers/fakes/fake_siparis_repository.dart` — `streamByKuryeId()` + `update()` from T01/S04
- S04 forward intelligence: use `SiparisRepository.update(id, fields)` with raw column names, omit `updated_at`
- Research pitfall: disable re-tap on already-set timestamps (safe default)
- Research pitfall: courier doesn't change `durum` — ops does via "Bitir", order drops off via stream

## Expected Output

- `lib/feature/kurye/presentation/kurye_ana_page.dart` — full courier screen replacing placeholder
- `test/feature/kurye/kurye_ana_page_test.dart` — 4+ widget tests covering toggle, order list, timestamp punch, disabled state
