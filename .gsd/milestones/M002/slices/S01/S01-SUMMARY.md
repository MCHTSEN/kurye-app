---
id: S01
parent: M002
milestone: M002
provides:
  - musteri_ugrama köprü tablosu (many-to-many)
  - ugrama_talepleri tablosu
  - MusteriUgramaRepository kontratı + Supabase impl
  - UgramaTalebiRepository kontratı + Supabase impl
  - Ugrama domain modeli (musteriId kaldırıldı)
  - UgramaTalebi domain modeli
  - Provider katmanı (musteri_ugrama, ugrama_talebi)
requires: []
affects:
  - S02
  - S03
  - S04
key_files:
  - supabase/migrations/20260315002000_ugrama_many_to_many.sql
  - packages/backend_core/lib/src/domain/ugrama.dart
  - packages/backend_core/lib/src/domain/ugrama_talebi.dart
  - packages/backend_core/lib/src/musteri_ugrama_repository.dart
  - packages/backend_core/lib/src/ugrama_talebi_repository.dart
  - packages/backend_supabase/lib/src/supabase_musteri_ugrama_repository.dart
  - packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart
  - lib/product/ugrama/musteri_ugrama_providers.dart
  - lib/product/ugrama/ugrama_talebi_providers.dart
key_decisions:
  - D035: musteri_ugrama köprü tablosu ile many-to-many model
  - D037: Köprü tablosu üzerinden uğrama erişim kontrolü (RLS)
patterns_established:
  - Köprü tablosu + syncMusterilerForUgrama pattern
observability_surfaces:
  - none
drill_down_paths: []
duration: ~2h
verification_result: passed
completed_at: 2026-03-15
---

# S01: DB Migration + Repository Katmanı

**Many-to-many uğrama modeli DB'de kuruldu, köprü tablosu + talep tablosu + repository katmanı + provider'lar çalışıyor.**

## What Happened

musteri_ugrama köprü tablosu ve ugrama_talepleri tablosu oluşturuldu. Mevcut ugramalar.musteri_id verileri köprü tablosuna migrate edildi, musteri_id sütunu kaldırıldı. RLS politikaları köprü üzerinden çalışacak şekilde güncellendi. Ugrama domain modelinden musteriId alanı kaldırıldı, UgramaTalebi domain modeli oluşturuldu. MusteriUgramaRepository ve UgramaTalebiRepository kontratları + Supabase implementasyonları yazıldı. Provider katmanı eklendi.

## Verification

- DB migration Supabase'e uygulandı, curl ile tablolar sorgulandı
- `flutter analyze` — 0 error
- `flutter test` — all passing

## Requirements Advanced

- R004 — Uğrama modeli many-to-many'ye geçirildi, müşteri bağımsız havuz

## Requirements Validated

- none (validation S04'te yapılacak)

## New Requirements Surfaced

- none

## Requirements Invalidated or Re-scoped

- none

## Deviations

none

## Known Limitations

- UI henüz yok — sadece DB + repository + provider katmanı

## Follow-ups

- S02: Operasyon uğrama-müşteri atama UI
- S03: Talep sistemi UI

## Files Created/Modified

- `supabase/migrations/20260315002000_ugrama_many_to_many.sql` — köprü + talep tabloları, data migration, RLS
- `packages/backend_core/lib/src/domain/ugrama.dart` — musteriId kaldırıldı
- `packages/backend_core/lib/src/domain/ugrama_talebi.dart` — yeni domain model
- `packages/backend_core/lib/src/musteri_ugrama_repository.dart` — yeni kontrat
- `packages/backend_core/lib/src/ugrama_talebi_repository.dart` — yeni kontrat
- `packages/backend_supabase/lib/src/supabase_musteri_ugrama_repository.dart` — yeni impl
- `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart` — yeni impl
- `lib/product/ugrama/musteri_ugrama_providers.dart` — yeni provider'lar
- `lib/product/ugrama/ugrama_talebi_providers.dart` — yeni provider'lar

## Forward Intelligence

### What the next slice should know
- syncMusterilerForUgrama(ugramaId, musteriIds) ile toplu atama yapılır
- getByMusteriId köprü üzerinden çalışıyor, API aynı

### What's fragile
- RLS politikaları köprü tablosuna bağımlı — köprü kayıtları silinirse erişim kesilir

### Authoritative diagnostics
- curl ile musteri_ugrama tablosunu sorgula — ilişkilerin doğruluğunu gösterir

### What assumptions changed
- none
