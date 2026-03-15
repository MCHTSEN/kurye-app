# M002: Many-to-Many Uğrama Modeli ve Talep Sistemi

**Vision:** Uğramalar bağımsız havuzda yaşar, müşterilere many-to-many atanır. Müşteri personeli yeni uğrama talep eder, operasyon kabul/red eder. Duplicate uğrama kayıtları ortadan kalkar.

## Success Criteria

- Bir uğrama birden fazla müşteriye atanabilir, DB'de tek kayıt
- Müşteri personeli sipariş formunda sadece kendi müşterisine atanmış uğramaları görür
- Müşteri personeli yeni uğrama talebi gönderebilir
- Operasyon talepleri kabul edebilir (→ ugramalar + köprü tablosuna insert) veya reddedebilir (not ile)
- Mevcut siparişler bozulmaz (FK referansları aynı kalır)

## Key Risks / Unknowns

- DB migration: musteri_id → köprü tablosu geçişi mevcut verileri ve FK'ları bozmamalı — risk medium
- RLS: Köprü tablosu üzerinden uğrama erişim kontrolü doğru çalışmalı — risk medium

## Proof Strategy

- DB migration riski → retire in S01 by proving mevcut veriler köprü tablosuna migrate edildikten sonra siparişler ve uğrama sorguları çalışmaya devam ediyor
- RLS riski → retire in S01 by proving müşteri personeli sadece kendi müşterisine atanmış uğramaları görebiliyor

## Verification Classes

- Contract verification: Repository unit tests, widget tests
- Integration verification: Supabase DB'de end-to-end CRUD + RLS kontrolü
- Operational verification: none
- UAT / human verification: Sipariş formunda doğru uğrama filtreleme

## Milestone Definition of Done

This milestone is complete only when all are true:

- All slices complete and verified
- Mevcut siparişler bozulmamış (FK referansları sağlam)
- Many-to-many uğrama atama çalışıyor
- Talep sistemi çalışıyor (gönder → kabul/red → sonuç)
- RLS ile müşteri izolasyonu sağlanmış

## Slices

- [x] **S01: DB Migration + Repository Katmanı** `risk:high` `depends:[]`
  > After this: musteri_ugrama köprü tablosu ve ugrama_talepleri tablosu DB'de var, repository kontratları ve Supabase implementasyonları çalışıyor, mevcut veriler migrate edilmiş, flutter analyze + test geçiyor
- [x] **S02: Operasyon Uğrama-Müşteri Atama UI** `risk:medium` `depends:[S01]`
  > After this: Operasyon uğrama yönetim sayfasında bir uğramayı birden fazla müşteriye atayabilir, uğrama oluşturma/düzenleme çalışıyor (müşteri bağımsız)
- [x] **S03: Uğrama Talep Sistemi UI** `risk:medium` `depends:[S01]`
  > After this: Müşteri personeli uğrama talebi gönderebilir, operasyon kabul/red edebilir, kabul edilen talep ugramalar + köprü tablosuna insert olur
- [x] **S04: Entegrasyon ve Sipariş Formu Uyumu** `risk:low` `depends:[S01,S02]`
  > After this: Sipariş formu köprü tablosu üzerinden filtreleme yapıyor, mevcut dispatch akışı bozulmadan çalışıyor, cross-role entegrasyon testi geçiyor

## Boundary Map

### S01 → S02

Produces:
- `musteri_ugrama` köprü tablosu + RLS politikaları
- `MusteriUgramaRepository` kontratı ve Supabase implementasyonu (assign/unassign/getByMusteriId)
- Güncellenmiş `UgramaRepository` (musteri_id'siz getAll)
- Güncellenmiş `Ugrama` domain modeli (musteri_id alanı yok)

Consumes:
- nothing (first slice)

### S01 → S03

Produces:
- `ugrama_talepleri` tablosu + RLS politikaları
- `UgramaTalebiRepository` kontratı ve Supabase implementasyonu
- `UgramaTalebi` domain modeli

### S01 → S04

Produces:
- `ugramaListByMusteriProvider` köprü üzerinden çalışıyor (API aynı, implementasyon değişmiş)

### S02 → S04

Produces:
- Operasyon uğrama-müşteri atama UI çalışıyor (test verisi oluşturulabilir)
