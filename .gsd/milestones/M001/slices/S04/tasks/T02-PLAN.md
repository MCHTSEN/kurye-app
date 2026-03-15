---
estimated_steps: 7
estimated_files: 3
---

# T02: Build 3-panel dispatch screen with assignment and finish flows

**Slice:** S04 — Operations Dispatch Screen
**Milestone:** M001

## Description

Replace the placeholder `OperasyonEkranPage` with the real 3-panel dispatch screen. Top panel: operations-side order creation form (adds müşteri dropdown before the cascading stop dropdowns). Bottom panels: "Kurye Bekleyenler" with checkbox selection + courier assignment, and "Devam Edenler" with checkbox selection + finish/auto-pricing. Both bottom panels are fed from the single `siparisStreamActiveProvider`, split client-side by durum. Status log entries are created on every transition.

## Steps

1. **Build the order creation panel (top).** Reuse the `MusteriSiparisPage` form pattern but add a `musteriDropdown` first — sourced from `musteriListProvider`. When müşteri is selected, load that müşteri's stops via `ugramaListByMusteriProvider(musteriId)`. Remaining fields: Çıkış, Uğrama, Uğrama1, Not (all from stops), Not1 (text). On submit: create order via `SiparisRepository.create()` with `olusturanId` from `currentUserProfileProvider`. The müşteri dropdown resets the stop dropdowns when changed.

2. **Build the "Kurye Bekleyenler" panel.** Subscribe to `siparisStreamActiveProvider` and filter to `durum == kuryeBekliyor`. Display as a list of `CheckboxListTile` items showing route info (cıkış → uğrama). Below the list: a `DropdownButtonFormField` for courier selection (from `kuryeListProvider`, filter to `isActive == true`) and an "Ata" (Assign) button. Button is disabled when no orders selected or no courier selected.

3. **Build the "Devam Edenler" panel.** Same stream, filter to `durum == devamEdiyor`. Display as `CheckboxListTile` items showing route + assigned courier name. Below: a "Bitir" (Finish) button. Button disabled when no orders selected.

4. **Implement the "Ata" (assign) flow.** For each selected order: call `SiparisRepository.update(id, {'kurye_id': kuryeId, 'atanma_saat': DateTime.now().toIso8601String(), 'durum': 'devam_ediyor'})`. Then create a `SiparisLog` with `eskiDurum: kuryeBekliyor`, `yeniDurum: devamEdiyor`, `degistirenId: currentUserId`. Show SnackBar on success. Clear selection after assignment.

5. **Implement the "Bitir" (finish) flow with auto-pricing.** For each selected order: call `getRecentPricing(musteriId, cikisId, ugramaId)`. If a match is found, use its `ucret`. If no match, show a dialog prompting operasyon to enter price manually (with a `TextField` and confirm button). Then call `SiparisRepository.update(id, {'ucret': price, 'bitis_saat': DateTime.now().toIso8601String(), 'durum': 'tamamlandi'})`. Create `SiparisLog` with `eskiDurum: devamEdiyor`, `yeniDurum: tamamlandi`. Show SnackBar on success. Clear selection.

6. **Handle realtime + selection state.** Clear all checkbox selections when the stream emits new data — prevents stale selection of orders that were already assigned/finished by another operasyon user. Use `Set<String>` for selected order IDs.

7. **Write widget tests** at `test/feature/operasyon/operasyon_ekran_page_test.dart`. Test cases: (a) 3 panels render with correct titles, (b) kurye bekleyenler shows waiting orders from seeded stream data, (c) courier assignment flow — select order checkbox, select courier, tap Ata, verify `update()` called with correct fields, (d) finish flow with auto-pricing — seed a matching historical order in fake repo, tap Bitir, verify ucret auto-populated, (e) manual pricing fallback — no historical match, dialog appears for manual entry. Use `FakeSiparisRepository`, `FakeKuryeRepository`, `FakeMusteriRepository`, `FakeUgramaRepository` with appropriate seed data.

## Must-Haves

- [ ] Placeholder `OperasyonEkranPage` fully replaced with 3-panel dispatch screen
- [ ] Order creation form with müşteri dropdown → cascading stop dropdowns works
- [ ] Kurye bekleyenler panel shows waiting orders with checkboxes
- [ ] Courier assignment via Ata button updates order with kurye_id, atanma_saat, durum
- [ ] Devam edenler panel shows in-progress orders with checkboxes
- [ ] Finish via Bitir button with auto-pricing from getRecentPricing()
- [ ] Manual pricing dialog when no historical match found
- [ ] SiparisLog created on both transitions (assign + finish)
- [ ] Checkbox selection cleared on stream updates
- [ ] Widget tests cover panel rendering, assignment, auto-pricing, manual pricing

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all tests pass including new `operasyon_ekran_page_test.dart`
- `flutter build ios --simulator` — succeeds

## Observability Impact

- Signals added: SnackBar feedback on assignment/finish success and failures. Log entries via `SiparisLogRepository.create()` on every status transition.
- How a future agent inspects this: query `siparis_log` for status transitions; grep `SupabaseSiparisRepo` for update/pricing calls in console output.
- Failure state exposed: auto-pricing miss shows warning SnackBar to operasyon user + `.w()` log. Assignment/finish errors surface as SnackBar + `.e()` log.

## Inputs

- `packages/backend_core/lib/src/siparis_repository.dart` — `update()` and `getRecentPricing()` from T01
- `packages/backend_core/lib/src/siparis_log_repository.dart` — `create()` from T01
- `lib/product/siparis/siparis_providers.dart` — `siparisStreamActiveProvider`, `siparisRepositoryProvider`
- `lib/product/siparis/siparis_log_providers.dart` — `siparisLogRepositoryProvider` from T01
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider` for courier dropdown
- `lib/product/musteri/musteri_providers.dart` — `musteriListProvider` for müşteri dropdown
- `lib/product/ugrama/ugrama_providers.dart` — `ugramaListByMusteriProvider` for cascading stops
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — cascading dropdown pattern to replicate
- `test/helpers/fakes/fake_siparis_repository.dart` — fake with update/getRecentPricing from T01
- `test/helpers/fakes/fake_kurye_repository.dart` — from T01
- T01 summary — data layer contracts and fake implementations

## Expected Output

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — fully replaced with 3-panel dispatch screen (~300-400 lines)
- `lib/product/siparis/siparis_log_providers.dart` — may need minor updates if not already complete from T01
- `test/feature/operasyon/operasyon_ekran_page_test.dart` — 5+ widget tests covering all dispatch flows
