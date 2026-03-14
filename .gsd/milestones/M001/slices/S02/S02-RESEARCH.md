# S02: Master Data CRUD — Research

**Date:** 2026-03-15

## Summary

S02 delivers CRUD for four master data entities (müşteri, uğrama, müşteri personel, kurye) plus the role request approval screen — all for the operasyon role. The foundation is solid: DB tables exist with RLS policies, the Supabase repository pattern is established, placeholder pages and routes are wired, and the drawer navigation already has menu items pointing to the right paths.

The main implementation work is: 4 domain models, 4 repository contracts + Supabase implementations, Riverpod providers, and replacing 4 placeholder pages with real CRUD forms/lists. The role request approval screen is the fifth deliverable — the `pendingRoleRequestsProvider` and `RoleRequestRepository.approveRequest()` already exist, so this is mostly UI.

One design decision needs attention: the `ugramalar` table has a `lokasyon GEOGRAPHY(POINT, 4326)` column. PostgREST returns Geography as a hex-encoded string. For S02, location is deferred to M002 — we can skip Geography input and store null for `lokasyon`, focusing on `ugrama_adi` and `adres` text fields. This avoids a PostGIS serialization rabbit hole.

## Recommendation

Follow the existing S01 patterns exactly:
- Plain dart domain models in `packages/backend_core/lib/src/domain/` with hand-written `fromJson`/`toJson`
- Abstract repository contracts in `packages/backend_core/lib/src/`
- Supabase implementations in `packages/backend_supabase/lib/src/`
- Factory methods on `BackendModule`, overridden in `SupabaseBackendModule`
- Riverpod providers in `lib/product/<entity>/` with `@Riverpod(keepAlive: true)` for repositories
- Replace placeholder pages in `lib/feature/operasyon/presentation/` with real CRUD UI

For the CRUD UI pattern: list view at bottom, form panel at top (spec says "alt tarafta excel tablosu, tıklandığında üst panele çıksın"). This is a master-detail layout within the same page.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Supabase CRUD queries | `SupabaseClient.from().select/insert/update/delete` | Already used in `SupabaseUserProfileRepository` — follow the pattern |
| Async state in UI | `AsyncValue` + `AppAsyncView` widget | Handles loading/error/data states consistently |
| Role request approval | `RoleRequestRepository.approveRequest()` + `pendingRoleRequestsProvider` | Backend logic exists — just needs UI |
| Realtime list updates | `SupabaseClient.from().stream(primaryKey:)` | Used in `watchPendingRequests()` — follow for live entity lists |
| Form validation | Flutter's built-in `Form` + `TextFormField.validator` | Standard approach, used in `RoleSelectionPage` |
| Navigation | `CustomRoute` enum paths + drawer | Routes and drawer items already defined |

## Existing Code and Patterns

- `packages/backend_core/lib/src/domain/app_user_profile.dart` — Domain model pattern: plain class, `fromJson` factory, `toJson` method, no codegen. Follow this for `Musteri`, `Ugrama`, `MusteriPersonel`, `Kurye`.
- `packages/backend_core/lib/src/user_profile_repository.dart` — Repository contract pattern: abstract class with Future-returning methods. Follow for new repositories.
- `packages/backend_supabase/lib/src/supabase_user_profile_repository.dart` — Supabase implementation pattern: `_client.from('table').select/insert/update`, `AppLogger` with `LogTag`, constructor takes `SupabaseClient`.
- `packages/backend_supabase/lib/src/supabase_role_request_repository.dart` — More complete pattern showing: `.maybeSingle()`, `.order()`, `.limit()`, `.eq()`, and `stream()` for realtime. Also shows `.upsert()`.
- `packages/backend_core/lib/src/backend_module.dart` — Optional factory pattern: `UserProfileRepository? createXxxRepository() => null;`. Add 4 new factory methods.
- `packages/backend_supabase/lib/src/supabase_backend_module.dart` — Override factory methods with `Supabase.instance.client`.
- `lib/product/role_request/role_request_providers.dart` — Provider pattern: `@Riverpod(keepAlive: true)` for repository, `@riverpod` for data streams/queries.
- `lib/product/user_profile/user_profile_providers.dart` — Provider that watches auth state and fetches data. Good pattern for fetching entity lists.
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — Drawer navigation already has menu items for all CRUD pages with TODO comments. Need to wire `Navigator.pushNamed` or `context.router.push`.
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — Placeholder page to replace. Already has correct AppBar title and uses `ProjectPadding`.
- `lib/feature/role_selection/presentation/role_selection_page.dart` — Form page pattern: `ConsumerStatefulWidget`, `TextEditingController`, submit button with loading state.
- `lib/app/router/custom_route.dart` — All routes defined: `musteriKayit`, `musteriPersonelKayit`, `ugramaYonetim`. No kurye management route exists — may need to add one, or reuse the kurye list on the dashboard.
- `lib/product/widgets/app_primary_button.dart` — Reusable button with loading state.
- `lib/product/widgets/app_section_card.dart` — Card wrapper for form sections.

## Constraints

- **RLS enforces operasyon-only access** — All master data tables use `get_my_role() = 'operasyon'` for write access. No extra RLS migration needed; operasyon has full CRUD on all tables already.
- **No codegen for domain models** — `backend_core` has zero dependencies beyond `logger`. Models are plain dart with hand-written JSON. Don't introduce freezed or json_serializable.
- **`lokasyon` column is Geography type** — PostgREST returns Geography as hex WKB string (e.g., `0101000020E6100000...`). Supabase Dart client doesn't auto-deserialize this. For S02, skip geography input — store null. Location entry deferred to M002 (R019).
- **`not_id` in siparisler references ugramalar** — The spec shows "Not" as a dropdown from the same ugramalar table. This means uğramalar serve dual purpose: stops AND note categories. No impact on S02 CRUD (same table), but worth noting for S03.
- **`musteri_personelleri.user_id` links to `app_users`** — When creating a customer staff record, operasyon may optionally link it to an app_user (so that person can log in as müşteri_personel). This linkage also needs `app_users.musteri_id` to be set.
- **Role request approval gap** — Current `approveRequest()` creates `app_users` but doesn't set `musteri_id` for müşteri_personel role. For S02, the approval screen should let operasyon select which müşteri this person belongs to (for müşteri_personel requests only).
- **Drawer navigation is not wired** — All drawer `ListTile` onTap handlers have TODO comments. Must wire them with `context.router.pushNamed(CustomRoute.xxx.path)`.
- **No kurye management route in `CustomRoute`** — Kurye CRUD doesn't have a dedicated route. Options: add one (e.g., `/operasyon/kurye`), or embed it in the dashboard. A dedicated route is cleaner — add it to `CustomRoute` enum.
- **`BackendModule` exports must be updated** — New repository contracts need exports in `backend_core.dart`. New Supabase implementations need exports in `backend_supabase.dart`.

## Common Pitfalls

- **Forgetting `backend_core.dart` barrel export** — Every new domain model and repository contract MUST be added to the barrel file or other packages can't import them.
- **RLS blocking anon-key test queries** — The anon key is subject to RLS. For testing CRUD, must login as an operasyon user first, or use service_role key for seed data (per D008).
- **Geography column in select queries** — If `ugramalar` select includes `lokasyon`, PostgREST returns hex WKB which may cause deserialization issues. Explicitly select columns excluding `lokasyon`, or handle null gracefully in fromJson.
- **`updated_at` trigger conflict** — Tables `musteriler`, `kuryeler` have `BEFORE UPDATE` triggers that auto-set `updated_at`. Don't include `updated_at` in update payloads — let the trigger handle it.
- **`musteri_id` on app_users for customer staff** — If operasyon creates a `musteri_personelleri` record and links it to a user, that user's `app_users.musteri_id` must also be set. Otherwise, RLS policies for müşteri data access (which check `app_users.musteri_id`) will block that user.
- **Riverpod codegen** — After adding new providers, must run `dart run build_runner build --delete-conflicting-outputs` or the `.g.dart` files won't exist.

## Open Risks

- **Approval flow for müşteri_personel role** — The current `approveRequest()` doesn't handle `musteri_id`. Need to extend it so operasyon can assign a customer when approving müşteri_personel requests. This is a repository contract change in `backend_core`.
- **No existing widget tests for CRUD pages** — Test helpers exist (`pumpApp`, `createTestProviderContainer`) but there are no CRUD-specific fakes yet. Need fake repositories for müşteri, uğrama, personel, kurye.
- **Drawer routing not tested** — The drawer exists but navigation isn't wired. Could reveal auto_route issues when navigating between operasyon sub-screens.
- **`select()` on ugramalar returning Geography hex** — If we do `_client.from('ugramalar').select()`, the `lokasyon` column returns a hex string. Either use `.select('id, musteri_id, ugrama_adi, adres, is_active, created_at')` to exclude it, or handle the hex gracefully in `fromJson` by ignoring it.

## Requirement Mapping

| Requirement | Owned/Supports | What S02 delivers |
|-------------|---------------|-------------------|
| R003 — Customer CRUD | Owned | Müşteri form + list page, `Musteri` model, `MusteriRepository` |
| R004 — Stop CRUD with location | Owned | Uğrama form + list page (without Geography input), `Ugrama` model, `UgramaRepository` |
| R005 — Customer staff CRUD | Owned | Personel form + list page, `MusteriPersonel` model, `MusteriPersonelRepository` |
| R006 — Courier management | Owned | Kurye form + list page, `Kurye` model, `KuryeRepository` |
| R002 — Role request approval | Supports | Approval screen in operasyon (backend already exists) |

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter | `jeffallan/claude-skills@flutter-expert` | available (4.9K installs) |
| Supabase | `bobmatnyc/claude-mpm-skills@supabase-backend-platform` | available (209 installs) |
| Riverpod | `juparave/dotfiles@flutter-riverpod-expert` | available (332 installs) |
| Mobile design | `mobile-design` | installed |
| Senior mobile | `senior-mobile` | installed |

## Sources

- DB schema fully defined in `supabase/migrations/20260315000000_initial_schema.sql`
- RLS policies updated in `supabase/migrations/20260315000100_fix_rls_recursion.sql` — all tables use `get_my_role()` function
- Spec requirements from `moto-kurye.md` — explicit mention of "Müşteri kayıt ekranı" and "Müşteri personel kayıt ekranı"
- Existing pattern established by S01 in `packages/backend_core/` and `packages/backend_supabase/`
