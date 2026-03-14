---
estimated_steps: 6
estimated_files: 8
---

# T02: CRUD UI pages, drawer wiring, and kurye route

**Slice:** S02 — Master Data CRUD
**Milestone:** M001

## Description

Replace the 4 placeholder operasyon pages with real master-detail CRUD interfaces. Add the missing kurye management route. Wire all drawer navigation items. Each page has a form panel at top (in an `AppSectionCard`) and an entity list at bottom, following the spec's "alt tarafta excel tablosu, tıklandığında üst panele çıksın" pattern.

## Steps

1. Add `kuryeYonetim('/operasyon/kurye')` to `CustomRoute` enum with a `routeName` case. Create `kurye_yonetim_page.dart` with `ConsumerStatefulWidget`. Register the route in `app_router.dart` with a `NamedRouteDef`.

2. Build a reusable master-detail CRUD page pattern. Each page:
   - `ConsumerStatefulWidget` with `GlobalKey<FormState>`, `TextEditingController`s per field
   - Top section: `AppSectionCard` wrapping a `Form` with `TextFormField`s, a submit `AppPrimaryButton` (with loading state), and a cancel button that clears the form
   - Bottom section: `AsyncValue`-based list using the entity list provider. Each row is a `ListTile` or `DataTable` row. Tapping a row populates the form for editing.
   - Editing vs creating distinguished by a nullable `_editingId` state variable
   - On submit: call repository `create()` or `update()`, invalidate the list provider, clear form

3. Implement `MusteriKayitPage` — fields: Firma Kısa Ad (required), Firma Tam Ad, Telefon, Adres, Email, Vergi No. List shows firma_kisa_ad + telefon + isActive.

4. Implement `UgramaYonetimPage` — fields: Müşteri (dropdown from musteriList provider), Uğrama Adı (required), Adres. List shows ugrama_adi + customer name + isActive. Dropdown uses `DropdownButtonFormField` with müşteri list.

5. Implement `MusteriPersonelKayitPage` — fields: Müşteri (dropdown), Ad (required), Telefon, Email. List shows ad + müşteri name + isActive. Similar müşteri dropdown.

6. Implement `KuryeYonetimPage` — fields: Ad (required), Telefon, Plaka. List shows ad + telefon + plaka + isOnline status.

7. Wire drawer in `OperasyonDashboardPage`:
   - Replace all TODO comments with `context.router.pushNamed(CustomRoute.xxx.path)` (or `Navigator.pushNamed` depending on auto_route usage)
   - Add kurye management drawer item with motorcycle icon

## Must-Haves

- [ ] `kuryeYonetim` route registered in `CustomRoute`, `app_router.dart`
- [ ] `MusteriKayitPage` — form + list, create/edit müşteri
- [ ] `UgramaYonetimPage` — form with müşteri dropdown + list, create/edit uğrama
- [ ] `MusteriPersonelKayitPage` — form with müşteri dropdown + list, create/edit personel
- [ ] `KuryeYonetimPage` — form + list, create/edit kurye
- [ ] All drawer items navigate to correct routes
- [ ] Forms validate required fields before submit
- [ ] Editing: tapping list item populates form, submit updates, clear resets to create mode
- [ ] `flutter analyze` clean

## Verification

- `flutter analyze` — 0 issues
- `flutter build ios --no-codesign` — builds without errors (or `flutter build ios --simulator`)
- Manual: Run on iOS simulator, navigate via drawer to each page, verify form renders with fields

## Inputs

- `lib/product/musteri/musteri_providers.dart` — T01 output, provides musteriList
- `lib/product/ugrama/ugrama_providers.dart` — T01 output
- `lib/product/musteri_personel/musteri_personel_providers.dart` — T01 output
- `lib/product/kurye/kurye_providers.dart` — T01 output
- `lib/product/widgets/app_primary_button.dart` — reusable button with loading
- `lib/product/widgets/app_section_card.dart` — card wrapper
- `lib/core/constants/project_padding.dart` — padding tokens
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — drawer to wire

## Expected Output

- `lib/app/router/custom_route.dart` — `kuryeYonetim` added
- `lib/app/router/app_router.dart` — kurye management route registered
- `lib/feature/operasyon/presentation/musteri_kayit_page.dart` — real CRUD page (replaces placeholder)
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart` — real CRUD page (replaces placeholder)
- `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart` — real CRUD page (replaces placeholder)
- `lib/feature/operasyon/presentation/kurye_yonetim_page.dart` — new CRUD page
- `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart` — drawer wired + kurye item added
