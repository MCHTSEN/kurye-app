# Onboarding Screens Doc

## Screen: OnboardingPage
- Purpose: Introduce the app and complete onboarding state.
- UI blocks: intro card, continue button.
- User actions:
  - Tap continue -> mark onboarding complete.
- Analytics events:
  - `screen_viewed` with `screen_name=onboarding`
- Navigation:
  - On success, route to `CustomRoute.auth.path`.

## Notes
- Keep onboarding content reusable and configurable.
- Use `ProjectPadding.all.normal` for base screen padding.

## Last Updated
- 2026-03-08
