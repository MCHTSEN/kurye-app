# Web Deploy — `app.bursamotokurye.com`

Tek kullanıcılı operasyon paneli. Subdomain altında host edilir, search engine'lere kapalıdır.

## 0. Mimari Özet

```
github.com/MCHTSEN/kurye-app  (development branch)
        │
        │  push → GitHub Actions
        ▼
  flutter build web --release --base-href=/
        │
        │  FTP (SamKirkland/FTP-Deploy-Action)
        ▼
  guzel.net.tr  →  /domains/bursamotokurye.com/public_html/app/
        │
        ▼
  https://app.bursamotokurye.com  (Let's Encrypt SSL)
        │
        ▼
  Supabase (ebxvkbhrxxplauhsntda.supabase.co)
```

## 1. Tek Seferlik Hosting Kurulumu (DirectAdmin)

1. **DirectAdmin paneline gir** → `bursamotokurye.com`
2. **Subdomain Management** → `app` ekle
   - Sonuç klasörü: `/domains/bursamotokurye.com/public_html/app/` (path'i not al — secret olarak gerekecek)
3. **SSL/TLS** → `app.bursamotokurye.com` için **Let's Encrypt** sertifikası al (otomatik renew)
4. **Force HTTPS** → açık

> Not: FTP user'ı zaten root yetkili olduğu için ayrıca user yaratmıyoruz. `FTP_SERVER_DIR_APP` secret'ı doğrudan `app/` klasörüne işaret edecek.

## 2. GitHub Secrets (kurye-app repo'su)

`Settings → Secrets and variables → Actions → New repository secret` ile aşağıdakileri ekle:

### FTP / Hosting

| Secret | Değer | Not |
|---|---|---|
| `FTP_HOST` | `ftp.guzel.net.tr` (veya hosting'in verdiği) | Mevcut kurye repo'sundan kopyala |
| `FTP_USERNAME` | mevcut FTP user | Mevcut kurye repo'sundan kopyala |
| `FTP_PASSWORD` | mevcut FTP password | Mevcut kurye repo'sundan kopyala |
| `FTP_SERVER_DIR_APP` | `/domains/bursamotokurye.com/public_html/app/` | **DirectAdmin'in gösterdiği gerçek path olmalı** — sonunda `/` olmalı |

### Supabase / App env

| Secret | Değer | Açıklama |
|---|---|---|
| `BACKEND_PROVIDER` | `supabase` | Sabit |
| `SUPABASE_URL` | `https://ebxvkbhrxxplauhsntda.supabase.co` | `.env`'de var |
| `SUPABASE_ANON_KEY` | `.env`'deki değer | Public key, RLS koruyor |
| `OPERASYON_REPORTS_PASSWORD` | `.env`'deki değer | Feature gate |
| `MIXPANEL_TOKEN` | `.env`'deki değer (opsiyonel) | Analytics |

### KESINLIKLE EKLEME ❌

Bunlar browser bundle'a girer ve admin yetkisi ele geçirilir:

- ❌ `SUPABASE_SERVICE_ROLE_KEY`
- ❌ `SUPABASE_ACCESS_TOKEN`

## 3. Lokal Test (Deploy Öncesi)

```bash
cd ~/kurye-app

# Supabase env'leri inject ederek build et (--wasm: dart2wasm + JS fallback)
flutter build web --wasm --release --base-href=/ \
  --target=lib/main_supabase.dart \
  --dart-define=APP_ENV=development \
  --dart-define=BACKEND_PROVIDER=supabase \
  --dart-define=SUPABASE_URL=$(grep SUPABASE_URL .env | cut -d= -f2) \
  --dart-define=SUPABASE_ANON_KEY=$(grep SUPABASE_ANON_KEY .env | cut -d= -f2) \
  --dart-define=OPERASYON_REPORTS_PASSWORD=$(grep OPERASYON_REPORTS_PASSWORD .env | cut -d= -f2)

# .htaccess'i build çıktısına kopyala
cp web/.htaccess build/web/.htaccess

# Lokal serve et (port 8080)
cd build/web && python3 -m http.server 8080
# Açık: http://localhost:8080
```

Kontrol listesi:

- [ ] Login akışı çalışıyor (Supabase auth)
- [ ] Refresh (F5) yapılınca path bozulmuyor (SPA routing)
- [ ] Bundle boyutu makul (`du -sh build/web/` → wasm build ~45-50 MB normal; CanvasKit + font + dual compile dahil, gerçekte servis edilen `main.dart.wasm` ~4 MB)
- [ ] DevTools → Console temiz, kritik error yok

## 4. Deploy

```bash
git checkout development
git add web/.htaccess web/index.html .github/workflows/deploy-web.yml DEPLOY_WEB.md
git commit -m "feat(web): app.bursamotokurye.com deploy pipeline"
git push origin development
```

GitHub Actions sekmesinden build'i izle. ~3-5 dakika sürer (Flutter SDK cache'ten yüklenir).

## 5. Canlı Doğrulama

```bash
# 1) Subdomain açılıyor mu
curl -I https://app.bursamotokurye.com
# Beklenen: HTTP/2 200 + X-Robots-Tag: noindex, nofollow, noarchive, nosnippet

# 2) HTTPS zorlaması çalışıyor mu
curl -I http://app.bursamotokurye.com
# Beklenen: HTTP/1.1 301 → https://...

# 3) SPA routing
curl -sI https://app.bursamotokurye.com/herhangi-bir-path | head -5
# Beklenen: 200 (404 değil — index.html'e fallback)

# 4) Cache header'ları
curl -sI https://app.bursamotokurye.com/index.html | grep -i cache
# Beklenen: Cache-Control: no-store, no-cache, ...

# 5) Robots
curl -s https://app.bursamotokurye.com/robots.txt
# Yoksa Flutter default sunulur, X-Robots-Tag header zaten yeterli
```

Browser doğrulaması:

- [ ] `https://app.bursamotokurye.com` → login ekranı
- [ ] Supabase login → operasyon paneline geç
- [ ] DevTools Application → Service Worker güncel
- [ ] DevTools Network → ana JS bundle gzip/brotli ile geliyor

## 6. Sorun Giderme

| Sorun | Sebep | Çözüm |
|---|---|---|
| `404` herhangi bir path'te | `.htaccess` deploy edilmemiş veya mod_rewrite kapalı | `cp web/.htaccess build/web/` adımı çalışmış mı kontrol et; LiteSpeed'de mod_rewrite default açık |
| Login → "Network error" | Supabase URL/anon key inject olmamış | GitHub Actions log'da `flutter build web` adımına bak; `--dart-define` değerleri `***` görünmeli |
| Eski sürüm yapışıyor | Service worker cache | `index.html` için `Cache-Control: no-store` zaten var; tarayıcıda hard refresh (Cmd+Shift+R) |
| FTP timeout / "421 Too many" | LiteSpeed connection limit | `timeout: 180000` zaten yüksek; `dangerous-clean-slate: false` olmalı (memory'deki tuning) |
| `mixed content` warnings | HTTP asset HTTPS sayfada | Tüm asset URL'leri relative olmalı; Flutter zaten relative üretir |
| `--wasm` build kırılıyor | `dart:html`/`dart:js_util` kullanan paket var (eski `flutter_secure_storage_web 1.2.x` gibi) | **Çözüldü** (2026-05-23): `flutter_secure_storage ^10.3.0` → web adapter `2.1.1` (`package:web` + js-interop, wasm uyumlu). Build artık `--wasm` ile alınıyor. Yeni bir paket `--wasm`'ı kırarsa: o paketin `package:web` tabanlı sürümüne geç |
| `.wasm` dosyası yanlış MIME ile gelir / yüklenmez | Sunucu `.wasm` için `application/wasm` döndürmüyor | `.htaccess`'e `AddType application/wasm .wasm` ekle (LiteSpeed/Apache default genelde tanır ama garanti değil) |

## 7. Sonraki Adımlar (opsiyonel)

- [ ] **Cloudflare** (önerilir): subdomain'i CF'ye ver → DDoS, brotli, edge cache, analytics
- [ ] **Sentry** entegrasyonu (`SENTRY_DSN` zaten env key'lerde var)
- [ ] **Custom 404** ayarla (DirectAdmin → Custom Error Pages)
- [ ] **HTTP Auth** ekstra katmanı (DirectAdmin Password Protected Directories) — login üstüne ekstra koruma istersen
