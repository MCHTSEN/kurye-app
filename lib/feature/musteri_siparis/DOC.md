# Feature: Müşteri Sipariş

## Scope
Müşteri personelinin sipariş oluşturması, aktif siparişlerini takip etmesi, geçmiş siparişlerini görmesi ve yeni uğrama talebi açması.

## Routes
- `/musteri/siparis` — Sipariş oluşturma + aktif siparişler (ana sayfa)
- `/musteri/gecmis` — Geçmiş siparişler (tarih filtreli)
- `/musteri/ugrama-talep` — Yeni uğrama talebi oluşturma + önceki talepleri izleme

## States
- **SiparisOlusturma**: Çıkış/Uğrama alanlarında mevcut seç + serbest metin;
  listede yoksa popup ile ekle/var olanı ata akışı → sipariş oluştur
- **AktifSiparisler**: Realtime liste, durum takibi, iş bitince düşer
- **GecmisSiparisler**: Tarih filtreli sayfalı liste
- **UgramaTalebi**: Yeni uğrama adı/adres girişi → talep oluştur → durum chip'leri ile izleme
- **MobilShellNavigasyon**: Mobilde drawer yerine alt sekmeler ile sipariş / geçmiş / uğrama geçişi

## Dependencies
- `UserProfileRepository` — müşteri bilgisi
- `UgramaRepository` — dropdown verileri ve talep işlemleri
- `UgramaResolutionService` — uğrama çözümleme (exact / ambiguous / create)
- `SiparisRepository` — sipariş CRUD
- Supabase Realtime — anlık güncellemeler
- `MusteriShellPage` — mobil alt sekme navigasyonu

## Extension Points
- Sipariş oluşturulduğunda operasyon ekranına realtime bildirim
- Uğrama talebi açıldığında operasyon tarafına bildirim
- Uğrama çözümleme stratejileri (normalize, eşleşme önceliği, popup metinleri)
