# Requirements

This file is the explicit capability and coverage contract for the project.

Use it to track what is actively in scope, what has been validated by completed work, what is intentionally deferred, and what is explicitly out of scope.

Guidelines:
- Keep requirements capability-oriented, not a giant feature wishlist.
- Requirements should be atomic, testable, and stated in plain language.
- Every **Active** requirement should be mapped to a slice, deferred, blocked with reason, or moved out of scope.
- Each requirement should have one accountable primary owner and may have supporting slices.
- Research may suggest requirements, but research does not silently make them binding.
- Validation means the requirement was actually proven by completed work and verification, not just discussed.

## Active

### R024 — iPhone 17 live runtime readiness
- Class: launchability
- Status: active
- Description: The app can be launched, driven, and observed reliably on the iPhone 17 simulator using the intended Supabase-backed runtime path.
- Why it matters: Live verification cannot be trusted if the target device/runtime itself is unstable or mismatched.
- Source: user
- Primary owning slice: M003/S01
- Supporting slices: none
- Validation: mapped
- Notes: Replaces the old iPhone 15 Pro manual verification baseline for this milestone.

### R025 — Cross-role live order loop proof
- Class: primary-user-loop
- Status: active
- Description: The müşteri → operasyon → kurye → tamamlandı order flow is exercised successfully in the real app against Supabase.
- Why it matters: This is the core value anchor of the product and the main thing that must work even if everything else is cut.
- Source: user
- Primary owning slice: M003/S02
- Supporting slices: M003/S04
- Validation: mapped
- Notes: Success is based on live behavior, not only on existing widget/integration tests.

### R026 — Live-loop blocker fixing
- Class: continuity
- Status: active
- Description: Failures discovered while proving the live cross-role loop are fixed or clearly surfaced as remaining gaps before milestone close.
- Why it matters: A verification milestone that only discovers bugs without hardening the flow would leave the core product unreliable.
- Source: inferred
- Primary owning slice: M003/S02
- Supporting slices: M003/S04
- Validation: mapped
- Notes: Scope is limited to blockers materially affecting the primary live loop or its repeatability.

### R027 — Repeatable mobile verification path
- Class: operability
- Status: active
- Description: The iPhone 17 mobile verification path is captured in durable artifacts so another agent can rerun it without rediscovering the workflow.
- Why it matters: The user explicitly wants a repeatable path, not one-off manual memory.
- Source: user
- Primary owning slice: M003/S03
- Supporting slices: M003/S04
- Validation: mapped
- Notes: Expected artifacts may include updated UAT, task summaries, and executable verification guidance.

### R028 — Browser-assisted local verification path
- Class: integration
- Status: active
- Description: Browser-based local verification is available where it accelerates diagnosis or proof of the same product flows.
- Why it matters: Browser tooling gives faster visibility into local runtime behavior and supports durable debugging of issues found from mobile.
- Source: user
- Primary owning slice: M003/S03
- Supporting slices: M003/S01, M003/S04
- Validation: mapped
- Notes: Browser is a supporting proof surface, not the primary success definition.

### R029 — Final rerun truth check
- Class: failure-visibility
- Status: active
- Description: After fixes, the full verification path is rerun and the project ends with a truthful pass/fail record of what works live.
- Why it matters: Without a final rerun, fixes remain assumptions and the milestone result would be untrustworthy.
- Source: inferred
- Primary owning slice: M003/S04
- Supporting slices: none
- Validation: mapped
- Notes: This requirement is about honest final state reporting, not just green tests.

## Validated

### R001 — Role-based auth & routing
- Class: core-capability
- Status: validated
- Description: Users authenticate via Supabase Auth and are routed to role-specific screens.
- Why it matters: Foundation for all role-specific functionality.
- Source: user
- Primary owning slice: M001/S01
- Supporting slices: none
- Validation: validated
- Notes: Previously proven in M001.

### R007 — Order creation with cascading dropdowns
- Class: primary-user-loop
- Status: validated
- Description: Both müşteri and operasyon can create orders, with dropdown-driven route selection.
- Why it matters: Core order creation flow.
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: M001/S04
- Validation: validated
- Notes: Existing validation remains; M003 rechecks it live under iPhone 17 constraints.

### R008 — Realtime order flow across all roles
- Class: core-capability
- Status: validated
- Description: Order status changes propagate across screens without manual refresh.
- Why it matters: Dispatch requires instant visibility.
- Source: user
- Primary owning slice: M001/S03
- Supporting slices: M001/S04, M001/S05, M001/S08
- Validation: validated
- Notes: Existing repo proof exists; M003 will re-prove the assembled flow live.

### R011 — Courier order acceptance & timestamp punching
- Class: primary-user-loop
- Status: validated
- Description: Courier can work assigned orders and punch timestamps at route points.
- Why it matters: Completes the courier side of the dispatch loop.
- Source: user
- Primary owning slice: M001/S05
- Supporting slices: none
- Validation: validated
- Notes: Existing tests prove the behavior; M003 rechecks in real runtime.

### R018 — Order status log tracking
- Class: continuity
- Status: validated
- Description: Order status changes are recorded in siparis_log.
- Why it matters: Auditability for operations.
- Source: user
- Primary owning slice: M001/S04
- Supporting slices: none
- Validation: validated
- Notes: Relevant as supporting evidence during hardening.

## Deferred

### R030 — Full secondary-screen exhaustive UAT closure
- Class: admin/support
- Status: deferred
- Description: Exhaustively proving every secondary screen, filter path, and support page in the same milestone.
- Why it matters: Useful for overall product confidence, but lower priority than the core live role loop.
- Source: inferred
- Primary owning slice: none
- Supporting slices: none
- Validation: unmapped
- Notes: Deferred because the user prioritized the live core loop and durable path over broad secondary-screen closure.

## Out of Scope

### R031 — New product features unrelated to verification hardening
- Class: anti-feature
- Status: out-of-scope
- Description: Shipping unrelated new capabilities as part of this milestone.
- Why it matters: Prevents the verification milestone from turning into feature creep.
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: n/a
- Notes: This milestone is about proving and hardening what already exists.

### R032 — Device support parity beyond iPhone 17 for this milestone
- Class: constraint
- Status: out-of-scope
- Description: Expanding live verification to a broader simulator/device matrix during this milestone.
- Why it matters: Keeps effort focused on the requested iPhone 17 target instead of reopening device-matrix scope.
- Source: user
- Primary owning slice: none
- Supporting slices: none
- Validation: n/a
- Notes: iPhone 15 Pro is intentionally not the main device for this milestone.

## Traceability

| ID | Class | Status | Primary owner | Supporting | Proof |
|---|---|---|---|---|---|
| R024 | launchability | active | M003/S01 | none | mapped |
| R025 | primary-user-loop | active | M003/S02 | M003/S04 | mapped |
| R026 | continuity | active | M003/S02 | M003/S04 | mapped |
| R027 | operability | active | M003/S03 | M003/S04 | mapped |
| R028 | integration | active | M003/S03 | M003/S01,M003/S04 | mapped |
| R029 | failure-visibility | active | M003/S04 | none | mapped |
| R001 | core-capability | validated | M001/S01 | none | validated |
| R007 | primary-user-loop | validated | M001/S03 | M001/S04 | validated |
| R008 | core-capability | validated | M001/S03 | M001/S04,M001/S05,M001/S08 | validated |
| R011 | primary-user-loop | validated | M001/S05 | none | validated |
| R018 | continuity | validated | M001/S04 | none | validated |
| R030 | admin/support | deferred | none | none | unmapped |
| R031 | anti-feature | out-of-scope | none | none | n/a |
| R032 | constraint | out-of-scope | none | none | n/a |

## Coverage Summary

- Active requirements: 6
- Mapped to slices: 6
- Validated: 5
- Unmapped active requirements: 0
