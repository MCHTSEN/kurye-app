# M003: M003: Live Verification and Hardening

**Vision:** Prove the existing courier app live on iPhone 17 simulator and browser-supported local runtime, fix blockers in the real cross-role loop, and leave behind a repeatable verification path instead of one-off manual knowledge.

## Success Criteria

- The app launches and can be driven reliably on iPhone 17 simulator using the intended Supabase runtime path.
- A müşteri can create an order, operasyon can assign it, kurye can work it, and operasyon can complete it in the real app.
- Blockers found in that live loop are fixed or explicitly recorded as remaining gaps.
- Another agent can rerun the verification path using durable mobile/browser artifacts without rediscovering the workflow.
- The final milestone state reflects a real rerun after fixes, not an assumed green outcome.

## Slices

- [ ] **S01: iPhone 17 Runtime Readiness** `risk:high` `depends:[]`
  > After this: the app can be launched and interacted with on iPhone 17 simulator, and the supporting local browser path is usable for debugging the same system.

- [ ] **S02: Live Cross-Role Loop Proof and Fixes** `risk:high` `depends:[S01]`
  > After this: the real müşteri → operasyon → kurye → tamamlandı flow works live on the requested runtime, or its blockers have been fixed and rechecked.

- [ ] **S03: Durable Verification Assets** `risk:medium` `depends:[S02]`
  > After this: the live verification path is captured in durable mobile/browser artifacts so another agent can rerun it without rediscovery.

- [ ] **S04: Final Rerun and Truth Check** `risk:low` `depends:[S02,S03]`
  > After this: the assembled system is rerun end-to-end after fixes and the final state is recorded as a truthful live pass/fail result.

## Boundary Map

### S01 → S02

Produces:
- iPhone 17 simulator device target and runnable app launch path
- verified login entry path for ops / müşteri / kurye test accounts
- browser-accessible local runtime/debug path for the same app system
- baseline evidence of what can already be driven reliably versus what is flaky at runtime

Consumes:
- nothing (first slice)

### S02 → S03

Produces:
- verified or fixed live cross-role path across `MusteriSiparisPage`, `OperasyonEkranPage`, and `KuryeAnaPage`
- concrete blocker list with code fixes or explicit gap outcomes
- stable repro steps for the exact live loop that matters most

Consumes from S01:
- iPhone 17 launch and interaction path
- working account-entry path and baseline runtime observations

### S03 → S04

Produces:
- updated UAT / verification artifacts for iPhone 17 and browser-supported diagnosis
- repeatable agent-facing execution notes and any supporting automated checks added during hardening
- clarified boundary of what is intentionally deferred versus proven

Consumes from S02:
- fixed or stabilized live cross-role flow
- concrete blocker history and real repro/fix path
