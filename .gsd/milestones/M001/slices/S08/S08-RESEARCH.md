# S08: Cross-role Integration & Polish — Research

**Date:** 2026-03-15

## Summary

S08 is the final slice of M001. It owns R017 (sound alerts for new orders on the operations screen) and completes validation of R008 (cross-role realtime). The codebase is solid — 114 tests passing, all screens implemented, zero analyze errors/warnings. The primary work is: (1) add an audio alert when new `kurye_bekliyor` orders arrive on the dispatch stream, (2) resolve raw UUIDs to human-readable names on the dispatch and courier screens, and (3) write a cross-role integration test proving the full order lifecycle works end-to-end.

The sound alert hooks naturally into the existing `ref.listen(siparisStreamActiveProvider, ...)` in `operasyon_ekran_page.dart`. The `audioplayers` package with `PlayerMode.lowLatency` + `AssetSource` is the right tool — well-maintained, iOS-compatible, 8/10 trust score on Context7. Name resolution is a display polish that reuses the ID-to-name map pattern already established in `operasyon_gecmis_page.dart` (D027). The integration test should be a widget test that wires all three role screens with fakes and drives an order through create → assign → timestamp → finish.

## Recommendation

Three tasks:
1. **Sound alert service + wiring** — Add `audioplayers` dependency, create a thin `OrderAlertService`, wire into the dispatch screen's existing `ref.listen` to detect new `kurye_bekliyor` arrivals. Bundle a short alert `.wav` in `assets/sounds/`.
2. **Display polish** — Resolve raw IDs to names on dispatch panels (`_routeLabel` → use ugramaMap, kuryeMap from already-watched providers) and courier screen (needs `ugramaListProvider` to build a map). Fix `Kurye: ${s.kuryeId}` in active panel to show courier name.
3. **Cross-role integration test** — Widget test simulating the full lifecycle: müşteri creates order → ops sees it in waiting panel → ops assigns courier → courier sees order → courier punches timestamps → ops finishes with auto-pricing. Uses existing fakes.

## Don't Hand-Roll

| Problem | Existing Solution | Why Use It |
|---------|------------------|------------|
| Audio playback on iOS/Android | `audioplayers` ^6.x | Well-maintained, supports AssetSource + lowLatency mode for short alerts. No need for platform channel work. |
| ID→name resolution | D027 pattern from `operasyon_gecmis_page.dart` | Maps built from already-cached list providers. Proven pattern used in 2+ screens. |
| Stream change detection | `ref.listen` pattern from `operasyon_ekran_page.dart:319` | Already watches `siparisStreamActiveProvider` — just extend the listener to detect new orders and trigger sound. |
| Widget test fakes | `test/helpers/fakes/` — all 6 fake repos | Complete set of fakes with stream emission support already built across S03-S07. |

## Existing Code and Patterns

- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart:319` — `ref.listen(siparisStreamActiveProvider, ...)` clears selection on new data. Sound alert will extend this listener by comparing `prev`/`next` to detect new `kurye_bekliyor` orders.
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart:621` — `_routeLabel(s) => '${s.cikisId} → ${s.ugramaId}'` shows raw IDs. Replace with ugrama name map lookup.
- `lib/feature/operasyon/presentation/operasyon_ekran_page.dart:589` — `Text('Kurye: ${s.kuryeId ?? '-'}')` shows raw kurye ID. Replace with kurye name map lookup.
- `lib/feature/kurye/presentation/kurye_ana_page.dart:180` — `'${order.cikisId} → ${order.ugramaId}'` — same raw ID issue on courier screen.
- `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart:232-249` — ID→name map pattern (musteriMap, ugramaMap, kuryeMap) built from list providers. Reuse this exact approach.
- `lib/product/ugrama/ugrama_providers.dart` — `ugramaListProvider` (all stops) and `ugramaListByMusteriProvider` (per-customer) already exist.
- `lib/product/kurye/kurye_providers.dart` — `kuryeListProvider` already watched by dispatch page's waiting panel.
- `test/helpers/fakes/fake_siparis_repository.dart` — Has `emit()` and `emitForKurye()` for driving stream updates in tests.
- `test/helpers/fakes/fake_kurye_repository.dart` — In-memory fake with all methods including `getByUserId`.

## Constraints

- **No assets directory exists** — Must create `assets/sounds/` and register in `pubspec.yaml` under `flutter.assets`.
- **audioplayers requires iOS config** — May need to add `NSAppTransportSecurity` or audio category settings in `ios/Runner/Info.plist` for playback.
- **The dispatch page's `ref.listen` fires on every stream emission** — Sound detection needs to compare previous and current order lists to only fire on genuinely new `kurye_bekliyor` arrivals, not on existing order state changes.
- **`kuryeListProvider` is already watched but only inside `_buildWaitingPanel`** — To use it for name resolution in `_buildActivePanel`, move the watch up to `_buildDispatchPanels` or `_buildBody` level.
- **`ugramaListProvider` (all stops) is NOT currently watched on the dispatch page** — Must add `ref.watch(ugramaListProvider)` for name resolution. This fetches all stops across all customers, which is correct for ops view.
- **Courier screen currently has no stop name data** — Needs to watch `ugramaListProvider` (or a new provider) to resolve stop IDs to names.
- **114 tests currently pass** — All changes must maintain zero regressions.
- **`very_good_analysis` enforced** — New code must pass strict analysis.

## Common Pitfalls

- **Sound playing on every stream update** — The `ref.listen` fires on any siparisStreamActiveProvider emission (including existing order status changes). Must compare previous `kurye_bekliyor` IDs against new to detect truly new arrivals. Use a `Set<String>` of known IDs.
- **AudioPlayer lifecycle** — Don't create a new `AudioPlayer` instance per sound event. Create once and reuse. Dispose on widget unmount. Low-latency mode doesn't fire completion events — must manually stop/reset if needed.
- **Widget test flakiness with audio** — Widget tests cannot actually play audio. The `OrderAlertService` (or equivalent) should be injectable/mockable so tests can verify the trigger without real audio playback.
- **Overfetching stops** — `ugramaListProvider` fetches ALL stops. For the dispatch page this is fine (ops sees all customers' orders). For the courier page, it's a slight overfetch but acceptable since the courier only needs to resolve a few IDs.
- **Stream listener in `build()`** — The `ref.listen` in `_buildBody` is already inside `build()`, which is fine for `ConsumerStatefulWidget`. Don't add a second `ref.listen` — extend the existing one.

## Open Risks

- **Sound file licensing** — Need a royalty-free alert sound. Can generate a simple system-style beep or find a CC0/public domain `.wav` file.
- **Audio playback on iOS simulator** — iOS simulator may not support audio output reliably. Sound functionality should be verified on a real device if possible, but the code structure can be validated in tests.
- **Integration test coverage depth** — A true cross-role integration test with all 3 screens in one widget test is complex (different profile providers per role). May need to be structured as sequential steps with provider overrides swapped between phases, or as separate test cases that verify each handoff point.

## Skills Discovered

| Technology | Skill | Status |
|------------|-------|--------|
| Flutter | `flutter/skills@flutter-state-management` | available (1.2K installs) — not needed, Riverpod patterns already established |
| Flutter | `flutter/skills@flutter-performance` | available (1.2K installs) — not needed for this slice |
| Supabase Realtime | `nice-wolf-studio/claude-code-supabase-skills@supabase-realtime` | available (106 installs) — potentially useful but realtime patterns already established in D015/D019 |
| Senior Mobile | `senior-mobile` | installed — available if needed |
| Mobile Design | `mobile-design` | installed — available if needed |
| QA Testing Mobile | `qa-testing-mobile` | installed — available for integration test strategy |

No skills need installing for this slice — the codebase patterns are mature and the work is integration/polish rather than new capability.

## Sources

- audioplayers docs: `AssetSource` + `PlayerMode.lowLatency` for short sound effects (source: Context7 `/bluefireteam/audioplayers`)
- D027: ID-to-name resolution via maps from list providers (source: `.gsd/DECISIONS.md`)
- D019: Single stream, client-side split (source: `.gsd/DECISIONS.md`)
- D020: Clear selection on stream emission (source: `.gsd/DECISIONS.md`)
