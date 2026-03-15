---
estimated_steps: 6
estimated_files: 4
---

# T02: Customer order creation and history pages

**Slice:** S03 — Order Creation & Customer Tracking
**Milestone:** M001

## Description

Replace both placeholder müşteri pages with real implementations. `MusteriSiparisPage` becomes an order creation form with cascading dropdowns (çıkış, uğrama, uğrama1, not — all loaded from customer's uğramalar) plus a realtime active orders list below the form. `MusteriGecmisPage` becomes a completed orders list with date range filtering. Includes widget tests covering form rendering, validation, and order creation flow.

## Steps

1. Rewrite `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` as `ConsumerStatefulWidget`. Profile-based auto-selection: read `musteriId` from `currentUserProfileProvider`, guard null with error message. Load dropdowns via `ugramaListByMusteriProvider(musteriId)`. Form fields: Çıkış (required `DropdownButtonFormField`), Uğrama (required), Uğrama1 (optional), Not (optional dropdown from same uğramalar), Not1 (optional `TextFormField`). Submit resolves `personel_id` via `ref.read(musteriPersonelRepositoryProvider).getByUserId(profile.id)`, creates `Siparis` with `olusturanId = profile.id`, `musteriId`, selected stop IDs, `durum = kurye_bekliyor`. Invalidate stream after creation. Show SnackBar on success/error.
2. Below the form, add an active orders section using `siparisStreamByMusteriProvider(musteriId)`. Display as a `ListView` of `Card` widgets showing: çıkış adı, uğrama adı, durum badge (color-coded), oluşturma zamanı. Use `ref.watch()` on the stream provider for live updates. Map stop IDs to names by joining with the uğramalar list.
3. Rewrite `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`. Load completed orders via `siparisListByMusteriProvider(musteriId)` (filter to `tamamlandi` on client side or add a dedicated provider). Add date range filter with `showDateRangePicker`. Display filtered results in a `ListView` with order details (stops, ucret, date).
4. Write `test/feature/musteri_siparis/musteri_siparis_page_test.dart` following `musteri_kayit_page_test.dart` pattern. Override providers with fakes: `FakeSiparisRepository`, `FakeMusteriRepository`, fake `UgramaRepository`, fake `MusteriPersonelRepository`. Tests: form renders all 5 fields (4 dropdowns + 1 text), validation rejects empty çıkış/uğrama, successful submit calls `create()` on fake repo with correct data.
5. Run `flutter analyze` and fix any issues. Run `flutter test` to verify all tests pass.
6. Run `flutter build ios --simulator` to verify build succeeds.

## Must-Haves

- [ ] Order form has 4 dropdown fields (çıkış, uğrama, uğrama1, not) + 1 text field (not1)
- [ ] Dropdowns load from customer's uğramalar via `ugramaListByMusteriProvider(musteriId)`
- [ ] Customer's `musteriId` auto-resolved from `AppUserProfile` — no manual selection
- [ ] `personel_id` resolved via `getByUserId(profile.id)` — allow null gracefully
- [ ] Active orders list updates in realtime via stream provider
- [ ] History page shows completed orders with date filter
- [ ] Widget test covers form render, validation, and create flow
- [ ] `flutter analyze` clean, `flutter test` all pass, `flutter build ios --simulator` succeeds

## Verification

- `flutter analyze` — 0 errors, 0 warnings
- `flutter test test/feature/musteri_siparis/musteri_siparis_page_test.dart` — all tests pass
- `flutter test` — all tests pass (no regressions)
- `flutter build ios --simulator` — succeeds

## Inputs

- `lib/product/siparis/siparis_providers.dart` — stream and list providers from T01
- `packages/backend_core/lib/src/domain/siparis.dart` — Siparis model from T01
- `test/helpers/fakes/fake_siparis_repository.dart` — fake repo from T01
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — CRUD page pattern to follow
- `test/feature/operasyon/musteri_kayit_page_test.dart` — widget test pattern to follow
- `lib/product/ugrama/ugrama_providers.dart` — ugramaListByMusteriProvider for dropdowns
- `lib/product/user_profile/user_profile_providers.dart` — currentUserProfileProvider for auto-selection

## Expected Output

- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — real order form + active orders list
- `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart` — real history page with date filter
- `test/feature/musteri_siparis/musteri_siparis_page_test.dart` — widget tests (3+ test cases)
