# Splash Screens Doc

## Screen: SplashPage
- Purpose: show loading indicator during route guard checks.
- UI blocks: centered progress indicator.
- User actions: none.
- Analytics events:
  - `screen_viewed` with `screen_name=splash`
- Navigation:
  - Redirected by router based on onboarding/auth state.

## Notes
- Keep splash free of business logic.

## Last Updated
- 2026-03-08
