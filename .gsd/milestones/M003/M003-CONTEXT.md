# M003: Live Verification and Hardening

**Gathered:** 2026-03-22
**Status:** Ready for planning

## Project Description

This milestone is not new feature delivery. It is a live verification and hardening pass for the existing courier dispatch app. The focus is to test what was already built through the real app surfaces using `mobile_mcp` and browser tooling, with the iPhone 17 simulator as the required mobile device.

## Why This Milestone

The project already has substantial feature coverage across M001 and M002, plus partial UAT and automated test coverage. What is still missing is a truthful, current proof that the assembled system works live on the requested device/runtime path. The user prioritised two things above all else: the core live role loop must actually work, and the verification path must be repeatable for the next agent instead of relying on one-off manual memory.

## User-Visible Outcome

### When this milestone is complete, the user can:

- watch the real müşteri → operasyon → kurye → tamamlandı flow succeed on iPhone 17 simulator against Supabase
- rerun the same verification path later using durable mobile/browser artifacts instead of reconstructing the workflow from scratch

### Entry point / environment

- Entry point: `lib/main_supabase.dart` for live app runtime; local browser run for supporting verification/debugging
- Environment: iPhone 17 simulator + local browser + Supabase-backed runtime
- Live dependencies involved: Supabase Auth, Supabase DB/RLS/Realtime, simulator automation via `mobile_mcp`

## Completion Class

- Contract complete means: updated verification artifacts, durable UAT/test path, and code fixes exist with substantive implementation
- Integration complete means: the live cross-role loop is executed through the real app against Supabase and survives end-to-end after fixes
- Operational complete means: iPhone 17 simulator becomes the working mobile verification target for this milestone and browser-assisted local verification is usable where needed

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- a müşteri user creates an order on the live app and operasyon can see it in the dispatch flow
- operasyon assigns the order to a kurye and the kurye can work the order through timestamp actions to completion
- after fixes, the same path is rerun and the final recorded state is truthful about what still passes or fails live

## Risks and Unknowns

- iPhone 17 simulator automation may expose different interaction issues than the old iPhone 15 Pro baseline — this matters because the user explicitly changed the target device
- Supabase-backed live flows may fail in ways not covered by existing widget/integration tests — this matters because the milestone success is based on real runtime truth, not previous test confidence
- Browser verification may help debugging but can diverge from the mobile UX path — this matters because browser is supportive, not the primary proof surface

## Existing Codebase / Prior Art

- `UAT-CHECKLIST.md` — existing cross-role UAT baseline, currently written against iPhone 15 Pro simulator
- `uat-recordings/UAT-FULL-TEST-PLAN.md` — prior manual verification flow and test accounts
- `integration_test/app_smoke_test.dart` — mock smoke proof for app boot and basic navigation
- `integration_test/operasyon_navigation_smoke_test.dart` — mock-backed operasyon navigation smoke test
- `lib/feature/auth/presentation/auth_page.dart` — debug quick-login entrypoint for ops/müşteri/kurye test accounts
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — müşteri-side order creation and active order visibility
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` — operasyon dispatch, assignment, and finish flow
- `lib/feature/kurye/presentation/kurye_ana_page.dart` — kurye active/passive toggle and timestamp punching

> See `.gsd/DECISIONS.md` for all architectural and pattern decisions — it is an append-only register; read it during planning, append to it during execution.

## Relevant Requirements

- R024 — establishes iPhone 17 live runtime readiness
- R025 — proves the core live cross-role loop
- R026 — scopes bug fixing to blockers found during live proof
- R027 — captures a durable mobile verification path
- R028 — uses browser as a supporting verification/debug surface
- R029 — requires final rerun and truthful result reporting

## Scope

### In Scope

- iPhone 17 simulator as the main mobile verification device
- live Supabase-backed müşteri / operasyon / kurye flow proof
- targeted fixes for blockers found while proving that loop
- durable verification artifacts, checklists, and repeatable execution notes
- browser-assisted local verification where it materially helps diagnosis or proof

### Out of Scope / Non-Goals

- unrelated feature work
- broad secondary-screen exhaustive closure unless it blocks the core loop
- expanding this milestone into a multi-device matrix

## Technical Constraints

- keep existing `core / product / feature` architecture intact
- verification must use the real app entrypoint and live Supabase path where milestone success depends on assembled behavior
- browser tools are only for local URLs, not external websites
- iPhone 15 Pro is not the primary simulator for this milestone because it is reserved for other use

## Integration Points

- Supabase Auth — role login and session continuity for ops/müşteri/kurye accounts
- Supabase DB/RLS/Realtime — order visibility, assignment flow, courier updates, and completion state
- mobile-mcp — simulator launch, app interaction, screenshots, and element-driven automation on iPhone 17
- browser tooling — local web verification/debugging to support diagnosis and durable repro paths

## Open Questions

- whether any secondary-screen regression discovered during live proof should be fixed immediately or recorded for later if it does not affect the core loop — current thinking: fix only when it blocks the primary live path or repeatability
