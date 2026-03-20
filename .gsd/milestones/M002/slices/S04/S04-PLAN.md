# S04: Entegrasyon ve Sipariş Formu Uyumu

**Goal:** Sipariş formu köprü tablosu üzerinden filtreleme yapıyor, mevcut dispatch akışı bozulmadan çalışıyor, cross-role entegrasyon testi geçiyor.
**Demo:** Sipariş formunda müşteriye atanmış uğramalar görünür, sipariş oluşturulur, tüm akış çalışır.

## Must-Haves

- Sipariş formu dropdown'ları köprü tablosu üzerinden filtreleme
- Mevcut dispatch akışı bozulmadan çalışma
- UgramaTalebi domain testleri

## Verification

- `flutter analyze` — 0 error
- `flutter test` — all passing

## Tasks

- [x] **T01: Entegrasyon doğrulama + UgramaTalebi domain testleri** `est:30m`

## Files Likely Touched

- test/domain/ugrama_talebi_test.dart
