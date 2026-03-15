# S03: Uğrama Talep Sistemi UI

**Goal:** Müşteri personeli yeni uğrama talebi gönderebilir, operasyon kabul/red edebilir.
**Demo:** Müşteri personeli talep gönderir, operasyon kabul eder → uğrama havuzuna ve müşteriye otomatik atanır. Red durumunda not görünür.

## Must-Haves

- Müşteri tarafı: Talep formu (ugrama_adi + adres) + talep listesi (durum + red notu)
- Operasyon tarafı: Bekleyen talepler listesi + kabul/red (red notu dialog)
- Route ve navigasyon eklenmesi
- Talep kabul → uğrama + köprü otomatik oluşturma (repository zaten hazır)

## Verification

- `flutter analyze` — 0 error
- `flutter test` — all passing

## Tasks

- [ ] **T01: Müşteri Uğrama Talep Sayfası** `est:45m`
  - Why: Müşteri personeli yeni uğrama talebi gönderebilmeli ve taleplerini görebilmeli
  - Files: `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart`, route/nav files
  - Do: Talep formu + talep listesi (durum chip, red notu). Route ve navigasyon ekle.
  - Verify: `flutter analyze`
  - Done when: Müşteri personeli talep sayfasını görebiliyor

- [ ] **T02: Operasyon Talep Yönetim Sayfası** `est:45m`
  - Why: Operasyon bekleyen talepleri görebilmeli, kabul/red edebilmeli
  - Files: `lib/feature/operasyon/presentation/ugrama_talep_yonetim_page.dart`, route/nav files
  - Do: Bekleyen talepler listesi. Kabul butonu → approve(). Red butonu → dialog ile not girişi → reject(). Route ve navigasyon ekle.
  - Verify: `flutter analyze && flutter test`
  - Done when: Operasyon talepleri kabul/red edebiliyor

## Files Likely Touched

- `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart` (yeni)
- `lib/feature/operasyon/presentation/ugrama_talep_yonetim_page.dart` (yeni)
- `lib/app/router/custom_route.dart`
- `lib/app/router/app_router.dart`
- `lib/product/navigation/role_nav_items.dart`
