# Feature: Kurye

## Scope
Kurye personelinin aktif/pasif olması, sipariş alması, teslim noktalarına saat basması ve konum paylaşması.

## Routes
- `/kurye/ana` — Aktif/pasif toggle + sipariş listesi

## States
- **KuryeAna**: Aktif/pasif toggle, atanmış sipariş listesi
- **SiparisDetay**: Onaylama, çıkış/uğrama saat basma
- **KonumTakip**: Arka plan konum paylaşımı

## Dependencies
- `KuryeRepository` — kurye durum yönetimi
- `SiparisRepository` — sipariş onay/teslim
- `KonumRepository` — konum kayıt
- Supabase Realtime — anlık sipariş güncellemeleri
