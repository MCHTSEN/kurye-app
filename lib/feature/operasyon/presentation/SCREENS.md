# Operasyon Ekranları

## OperasyonShellPage
- Purpose: Mobil operasyon ana akışını 4 sekmeli `NavigationBar` ile sarmalar.
- Mobile tabs:
  - `Operasyon`
  - `Uğrama`
  - `Raporlar`
  - `Ayarlar`
- State behavior:
  - Sekmeler `AutoTabsScaffold` üzerinden korunur.
  - `Operasyon Ekranı` form state'i sekme değişiminde resetlenmez.
  - Varsayılan açılış `Operasyon` sekmesidir.
- Desktop/tablet:
  - Shell child route'u doğrudan gösterir.
  - Sayfalar kendi `ResponsiveScaffold` desktop sidebar davranışını korur.

## OperasyonDashboardPage
- Purpose: Şifre ile açılan rapor ekranı
- Giriş davranışı:
  - `OPERASYON_REPORTS_PASSWORD` tanımlıysa önce şifre formu gösterilir
  - Doğru şifre girilmeden metrikler render edilmez
- 3 aylık / 1 aylık / 1 haftalık ciro toplamları
- İçinde bulunulan ayın günlük ortalaması
- Kuryelerin aylık ve günlük iş sayıları
- Bugünkü aktif kuryeler
- Mobile nav: `Raporlar` tab'ı
- Desktop UX:
  - Özet metrikler taranabilir bloklar halinde kalır
  - Hızlı operasyon geçişleri dashboard içindeki kartlar ve sidebar üzerinden yapılır

## OperasyonEkranPage
- Panel A: Sipariş oluşturma formu
- Panel B: Kurye Bekleyenler (checkbox + kurye atama + satır bazlı düzenleme)
- Panel C: Devam Edenler (checkbox + bitir + satır bazlı düzenleme)
- Desktop özet barı: `Bugünkü Kazanç` yanında `Aktif Kurye` (online) sayısını gösterir.
- Kurye bekleyen siparişte düzenlenebilir alanlar:
  - Kurye
  - Personel
  - Çıkış / Uğrama / Uğrama 1
  - Not (rehber) ve serbest not
- Devam eden siparişte düzenlenebilir alanlar:
  - Kurye
  - Personel
  - Çıkış / Uğrama / Uğrama 1
  - Not (rehber) ve serbest not
- Realtime güncelleme, sesli uyarı
- Görsel tema: koyu gri zemin + koyu kart yüzeyleri; metin/ikonlar açık tonda kontrastlı okunabilir
- Tipografi: tablo başlık/satır metinleri responsive olarak büyür, küçük ekranda taşma önlenir
- Kurye atama dropdown'u kompakt genişlikte kalır; kapanmış durumdaki seçili kurye adı koyu temada beyaz görünür
- Bekleyen siparişlerde personel adı müşteri kısa adının yanında aynı satırda gösterilir
- Mobile nav: `Operasyon` tab'ı
- Desktop UX:
  - 3 kolon bağımsız scroll alanı olarak çalışır, panel oranları genişlikte dinamik ayarlanır
  - `Kurye Bekleyenler` ve `Devam Eden İşler` kartları uzun listelerde iç scroll kullanır; kart yüksekliği korunur ve alt overflow oluşmaz
  - Bekleyen/devam eden tablo başlıkları satır kolonları ile aynı `flex` oranını kullanır; özellikle `SAAT` başlığı ve saat değerleri aynı sütunda hizalanır
  - Üstte güncel operasyon özeti ve kısayol ipuçları yer alır
  - `Bugünkü Kazanç` kartı bugün tamamlanan siparişlerin toplam ücretiyle canlı hesaplanır
  - `Esc` seçimleri temizler
- Etkileşim:
  - Sipariş formundaki typeahead alanlarında öneri satırına mouse/touch ile tıklama doğrudan seçim yapar; seçim için yalnızca Enter zorunlu değildir.
  - Çıkış/Uğrama alanlarında listede olmayan metin girilirse popup ile çözümleme yapılır:
    - bulunamadı → yeni uğrama oluşturma onayı
    - aynı ada sahip çoklu kayıt → mevcut seç / yeni oluştur
  - Seçili müşteri adı, çıkış/uğrama listesinde doğrudan seçenek olarak gösterilir; seçildiğinde müşteri adına uğrama güvenli şekilde çözülür/oluşturulur.
  - Çıkış ↔ Uğrama alanları arasında tek tık swap butonu bulunur.

## UgramaYonetimPage
- Mobile nav: `Uğrama` tab'ı
- Desktop UX:
  - Sol panel form / sağ panel uğrama listesi
  - Liste içinde hızlı arama

## OperasyonAyarlarPage
- Purpose: Mobil ayarlar hub ekranı
- Sections:
  - `Hesap`: profil özeti + çıkış + hesap silme
  - `Yönetim`: müşteri, personel, kurye, rol onay
  - `Kayıt ve Talepler`: geçmiş siparişler, uğrama talepleri
- Navigation:
  - Secondary operasyon sayfalarını ayarlar stack'ine push eder
  - Bottom nav görünür kalır, aktif sekme `Ayarlar` olur
- Critical actions:
  - `Hesabı Sil` aksiyonu iki adımlı onay dialog'u ile çalışır
  - Onay sonrası merkezi auth akışı kullanıcıyı login sürecine döndürür

## MusteriKayitPage / MusteriPersonelKayitPage / UgramaYonetimPage / GecmisSiparisPage
- Mobilde `Ayarlar` stack'i altında açılır
- Desktop/tablet'te tam operasyon rail menüsünde bağımsız ekran gibi görünür
- Desktop UX:
  - CRUD ekranları split-view düzenindedir
  - `/` hızlı aramayı focus eder
  - `Esc` aktif düzenlemeyi kapatır

## OperasyonGecmisPage
- Filtre dropdown'ları tam genişlik yerine kompakt kontrol boyutunda görünür
- Desktop UX:
  - Sol tarafta filtre ve tablo, sağ tarafta seçili sipariş detay/düzenleme paneli
  - Durum quick filter chip'leri ve metin araması bulunur
  - `/` arama alanını focus eder
  - `Esc` seçili siparişi kapatır
- Liste:
  - Son sütunda satır bazlı `Faturalandırıldı` checkbox'ı bulunur
  - Satırdan değiştirildiğinde kalıcı olarak kayıt yapılır
  - Header'da toplu `Faturalandırıldı` toggle aksiyonu bulunur (filtrelenmiş görünür listeye uygulanır)
- Edit panel:
  - `Faturalandırıldı` checkbox'ı siparişte kalıcı boolean alanı yönetir
  - Değer değişikliği `Kaydet` ile kalıcı olarak yazılır
  - Seçili sipariş özetinde `Faturalandırıldı: Evet/Hayır` bilgisi gösterilir

## Last Updated
- 2026-04-08
