---
estimated_steps: 4
estimated_files: 1
---

# T03: Cross-role integration test for full order lifecycle

**Slice:** S08 — Cross-role integration & polish
**Milestone:** M001

## Description

Write the final-assembly integration test that proves the complete order lifecycle works across all 3 roles (müşteri → operasyon → kurye → operasyon). This is the R008 validation gate and the M001 definition-of-done proof. Uses widget tests with fake repositories and stream emission to drive each handoff.

## Steps

1. Create `test/integration/cross_role_lifecycle_test.dart`. Set up a shared `FakeSiparisRepository`, `FakeKuryeRepository`, `FakeSiparisLogRepository`, `FakeUgramaRepository`, and `FakeMusteriPersonelRepository`. Configure fake data: one müşteri, two uğramalar, one courier.
2. Write the lifecycle test flow: (a) Call `siparisRepository.create()` to simulate müşteri creating an order → verify order exists with `durum = kurye_bekliyor`. (b) Emit the order on the active stream → build the dispatch page widget → verify order appears in waiting panel. (c) Call `siparisRepository.update()` to simulate ops assigning courier (set kurye_id, atanma_saat, durum=devam_ediyor) → verify state transition. (d) Emit updated order on kurye stream → build courier page → verify order appears. (e) Call `siparisRepository.update()` to simulate courier punching timestamps. (f) Call `siparisRepository.update()` to simulate ops finishing with price → verify final state is `tamamlandi` with ucret, bitis_saat, all timestamps populated.
3. Add assertion blocks at each handoff: verify order fields match expected state after each transition. Verify the siparis_log entries were created for key transitions (assign, finish).
4. Run `flutter test test/integration/cross_role_lifecycle_test.dart` and `flutter test` — verify all pass.

## Must-Haves

- [ ] Test covers all 6 lifecycle steps: create → wait → assign → courier-view → timestamp → finish
- [ ] Each handoff point has explicit assertions on order state
- [ ] SiparisLog creation verified for status transitions
- [ ] Final order state: durum=tamamlandi, ucret set, bitis_saat set, all timestamps populated
- [ ] Test passes in isolation and alongside all other tests

## Verification

- `flutter test test/integration/cross_role_lifecycle_test.dart` — passes
- `flutter test` — all 114+ tests pass with zero regressions
- `flutter analyze` — 0 errors, 0 warnings

## Inputs

- `test/helpers/fakes/fake_siparis_repository.dart` — stream emission + CRUD operations
- `test/helpers/fakes/fake_kurye_repository.dart` — courier data
- `test/helpers/fakes/fake_siparis_log_repository.dart` — log verification
- All S03-S07 summaries — understanding of the lifecycle flow and state transitions

## Expected Output

- `test/integration/cross_role_lifecycle_test.dart` — comprehensive lifecycle test proving R008 and the M001 end-to-end flow
