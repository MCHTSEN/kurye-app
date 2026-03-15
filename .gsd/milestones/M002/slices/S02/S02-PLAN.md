# S02: Operasyon Uğrama-Müşteri Atama UI

**Goal:** Operasyon uğrama yönetim sayfasında bir uğramayı birden fazla müşteriye atayabilir. Uğrama listesinde hangi müşterilere atandığı görünür.
**Demo:** Operasyon uğrama yönetim sayfasında uğrama oluşturur, müşteri atar, atama değiştirir. Müşteri sipariş formunda sadece atanmış uğramaları görür.

## Must-Haves

- Uğrama yönetim sayfasında müşteri atama UI'ı (multi-select)
- Uğrama listesinde atanmış müşteri sayısı/isimleri görünmeli
- Atama değişikliği anında köprü tablosuna yansımalı
- Mevcut uğrama oluşturma/düzenleme çalışmalı (müşteri bağımsız)

## Verification

- `flutter analyze` — 0 error
- `flutter test` — all passing
- Widget test: Uğrama yönetim sayfasında müşteri atama chip'leri görünür

## Tasks

- [ ] **T01: Uğrama Yönetim Sayfası — Müşteri Atama UI** `est:1h`
  - Why: Operasyon bir uğramayı hangi müşterilere atayacağını seçebilmeli
  - Files: `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`, `lib/product/ugrama/ugrama_providers.dart`
  - Do: Uğrama listesinde her uğramanın yanında atanmış müşteri chip'leri göster. Uğramaya tıklandığında form + müşteri multi-select alanı açılsın. Kaydet'e basınca uğrama güncellenir + müşteri atamaları syncMusterilerForUgrama ile güncellenir.
  - Verify: `flutter analyze && flutter test`
  - Done when: Operasyon uğrama-müşteri atamasını yapabiliyor, liste doğru gösteriyor

## Files Likely Touched

- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`
- `lib/product/ugrama/ugrama_providers.dart`
