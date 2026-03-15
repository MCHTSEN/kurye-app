# Feature: Operasyon

## Scope
Operasyon personelinin sipariş yönetimi, kurye atama, analiz ve yönetim
ekranlarını içerir. Mobilde ana akış 4 sekmeli bir shell içinden çalışır;
tablet ve desktop'ta tam operasyon menüsü `NavigationRail` ile korunur.

## Routes
- `CustomRoute.operasyonShell.path` — Mobil operasyon giriş shell'i
- `CustomRoute.operasyonDashboard.path` — Ciro analizi + kurye performans + aktif kuryeler
- `CustomRoute.operasyonEkran.path` — 3-panel operasyon ekranı (sipariş form + bekleyenler + devam edenler)
- `CustomRoute.ugramaYonetim.path` — Uğrama yönetimi (lokasyon dahil)
- `CustomRoute.operasyonAyarlar.path` — Mobil ayarlar hub ekranı
- `CustomRoute.musteriKayit.path` — Ayarlar altından açılan müşteri CRUD
- `CustomRoute.musteriPersonelKayit.path` — Ayarlar altından açılan müşteri personel CRUD
- `CustomRoute.operasyonGecmis.path` — Ayarlar altından açılan geçmiş siparişler
- `CustomRoute.ugramaTalepYonetim.path` — Ayarlar altından açılan uğrama talepleri
- `CustomRoute.kuryeYonetim.path` — Ayarlar altından açılan kurye yönetimi
- `CustomRoute.rolOnay.path` — Ayarlar altından açılan rol onayları

## States
- **OperasyonShell**: Mobilde `AutoTabsScaffold` ile state-preserving sekme yapısı
- **Dashboard**: Ciro toplamları, kurye performans, aktif kuryeler
- **OperasyonEkran**: 3 panel realtime yönetim; sekme değişiminde form state'i korunur
- **UgramaYonetim**: Lokasyon/uğrama yönetimi
- **OperasyonAyarlar**: Yönetim sayfalarına giriş, hesap özeti ve çıkış aksiyonu
- **MusteriKayit**: CRUD form + alt tablo
- **GecmisSiparis**: Filtrelenmiş liste + düzenleme paneli

## Dependencies
- Tüm repository'ler
- Supabase Realtime
- Sesli uyarı servisi
- `auto_route` nested router / tabs

## Extension Points
- Mobil ayarlar hub gruplarına yeni operasyon araçları eklenebilir.
- Operasyon tab analytics eventleri genişletilebilir.
- Ayarlar içinde profil detay ekranı sonradan nested route olarak ayrılabilir.

## Last Updated
- 2026-03-16
