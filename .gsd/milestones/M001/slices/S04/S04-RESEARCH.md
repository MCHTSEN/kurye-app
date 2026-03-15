# S04: Operations Dispatch Screen — Research

**Date:** 2026-03-15

## Summary

S04 is the highest-risk slice in M001 — it builds the central 3-panel dispatch screen that is the core of the application. The good news: the data layer foundation from S02+S03 is solid. `SiparisRepository` already has `create()`, `updateDurum()`, `streamActive()`, and the `Siparis` model covers all DB columns including courier assignment fields (`kurye_id`, `atanma_saat`, `ucret`, `bitis_saat`). Supabase Realtime is proven via `stream(primaryKey: ['id'])` with `inFilter` for active orders.

The work breaks into two clear halves: (1) extending the data layer with `update()`, `getRecentPricing()`, `SiparisLog` model/repository, and a `FakeKuryeRepository` for tests; (2) replacing the `OperasyonEkranPage` placeholder with a real 3-panel screen — order creation form (top), kurye bekleyenler panel (bottom-left), devam edenler panel (bottom-right) — all wired to realtime streams.

The riskiest parts are the 3-panel layout on mobile screens (needs careful scrolling/sizing), the auto-pricing query (needs a new composite index for performance), and keeping the UI responsive while three independent realtime streams update simultaneously. The `streamActive()` stream already serves both panels — we filter client-side by durum to split waiting vs in-progress.

## Recommendation

Build data layer first (SiparisLog model/repo, SiparisRepository.update + getRecentPricing, FakeKuryeRepository, composite index migration), then the 3-panel screen. Reuse the existing `streamActive()` for both panels — one stream subscription, client-side split into `kuryeBekliyor` and `devamEdiyor` lists. This avoids two concurrent Supabase Realtime channels on the same table which could create ordering/consistency issues.

For the 3-panel layout on mobile: use a vertical `ListView` with the form at top, then two `AppSectionCard`-style panels below. On wider screens (tablet/web), the two lower panels can sit side-by-side in a `Row`. Start mobile-first since that's the primary device.

Auto-pricing: add a Supabase RPC function or a simple `.select().eq().eq().eq().eq().order().limit(1)` query. The PostgREST approach is simpler and works within existing patterns. Add a composite index `(musteri_id, cikis_id, ugrama_id, durum, created_at DESC)` for performance.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Realtime order stream | `SupabaseSiparisRepository.streamActive()` | Already proven in S03, handles reconnect, filters active orders |
| Dropdown cascading | `MusteriSiparisPage` form pattern | Exact same cascading dropdown logic — copy pattern for ops form, but add müşteri selector first |
| Test scaffold | `test_app.dart` `pumpApp()` + fakes | Established override pattern with `overrideWithValue` / `overrideWithBuild` |
| CRUD page pattern | `musteri_kayit_page.dart` pattern | Master-detail with `_editingId`, form top, list bottom |

## Existing Code and Patterns

- `packages/backend_supabase/lib/src/supabase_siparis_repository.dart` — Has `create()`, `updateDurum()`, `streamActive()`. Missing: `update()` (for courier assignment fields), `getRecentPricing()` (auto-pricing). `streamActive` uses `inFilter(['kurye_bekliyor', 'devam_ediyor'])` — one stream for both panels.
- `packages/backend_core/lib/src/domain/siparis.dart` — Full model with all columns including `kuryeId`, `atanmaSaat`, `ucret`, `bitisSaat`. No `copyWith()` — update payloads need manual field mapping.
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — Customer order form with cascading dropdowns. Ops form is similar but adds a müşteri selector before the stop dropdowns.
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — **Placeholder** with 3 TODO `AppSectionCard` widgets. Replace entirely.
- `lib/product/siparis/siparis_providers.dart` — Has `siparisStreamActiveProvider` (autoDispose). This is the primary data source for both panels.
- `lib/product/kurye/kurye_providers.dart` — Has `kuryeListProvider` (autoDispose Future). No `getOnline()` method — filter `isActive && isOnline` client-side from `getAll()`, or add `getOnlineKuryeler()` method.
- `lib/product/musteri/musteri_providers.dart` — Has `musteriListProvider` for the müşteri dropdown in the ops order form.
- `test/helpers/fakes/fake_siparis_repository.dart` — Full fake with `StreamController.broadcast`, `emitActive()`, `startWithValue()` extension. Needs `update()` and `getRecentPricing()` added.
- `supabase/migrations/20260315000000_initial_schema.sql` — `siparis_log` table exists with `siparis_id`, `eski_durum`, `yeni_durum`, `degistiren_id`, `aciklama`, `created_at`. No domain model or repository exists yet.
- `supabase/migrations/20260315000100_fix_rls_recursion.sql` — RLS policies: operasyon has full access to `siparisler` and `siparis_log` via `get_my_role() = 'operasyon'`.

## Constraints

- **`siparisler` has a BEFORE UPDATE trigger** — omit `updated_at` from update payloads (same pattern as `musteriler`/`kuryeler` in S02).
- **No `copyWith` on `Siparis`** — manual field mapping in update methods. All 20+ fields must be handled if doing full update, or use partial update with only changed columns.
- **Supabase `stream()` only supports one filter** — can't do `.eq('durum', 'kurye_bekliyor').eq('kurye_id', kuryeId)` on a stream. Must filter client-side from `streamActive()`.
- **RLS already set** — operasyon has full CRUD on `siparisler` and `siparis_log`. No new policies needed.
- **`ugramalar` explicit column selection** — any query joining or looking up ugramalar must use explicit column selection to avoid Geography hex from `lokasyon` field (D010).
- **Auto-pricing query** — needs matching: same `musteri_id` + `cikis_id` + `ugrama_id`, `durum = tamamlandi`, `ORDER BY created_at DESC LIMIT 1`. No composite index exists — add one for performance.
- **`BackendModule` pattern** — new `SiparisLogRepository` must be registered on `BackendModule` with factory method, same as all other repos.

## Common Pitfalls

- **Partial vs full update on `siparisler`** — Using full-row update would overwrite fields set by other roles (courier timestamps). The `update()` method should accept specific field maps, not reconstruct the entire `Siparis` object. Alternatively, add targeted methods: `assignKurye(siparisId, kuryeId)`, `finishOrder(siparisId, ucret)`.
- **Three concurrent stream subscriptions on one page** — `streamActive()` is one channel. If we also stream `kuryeler` for the courier dropdown, that's a second channel. Keep the courier list as a `Future` (refetched on pull or button press), not a stream, to reduce Realtime load.
- **Auto-pricing returning null** — First order for a customer+route has no historical match. Must show a warning and let operasyon enter price manually. UI needs to handle both auto-populated and manual-entry states.
- **Checkbox selection state vs realtime updates** — If the order list updates via realtime while checkboxes are selected, selection state could go stale (selected order might have been assigned by another operasyon). Clear selection on stream emission, or validate selection before action.
- **`siparis_log` insert timing** — Log should be created in the same logical transaction as the status update. Since Supabase PostgREST doesn't support multi-table transactions, consider a DB trigger or a Supabase RPC function that does both atomically. Alternatively, insert log client-side after successful status update (simpler, slightly less reliable).

## Open Risks

- **Mobile 3-panel layout** — Spec says "Üstte: Sipariş oluşturma paneli, altta: Kurye Bekleyenler bunun yanında Devam edenler." Side-by-side panels on mobile is tight. May need a `TabBar` toggle between the two lower panels on narrow screens, or a scrollable horizontal layout.
- **Concurrent operasyon users** — If two operasyon users are on the dispatch screen simultaneously, they might try to assign the same courier to different orders. No locking mechanism exists. Realtime stream will show the conflict post-fact but won't prevent it.
- **Auto-pricing query without composite index** — Without `idx_siparisler_pricing(musteri_id, cikis_id, ugrama_id, durum, created_at DESC)`, the query scans by `musteri_id` then filters. With a small order volume this is fine, but should add the index proactively.
- **SiparisLog consistency** — Client-side log insertion after status update means: if the update succeeds but log insert fails (network issue), the status change is unlogged. Acceptable for MVP but worth noting. A DB trigger would be more reliable but adds migration complexity.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter layout | `flutter/skills@flutter-layout` | available (1.2K installs) — useful for 3-panel responsive layout |
| Flutter performance | `flutter/skills@flutter-performance` | available (1.2K installs) — relevant for multi-stream realtime page |
| Supabase best practices | `supabase/agent-skills@supabase-postgres-best-practices` | available (34.1K installs) — relevant for RPC functions and index design |
| Riverpod | `juparave/dotfiles@flutter-riverpod-expert` | available (332 installs) — low install count, skip |
| Mobile design | `mobile-design` | installed — already available for layout decisions |
| Senior mobile | `senior-mobile` | installed — already available for Flutter patterns |

## Sources

- Spec `moto-kurye.md` sections 2-2-a, 2-2-b, 2-3 — 3-panel layout: form top, kurye bekleyenler bottom-left with checkboxes + courier dropdown, devam edenler bottom-right with checkboxes + finish button
- `siparis_log` DB schema — `eski_durum`, `yeni_durum`, `degistiren_id`, `aciklama`, `created_at`
- Auto-pricing rule (spec 2-3): "sistem tablodan daha önce yapılmış en yakın tarihteki siparişin ücretini biten siparişe eklesin, yoksa operasyon personeline uyarı versin"
- S03 forward intelligence: `SiparisRepository` needs `update()` and `getRecentPricing()` added
- D010: Skip lokasyon Geography in queries
- D015: `stream(primaryKey: ['id'])` + filter pattern for Supabase Realtime
- D016: Controlled `DropdownButtonFormField.value` + `setState` pattern
