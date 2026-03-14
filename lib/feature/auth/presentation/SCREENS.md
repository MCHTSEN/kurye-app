# Auth Screens Doc

## Screen: AuthPage
- Purpose: Entry point for sign-in.
- UI blocks: backend summary card, auth summary card, primary sign-in button.
- User actions:
  - Tap anonymous sign-in.
- Analytics events:
  - `screen_viewed` with `screen_name=auth`
  - `auth_sign_in_success`
- Navigation:
  - Router redirect sends authenticated users to `CustomRoute.home.path`.

## Notes
- Keep this screen backend-agnostic.
- Do not call SDKs directly in UI.

## Last Updated
- 2026-03-08
