---
id: S03
parent: M002
milestone: M002
provides:
  - Müşteri uğrama talep sayfası (form + liste)
  - Operasyon talep yönetim sayfası (kabul/red)
  - Talep kabul → otomatik uğrama + köprü oluşturma
requires:
  - slice: S01
    provides: UgramaTalebiRepository, UgramaTalebi domain modeli
affects: []
key_files:
  - lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart
  - lib/feature/operasyon/presentation/ugrama_talep_yonetim_page.dart
key_decisions:
  - D036: Müşteri talep eder, operasyon kabul/red eder
patterns_established:
  - Talep-onay akışı (pending → approved/rejected)
observability_surfaces:
  - none
drill_down_paths: []
duration: ~1.5h
verification_result: passed
completed_at: 2026-03-15
---

# S03: Uğrama Talep Sistemi UI

**Müşteri personeli uğrama talebi gönderebilir, operasyon kabul/red edebilir, kabul edilen talep otomatik uğrama + köprü oluşturur.**

## What Happened

Müşteri tarafında talep formu (ugrama_adi + adres) ve talep listesi (durum chip + red notu) oluşturuldu. Operasyon tarafında bekleyen talepler listesi + kabul/red UI eklendi. Kabul edilen talep otomatik olarak ugramalar tablosuna ve musteri_ugrama köprüsüne insert oluyor. Red durumunda not ile birlikte kaydediliyor. Route ve navigasyon eklendi.

## Verification

- `flutter analyze` — 0 error
- `flutter test` — all passing

## Requirements Advanced

- R004 — Müşteri personeli yeni uğrama talebi gönderebilir

## Requirements Validated

- none

## New Requirements Surfaced

- none

## Requirements Invalidated or Re-scoped

- none

## Deviations

none

## Known Limitations

- none

## Follow-ups

- S04: Entegrasyon doğrulama

## Files Created/Modified

- `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart` — müşteri talep sayfası
- `lib/feature/operasyon/presentation/ugrama_talep_yonetim_page.dart` — operasyon talep yönetimi
- `lib/app/router/custom_route.dart` — yeni route'lar
- `lib/app/router/app_router.dart` — route registration
- `lib/product/navigation/role_nav_items.dart` — nav items

## Forward Intelligence

### What the next slice should know
- Talep approve akışı repository katmanında — approve() bir transaction'da uğrama + köprü oluşturuyor

### What's fragile
- none

### Authoritative diagnostics
- none

### What assumptions changed
- none
