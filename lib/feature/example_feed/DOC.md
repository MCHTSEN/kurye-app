# Example Feed Feature Doc

## Purpose
- Demonstrate the reference vertical slice for future projects.
- Show remote fetch, repository composition, runtime-service usage,
  analytics, and tests in one small feature.

## Routes
- `CustomRoute.exampleFeed.path`

## State and Providers
- `exampleFeedRemoteDataSourceProvider`
- `exampleFeedRepositoryProvider`
- `exampleFeedControllerProvider`

## Dependencies
- `product/network`
- `product/runtime`
- `product/analytics`
- `product/widgets`

## Extension Points
- Replace the sample endpoint and model with a real domain.
- Expand repository rules with pagination or mutations.
- Swap secure cache implementation without changing the feature API.

## Open Tasks
- Add pagination example when the skeleton needs list-heavy features.
- Add mutation example with optimistic update if required later.

## Last Updated
- 2026-03-08
