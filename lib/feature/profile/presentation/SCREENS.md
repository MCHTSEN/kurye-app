# Profile Screens Doc

## Screen: ProfilePage
- Purpose: Show current session user metadata.
- UI blocks: user card and loading/error placeholders.
- User actions:
  - View user id/email.
- Analytics events:
  - `screen_viewed` with `screen_name=profile`
- Navigation:
  - Accessed from `CustomRoute.home.path`.

## Notes
- Keep profile rendering resilient when session is null.

## Last Updated
- 2026-03-08
