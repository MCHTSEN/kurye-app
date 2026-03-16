

Riverpod 3 tabanlı, `auto_route` kullanan, çoklu backend
(`mock` / custom API / Supabase / Firebase), standart analytics
(Mixpanel), runtime servisleri ve referans vertical slice örneği içeren
Flutter iskeleti.

## Çalıştırma

```bash
flutter pub get
flutter run --dart-define=APP_ENV=dev --dart-define=BACKEND_PROVIDER=mock --dart-define=CREDIT_ACCESS_PROVIDER=backend
```

## Web Debug (Local)

Local web geliştirmede bazı ortamlarda CSP, Flutter web debug çıktısındaki
`eval` kullanımını bloklayabilir. Bu durumda production CSP'yi gevşetmek yerine
Chrome'u yalnızca local development için gevşetilmiş güvenlik flag'leriyle aç.

```bash
flutter run -d chrome -t lib/main_supabase.dart \
  --web-hostname 127.0.0.1 \
  --web-port 8080 \
  --dart-define-from-file=.env \
  --dart-define=APP_ENV=dev \
  --dart-define=CREDIT_ACCESS_PROVIDER=backend \
  --dart-define=ANALYTICS_ENABLED=false \
  --web-browser-flag=--disable-web-security \
  --web-browser-flag=--disable-site-isolation-trials \
  --web-browser-flag=--user-data-dir=/tmp/kurye-app-chrome-dev
```

Bu komut yalnızca local debug içindir. Production / staging build'lerinde CSP
gevşetilmemelidir.

## Ortam Değişkenleri

- `APP_ENV`: `dev`, `staging`, `prod`
- `BACKEND_PROVIDER`: `mock`, `custom`, `supabase`, `firebase`
- `CREDIT_ACCESS_PROVIDER`: `navigationSignal`, `backend`, `revenueCat`
- `CUSTOM_API_BASE_URL`: custom API taban URL
- `SUPABASE_URL`: Supabase URL
- `SUPABASE_ANON_KEY`: Supabase anon key
- `MIXPANEL_TOKEN`: Mixpanel project token
- `ANALYTICS_ENABLED`: `true` / `false`
- `OPERASYON_REPORTS_PASSWORD`: operasyon rapor ekranı şifresi

## İskelet Kapsamı

- Auth (anonymous login demo)
- Onboarding
- Home
- Profile
- Example Feed vertical slice
- Reusable widget katmanı
- Backend adapter stratejisi
- Analytics abstraction katmanı
- Runtime servisleri (`secure storage`, `connectivity`, `feature flags`,
  `crash reporting`, `permissions`, `cache`, `retry`)
- Mock backend ve smoke test akışı
- Merkezi route guard (onboarding/auth/credit)

## Geliştirme Kuralı

- Katman dokümanlarını (`lib/core/DOC.md`, `lib/product/DOC.md`) güncel tut.
- Feature/screen koduna geçmeden ilgili `DOC.md` ve `SCREENS.md` dosyalarını güncelle.
- Tüm önemli değişiklikleri root `BACKLOG.md` dosyasına işle.
- İş bitti demeden önce `flutter analyze` ve `flutter test` çalıştır.
- Task çıktısında test/analiz sonuçlarını paylaş.
