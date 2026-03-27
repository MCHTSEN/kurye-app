# S02: Live Cross-Role Loop Proof and Fixes

**Goal:** Drive the main Supabase-backed live order loop through müşteri, operasyon, and kurye surfaces, fixing blockers that materially break the loop or its repeatability.
**Demo:** the real müşteri → operasyon → kurye → tamamlandı flow works live on the requested runtime, or its blockers have been fixed and rechecked.

## Must-Haves

- A müşteri can create an order in the live app.
- Operasyon can see and assign the live order.
- Kurye can progress the order through its active steps.
- Blockers found during proof are fixed or explicitly recorded as remaining gaps with evidence.

## Proof Level

- This slice proves: End-to-end live integration proof with targeted code hardening.

## Integration Closure

Primary value loop is either working live or reduced to explicit, evidenced remaining gaps.

## Verification

- Adds or sharpens diagnostics only where needed to make live-loop failures visible and debuggable.

## Tasks

- [ ] **T01: Exercise the live müşteri to operasyon handoff** `est:90m`
  Using the runtime path established in S01, log in as a müşteri, create a live order, then verify operasyon can see it in the dispatch surface. Capture exact failure points, DB/runtime evidence, and whether the handoff succeeds unchanged.
  - Files: `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`, `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`, `lib/product/auth/auth_providers.dart`
  - Verify: Live müşteri creation and operasyon visibility either pass or yield concrete blockers with evidence.

- [ ] **T02: Exercise the live operasyon to kurye completion path** `est:90m`
  From the live operasyon queue, assign the order to a kurye and then drive the kurye surface through active work and completion-related state transitions. Capture where realtime, auth, or UI behavior breaks if it does.
  - Files: `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`, `lib/feature/kurye/presentation/kurye_ana_page.dart`, `lib/product/kurye/kurye_providers.dart`
  - Verify: Live operasyon assignment and kurye progression either pass or yield concrete blockers with evidence.

- [ ] **T03: Fix loop blockers and rerun the broken path** `est:120m`
  Investigate and fix blockers materially affecting the primary live loop or its repeatability. Verify fixes with focused reruns plus repo validation commands, and record any remaining gap that could not be closed within scope.
  - Files: `lib/feature/musteri_siparis/**`, `lib/feature/operasyon/**`, `lib/feature/kurye/**`, `lib/product/**`, `lib/core/**`, `test/**`, `integration_test/**`
  - Verify: flutter analyze && flutter test plus focused live rerun of the previously failing path.

## Files Likely Touched

- lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart
- lib/feature/operasyon/presentation/operasyon_ekran_page.dart
- lib/product/auth/auth_providers.dart
- lib/feature/kurye/presentation/kurye_ana_page.dart
- lib/product/kurye/kurye_providers.dart
- lib/feature/musteri_siparis/**
- lib/feature/operasyon/**
- lib/feature/kurye/**
- lib/product/**
- lib/core/**
- test/**
- integration_test/**
