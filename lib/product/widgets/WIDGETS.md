# Shared Widgets Doc

## Purpose
Defines reusable widget contracts used across features.

## Current Widgets
- `AppPrimaryButton`
  - Full width primary action button
  - Supports loading state
- `AppSectionCard`
  - Standard card wrapper for section blocks
- `AppAsyncView<T>`
  - Standard async data / loading / error renderer
- `AppEmptyState`
  - Reusable empty-state block with optional action
- `AppErrorState`
  - Reusable retryable error block
- `AppPageScaffold`
  - Standard page shell with title, padding, and scroll behavior

## Usage Rules
- Use shared widgets before creating new duplicates.
- Any new shared widget must be documented here first.
- If contract changes, update this file before refactoring feature screens.
- Base screen/section paddings should use `ProjectPadding` tokens.
- Screen analytics is handled centrally by router observer, not by widget wrappers.

## Last Updated
- 2026-03-08
