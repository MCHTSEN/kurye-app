# Moto Kurye Sipariş & Takip Uygulaması — Proje Planı

## 1. Genel Bakış

Moto kurye sipariş ve takip uygulaması. 3 farklı kullanıcı rolü:
- **Müşteri (Personel)**: Sipariş oluşturur, takip eder (Mobil)
- **Operasyon Personeli**: Siparişleri yönetir, kurye atar, analiz görür (Web + Mobil)
- **Kurye**: Siparişleri alır, teslim eder, konum paylaşır (Mobil)

**Backend**: Supabase (PostgreSQL + Realtime + Auth + Geography)

---

## 2. Veritabanı Şeması (Supabase/PostgreSQL)

### 2.1 Kullanıcı & Roller

```sql
-- Supabase Auth kullanılacak (auth.users otomatik)

-- Uygulama kullanıcıları (auth.users ile ilişkili)
CREATE TABLE app_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  role TEXT NOT NULL CHECK (role IN ('musteri_personel', 'operasyon', 'kurye')),
  display_name TEXT NOT NULL,
  phone TEXT,
  is_active BOOLEAN DEFAULT true,
  musteri_id UUID REFERENCES musteriler(id), -- müşteri personeli için
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.2 Müşteriler (Firmalar)

```sql
CREATE TABLE musteriler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firma_kisa_ad TEXT NOT NULL,
  firma_tam_ad TEXT,
  telefon TEXT,
  adres TEXT,
  email TEXT,
  vergi_no TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.3 Müşteri Personelleri

```sql
CREATE TABLE musteri_personelleri (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id),
  user_id UUID REFERENCES app_users(id), -- auth ile bağlantı
  ad TEXT NOT NULL,
  telefon TEXT,
  email TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.4 Uğramalar (Müşteriye ait güzergah noktaları)

```sql
CREATE TABLE ugramalar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id),
  ugrama_adi TEXT NOT NULL,
  adres TEXT,
  lokasyon GEOGRAPHY(POINT, 4326), -- PostGIS konum
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.5 Kuryeler

```sql
CREATE TABLE kuryeler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES app_users(id),
  ad TEXT NOT NULL,
  telefon TEXT,
  plaka TEXT,
  is_active BOOLEAN DEFAULT true, -- aktif/pasif durumu
  is_online BOOLEAN DEFAULT false, -- o an çalışıyor mu
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.6 Siparişler

```sql
CREATE TYPE siparis_durum AS ENUM (
  'kurye_bekliyor',
  'devam_ediyor',
  'tamamlandi',
  'iptal'
);

CREATE TABLE siparisler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id),
  personel_id UUID REFERENCES musteri_personelleri(id),
  kurye_id UUID REFERENCES kuryeler(id),
  cikis_id UUID NOT NULL REFERENCES ugramalar(id),
  ugrama_id UUID NOT NULL REFERENCES ugramalar(id),
  ugrama1_id UUID REFERENCES ugramalar(id), -- opsiyonel 2. uğrama
  not_id UUID REFERENCES ugramalar(id), -- not dropdown
  not1 TEXT, -- serbest metin not
  durum siparis_durum NOT NULL DEFAULT 'kurye_bekliyor',
  ucret NUMERIC(10,2),
  cikis_saat TIMESTAMPTZ, -- kurye çıkış saati
  ugrama_saat TIMESTAMPTZ, -- kurye uğrama saati
  ugrama1_saat TIMESTAMPTZ, -- kurye uğrama1 saati
  atanma_saat TIMESTAMPTZ, -- kurye atanma saati
  bitis_saat TIMESTAMPTZ,
  olusturan_id UUID REFERENCES app_users(id), -- kim oluşturdu
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.7 Sipariş Log

```sql
CREATE TABLE siparis_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  siparis_id UUID NOT NULL REFERENCES siparisler(id),
  eski_durum siparis_durum,
  yeni_durum siparis_durum NOT NULL,
  degistiren_id UUID REFERENCES app_users(id),
  aciklama TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 2.8 Kurye Konum (Günlük)

```sql
CREATE TABLE kurye_konum (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kurye_id UUID NOT NULL REFERENCES kuryeler(id),
  lokasyon GEOGRAPHY(POINT, 4326),
  tarih DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Günlük partitioning / cleanup ile şişme önlenir
CREATE INDEX idx_kurye_konum_tarih ON kurye_konum(kurye_id, tarih);
```

### 2.9 Geçmiş Sipariş Ücretleri (Otomatik fiyatlandırma referansı)

```sql
-- Ücret geçmişi siparisler tablosundaki ucret alanından sorgulanır.
-- İş bittiğinde: aynı müşteri + aynı güzergah (cikis+ugrama) en yakın 
-- tarihli tamamlanmış siparişin ücreti bulunup yeni siparişe yazılır.
```

---

## 3. Supabase Realtime Stratejisi

| Kanal | Kullanım |
|-------|----------|
| `siparisler` INSERT | Müşteri sipariş verdiğinde → operasyon ekranına anlık düşer + sesli uyarı |
| `siparisler` UPDATE | Durum değişikliği → tüm ilgili ekranlar güncellenir |
| `kurye_konum` INSERT | Kurye konumu → haritada anlık gösterim |
| `kuryeler` UPDATE | Kurye aktif/pasif → operasyon ekranı güncellenir |

---

## 4. Ekran Haritası

### 4.0 Login Ekranı
- Email/şifre girişi
- Rol bazlı yönlendirme (müşteri → 4.1, operasyon → 4.2, kurye → 4.3)

### 4.1 Müşteri Ekranları
| Ekran | Açıklama |
|-------|----------|
| 4.1.1 Sipariş Oluşturma | Karşılama + dropdown'lar (Çıkış, Uğrama, Not) + sipariş ver |
| 4.1.2 Aktif Siparişler | Oluşturulan siparişler listesi, durum takibi, iş bitince düşer |
| 4.1.3 Geçmiş Siparişler | Tarih filtreli geçmiş, detay görüntüleme |

### 4.2 Operasyon Ekranları
| Ekran | Açıklama |
|-------|----------|
| 4.2.1 Ana Ekran (Dashboard) | Ciro analizi (3ay/1ay/1hafta/günlük ort.), kurye performans, aktif kuryeler |
| 4.2.2 Operasyon Ekranı | **ANA EKRAN** — 3 panel tek sayfada: |
| ↳ Panel A | Sipariş oluşturma formu |
| ↳ Panel B | Kurye Bekleyenler (checkbox + kurye atama) |
| ↳ Panel C | Devam Edenler (checkbox + bitir butonu + harita tooltip) |
| 4.2.3 Müşteri Kayıt | CRUD müşteri yönetimi + alt tablo |
| 4.2.4 Müşteri Personel Kayıt | Müşteri seçimli personel CRUD |
| 4.2.5 Geçmiş Siparişler | Filtreleme + düzenleme paneli + ciro toplamı |
| 4.2.6 Uğrama Yönetimi | Müşteriye ait uğrama CRUD + lokasyon (Geography) |

### 4.3 Kurye Ekranları
| Ekran | Açıklama |
|-------|----------|
| 4.3.1 Kurye Ana | Aktif/pasif toggle + sipariş listesi |
| 4.3.2 Sipariş Detay | Onaylama + çıkış/uğrama noktalarına saat basma |
| 4.3.3 Konum Paylaşımı | Arka plan konum takibi |

---

## 5. Feature Breakdown (Flutter tarafı)

### Feature 1: `auth` (Mevcut — Genişletilecek)
- Supabase Auth entegrasyonu
- Login sonrası `app_users` tablosundan rol sorgusu
- Rol bazlı route yönlendirme (guard güncelleme)
- **AuthUser** modeline `role`, `musteriId` eklenmesi

### Feature 2: `musteri_siparis` (Müşteri tarafı)
- `domain/`: Siparis, Ugrama modelleri
- `data/`: SiparisRepository (Supabase), UgramaRepository
- `application/`: SiparisController, AktifSiparisController
- `presentation/`: SiparisOlusturmaPage, AktifSiparislerPage, GecmisSiparislerPage

### Feature 3: `operasyon` (Operasyon personeli tarafı)
- `domain/`: Dashboard modelleri, Siparis, Kurye
- `data/`: DashboardRepository, SiparisRepository, KuryeRepository
- `application/`: DashboardController, OperasyonController
- `presentation/`:
  - DashboardPage (analiz)
  - OperasyonPage (3-panel: form + bekleyenler + devam edenler)

### Feature 4: `musteri_yonetim` (Operasyon — müşteri CRUD)
- `domain/`: Musteri modeli
- `data/`: MusteriRepository
- `presentation/`: MusteriKayitPage, MusteriPersonelKayitPage

### Feature 5: `kurye` (Kurye tarafı)
- `domain/`: KuryeSiparis modeli
- `data/`: KuryeSiparisRepository, KonumRepository
- `application/`: KuryeController
- `presentation/`: KuryeAnaPage, SiparisDetayPage

### Feature 6: `gecmis_siparis` (Operasyon — geçmiş)
- `data/`: GecmisSiparisRepository
- `presentation/`: GecmisSiparisPage (excel görünüm + düzenleme paneli)

### Feature 7: `ugrama_yonetim`
- Uğrama CRUD + lokasyon (Geography) kaydı

### Feature 8: `kurye_takip` (Harita + konum)
- Kurye konum takibi
- Operasyon ekranında harita tooltip
- Otomatik kurye atama algoritması (mesafe bazlı)

---

## 6. Uygulama Mimarisi Değişiklikleri

### 6.1 Rol Bazlı Routing
```
Login → app_users.role sorgusu →
  'musteri_personel' → /musteri/siparis
  'operasyon'        → /operasyon/dashboard
  'kurye'            → /kurye/ana
```

### 6.2 Yeni CustomRoute Enum Değerleri
```dart
// Müşteri
musteriSiparis('/musteri/siparis')
musteriGecmis('/musteri/gecmis')

// Operasyon
operasyonDashboard('/operasyon/dashboard')
operasyonEkran('/operasyon/ekran')
musteriKayit('/operasyon/musteri-kayit')
musteriPersonelKayit('/operasyon/personel-kayit')
operasyonGecmis('/operasyon/gecmis')
ugramaYonetim('/operasyon/ugrama')

// Kurye
kuryeAna('/kurye/ana')
kuryeSiparis('/kurye/siparis/:id')
```

### 6.3 Guard Güncellemesi
- `AppAccessGuard` rol bazlı erişim kontrolü eklenecek
- Operasyon rotalarına sadece `operasyon` rolü erişebilir
- Müşteri rotalarına sadece `musteri_personel` rolü erişebilir
- Kurye rotalarına sadece `kurye` rolü erişebilir

### 6.4 Supabase Realtime Provider
- Sipariş değişikliklerini dinleyen Riverpod StreamProvider
- Kurye konum stream'i
- Sesli bildirim servisi (sipariş düştüğünde)

---

## 7. Gerekli Ek Paketler

| Paket | Kullanım |
|-------|----------|
| `supabase_flutter` | Zaten mevcut (backend_supabase) |
| `google_maps_flutter` veya `flutter_map` | Kurye takip haritası |
| `geolocator` | Kurye konum alma |
| `audioplayers` veya `just_audio` | Sesli uyarı |
| `data_table_2` veya `pluto_grid` | Excel benzeri tablo görünümü |
| `intl` | Tarih/saat formatlama (mevcut) |

---

## 8. İş Sıralaması (Sprint Planı)

### Sprint 1: Temel Altyapı (Öncelik: Kritik)
1. ☐ Supabase proje kurulumu + tablo migration'ları
2. ☐ `AuthUser` modeline rol ekleme
3. ☐ Supabase Auth gateway güncelleme (login sonrası rol sorgusu)
4. ☐ Rol bazlı route guard + yeni route tanımları
5. ☐ Login sayfası güncelleme

### Sprint 2: Müşteri Sipariş Akışı
6. ☐ Domain modelleri (Siparis, Ugrama, Musteri)
7. ☐ Supabase repository'ler (SiparisRepository, UgramaRepository)
8. ☐ Müşteri sipariş oluşturma ekranı (dropdown'lar + form)
9. ☐ Aktif siparişler listesi (realtime durum takibi)
10. ☐ Müşteri geçmiş siparişler ekranı

### Sprint 3: Operasyon Ana Ekranı
11. ☐ Operasyon 3-panel ekranı layout
12. ☐ Sipariş oluşturma paneli (Panel A)
13. ☐ Kurye Bekleyenler paneli (Panel B) — checkbox + kurye atama
14. ☐ Devam Edenler paneli (Panel C) — bitir + otomatik ücret
15. ☐ Realtime sipariş akışı + sesli uyarı
16. ☐ Dashboard (analiz) ekranı

### Sprint 4: Yönetim Ekranları
17. ☐ Müşteri kayıt/düzenleme ekranı
18. ☐ Müşteri personel kayıt ekranı
19. ☐ Uğrama yönetim ekranı (lokasyon dahil)
20. ☐ Geçmiş siparişler ekranı (operasyon) — filtreleme + düzenleme

### Sprint 5: Kurye Tarafı
21. ☐ Kurye ana ekranı (aktif/pasif + sipariş listesi)
22. ☐ Sipariş onaylama + saat basma
23. ☐ Arka plan konum takibi
24. ☐ Kurye konum stream → operasyon haritası

### Sprint 6: Gelişmiş Özellikler
25. ☐ Otomatik kurye atama algoritması (mesafe bazlı)
26. ☐ Otomatik/Manuel atama toggle
27. ☐ Harita tooltip (kurye üzerinde devam eden işler)
28. ☐ Sipariş log görüntüleme
29. ☐ Web responsive düzenlemeler (operasyon tarafı)

---

## 9. Sipariş Akış Diyagramı

```
Müşteri sipariş verir
        ↓
  [kurye_bekliyor] → Operasyon ekranına düşer (Panel B) + sesli uyarı
        ↓
  Operasyon kurye atar (veya otomatik atama)
        ↓
  [devam_ediyor] → Panel C'ye geçer, Kurye ekranına düşer
        ↓
  Kurye onaylar → Çıkış/Uğrama noktalarına saat basar
        ↓
  Operasyon "Bitir" → Otomatik ücret atanır
        ↓
  [tamamlandi] → Tüm ekranlardan düşer, geçmişe eklenir
```

---

## 10. Öneriler (Ek)

### 10.1 Sipariş Log Stratejisi
- Her durum değişikliğinde `siparis_log` tablosuna kayıt
- Kim, ne zaman, hangi durumdan hangi duruma değiştirdi
- Geçmiş siparişlerde log timeline gösterilebilir

### 10.2 Güvenlik
- Supabase RLS (Row Level Security) ile rol bazlı veri erişimi
- Müşteri sadece kendi siparişlerini görebilir
- Kurye sadece kendine atanmış siparişleri görebilir
- Operasyon tüm verilere erişebilir

### 10.3 Performans
- Kurye konumu günlük partitioning ile saklanır (şişme önlenir)
- Geçmiş siparişler paginated yüklenir
- Dashboard verileri Supabase RPC fonksiyonları ile özetlenir

### 10.4 Not Uygulaması
- Spec'te bahsedilen basit not tutma özelliği → operasyon personeli
  için küçük bir "Notlar" sayfası/widget'ı olarak eklenebilir

---

## 11. Mock Backend Stratejisi

Sprint 1'de Supabase kurulmadan önce `backend_mock` ile UI geliştirme yapılabilir.
Mock data ile tüm ekranlar test edilebilir, ardından Supabase adapter'a geçilir.
