# Feature: Müşteri Sipariş

## Scope
Müşteri personelinin sipariş oluşturması, aktif siparişlerini takip etmesi ve geçmiş siparişlerini görmesi.

## Routes
- `/musteri/siparis` — Sipariş oluşturma + aktif siparişler (ana sayfa)
- `/musteri/gecmis` — Geçmiş siparişler (tarih filtreli)

## States
- **SiparisOlusturma**: Çıkış/Uğrama/Not dropdown seçimleri → sipariş oluştur
- **AktifSiparisler**: Realtime liste, durum takibi, iş bitince düşer
- **GecmisSiparisler**: Tarih filtreli sayfalı liste

## Dependencies
- `UserProfileRepository` — müşteri bilgisi
- `UgramaRepository` — dropdown verileri
- `SiparisRepository` — sipariş CRUD
- Supabase Realtime — anlık güncellemeler

## Extension Points
- Sipariş oluşturulduğunda operasyon ekranına realtime bildirim
