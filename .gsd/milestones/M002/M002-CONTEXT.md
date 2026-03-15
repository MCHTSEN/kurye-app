# M002: Many-to-Many Uğrama Modeli ve Talep Sistemi

**Gathered:** 2026-03-15
**Status:** Ready for planning

## Project Description

Moto Kurye dispatch uygulaması. M001 tamamlandı. M002'de uğrama veri modelini müşteri bazlı havuz modeline geçiriyoruz ve müşterilerin yeni uğrama talep edebilmesini sağlıyoruz.

## Why This Milestone

Mevcut modelde her uğrama tek bir müşteriye ait (ugramalar.musteri_id FK). Gerçek operasyonda aynı fiziksel adres birden fazla müşteri tarafından kullanılıyor. Bu modelde her müşteri için ayrı kayıt oluşturmak gerekiyor (veri tekrarı). Ayrıca yeni uğrama eklemek tamamen operasyonun üzerinde.

## User-Visible Outcome

### When this milestone is complete, the user can:

- Operasyon: Uğrama havuzundan bir uğramayı birden fazla müşteriye atayabilir
- Operasyon: Müşteri personelinin gönderdiği uğrama taleplerini kabul veya red edebilir
- Müşteri Personeli: Yeni uğrama ekleme talebi gönderebilir
- Müşteri Personeli: Taleplerinin durumunu görebilir
- Sipariş formunda müşteri personeli sadece kendi müşterisine atanmış uğramaları görür

### Entry point / environment

- Entry point: Flutter mobile app (lib/main_supabase.dart)
- Environment: iOS simulator + Supabase production DB
- Live dependencies involved: Supabase (DB, RLS, Realtime)

## Completion Class

- Contract complete means: Unit tests for repository layer, widget tests for new UI screens
- Integration complete means: End-to-end talep gönderme ve onay akışı çalışır
- Operational complete means: RLS politikaları doğru çalışıyor, müşteriler birbirinin verilerini göremiyor

## Final Integrated Acceptance

To call this milestone complete, we must prove:

- Müşteri personeli uğrama talebi gönderir, operasyon kabul eder, uğrama müşterinin sipariş formunda görünür
- Operasyon bir uğramayı 2 müşteriye atar, her müşteri kendi dropdown'ında görür, DB'de tek kayıt
- Bir müşteri personeli başka müşterinin uğramalarını göremez

## Risks and Unknowns

- DB migration: Mevcut musteri_id FK'yı kaldırıp köprü tablosuna migrate etmek, mevcut siparişleri bozmadan
- RLS politikaları: Köprü tablosu üzerinden uğrama erişimi doğru çalışmalı

## Existing Codebase / Prior Art

- `packages/backend_core/lib/src/domain/ugrama.dart` — Mevcut Ugrama modeli
- `packages/backend_core/lib/src/ugrama_repository.dart` — UgramaRepository kontratı
- `packages/backend_supabase/lib/src/supabase_ugrama_repository.dart` — Supabase implementasyonu
- `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart` — Operasyon uğrama CRUD UI
- `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart` — Sipariş formu
- `supabase/migrations/20260315000000_initial_schema.sql` — Mevcut DB şeması

## Scope

### In Scope

- ugramalar tablosundan musteri_id kaldırma + musteri_ugrama köprü tablosu
- ugrama_talepleri tablosu ve CRUD
- Müşteri personeli talep UI
- Operasyon talep yönetim UI
- Operasyon uğrama-müşteri atama UI
- RLS politikaları güncelleme
- Data migration: mevcut musteri_id verisi köprü tablosuna

### Out of Scope / Non-Goals

- Access DB import (ayrı milestone)
- Konum/harita entegrasyonu

## Technical Constraints

- Supabase only (D001)
- Riverpod 3 state management
- very_good_analysis lint compliance
- Mevcut sipariş FK'ları değişmez

## Integration Points

- siparisler tablosu: FK referansları aynı kalır, dropdown filtreleme köprü üzerinden
- RLS: musteri_ugrama köprü tablosu üzerinden müşteri erişim kontrolü
