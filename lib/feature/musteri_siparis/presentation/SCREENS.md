# Müşteri Sipariş Ekranları

## MusteriSiparisPage
- Karşılama mesajı
- Sipariş oluşturma formu:
  - Çıkış/Uğrama: typeahead + serbest metin
  - Müşteri kendi kısa adıyla çıkış/uğrama seçimi yapabilir (gerekirse otomatik uğrama oluşturulur)
  - Çıkış ↔ Uğrama tek tık swap butonu bulunur
  - Bilinmeyen girişte popup: yeni uğrama oluşturma onayı
  - Aynı ad birden çok kayda denk gelirse popup: mevcut seç / yeni oluştur
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
- Not: Sipariş ekranındaki hızlı uğrama ekleme akışına paralel olarak korunur.

## MusteriShellPage
- Sadece mobilde aktif
- 3 sekme: Sipariş / Geçmiş / Uğrama
- Sekmeler arası geçiş `AutoTabsScaffold` ile yapılır
- Drawer navigasyon problemini ortadan kaldırır
