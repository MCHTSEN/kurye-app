# S04: Final Rerun and Truth Check

**Goal:** Rerun the assembled live system after fixes and documentation updates, then record an honest final pass/fail state for milestone closure.
**Demo:** the assembled system is rerun end-to-end after fixes and the final state is recorded as a truthful live pass/fail result.

## Must-Haves

- The full intended live verification path is rerun after fixes.
- Final results distinguish proven behavior from deferred or unresolved gaps.
- Milestone artifacts reflect the actual rerun outcome, not inferred confidence.
- Remaining limitations are stated plainly if any still exist.

## Proof Level

- This slice proves: Final end-to-end rerun with truthful milestone-level reporting.

## Integration Closure

Milestone closes only on a rerun-backed final state.

## Verification

- Leaves a truthful final record of what passed, failed, and remains deferred.

## Tasks

- [ ] **T01: Rerun the full live verification path after hardening** `est:90m`
  Execute the final iPhone 17-led live verification path across müşteri, operasyon, and kurye after S02 fixes and S03 artifact updates. Confirm the rerun matches the documented path and capture pass/fail evidence at each stage.
  - Files: `.gsd/milestones/M003/slices/S03/S03-UAT.md`, `lib/feature/musteri_siparis/**`, `lib/feature/operasyon/**`, `lib/feature/kurye/**`
  - Verify: Documented live rerun completed with explicit pass/fail evidence for each step.

- [ ] **T02: Close milestone with truthful summary and validation state** `est:60m`
  Update the final milestone-level artifacts to reflect the rerun truthfully, including what passed live, what was fixed, what remains deferred, and whether the milestone can be validated as pass or needs attention.
  - Files: `.gsd/milestones/M003/M003-SUMMARY.md`, `.gsd/milestones/M003/M003-VALIDATION.md`, `.gsd/REQUIREMENTS.md`, `BACKLOG.md`
  - Verify: Milestone summary and validation artifacts align with rerun evidence and requirement outcomes.

## Files Likely Touched

- .gsd/milestones/M003/slices/S03/S03-UAT.md
- lib/feature/musteri_siparis/**
- lib/feature/operasyon/**
- lib/feature/kurye/**
- .gsd/milestones/M003/M003-SUMMARY.md
- .gsd/milestones/M003/M003-VALIDATION.md
- .gsd/REQUIREMENTS.md
- BACKLOG.md
