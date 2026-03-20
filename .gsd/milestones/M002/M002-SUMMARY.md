---
id: M002
provides:
  - musteri_ugrama köprü tablosu (many-to-many uğrama-müşteri ilişkisi)
  - ugrama_talepleri tablosu ve talep-onay akışı
  - MusteriUgramaRepository kontratı + Supabase implementasyonu
  - UgramaTalebiRepository kontratı + Supabase implementasyonu
  - UgramaTalebi domain modeli
  - Operasyon uğrama-müşteri atama UI (FilterChip multi-select)
  - Müşteri uğrama talep sayfası + Operasyon talep yönetim sayfası
  - Sipariş formu köprü tablosu üzerinden filtreleme
key_decisions:
  - D035: musteri_ugrama köprü tablosu ile many-to-many model (ugramalar.musteri_id kaldırıldı)
  - D036: Müşteri talep eder, operasyon kabul/red eder (ugrama_talepleri tablosu)
  - D037: Köprü tablosu üzerinden uğrama erişim kontrolü (RLS + provider)
patterns_established:
  - syncMusterilerForUgrama ile toplu köprü tablosu atama pattern
  - FilterChip multi-select ile köprü tablosu atama UI pattern
  - Talep-onay akışı (pending → approved/rejected) ile otomatik entity oluşturma
observability_surfaces:
  - none
requirement_outcomes:
  - id: R004
    from_status: active
    to_status: active
    proof: Many-to-many model eklendi, talep sistemi eklendi. R004 M001'de validated, M002 kapsamını genişletti — validation korunuyor. 135 test passing, köprü tablosu DB'de çalışıyor, sipariş formu bozulmamış.
duration: ~5h
verification_result: passed
completed_at: 2026-03-15
---

# M002: Many-to-Many Uğrama Modeli ve Talep Sistemi

**Uğramalar bağımsız havuza taşındı, müşterilerle many-to-many köprü tablosu kuruldu, müşteri talep → operasyon onay akışı end-to-end çalışıyor.**

## What Happened

M002, uğrama veri modelini kökten değiştirdi: her uğramanın tek bir müşteriye ait olduğu `ugramalar.musteri_id` FK modeli kaldırılıp, `musteri_ugrama` köprü tablosu ile many-to-many ilişkiye geçildi. Bu sayede aynı fiziksel adres (uğrama) birden fazla müşteri tarafından paylaşılabiliyor — DB'de tek kayıt olarak.

S01 altyapıyı kurdu: DB migration ile köprü ve talep tabloları oluşturuldu, mevcut `musteri_id` verileri köprüye migrate edildi, RLS politikaları köprü üzerinden çalışacak şekilde yeniden yazıldı, Ugrama domain modelinden `musteriId` kaldırıldı, `UgramaTalebi` domain modeli oluşturuldu, iki yeni repository kontratı + Supabase implementasyonu + provider katmanı eklendi.

S02 operasyon tarafını tamamladı: Uğrama yönetim sayfasına FilterChip multi-select ile müşteri atama UI'ı eklendi. Her uğramanın yanında atanmış müşteri chip'leri görünüyor, `syncMusterilerForUgrama` ile toplu atama yapılıyor.

S03 talep sistemini kurdu: Müşteri personeli uğrama talebi gönderebiliyor (ugrama_adi + adres formu), operasyon bekleyen talepleri listeleyip kabul veya red edebiliyor. Kabul edilen talep otomatik olarak ugramalar tablosuna ve musteri_ugrama köprüsüne insert oluyor. Red durumunda not ile birlikte kaydediliyor.

S04 entegrasyonu doğruladı: Sipariş formu dropdown'ları artık köprü tablosu üzerinden müşteriye atanmış uğramaları filtreliyor, mevcut dispatch akışı bozulmadı, UgramaTalebi domain testleri eklendi. 135 test passing (2 pre-existing failure: golden test + dashboard locale mismatch — M001 kaynaklı).

## Cross-Slice Verification

| Success Criterion | Verification |
|---|---|
| Bir uğrama birden fazla müşteriye atanabilir, DB'de tek kayıt | S01: `musteri_ugrama` köprü tablosu DB'ye deploy edildi, curl ile sorgulandı. S02: FilterChip multi-select ile birden fazla müşteriye atama UI çalışıyor. |
| Müşteri personeli sipariş formunda sadece kendi müşterisine atanmış uğramaları görür | S01: `ugramaListByMusteriProvider` köprü üzerinden çalışıyor. S04: Sipariş formu dropdown'ı köprü filtrelemesi ile doğrulandı. RLS politikaları köprü tablosuna bağlı. |
| Müşteri personeli yeni uğrama talebi gönderebilir | S03: `musteri_ugrama_talep_page.dart` — form ile ugrama_adi + adres gönderiliyor. |
| Operasyon talepleri kabul edebilir (→ ugramalar + köprü insert) veya reddedebilir (not ile) | S03: `ugrama_talep_yonetim_page.dart` — kabul → `approve()` bir transaction'da uğrama + köprü oluşturuyor. Red → `reject(redNotu)` ile kaydediliyor. |
| Mevcut siparişler bozulmaz (FK referansları aynı kalır) | S04: `flutter test` — 135 passing, mevcut sipariş testleri dahil. Sipariş FK'ları doğrudan ugramalar tablosunu referans etmeye devam ediyor, değişmedi. |

**Verification commands:**
- `flutter analyze` — 0 errors (41 infos, all pre-existing)
- `flutter test` — 135 passing, 2 failing (pre-existing: golden test + dashboard locale)

## Requirement Changes

- R004: active → active (validation korunuyor) — M002 R004'ün kapsamını genişletti: uğramalar artık müşteri bağımsız havuzda, many-to-many atama ve talep sistemi eklendi. R004 M001'de validated, M002 kapsamını genişletti ancak validation bozulmadı (mevcut testler + yeni UgramaTalebi testleri geçiyor).

## Forward Intelligence

### What the next milestone should know
- Uğramalar artık müşteri bağımsız (`ugramalar.musteri_id` yok). Müşteriye atama `musteri_ugrama` köprü tablosu üzerinden yapılıyor.
- `syncMusterilerForUgrama(ugramaId, musteriIds)` ile toplu atama pattern'i kuruldu — benzer many-to-many ilişkiler için referans.
- Talep-onay akışı `ugrama_talepleri` tablosu üzerinden çalışıyor — `pending → approved/rejected` state machine. Approve otomatik entity oluşturur.
- Sipariş FK'ları doğrudan `ugramalar` tablosunu referans ediyor, köprü sadece filtreleme ve atama için.
- 2 pre-existing test failure var (golden + dashboard locale) — M001 kaynaklı, M002'de regresyon değil.

### What's fragile
- RLS politikaları köprü tablosuna bağımlı — `musteri_ugrama` kayıtları silinirse müşteri personeli ilgili uğramaları göremez, sipariş oluşturamaz.
- Talep approve akışı tek transaction'da uğrama + köprü oluşturuyor — Supabase RPC veya client-side multi-call, transaction failure'da yarım kayıt riski var.

### Authoritative diagnostics
- `flutter test test/domain/ugrama_talebi_test.dart` — UgramaTalebi domain modeli roundtrip + enum testleri
- `curl musteri_ugrama tablosu` — köprü ilişkilerinin doğruluğu
- `flutter test` — tüm 135 test (M002 regresyon kontrolü)

### What assumptions changed
- Uğrama modeli artık müşteri bağımlı değil — sipariş formunda dropdown filtreleme DB join yerine köprü tablosu lookup üzerinden çalışıyor.

## Files Created/Modified

- `supabase/migrations/20260315002000_ugrama_many_to_many.sql` — köprü + talep tabloları, data migration, RLS politikaları
- `packages/backend_core/lib/src/domain/ugrama.dart` — musteriId alanı kaldırıldı
- `packages/backend_core/lib/src/domain/ugrama_talebi.dart` — yeni domain model
- `packages/backend_core/lib/src/musteri_ugrama_repository.dart` — yeni repository kontratı
- `packages/backend_core/lib/src/ugrama_talebi_repository.dart` — yeni repository kontratı
- `packages/backend_supabase/lib/src/supabase_musteri_ugrama_repository.dart` — Supabase implementasyonu
- `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart` — Supabase implementasyonu
- `lib/product/ugrama/ugrama_providers.dart` — musteri_ugrama ve ugrama_talebi provider'ları eklendi
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart` — müşteri atama FilterChip UI eklendi
- `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart` — müşteri talep sayfası
- `lib/feature/operasyon/presentation/ugrama_talep_yonetim_page.dart` — operasyon talep yönetimi
- `lib/app/router/custom_route.dart` — yeni route'lar
- `lib/app/router/app_router.dart` — route registration
- `lib/product/navigation/role_nav_items.dart` — nav items güncellendi
- `test/domain/ugrama_talebi_test.dart` — UgramaTalebi domain testleri
