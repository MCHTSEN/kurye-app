# Runtime Services Doc

## Purpose
- Centralize reusable runtime services that almost every app needs.
- Keep SDK choices swappable while exposing provider-based access to
  features.

## Scope
- Secure storage
- Connectivity status
- Feature flags
- Crash reporting
- Permission handling
- Cache policy
- Retry policy

## Rules
- Features consume runtime services through product providers.
- SDK implementations stay hidden behind contracts from `core/runtime`.
- Test suites should override runtime providers with fakes instead of
  touching platform plugins.

## Extension Points
- Replace noop providers with production SDK adapters per project.
- Add app-specific policies by composing existing contracts instead of
  reaching directly into plugins.

## Last Updated
- 2026-03-08
