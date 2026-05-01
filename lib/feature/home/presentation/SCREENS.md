# Home Screens Doc

## Screen: HomePage
- Purpose: Post-auth hub and provisional-account in-app onboarding area.
- UI blocks: approved-user welcome card, provisional-account guidance card,
  new-customer company setup card, quick links into customer panel,
  sign-out button, account-delete action.
- User actions:
  - Refresh pending account status.
  - Complete provisional company info.
  - Open customer workflow before final approval when linked to a customer.
  - Sign out.
  - Delete account.
- Analytics events:
  - `screen_viewed` with `screen_name=home`
  - `auth_sign_out`
  - `auth_account_deleted`
- Navigation:
  - Approved users are redirected by guard to role home routes.
  - Provisional customer users land on `CustomRoute.home.path` first.
  - Customer panel routes remain reachable from explicit user action.

## Notes
- Keep this page lightweight in skeleton mode.
- Provisional users may access customer flows only when they already have a
  linked `musteri_id`.
- New-customer signup should surface firm fields here instead of a separate
  pending-only dead-end.
- Use `ProjectPadding.all.normal` for base screen padding.

## Last Updated
- 2026-04-12
