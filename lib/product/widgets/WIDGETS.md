# Shared Widgets Doc

## Purpose
Defines reusable widget contracts used across features.

## Current Widgets
- `AppPrimaryButton`
  - Full width primary action button
  - Supports loading state
- `AppSectionCard`
  - Standard card wrapper for section blocks
  - Dar alanlarda `trailing` içeriğini başlığın altına alarak taşmayı önler
- `AppAsyncView<T>`
  - Standard async data / loading / error renderer
- `AppEmptyState`
  - Reusable empty-state block with optional action
- `AppErrorState`
  - Reusable retryable error block
- `AppPageScaffold`
  - Standard page shell with title, padding, and scroll behavior
- `ResponsiveScaffold`
  - Adaptive page shell
  - Mobile: `AppBar` + optional drawer
  - Drawer + desktop sidebar can use the same dark palette for visual continuity
  - Drawer header uses `assets/images/bmk-logo.png` logo block in the top area
  - Tablet: compact navigation rail
  - Desktop: grouped navigation sidebar + body, responsive sidebar width
  - Navigation labels scale by screen size for better readability
  - Supports disabling the mobile drawer for shell-based flows
- `WorkbenchSplitView`
  - Shared desktop-first split-view layout
  - Fixed-width editor pane + flexible content pane
  - Falls back to stacked mobile/tablet flow when needed
- `TypeaheadField<T>`
  - Searchable text-input + overlay suggestion list
  - Keyboard: `↑/↓` ile gezinme, `Enter/Tab` ile seçim
  - Pointer: Öneri satırına mouse/touch tıklaması ile doğrudan seçim
  - Alan boşken tıklamada da mevcut seçenekleri listeleyerek açar
- `SearchableDropdown<T>`
  - `ShadSelect.withSearch` tabanlı arama destekli seçim alanı

## Usage Rules
- Use shared widgets before creating new duplicates.
- Any new shared widget must be documented here first.
- If contract changes, update this file before refactoring feature screens.
- Base screen/section paddings should use `ProjectPadding` tokens.
- Screen analytics is handled centrally by router observer, not by widget wrappers.
- Feature shells may own the mobile bottom navigation while still reusing
  `ResponsiveScaffold` for the inner page chrome.
- Desktop-first admin pages should prefer grouped sidebar navigation and
  split-view workbenches instead of long single-column forms.

## Last Updated
- 2026-03-31
