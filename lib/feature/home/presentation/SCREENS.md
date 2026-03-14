# Home Screens Doc

## Screen: HomePage
- Purpose: Post-auth hub.
- UI blocks: status card, example-feed shortcut, profile button,
  sign-out button, buy-credit shortcut.
- User actions:
  - Navigate to example feed.
  - Navigate to profile.
  - Sign out.
  - Navigate to buy-credit.
- Analytics events:
  - `screen_viewed` with `screen_name=home`
  - `auth_sign_out`
- Navigation:
  - Push `CustomRoute.exampleFeed.path`.
  - Push `CustomRoute.profile.path`.
  - Push `CustomRoute.buyCredit.path`.

## Notes
- Keep this page lightweight in skeleton mode.
- Use `ProjectPadding.all.normal` for base screen padding.

## Last Updated
- 2026-03-08
