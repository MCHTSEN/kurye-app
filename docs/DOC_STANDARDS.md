# Doc Standards

## Why
Local docs are required to reduce implementation time and avoid re-discovery.

## Mandatory Docs
- Layer docs:
  - `lib/core/DOC.md`
  - `lib/product/DOC.md`
- Reusable runtime modules should keep a local `DOC.md` when they grow
  beyond a single file.
- Each `lib/feature/<name>/DOC.md`
- Each `lib/feature/<name>/presentation/SCREENS.md`
- Shared widgets: `lib/product/widgets/WIDGETS.md`
- Audit log: `/BACKLOG.md`

## Rule
1. Read local docs before implementing or refactoring any widget/screen/feature logic.
2. Update docs first if behavior/contract changes.
3. Then implement code changes.
4. Append an entry to `BACKLOG.md`.
5. Route references in docs should use `CustomRoute.<name>.path`.
6. Layout padding references should use `ProjectPadding` tokens.
7. Before saying a task is complete, run `flutter analyze` and `flutter test`.
8. Report validation outputs in task summary.
9. New or materially changed features must define the required test layer before completion:
   - repository/controller unit test for business logic
   - at least one widget test for the main screen or interaction
   - golden test for visual contract changes
   - smoke `integration_test` update when app-entry flow changes
10. If a feature intentionally skips one of these layers, document the reason in the feature `DOC.md` and task summary.

## Required Sections for DOC.md
- Purpose
- Routes
- State and Providers
- Dependencies
- Extension Points
- Open Tasks
- Last Updated

## Required Sections for SCREENS.md
- Screen name
- UI structure
- User actions
- Analytics events
- Navigation
- Notes
- Last Updated
