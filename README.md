

Riverpod 3 tabanlı, `auto_route` kullanan, çoklu backend
(`mock` / custom API / Supabase / Firebase), standart analytics
(Mixpanel), runtime servisleri ve referans vertical slice örneği içeren
Flutter iskeleti.

## Çalıştırma

```bash
flutter pub get
flutter run --dart-define=APP_ENV=dev --dart-define=BACKEND_PROVIDER=mock --dart-define=CREDIT_ACCESS_PROVIDER=backend
```

## Ortam Değişkenleri

- `APP_ENV`: `dev`, `staging`, `prod`
- `BACKEND_PROVIDER`: `mock`, `custom`, `supabase`, `firebase`
- `CREDIT_ACCESS_PROVIDER`: `navigationSignal`, `backend`, `revenueCat`
- `CUSTOM_API_BASE_URL`: custom API taban URL
- `SUPABASE_URL`: Supabase URL
- `SUPABASE_ANON_KEY`: Supabase anon key
- `MIXPANEL_TOKEN`: Mixpanel project token
- `ANALYTICS_ENABLED`: `true` / `false`

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
