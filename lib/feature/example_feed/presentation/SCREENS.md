# Example Feed Screens Doc

## Screen: ExampleFeedPage
- Purpose: Demonstrate the preferred feature slice for remote list data.
- UI blocks: page scaffold, refresh action, async state view, item list.
- User actions:
  - Pull or tap to refresh the feed.
  - Tap an item to track selection.
- Analytics events:
  - `screen_viewed` with `screen_name=example_feed`
  - `example_feed_refreshed`
  - `example_feed_item_selected`
- Navigation:
  - Push from `CustomRoute.home.path`.

## Notes
- Use shared async/error/empty widgets instead of inline branching.
- This screen exists as a template for future feature work.

## Last Updated
- 2026-03-08
