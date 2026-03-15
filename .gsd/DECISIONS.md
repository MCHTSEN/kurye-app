# Decisions Register

<!-- Append-only. Never edit or remove existing rows.
     To reverse a decision, add a new row that supersedes it.
     Read this file at the start of any planning or research phase. -->

| # | When | Scope | Decision | Choice | Rationale | Revisable? |
|---|------|-------|----------|--------|-----------|------------|
| D001 | M001/S01 | arch | Backend provider | Supabase only | Only backend needed for this project — no mock/custom/firebase implementations for new features | No |
| D002 | M001/S01 | arch | RLS recursion solution | `get_my_role()` SECURITY DEFINER function | Avoids infinite recursion when app_users RLS policies reference app_users table | No |
| D003 | M001/S01 | arch | Profile-less user handling | Redirect to /role-selection | Users without app_users entry see role selection page, not an error | No |
| D004 | M001/S01 | auth | Email confirmation | Enabled (can disable for testing) | Production security, but user allows disabling for dev | Yes — disable for testing |
| D005 | M001/S01 | arch | Role request flow | role_requests table + approval by operasyon | Controlled onboarding — new users must be approved before accessing the app | No |
| D006 | M001/S01 | convention | Guard navigation | Direct repository.getProfile() instead of stream provider | Avoids async stream hang in guard — profile fetched synchronously from Supabase | No |
| D007 | M001/S01 | convention | Error messages | Turkish user-friendly messages via _friendlyError() | Auth errors translated to clear Turkish messages instead of raw exceptions | No |
| D008 | M001 | arch | Admin DB operations | service_role key via curl | anon key blocked by RLS (correct behavior), service_role key used for admin seeding/queries | No |
| D009 | M001 | convention | MCP tools | mobile-mcp for iOS simulator UI testing, Supabase MCP for DB (curl fallback) | Automated UI verification during development | No |
| D010 | M001/S02 | convention | Geography column handling | Skip `lokasyon` in domain model and SELECT queries | PostgREST returns Geography as hex WKB — defer to M002 (R019). Use explicit column selection to exclude. | Yes — add in M002 |
| D011 | M001/S02 | convention | CRUD page pattern | Master-detail: form in AppSectionCard at top, list at bottom, tap to edit | Follows spec "alt tarafta excel tablosu, tıklandığında üst panele çıksın" | No |
| D012 | M001/S02 | arch | Approval flow musteriId | Extend `approveRequest()` with optional `musteriId` parameter | müşteri_personel role needs `musteri_id` on `app_users` for RLS data access | No |
| D013 | M001/S02/T01 | convention | LogTag.data | Added `LogTag.data` enum value + config field | Master data CRUD repos need a distinct log tag from `LogTag.auth`. All 4 Supabase repos use `LogTag.data`. | No |
| D014 | M001/S02/T01 | convention | Named bool in KuryeRepository | `updateOnlineStatus(id, {required bool isOnline})` | Positional booleans flagged by `very_good_analysis` — use named parameter | No |
| D015 | M001/S03/T01 | pattern | Realtime stream pattern | `stream(primaryKey: ['id'])` + `.eq()`/`.inFilter()` + `handleError` | First Supabase Realtime usage — `stream()` combines initial fetch + live updates, auto-reconnects. Stream providers must be `autoDispose` to prevent channel leaks. Reuse in S04/S05/S08. | No |
| D016 | M001/S03/T02 | convention | Controlled dropdown pattern | `DropdownButtonFormField.value` + `setState` | State tracked via `setState` for controlled form fields. `initialValue` deprecated replacement breaks controlled pattern — keep using `value` despite deprecation info. | No |
| D017 | M001/S03/T02 | convention | musteriId resolution | `AppUserProfile.musteriId` direct access | Profile already carries `musteri_id` — no need for separate lookup. Null-guarded with user-facing "Müşteri bilgisi bulunamadı" message. | No |
| D018 | M001/S04 | pattern | Partial update for siparisler | `update(String id, Map<String, dynamic> fields)` with field map | Avoids overwriting courier-set timestamps or fields from other roles. Full-row update would clobber concurrent changes. Omit `updated_at` (BEFORE UPDATE trigger). | No |
| D019 | M001/S04 | pattern | Single stream, client-side split | One `siparisStreamActiveProvider` feeds both panels | Avoids two concurrent Supabase Realtime channels on the same table. Client-side `where(durum == ...)` splits into kurye_bekliyor and devam_ediyor lists. | No |
| D020 | M001/S04 | pattern | Selection state on stream update | Clear checkbox `Set<String>` on each stream emission | Prevents stale selection when orders are assigned/finished by another operasyon user while checkboxes are checked. | Yes — could add smarter reconciliation later |
| D021 | M001/S04 | convention | SiparisLog insert timing | Client-side after successful status update | Simpler than DB trigger. If update succeeds but log fails, status change is unlogged — acceptable for MVP. DB trigger would be more reliable. | Yes — migrate to DB trigger if reliability matters |
| D022 | M001/S04/T02 | pattern | Snapshot selection before async iteration | `Set<String>.of(_selected)` copied before for-loop | Stream listener clears selection set on new data, causing ConcurrentModificationError if iterating the live set during assign/finish. Copy-on-iterate solves it. | No |
| D023 | M001/S05/T02 | pattern | Optimistic toggle for courier online status | Local `_isOnline` state in ConsumerStatefulWidget with revert on failure | Avoids extra provider for simple boolean toggle. Immediate UI feedback; reverts if `updateOnlineStatus()` throws. | No |
| D024 | M001/S05/T02 | convention | Client-side devamEdiyor filter on courier stream | Stream returns all courier orders, UI filters to `devamEdiyor` | Consistent with D019 (single stream, client-side split). Avoids adding a second filtered stream channel. | No |
| D025 | M001/S05/T02 | convention | Provider override pattern for courier tests | `currentKuryeProvider.overrideWith(...)` in test setup | Simpler than wiring full auth session + fake repo chain. Directly injects courier state for widget tests. | No |
