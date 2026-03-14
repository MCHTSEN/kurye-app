# Onboarding Feature Doc

## Purpose
Controls first-run onboarding state and completion transition.

## Routes
- `CustomRoute.onboarding.path`

## State and Providers
- `onboardingStatusControllerProvider`
- `onboardingRepositoryProvider`

## Dependencies
- `product/onboarding` repository
- `shared_preferences`

## Extension Points
- Multi-step onboarding pages.
- Remote-config driven onboarding variations.
- A/B experiment variants.

## Open Tasks
- Add step model and progress indicators.
- Add skip/resume behavior.

## Last Updated
- 2026-03-08
