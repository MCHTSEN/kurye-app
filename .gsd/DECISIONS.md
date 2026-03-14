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
