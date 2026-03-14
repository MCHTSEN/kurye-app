# Feature: Operasyon

## Scope
Operasyon personelinin sipariş yönetimi, kurye atama, analiz ve CRUD işlemleri.

## Routes
- `/operasyon/dashboard` — Ciro analizi + kurye performans + aktif kuryeler
- `/operasyon/ekran` — 3-panel operasyon ekranı (sipariş form + bekleyenler + devam edenler)
- `/operasyon/musteri-kayit` — Müşteri CRUD
- `/operasyon/personel-kayit` — Müşteri personel CRUD
- `/operasyon/gecmis` — Geçmiş siparişler (filtreleme + düzenleme)
- `/operasyon/ugrama` — Uğrama yönetimi (lokasyon dahil)

## States
- **Dashboard**: Ciro toplamları, kurye performans, aktif kuryeler
- **OperasyonEkran**: 3 panel realtime yönetim
- **MusteriKayit**: CRUD form + alt tablo
- **GecmisSiparis**: Filtrelenmiş liste + düzenleme paneli

## Dependencies
- Tüm repository'ler
- Supabase Realtime
- Sesli uyarı servisi
