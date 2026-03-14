# S03: Order Creation & Customer Tracking — Research

**Date:** 2026-03-15

## Summary

S03 introduces the `Siparis` domain model, `SiparisRepository` contract and Supabase implementation, and replaces two placeholder müşteri pages with real order creation + active order tracking. The customer creates orders with cascading dropdowns (select müşteri's uğramalar), and operations sees new orders arrive via Supabase Realtime. This is the first slice to use Supabase Realtime — the stream pattern needs to be established here for reuse in S04/S05/S08.

The data layer follows the same pattern as S02 (domain model → abstract repo → Supabase impl → BackendModule factory → Riverpod providers). The main new challenge is the Realtime subscription: Supabase's `stream()` API combines initial Postgrest fetch with Realtime changes into a single `Stream<List<Map>>` — this is cleaner than manual channel management and handles reconnection automatically. RLS policies already correctly scope customer access.

One gap: `MusteriPersonelRepository` lacks a `getByUserId()` method. The customer order form needs to resolve the current user → their `musteri_personelleri` record → get `personel_id` for the order. This method must be added.

## Recommendation

1. **Domain model first** — `Siparis` model + `SiparisDurum` enum following the existing plain-Dart pattern. No `siparis_log` model yet (that's S04's concern).
2. **Repository contract** — `SiparisRepository` with `create()`, `getByMusteriId()`, `getByDurum()`, `streamByMusteriId()`, `streamActive()`, and `updateDurum()`. Add `getByUserId()` to `MusteriPersonelRepository`.
3. **Supabase implementation** — Use `stream()` API with `.eq()` filter for realtime scoped lists. Use explicit column selection (like ugrama) to avoid any future Geography column issues, though siparisler has none currently.
4. **Customer page** — Replace placeholder `MusteriSiparisPage` with order creation form (cascading dropdowns: musteri auto-selected from profile, stops loaded by musteriId) + active orders list below using `streamByMusteriId`. Replace `MusteriGecmisPage` with completed orders filtered by date.
5. **Realtime verification** — Prove that when customer inserts an order, operasyon's stream picks it up without refresh.

Use `stream(primaryKey: ['id'])` for realtime data — it combines initial fetch + live updates. The `inFilter('durum', [...])` filter can scope to active statuses only.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Realtime + initial data | Supabase `stream()` API | Handles reconnection, initial fetch, and delta merging automatically — no manual channel management |
| Cascading dropdown state | Riverpod `ugramaListByMusteriProvider(musteriId)` | Already exists from S02, triggers reload when musteriId changes |
| Customer scoping | `AppUserProfile.musteriId` | Auth profile already carries the customer's company ID — no extra lookup needed |
| RLS enforcement | Existing Supabase RLS policies | `musteri_personel_siparisler_insert` and `_select` policies already scope correctly |
| Form pattern | `MusteriKayitPage` pattern from S02 | ConsumerStatefulWidget with form key, controllers, submit handler, list below |
| Logging | `AppLogger(tag: LogTag.data)` | Established in S02 for all data repositories |

## Existing Code and Patterns

- `packages/backend_core/lib/src/domain/musteri.dart` — Domain model pattern: plain Dart class with `fromJson`/`toJson`, nullable fields, default values
- `packages/backend_core/lib/src/musteri_repository.dart` — Abstract repository contract pattern: Future-based CRUD methods
- `packages/backend_supabase/lib/src/supabase_musteri_repository.dart` — Supabase CRUD impl pattern: `_client`, `_log`, `_table` constant, `.insert().select().single()` for create, `.update().eq().select().single()` for update
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart` — Explicit column selection pattern (avoid Geography hex) — siparisler doesn't need this now but sets precedent
- `packages/backend_core/lib/src/backend_module.dart` — Factory method pattern: `createXxxRepository() => null` in base, override in Supabase module
- `lib/product/musteri/musteri_providers.dart` — Provider pattern: keepAlive for repo, autoDispose for data lists
- `lib/product/ugrama/ugrama_providers.dart` — Family provider pattern: `ugramaListByMusteri(ref, musteriId)` for filtered queries
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — Full CRUD page pattern to follow for form structure
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — Placeholder to be replaced (uses `AppSectionCard`, `ProjectPadding`, `currentUserProfileProvider`)
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — Placeholder to be replaced
- `lib/app/router/custom_route.dart` — Routes `musteriSiparis` and `musteriGecmis` already registered
- `lib/app/router/app_router.dart` — Routes already wired to existing placeholder pages
- `test/helpers/fakes/fake_musteri_repository.dart` — In-memory fake pattern for testing

## Constraints

- **RLS: Customer can only INSERT orders for their own `musteri_id`** — The insert payload must have `musteri_id` matching the user's `app_users.musteri_id`. Enforced by `musteri_personel_siparisler_insert` policy.
- **RLS: Customer cannot UPDATE orders** — No update policy exists for müşteri_personel role on siparisler. Per spec 1-3: "Bundan sonraki durumlara müdahale edemesin."
- **`olusturan_id` must be `auth.uid()`** — The column references `app_users(id)` which equals the Supabase Auth UID.
- **`personel_id` resolution** — Need to look up `musteri_personelleri` where `user_id = auth.uid()` to get the current user's personel record ID. No existing repo method for this.
- **`not_id` references `ugramalar`** — The "Not" dropdown also loads from ugramalar for the selected customer (same source as Çıkış/Uğrama/Uğrama1).
- **`siparisler` has BEFORE UPDATE trigger** — Must omit `updated_at` from update payloads (same pattern as musteriler/kuryeler).
- **Realtime already configured** — `ALTER PUBLICATION supabase_realtime ADD TABLE siparisler` is in the migration. No additional DB config needed.
- **`siparis_durum` enum in DB** — Values: `kurye_bekliyor`, `devam_ediyor`, `tamamlandi`, `iptal`. Domain model enum must match exactly.
- **`ucret` is NUMERIC(10,2)** — Map to `double?` in Dart (comes back as `num` from JSON).
- **Supabase stream() RLS interaction** — The `stream()` API uses Postgrest for initial fetch (respects RLS) and Realtime for changes (Realtime broadcasts all changes, but `stream()` filters client-side by the specified filters). For customer scoping, use `.eq('musteri_id', musteriId)` filter.

## Common Pitfalls

- **Realtime doesn't respect RLS by default** — Supabase Realtime broadcasts INSERT/UPDATE/DELETE to all channel subscribers. The `stream()` API handles this by maintaining a client-side list and filtering. But if using raw `onPostgresChanges()`, you'd get all changes regardless of RLS. Stick with `stream()` + filter.
- **Stream disposal** — Riverpod `StreamProvider` auto-cancels when no widgets are listening, which handles Realtime channel cleanup. But `keepAlive` stream providers would leak — use `autoDispose` for all stream providers.
- **Customer personel without musteri_id** — If `AppUserProfile.musteriId` is null for a customer user, the order form breaks. This shouldn't happen if approval flow (S02 RolOnayPage) works correctly, but add a guard.
- **Cascading dropdown reset** — When the customer is auto-selected (from profile), uğramalar load immediately. But if the customer changes (operasyon flow), dependent dropdowns must reset. Customer page has fixed müşteri so this is simpler.
- **`stream()` filter limitations** — The `stream()` API only supports simple equality/comparison filters. For "active orders" (durum IN [kurye_bekliyor, devam_ediyor]), use `.inFilter('durum', ['kurye_bekliyor', 'devam_ediyor'])`.
- **Timestamp fields** — `cikis_saat`, `ugrama_saat`, `ugrama1_saat`, `atanma_saat`, `bitis_saat` are all nullable TIMESTAMPTZ. Map to `DateTime?`. These are set by courier (S05) and operations (S04), not by the customer.

## Open Risks

- **Realtime latency with RLS** — First time using Supabase Realtime in this app. If stream() performance is poor or reconnection is flaky on iOS, it could block S03 verification. Mitigation: test early with a simple stream before building the full UI.
- **Customer personel_id resolution** — Need to add `getByUserId(String userId)` to `MusteriPersonelRepository`. If the customer user's personel record doesn't exist or doesn't have `user_id` set, the order form can't resolve personel_id. Need to handle gracefully (allow null personel_id or show error).
- **Stream provider invalidation** — When a new order is created via REST, the `stream()` should pick it up automatically via Realtime. But if Realtime is delayed, the UI might not update instantly. Need to verify this works reliably.
- **`not_id` naming confusion** — In the DB schema, `not_id` references `ugramalar` — it's a dropdown that selects an ugrama as a "note destination". The spec names it "Not (Dropdown)" which is non-obvious. Document this clearly in the domain model.

## Schema Reference

```sql
CREATE TYPE siparis_durum AS ENUM (
  'kurye_bekliyor',
  'devam_ediyor',
  'tamamlandi',
  'iptal'
);

CREATE TABLE siparisler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id),
  personel_id UUID REFERENCES musteri_personelleri(id),
  kurye_id UUID REFERENCES kuryeler(id),
  cikis_id UUID NOT NULL REFERENCES ugramalar(id),
  ugrama_id UUID NOT NULL REFERENCES ugramalar(id),
  ugrama1_id UUID REFERENCES ugramalar(id),           -- optional
  not_id UUID REFERENCES ugramalar(id),                -- "Not" dropdown, ugrama ref
  not1 TEXT,                                            -- free text note
  durum siparis_durum NOT NULL DEFAULT 'kurye_bekliyor',
  ucret NUMERIC(10,2),
  cikis_saat TIMESTAMPTZ,
  ugrama_saat TIMESTAMPTZ,
  ugrama1_saat TIMESTAMPTZ,
  atanma_saat TIMESTAMPTZ,
  bitis_saat TIMESTAMPTZ,
  olusturan_id UUID REFERENCES app_users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
-- BEFORE UPDATE trigger: auto-updates updated_at
-- Indexes: durum, musteri_id, kurye_id, created_at DESC
-- Realtime: published via supabase_realtime
-- RLS: operasyon full, customer select+insert (own musteri_id), kurye select+update (own kurye_id)
```

## Deliverables Map

| Deliverable | Requirement | Notes |
|-------------|-------------|-------|
| `Siparis` domain model | R007 | All columns except Geography-related |
| `SiparisDurum` enum | R007, R008 | 4 values matching DB enum |
| `SiparisRepository` contract | R007, R008, R013 | create, getByMusteriId, getByDurum, streamByMusteriId, streamActive, updateDurum |
| `SupabaseSiparisRepository` | R007, R008, R013 | Supabase impl with `stream()` for realtime |
| BackendModule + barrel exports | R007 | Factory method + exports |
| Riverpod providers (repo, stream, list) | R007, R008, R013 | autoDispose stream providers for realtime |
| `MusteriPersonelRepository.getByUserId()` | R007 | Needed to resolve current user → personel_id |
| `MusteriSiparisPage` (order form + active list) | R007, R008, R013 | Replace placeholder with cascading dropdowns + realtime active order list |
| `MusteriGecmisPage` (history with date filter) | R013 | Replace placeholder with completed order list + date filtering |

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Supabase | `supabase/agent-skills@supabase-postgres-best-practices` (34K installs) | available — not installed. Postgres-focused, may help with RLS/query optimization. |
| Flutter | `jeffallan/claude-skills@flutter-expert` (4.9K installs) | available — not installed. General Flutter skill. |
| Flutter Riverpod | `juparave/dotfiles@flutter-riverpod-expert` (332 installs) | available — not installed. Low install count. |
| Mobile Design | `mobile-design` | installed |
| Senior Mobile | `senior-mobile` | installed |
| QA Testing Mobile | `qa-testing-mobile` | installed |

## Sources

- Supabase `stream()` API: combines Postgrest initial fetch + Realtime into one `Stream<List<Map>>`, supports `.eq()`, `.inFilter()` etc. (source: [Supabase Dart Reference](https://supabase.com/docs/reference/dart/or))
- Supabase `onPostgresChanges()`: raw channel subscription, doesn't filter by RLS — prefer `stream()` (source: [Supabase Dart Reference](https://supabase.com/docs/reference/dart/auth-getuseridentities))
- Spec: moto-kurye.md sections 1-1 through 1-5 define customer order creation and tracking requirements
- Spec: moto-kurye.md section 2-2-a defines operasyon order creation panel with same dropdown pattern
