# S08: Cross-role Integration & Polish — UAT

**Milestone:** M001
**Written:** 2026-03-15

## UAT Type

- UAT mode: mixed (artifact-driven for logic + live-runtime for cross-role flow)
- Why this mode is sufficient: Integration tests prove data lifecycle correctness; live runtime verifies sound playback, name rendering, and cross-role screen transitions with real Supabase

## Preconditions

- Supabase project running with all tables, RLS policies, and seed data (at least 1 müşteri, 2+ uğrama, 1+ kurye, 1+ müşteri personel)
- App running on iOS simulator via `flutter run --dart-define-from-file=.env`
- Three user accounts: one operasyon, one müşteri personel, one kurye (all approved)
- Device audio enabled (simulator Settings → Sounds)

## Smoke Test

Login as operasyon → dispatch screen shows 3 panels → create an order → verify it appears in the "Kurye Bekleyenler" panel with stop names (not UUIDs) and a sound alert plays.

## Test Cases

### 1. Sound alert on new order arrival

1. Login as operasyon, navigate to dispatch screen
2. Keep the dispatch screen open
3. In a separate session (or from müşteri login), create a new order
4. **Expected:** A short beep plays when the new order appears in the "Kurye Bekleyenler" panel. No sound on page load or when existing orders change status.

### 2. Name resolution on dispatch screen

1. Login as operasyon, navigate to dispatch screen
2. Create an order specifying known stops (çıkış, uğrama)
3. Look at the order in "Kurye Bekleyenler" panel
4. **Expected:** Route shows stop names (e.g., "Merkez Ofis → Şube B"), not UUIDs. After assigning a courier, the "Devam Edenler" panel shows the courier's name, not UUID.

### 3. Name resolution on courier screen

1. Login as kurye
2. Have at least one order assigned to this courier
3. Look at the order card
4. **Expected:** Route text shows stop names (e.g., "Depo A → Şube B"), not UUIDs. If uğrama1 is set, it also shows a resolved name.

### 4. Full cross-role lifecycle

1. Login as müşteri personel → create an order (pick çıkış, uğrama, not)
2. Login as operasyon → verify order appears in "Kurye Bekleyenler" with sound
3. Select the order checkbox → pick a courier → tap "Ata"
4. Verify order moves to "Devam Edenler" panel with courier name
5. Login as kurye → verify order appears in the order list
6. Tap "Çıkış" timestamp button → verify timestamp is set
7. Tap "Uğrama" timestamp button → verify timestamp is set
8. Login as operasyon → select order in "Devam Edenler" → tap "Bitir"
9. **Expected:** Auto-pricing dialog appears (if matching historical order exists) or manual price prompt. After confirming, order disappears from active panels.
10. Navigate to order history → verify order shows with status "tamamlandı" and price set

### 5. No false alerts on status changes

1. Login as operasyon on dispatch screen with existing waiting orders
2. Assign a courier to one of the waiting orders
3. **Expected:** No sound alert plays — the order changed status but no *new* order arrived

## Edge Cases

### Sound on rapid multiple orders

1. Create 3 orders in quick succession from müşteri
2. **Expected:** Sound plays once per stream emission batch (may be 1-3 times depending on batching), not 3 separate sounds stacked

### Name fallback for deleted stop

1. If a stop referenced by an order is deleted from the database
2. **Expected:** Order displays the raw UUID instead of crashing — graceful fallback

### Courier sees only their orders

1. Have two couriers with different assigned orders
2. Login as each courier separately
3. **Expected:** Each courier sees only their own assigned orders, not the other courier's

## Failure Signals

- Raw UUIDs (long hex strings) visible anywhere on dispatch or courier order cards
- Sound plays on every stream emission (including page load or existing order status changes)
- No sound at all when a genuinely new order arrives
- Courier seeing orders assigned to other couriers
- App crash on dispatch screen when providers are loading

## Requirements Proved By This UAT

- R017 — Sound alert fires on new kurye_bekliyor orders, not on status changes
- R008 — Full cross-role lifecycle: create → assign → deliver → complete with realtime visibility across all screens
- R009 — Dispatch 3-panel screen with name resolution
- R011 — Courier timestamp punching visible from courier screen
- R012 — Auto-pricing on order finish

## Not Proven By This UAT

- R019 (location tracking) — deferred to M002
- R020 (map tracking) — deferred to M002
- R021 (auto assignment) — deferred to M002
- R022 (web responsive) — deferred to M002
- Sound playback on real iOS device (only tested on simulator)
- Concurrent multi-operasyon scenarios (single user per role tested)

## Notes for Tester

- iOS simulator audio can be finicky — if no sound plays, check simulator volume and Settings → Sounds. The sound service is best-effort; absence of sound doesn't mean the feature is broken, just that the simulator may not be producing audio.
- Name resolution shows raw UUIDs briefly during initial load while providers fetch data — this is expected, not a bug.
- The auto-pricing lookup needs at least one previously completed order with the same müşteri+çıkış+uğrama route to auto-populate the price. If no match exists, the manual pricing dialog appears — this is correct behavior.
