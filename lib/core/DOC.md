# Core Layer Doc

## Purpose
- Framework-agnostic primitives and global contracts.
- Keep platform/backend independent building blocks in one place.

## Scope
- `analytics`: shared analytics contracts and adapters.
- `constants`: spacing/radius/padding design tokens.
- `environment`: runtime config parsing (`dart-define`) and enums.
- `network`: low-level API client contract and Dio implementation.
- `runtime`: reusable runtime contracts such as storage, connectivity,
  crash reporting, feature flags, permissions, cache, and retry policy.
- `theme`: app theme tokens.

## Riverpod Notes
- `core` has no Riverpod provider definitions.
- `core` exposes pure contracts/classes; `product` composes them with providers.

## Extension Points
- Add new environment keys/enums under `core/environment`.
- Add new cross-project constants under `core/constants`.
- Add new low-level client implementations behind `ApiClient`.
- Add runtime service contracts under `core/runtime` and keep them
  SDK-agnostic.

## Rules
- No feature imports from `core`.
- No direct UI business logic in `core`.
- Keep third-party SDK references minimal and replaceable.
- Runtime policies such as retry and cache must be expressed as pure
  core types so they can be reused across features.

## Last Updated
- 2026-03-08
