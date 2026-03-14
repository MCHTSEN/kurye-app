# Splash Feature Doc

## Purpose
Temporary loading gate while router evaluates onboarding/auth state.

## Routes
- `CustomRoute.splash.path`

## State and Providers
- Depends on router readiness of:
  - onboarding async state
  - auth async state

## Dependencies
- `app/router`

## Extension Points
- Add branded splash visuals.
- Add startup diagnostics and migration checks.

## Open Tasks
- Add startup timeout and fallback strategy.

## Last Updated
- 2026-03-08
