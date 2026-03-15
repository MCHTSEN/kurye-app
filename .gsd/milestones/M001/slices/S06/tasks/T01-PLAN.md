---
estimated_steps: 5
estimated_files: 5
---

# T01: Add getHistory() to SiparisRepository with server-side filtering

**Slice:** S06 — Order History & Editing
**Milestone:** M001

## Description

Add a `getHistory()` method to the `SiparisRepository` contract that queries completed and cancelled orders with optional server-side filters: date range, müşteri, çıkış, uğrama. Implement in both the Supabase and fake repositories. Add a Riverpod provider for the UI to consume. This is the data foundation for the history page.

## Steps

1. Add `getHistory()` to `SiparisRepository` abstract contract with optional named parameters: `DateTime? startDate`, `DateTime? endDate`, `String? musteriId`, `String? cikisId`, `String? ugramaId`. Returns `Future<List<Siparis>>`.
2. Implement in `SupabaseSiparisRepository`: start with `.select()` on siparisler, chain `.gte('created_at', startDate.toIso8601String())` and `.lte('created_at', endDate.toIso8601String())` when provided, chain `.eq()` for each non-null filter, order by `created_at` descending. Add `.i()` logging.
3. Implement in `FakeSiparisRepository`: filter `store.values` client-side matching the same parameters. Sort by `createdAt` descending.
4. Add `siparisHistoryProvider` as a `@riverpod` family provider in `siparis_providers.dart` — takes a filter parameter object or uses individual params. Run `dart run build_runner build --delete-conflicting-outputs`.
5. Verify: `flutter analyze` clean, `flutter test` — all existing tests pass.

## Must-Haves

- [ ] `getHistory()` on `SiparisRepository` contract with all 5 optional filter params
- [ ] Supabase implementation with server-side PostgREST filter chaining
- [ ] Fake implementation with equivalent client-side filtering
- [ ] Riverpod provider exposing the filtered history query
- [ ] Existing tests unbroken

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test` — all existing tests pass
- Provider compiles and is importable from the history page (verified in T02)

## Inputs

- `packages/backend_core/lib/src/siparis_repository.dart` — existing contract to extend
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Supabase query patterns (`.eq()`, `.order()`, `.select()`)
- `test/helpers/fakes/fake_siparis_repository.dart` — in-memory fake with store pattern
- `lib/product/siparis/siparis_providers.dart` — existing providers to add new one alongside

## Expected Output

- `packages/backend_core/lib/src/siparis_repository.dart` — `getHistory()` added to contract
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — server-side filtered implementation
- `test/helpers/fakes/fake_siparis_repository.dart` — client-side filtered implementation
- `lib/product/siparis/siparis_providers.dart` — `siparisHistoryProvider` added
- `lib/product/siparis/siparis_providers.g.dart` — regenerated
