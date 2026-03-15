# S05: Courier Workflow — Research

**Date:** 2026-03-15

## Summary

S05 delivers two requirements: R011 (courier order acceptance & timestamp punching) and R016 (courier active/passive toggle). The data layer is mostly ready — `KuryeRepository.updateOnlineStatus()` already handles the toggle, and `SiparisRepository.update(id, fields)` already supports the partial updates needed for timestamp punching. Two data layer additions are needed: (1) `KuryeRepository.getByUserId(String userId)` so the courier can resolve their `kuryeId` from their auth UID, and (2) `SiparisRepository.streamByKuryeId(String kuryeId)` so the courier sees assigned orders in realtime. The UI replaces the placeholder `KuryeAnaPage` with a single-screen layout: active/passive switch at top, assigned orders list below, each order showing tap-to-punch timestamp buttons for çıkış/uğrama/uğrama1. RLS policies are already deployed and correctly scoped — courier can SELECT/UPDATE their own orders and read/write their own `kuryeler` record.

The main risk is the realtime stream for courier orders. The existing `streamActive()` uses `.inFilter('durum', [...])` which filters across all orders. The courier stream needs `.eq('kurye_id', kuryeId)` plus `.inFilter('durum', ['devam_ediyor'])` — but Supabase `stream()` only supports one filter type at a time (`.eq()` OR `.inFilter()`, not both chained). The pragmatic solution: stream by `kurye_id` only and filter `durum` client-side, same pattern as D019 (single stream, client-side split).

## Recommendation

Two tasks:

**T01 — Data layer extensions:** Add `getByUserId(userId)` to `KuryeRepository` contract + Supabase implementation. Add `streamByKuryeId(kuryeId)` to `SiparisRepository` contract + Supabase implementation. Update both fake repositories. Add a `currentKuryeProvider` in `kurye_providers.dart` that resolves the logged-in courier's `Kurye` record via `getByUserId`. Add `siparisStreamByKuryeProvider(kuryeId)` in `siparis_providers.dart`. Unit test the new domain lookup.

**T02 — Courier screen UI:** Replace placeholder `KuryeAnaPage` with the real screen. Top: active/passive `Switch` backed by `updateOnlineStatus()`. Below: list of `devam_ediyor` orders assigned to this courier, each with three tap-to-punch buttons (Çıkış, Uğrama, Uğrama1). Each button sets the corresponding `*_saat` field to `DateTime.now()` via `update(id, fields)`. Completed orders (all timestamps set or order status changes to `tamamlandi`) drop off the list automatically via the realtime stream. Widget tests for: toggle rendering, order list, timestamp punch action.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Partial field update on siparisler | `SiparisRepository.update(id, Map<String, dynamic>)` | Already handles concurrent multi-role writes without clobbering. D018 pattern. |
| Active/passive toggle | `KuryeRepository.updateOnlineStatus(id, isOnline:)` | Already implemented in S02, including Supabase implementation. |
| Realtime order stream | `SupabaseSiparisRepository.stream()` pattern | Copy the `.stream(primaryKey: ['id']).eq()` pattern from `streamByMusteriId`. |
| Widget test infrastructure | `TestApp` + `FakeKuryeRepository` + `FakeSiparisRepository` | Established fake pattern with stream support, used in S03/S04 tests. |

## Existing Code and Patterns

- `packages/backend_core/lib/src/kurye_repository.dart` — Has `updateOnlineStatus()` but missing `getByUserId()`. Need to add it.
- `packages/backend_supabase/lib/src/supabase_kurye_repository.dart` — Full CRUD impl. `getByUserId` just needs `.eq('user_id', userId).maybeSingle()`.
- `packages/backend_core/lib/src/siparis_repository.dart` — Has `streamActive()` and `streamByMusteriId()`. Need to add `streamByKuryeId()` using the same pattern.
- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — `streamByMusteriId` is the exact template: `.stream(primaryKey: ['id']).eq('musteri_id', musteriId)`. Replace with `.eq('kurye_id', kuryeId)`.
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — Placeholder with TODO markers. Replace entirely.
- `lib/product/kurye/kurye_providers.dart` — Has `kuryeRepositoryProvider` and `kuryeListProvider`. Add `currentKuryeProvider`.
- `lib/product/siparis/siparis_providers.dart` — Has `siparisStreamActiveProvider` and `siparisStreamByMusteriProvider`. Add `siparisStreamByKuryeProvider`.
- `test/helpers/fakes/fake_kurye_repository.dart` — Full in-memory fake. Add `getByUserId()`.
- `test/helpers/fakes/fake_siparis_repository.dart` — Has stream support with `_controllers` map. Add `streamByKuryeId()` following `streamByMusteriId()` pattern.
- `lib/app/router/custom_route.dart` — `kuryeAna` route already registered at `/kurye/ana`.
- `lib/app/router/guards/app_access_guard.dart` — Routes courier role to `kuryeAna`. No changes needed.

## Constraints

- **Supabase `stream()` supports only one filter** — `.eq()` OR `.inFilter()`, not both chained. Courier stream must filter by `kurye_id` only, then split by `durum` client-side.
- **RLS policy `kurye_siparisler`** scopes SELECT to `kurye_id = (SELECT id FROM kuryeler WHERE user_id = auth.uid())`. The courier can only see their own assigned orders — no extra client-side security needed.
- **RLS policy `kurye_siparisler_update`** allows UPDATE with same scope. Courier can only update their own orders' timestamps.
- **RLS policy `kurye_kuryeler_self`** — `FOR ALL USING (user_id = auth.uid())`. Courier can read/write their own `kuryeler` record for the active/passive toggle.
- **`updated_at` is handled by BEFORE UPDATE trigger** on both `kuryeler` and `siparisler` tables — don't include it in update payloads (D018).
- **`AppUserProfile` has no `kuryeId` field** — only `musteriId`. Must resolve `kuryeId` via `KuryeRepository.getByUserId()` using the courier's auth UID.
- **Supabase Realtime table publication** — `kuryeler` and `siparisler` tables are already published for Realtime (verified from S03/S04 stream usage).

## Common Pitfalls

- **Resolving kuryeId on every build** — The courier's `kuryeId` is static for the session. Use a `keepAlive` provider that resolves once and caches. Don't re-query on every widget rebuild.
- **Stream filter mismatch with RLS** — The `stream()` call may return only courier's own orders due to RLS, making the `.eq('kurye_id', kuryeId)` filter technically redundant at the DB level. But include it anyway for correctness — the stream filter defines the Realtime channel subscription scope.
- **Timestamp already set** — Courier might accidentally tap a timestamp button twice. The UI should show the existing time and either disable the button or confirm overwrite. Spec doesn't specify — safe default is to show set time and disable re-tap.
- **Order "drops off" when completed** — The spec says "İşler bitince ekrandan düşsün" (3-4). The courier doesn't set `durum` to `tamamlandi` — operasyon does via "Bitir". When ops finishes the order, the realtime stream stops including it automatically because the status changes. No courier-side action needed for removal.
- **No confirmation/acceptance status change** — Spec says "Siparişi aldığını onaylasın" (3-2). The order is already in `devam_ediyor` status when assigned by ops. "Accepting" is informational — the courier sees it and starts working. There's no separate acceptance status in the `siparis_durum` enum. Implement as a visual confirmation (e.g., the order appearing in the courier's list IS the acceptance). No DB state change needed.

## Open Risks

- **Supabase Realtime stream by `kurye_id`** — This is the first stream filtered by `kurye_id`. While `streamByMusteriId` proves the `.eq()` filter works, the combination with RLS policy `kurye_siparisler` hasn't been tested in production. If the RLS policy and stream filter conflict, the stream might return empty. Mitigate by testing on live Supabase during integration verification.
- **Courier with no `kuryeler` record** — If a user has `role=kurye` in `app_users` but no matching row in `kuryeler` (broken state from manual DB edits or incomplete onboarding), `getByUserId` returns null. The UI must handle this gracefully — show an error message, not crash.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter | `flutter/skills@flutter-layout` | available (1.2K installs) — layout patterns, useful but not critical |
| Flutter | `flutter/skills@flutter-performance` | available (1.2K installs) — not needed for this slice |
| Supabase | `supabase/agent-skills@supabase-postgres-best-practices` | available (34.2K installs) — general best practices, could help |
| Mobile design | `mobile-design` | installed — general mobile patterns |
| Senior mobile | `senior-mobile` | installed — expert mobile dev |

No skills are critical to install for this slice. The work is straightforward CRUD + stream extension following established patterns.

## Sources

- `moto-kurye.md` spec sections 3-1, 3-2, 3-3 — courier screen requirements (active/passive, accept order, punch timestamps)
- `supabase/migrations/20260315000000_initial_schema.sql` — RLS policies for `kurye_*` and table schemas
- S04 summary — `SiparisRepository.update()` partial update pattern, stream architecture decisions (D018, D019)
- Existing codebase — `streamByMusteriId()` as template for `streamByKuryeId()`
