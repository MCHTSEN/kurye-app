# Müşteri Sipariş Ekranları

## MusteriSiparisPage
- Karşılama mesajı
- Sipariş oluşturma formu (Çıkış, Uğrama, Not dropdown'ları)
- Altında aktif siparişler listesi
- Realtime durum güncellemeleri
- Mobilde `MusteriShellPage` alt sekmesi altında çalışır; drawer kullanılmaz

## MusteriGecmisPage
- Tarih filtresi
- Sipariş detay görüntüleme
- Sayfalı liste
- Mobilde alt sekme ile açılır

## MusteriUgramaTalepPage
- Yeni uğrama talep formu (uğrama adı + adres)
- Gönderilmiş talepler listesi
- Beklemede / onaylandı / reddedildi durum chip'leri
- Mobilde alt sekme ile açılır

## MusteriShellPage
- Sadece mobilde aktif
- 3 sekme: Sipariş / Geçmiş / Uğrama
- Sekmeler arası geçiş `AutoTabsScaffold` ile yapılır
- Drawer navigasyon problemini ortadan kaldırır
