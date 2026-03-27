# S03: Durable Verification Assets

**Goal:** Turn the proven or stabilized runtime path into durable artifacts, updated checklists, and repeatable execution guidance for future reruns.
**Demo:** the live verification path is captured in durable mobile/browser artifacts so another agent can rerun it without rediscovery.

## Must-Haves

- Mobile verification notes target iPhone 17 instead of the older baseline.
- Browser-assisted local verification steps are captured where they add value.
- Durable artifacts point clearly to accounts, entrypoints, steps, and expected outcomes.
- Any automation or supporting test assets added during hardening are reflected in the documentation.

## Proof Level

- This slice proves: Operational repeatability proof through artifacts and runnable guidance.

## Integration Closure

Future agents can reproduce the same verification path without reconstructing context from scratch.

## Verification

- Improves long-term visibility by documenting the right verification surfaces and expected signals.

## Tasks

- [ ] **T01: Update mobile UAT and verification documents for iPhone 17** `est:60m`
  Revise the existing manual/live verification artifacts so they target iPhone 17 simulator and reflect the actual verified role loop, accounts, entrypoints, and expected runtime signals discovered in S01/S02.
  - Files: `UAT-CHECKLIST.md`, `uat-recordings/UAT-FULL-TEST-PLAN.md`, `.gsd/milestones/M003/slices/S03/S03-UAT.md`
  - Verify: Artifact review confirms iPhone 17 target and current live loop steps are documented consistently.

- [ ] **T02: Document browser-supported diagnosis and rerun guidance** `est:45m`
  Capture the local browser verification path, when to use it, what it proves, and what it does not prove. Include durable rerun notes so another agent can reuse browser support without mistaking it for primary mobile proof.
  - Files: `.gsd/milestones/M003/slices/S03/S03-SUMMARY.md`, `.gsd/milestones/M003/slices/S03/S03-UAT.md`, `BACKLOG.md`
  - Verify: Browser support path, boundaries, and rerun usage are clearly documented in durable artifacts.

## Files Likely Touched

- UAT-CHECKLIST.md
- uat-recordings/UAT-FULL-TEST-PLAN.md
- .gsd/milestones/M003/slices/S03/S03-UAT.md
- .gsd/milestones/M003/slices/S03/S03-SUMMARY.md
- BACKLOG.md
