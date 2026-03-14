---
id: S01
milestone: M001
provides:
  - Supabase Auth integration with email/password login
  - Role-based routing via AppAccessGuard (müşteri→/musteri/siparis, operasyon→/operasyon/dashboard, kurye→/kurye/ana)
  - Role request flow (register → select role → submit → pending → approved/rejected)
  - AppUserProfile + UserRole domain models
  - UserProfileRepository + RoleRequestRepository contracts and Supabase implementations
  - 10 DB tables deployed with RLS policies
  - get_my_role() SECURITY DEFINER function for RLS recursion fix
  - Placeholder pages for all 3 roles (9 pages)
  - Turkish user-friendly auth error messages
key_files:
  - packages/backend_core/lib/src/domain/app_user_profile.dart
  - packages/backend_core/lib/src/domain/user_role.dart
  - packages/backend_core/lib/src/domain/role_request.dart
  - packages/backend_core/lib/src/user_profile_repository.dart
  - packages/backend_core/lib/src/role_request_repository.dart
  - packages/backend_supabase/lib/src/supabase_user_profile_repository.dart
  - packages/backend_supabase/lib/src/supabase_role_request_repository.dart
  - lib/app/router/guards/app_access_guard.dart
  - lib/app/router/custom_route.dart
  - lib/feature/role_selection/presentation/role_selection_page.dart
  - lib/feature/auth/presentation/auth_page.dart
  - supabase/migrations/20260315000000_initial_schema.sql
key_decisions:
  - "Supabase only backend — no mock/custom/firebase for new features"
  - "get_my_role() SECURITY DEFINER solves RLS recursion"
  - "Guard fetches profile directly from repository, not via stream provider"
  - "Email confirmation enabled but can be disabled for testing"
patterns_established:
  - "BackendModule.createXxxRepository() → optional factory method pattern"
  - "SupabaseXxxRepository → Supabase client CRUD pattern"
  - "@Riverpod(keepAlive: true) for singleton providers"
  - "AppAccessGuard.homePathForRole() for role-based navigation"
drill_down_paths:
  - .gsd/milestones/M001/slices/S01/
duration: ~4 hours
verification_result: pass
completed_at: 2026-03-15T00:00:00Z
---

# S01: Auth Foundation & Role Routing

**Supabase auth, role-based routing, and role request/approval flow deployed with 10 DB tables, RLS policies, and 53 passing tests**

## What Happened

Built the complete authentication and authorization foundation. Deployed Supabase schema with 10 tables including PostGIS support. Implemented role-based routing that directs users to their role-specific screens. Created a role request flow where new users select their desired role, submit a request, and wait for operations approval.

Key technical decisions: using a SECURITY DEFINER function to solve RLS recursion, fetching profiles directly from repository in the guard (not via stream provider to avoid async hangs), and Turkish user-friendly error messages for auth failures.

## Deviations

Added role request/approval flow (not in original sprint plan) — user requested it as the onboarding mechanism.

## Files Created/Modified

- 57 files changed, 3539 insertions
- See key_files above for the most important ones
