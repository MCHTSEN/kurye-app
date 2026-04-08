# Feature: Kurye

## Scope
Kurye personelinin aktif/pasif olması, sipariş alması, teslim noktalarına saat basması ve konum paylaşması.

## Routes
- `CustomRoute.kuryeAna.path` — Aktif/pasif toggle + sipariş listesi + hesap aksiyonları

## States
- **KuryeAna**: Aktif/pasif toggle, atanmış sipariş listesi, çıkış ve hesap silme aksiyonları
- **SiparisDetay**: Onaylama, çıkış/uğrama saat basma
- **KonumTakip**: Arka plan konum paylaşımı

## Dependencies
- `KuryeRepository` — kurye durum yönetimi
- `SiparisRepository` — sipariş onay/teslim
- `KonumRepository` — konum kayıt
- Supabase Realtime — anlık sipariş güncellemeleri

## Last Updated
- 2026-04-01
