# S01: DB Migration + Repository Katmanı

**Goal:** ugramalar tablosundan musteri_id bağımlılığını kaldırıp many-to-many köprü tablosuna geçirmek, ugrama_talepleri tablosunu oluşturmak, repository katmanını güncellemek.
**Demo:** flutter analyze + flutter test geçiyor, mevcut veriler köprü tablosuna migrate edilmiş, repository üzerinden uğrama-müşteri ataması ve talep CRUD'u çalışıyor.

## Must-Haves

- musteri_ugrama köprü tablosu (DB + migration)
- ugrama_talepleri tablosu (DB + migration)
- Data migration: mevcut ugramalar.musteri_id → musteri_ugrama köprü kaydına
- ugramalar.musteri_id sütunu kaldırma
- RLS politikaları güncelleme (köprü tablosu üzerinden erişim)
- Ugrama domain modeli güncelleme (musteriId kaldır)
- MusteriUgramaRepository kontratı + Supabase implementasyonu
- UgramaTalebi domain modeli + repository kontratı + Supabase implementasyonu
- UgramaRepository.getByMusteriId köprü üzerinden çalışsın
- Mevcut testler geçsin

## Verification

- `flutter analyze` — 0 error
- `flutter test` — all passing
- Supabase'de curl ile musteri_ugrama köprü tablosunu sorgulama
- Supabase'de curl ile ugrama_talepleri tablosunu sorgulama

## Tasks

- [ ] **T01: DB Migration — Köprü ve Talep Tabloları** `est:45m`
  - Why: Many-to-many model için DB altyapısı gerekli
  - Files: `supabase/migrations/20260315002000_ugrama_many_to_many.sql`
  - Do: musteri_ugrama köprü tablosu oluştur, ugrama_talepleri tablosu oluştur, mevcut musteri_id verilerini köprüye migrate et, ugramalar.musteri_id sütununu kaldır, RLS politikalarını güncelle, mevcut ugramalar RLS'ini köprü üzerinden yeniden yaz
  - Verify: Supabase MCP veya curl ile migration'ı uygula, tabloları sorgula, mevcut sipariş FK'larının çalıştığını doğrula
  - Done when: Köprü tablosu var, mevcut veriler migrate edilmiş, RLS çalışıyor

- [ ] **T02: Domain Modelleri + Repository Kontratları** `est:30m`
  - Why: Uygulama katmanı yeni DB yapısını yansıtmalı
  - Files: `packages/backend_core/lib/src/domain/ugrama.dart`, `packages/backend_core/lib/src/domain/ugrama_talebi.dart`, `packages/backend_core/lib/src/ugrama_repository.dart`, `packages/backend_core/lib/src/musteri_ugrama_repository.dart`, `packages/backend_core/lib/src/ugrama_talebi_repository.dart`, `packages/backend_core/lib/backend_core.dart`
  - Do: Ugrama modelinden musteriId kaldır, UgramaTalebi domain modeli oluştur (id, musteriId, talepEdenId, ugramaAdi, adres, durum enum, redNotu, onaylananUgramaId, createdAt, updatedAt), MusteriUgramaRepository kontratı (assign, unassign, getByMusteriId, getMusterilerByUgramaId), UgramaTalebiRepository kontratı (create, getByMusteriId, getAll, approve, reject), backend_core barrel export güncelle
  - Verify: `cd packages/backend_core && dart analyze`
  - Done when: Tüm kontratlar derlenebilir, barrel export temiz

- [ ] **T03: Supabase Repository İmplementasyonları** `est:45m`
  - Why: DB'ye erişim katmanı
  - Files: `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart`, `packages/backend_supabase/lib/src/supabase_musteri_ugrama_repository.dart`, `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart`, `packages/backend_supabase/lib/src/supabase_backend_module.dart`, `packages/backend_supabase/lib/backend_supabase.dart`
  - Do: SupabaseUgramaRepository'den musteri_id referanslarını kaldır, getByMusteriId'yi köprü üzerinden join query ile yeniden yaz. SupabaseMusteriUgramaRepository ve SupabaseUgramaTalebiRepository oluştur. BackendModule'a yeni repository factory'leri ekle. Barrel export güncelle.
  - Verify: `cd packages/backend_supabase && dart analyze`
  - Done when: Tüm implementasyonlar derlenebilir

- [ ] **T04: Provider Katmanı + Mevcut Kod Uyumu** `est:30m`
  - Why: UI katmanı provider üzerinden repository'lere erişir, mevcut kodun yeni modelle çalışması gerekli
  - Files: `lib/product/ugrama/ugrama_providers.dart`, `lib/product/ugrama/musteri_ugrama_providers.dart`, `lib/product/ugrama/ugrama_talebi_providers.dart`, `lib/app/backend_module_factory.dart`, `packages/backend_core/lib/src/backend_module.dart`
  - Do: Yeni provider'lar oluştur (musteriUgramaRepository, ugramaTalebiRepository, provider'lar), mevcut ugramaListByMusteriProvider'ı köprü repo üzerinden çalışacak şekilde güncelle, BackendModule kontratına yeni factory'leri ekle
  - Verify: `flutter analyze && flutter test`
  - Done when: 0 analysis error, mevcut testler geçiyor

## Files Likely Touched

- `supabase/migrations/20260315002000_ugrama_many_to_many.sql`
- `packages/backend_core/lib/src/domain/ugrama.dart`
- `packages/backend_core/lib/src/domain/ugrama_talebi.dart`
- `packages/backend_core/lib/src/ugrama_repository.dart`
- `packages/backend_core/lib/src/musteri_ugrama_repository.dart`
- `packages/backend_core/lib/src/ugrama_talebi_repository.dart`
- `packages/backend_core/lib/backend_core.dart`
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart`
- `packages/backend_supabase/lib/src/supabase_musteri_ugrama_repository.dart`
- `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart`
- `packages/backend_supabase/lib/src/supabase_backend_module.dart`
- `packages/backend_supabase/lib/backend_supabase.dart`
- `lib/product/ugrama/ugrama_providers.dart`
- `lib/product/ugrama/musteri_ugrama_providers.dart`
- `lib/product/ugrama/ugrama_talebi_providers.dart`
- `lib/app/backend_module_factory.dart`
