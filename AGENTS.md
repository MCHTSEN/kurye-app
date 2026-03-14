# Project Rules

## Architecture Rules
- Use `core / product / feature` layer separation.
- Keep UI and business logic separated.
- Feature-level business logic must go through repository contracts.
- Keep third-party SDK usage behind adapters or gateways.
- Router standard is `auto_route` with central guards.
- Auth, onboarding and credit access policies must be enforced by centralized route guards, not per-screen ad-hoc checks.
- Route path strings must not be hardcoded in features; use `CustomRoute.<name>.path`.
- Every feature folder must contain a living doc (`DOC.md`) that explains scope, routes, states, dependencies, and extension points.
- Every screen folder (for now `presentation/`) must contain a living screen doc (`SCREENS.md`) before widget implementation/refactor.
- `lib/core` and `lib/product` must keep living layer docs (`DOC.md`) updated as architecture evolves.
- Widget work must start by reading/updating the local feature/screen doc first. Code comes after docs are aligned.

## State Management Rules
- Riverpod 3 is mandatory.
- Use immutable state transitions.
- Prefer targeted rebuilds and keep widgets `const` when possible.

## Backend Rules
- Backend provider must be selectable with `BACKEND_PROVIDER`.
- Supported adapters: `mock`, `custom`, `supabase`, `firebase`.
- Feature code cannot directly depend on backend SDK primitives.
- Credit policy source must be configurable through `CREDIT_ACCESS_PROVIDER` and evaluated centrally by guard-compatible services.

## Analytics Rules
- Analytics is a platform standard and cannot be bypassed.
- Track screen views and critical user actions.
- Use `AnalyticsService` abstraction instead of direct SDK calls.

## Reusability Rules
- Common components must live in `product/widgets`.
- Auth, onboarding, profile should stay decoupled and reusable.
- Keep backend and analytics integrations swappable.
- Shared widget groups must keep a living doc (`WIDGETS.md`) with contract and usage notes.
- Shared layout paddings must use `ProjectPadding` tokens (`ProjectPadding.all.normal` etc.) instead of inline `EdgeInsets`.

## Quality Rules
- Keep analysis clean with `very_good_analysis` baseline.
- Avoid dead code and unused imports.
- Prefer predictable folder structures and file naming.
- For library/API documentation lookups, use Context7 MCP first when available.
- Use root `BACKLOG.md` as an audit log for all significant project changes.
- Each backlog entry must include date, scope, summary, touched files, and validation status.
- Do not mark a task complete before running tests.
- Minimum validation for completion: `flutter analyze` and `flutter test`.
- Keep one smoke `integration_test` flow runnable on the mock backend.
- Task summaries must include validation command results (pass/fail and key output).
- Adding or materially changing a feature requires feature-level validation before completion.
- Minimum feature validation:
  - repository/controller unit test when business logic changes
  - at least one widget test for the primary screen state or interaction
  - golden test when shared UI structure or visual contract is introduced/changed
  - update or add smoke `integration_test` coverage when the main app flow is affected
- A feature is not complete if its required test layer is missing, even if `flutter analyze` and `flutter test` pass on unrelated coverage.
