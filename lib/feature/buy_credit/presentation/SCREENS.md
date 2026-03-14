# Buy Credit Screens Doc

## Screen: BuyCreditPage
- Purpose: route users to a credit purchase flow.
- UI blocks: explanation card, placeholder purchase CTA.
- User actions:
  - Confirm purchase flow (placeholder in skeleton).
- Analytics events:
  - `screen_viewed` with `screen_name=buy_credit`
  - `credit_purchase_intent`
- Navigation:
  - Reached automatically from guard when credit is insufficient.
  - Success action returns to `CustomRoute.home.path`.

## Notes
- Payment provider integration is intentionally deferred.
- Use `ProjectPadding.all.normal` for base screen padding.

## Last Updated
- 2026-03-08
