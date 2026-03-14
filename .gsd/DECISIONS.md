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
