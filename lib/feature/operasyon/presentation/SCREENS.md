# Operasyon Ekranları

## OperasyonShellPage
- Purpose: Mobil operasyon ana akışını 4 sekmeli `NavigationBar` ile sarmalar.
- Mobile tabs:
  - `Dashboard`
  - `Operasyon`
  - `Uğrama`
  - `Ayarlar`
- State behavior:
  - Sekmeler `AutoTabsScaffold` üzerinden korunur.
  - `Operasyon Ekranı` form state'i sekme değişiminde resetlenmez.
- Desktop/tablet:
  - Shell child route'u doğrudan gösterir.
  - Sayfalar kendi `ResponsiveScaffold` + `NavigationRail` davranışını korur.

## OperasyonDashboardPage
- 3 aylık / 1 aylık / 1 haftalık ciro toplamları
- İçinde bulunulan ayın günlük ortalaması
- Kuryelerin aylık ve günlük iş sayıları
- Bugünkü aktif kuryeler
- Mobile nav: `Dashboard` tab'ı

## OperasyonEkranPage
- Panel A: Sipariş oluşturma formu
- Panel B: Kurye Bekleyenler (checkbox + kurye atama)
- Panel C: Devam Edenler (checkbox + bitir + harita tooltip)
- Realtime güncelleme, sesli uyarı
- Mobile nav: `Operasyon` tab'ı

## UgramaYonetimPage
- Mobile nav: `Uğrama` tab'ı

## OperasyonAyarlarPage
- Purpose: Mobil ayarlar hub ekranı
- Sections:
  - `Hesap`: profil özeti + çıkış
  - `Yönetim`: müşteri, personel, kurye, rol onay
  - `Kayıt ve Talepler`: geçmiş siparişler, uğrama talepleri
- Navigation:
  - Secondary operasyon sayfalarını ayarlar stack'ine push eder
  - Bottom nav görünür kalır, aktif sekme `Ayarlar` olur

## MusteriKayitPage / MusteriPersonelKayitPage / UgramaYonetimPage / GecmisSiparisPage
- Mobilde `Ayarlar` stack'i altında açılır
- Desktop/tablet'te tam operasyon rail menüsünde bağımsız ekran gibi görünür

## Last Updated
- 2026-03-16
