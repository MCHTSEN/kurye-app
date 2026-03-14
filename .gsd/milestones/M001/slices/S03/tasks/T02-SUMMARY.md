---
id: T02
parent: S03
milestone: M001
provides:
  - Order creation form with cascading dropdowns from customer uğramalar
  - Active orders realtime list via stream provider
  - Completed orders history page with date range filtering
  - Widget tests (4 cases) for form render, validation, submit, and null guard
  - Fake repos for UgramaRepository and MusteriPersonelRepository
key_files:
  - lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart
  - lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart
  - test/feature/musteri_siparis/musteri_siparis_page_test.dart
  - test/helpers/fakes/fake_ugrama_repository.dart
  - test/helpers/fakes/fake_musteri_personel_repository.dart
key_decisions:
  - "D016: Controlled DropdownButtonFormField pattern — state tracked via setState with form validation, not initialValue-based uncontrolled form fields"
  - "D017: musteriId resolved from AppUserProfile.musteriId — no separate lookup needed; null guarded with user-facing error message"
patterns_established:
  - "overrideWithBuild for Riverpod 3 AsyncNotifier providers in widget tests — (ref, notifier) => value pattern"
  - "FakeUgramaRepository and FakeMusteriPersonelRepository for widget test isolation — reuse in S04+"
observability_surfaces:
  - "SiparisDurum color-coded chips in active orders list — visual confirmation of order status"
  - "SnackBar feedback on order creation success/failure"
duration: 20m
verification_result: passed
completed_at: 2026-03-15
blocker_discovered: false
---

# T02: Customer order creation and history pages

**Replaced both placeholder müşteri pages with real implementations: order creation form with 4 cascading dropdowns + text field, realtime active orders list, and completed orders history page with date range filtering.**

## What Happened

Rewrote `MusteriSiparisPage` as a `ConsumerStatefulWidget` with a real order creation form. The form loads uğramalar from `ugramaListByMusteriProvider(musteriId)` and populates 4 `DropdownButtonFormField`s (Çıkış *, Uğrama *, Uğrama1, Not) plus a `TextFormField` for Not1. The `musteriId` is auto-resolved from `AppUserProfile.musteriId` — null profile or null musteriId shows a guard message. On submit, `personel_id` is resolved via `MusteriPersonelRepository.getByUserId(profile.id)` (allowed to be null), and the `Siparis` is created with `durum = kurye_bekliyor`. After creation, the stream provider is invalidated and a success SnackBar is shown.

Below the form, an active orders section uses `siparisStreamByMusteriProvider(musteriId)` with `ref.watch()` for realtime updates. Orders are filtered client-side to active statuses and displayed as cards with color-coded durum chips (orange for kurye_bekliyor, blue for devam_ediyor) and stop name resolution from the uğramalar list.

Rewrote `MusteriGecmisPage` with `siparisListByMusteriProvider(musteriId)`, client-side filtering to `tamamlandi`, and `showDateRangePicker` for date range filtering. Results sorted newest-first, with ücret and date display.

Created `FakeUgramaRepository` and `FakeMusteriPersonelRepository` in test helpers for widget test isolation. Used `currentUserProfileProvider.overrideWithBuild((ref, notifier) => profile)` pattern for the AsyncNotifier provider override — this is the first use of this pattern in the codebase.

## Verification

- `flutter analyze` — 0 errors, 0 warnings (12 infos, all pre-existing or trivial deprecation notices)
- `flutter test test/feature/musteri_siparis/musteri_siparis_page_test.dart` — 4/4 tests pass
  - renders all 5 form fields (4 dropdowns + 1 text)
  - validation rejects empty required fields (Çıkış, Uğrama)
  - successful submit creates order with correct data (musteriId, cikisId, ugramaId, not1, personelId, olusturanId, durum)
  - shows error when profile has no musteriId
- `flutter test` — 76/76 tests pass, 0 failures, no regressions
- `flutter build ios --simulator` — succeeds

### Slice-level verification (final task — T02 of 2):
- ✅ `flutter analyze` — 0 errors, 0 warnings
- ✅ `flutter test` — all 76 tests pass including:
  - ✅ `test/domain/siparis_test.dart` — 7 domain model tests
  - ✅ `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — 4 widget tests
- ✅ `flutter build ios --simulator` — builds successfully

## Diagnostics

- SnackBar messages confirm order creation success/failure to the user
- Durum color-coded chips provide visual status inspection in active orders list
- Stream subscription lifecycle managed by autoDispose — no leak risk
- Error states surfaced via `AsyncValue.error` in both pages

## Deviations

None.

## Known Issues

- `DropdownButtonFormField.value` parameter shows deprecation info in Flutter 3.33+ (use `initialValue`), but switching to `initialValue` would break the controlled dropdown pattern. Info-level only, no functional impact.

## Files Created/Modified

- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — **rewritten** — order creation form + active orders realtime list
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — **rewritten** — completed orders list with date range filter
- `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — **created** — 4 widget tests
- `test/helpers/fakes/fake_ugrama_repository.dart` — **created** — in-memory fake for widget tests
- `test/helpers/fakes/fake_musteri_personel_repository.dart` — **created** — in-memory fake for widget tests
