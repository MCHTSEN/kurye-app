# BACKLOG

Project audit log for major changes.

## Entry Format
- Date: YYYY-MM-DD
- Scope:
- Summary:
- Files:
- Validation:

## Entries

### 2026-05-21
- Scope: Shorebird code push entegrasyonu (kurulum)
- Summary:
  - `shorebird init` çalıştırıldı (display name: Kuryem). App ID: `8194d9b4-c976-4888-9610-86a4339e78a1`.
  - `shorebird.yaml` kök dizine eklendi (auto_update varsayılan açık → patch'ler arka planda inip bir sonraki açılışta aktif).
  - `pubspec.yaml` assets'ine `shorebird.yaml` eklendi.
  - Android `AndroidManifest.xml` → `INTERNET` izni eklendi (zaten implicit ama Shorebird açıkça istiyor).
  - macOS `Release.entitlements` → `network.client` + `allow-unsigned-executable-memory` eklendi.
  - `shorebird doctor`: temiz, no issues.
  - Workflow: prod release `main.dart` + `.env.prod` (BACKEND_PROVIDER=supabase) üzerinden.
- Files:
  - `shorebird.yaml` [NEW]
  - `pubspec.yaml`
  - `android/app/src/main/AndroidManifest.xml`
  - `macos/Runner/Release.entitlements`
- Validation: `shorebird doctor` → OK. İlk release kullanıcı tarafından store'a yüklenecek.
- Notlar:
  - **Release** (store'a her yüklemede): `shorebird release android --dart-define-from-file=.env.prod` / `shorebird release ios --dart-define-from-file=.env.prod`
  - **Patch** (kullanıcıya OTA Dart kod güncellemesi): `shorebird patch android --dart-define-from-file=.env.prod` / `shorebird patch ios --dart-define-from-file=.env.prod`
  - **Patch sadece Dart kodu** günceller. Native, dependency, asset değişikliği → yeni release zorunlu.

### 2026-05-20
- Scope: 4 yönlü iyileştirme — TR saat / sipariş silme / toplu bitirme / kurye iş bitirme + bildirim
- Summary:
  - **AppTime helper**: `lib/core/utils/app_time.dart` ile UTC+3 sabit dönüşüm — tüm sayfalardaki manuel `HH:mm` / `dd.MM.yyyy` çağrıları merkezi formatter'a taşındı. TR'de DST yok, sabit offset güvenli.
  - **Sipariş hard delete**: `SiparisRepository.delete()` interface'e eklendi (Supabase + fake impl). Operasyon dispatch'te 3-nokta menü, geçmiş edit panelinde "Kalıcı Olarak Sil" butonu. RLS `FOR ALL` zaten DELETE'i kapsıyor.
  - **Toplu bitirme**: `_onFinish()` refactor — paralel auto-pricing lookup, sonra manuel ücret bekleyenler için tek `_BulkPricingDialog` (önceki sıralı popup'ları değiştirdi). "Hepsini Atla" / "Tümünü Onayla". Active card'a `GestureDetector` ile toggle seçim, multi-select etkin.
  - **Kurye ekranı redesign**: `_TimestampButton` labelları artık uğrama adı (örn. "Fatih", "Dış Latife") — sabit "Çıkış/Uğrama" yazıları kaldırıldı. Rota satırı kalktı (artık butonlar yetiyor). Yeni "İşi Bitir" butonu: otomatik ücret lookup, yoksa `ucret=null` (operasyon geçmişten düzenler).
  - **Operasyon kartında progress**: Devam Eden Siparişler kartına `_OrderProgressRow` eklendi — çıkış/uğrama/uğrama1 timestamp'leri yeşil ✓ veya gri ○ ile gösterilir, set olanların yanına TR saati yazılır.
  - **Local notifications**: `LocalNotificationService` no-op stub → `flutter_local_notifications` ile gerçek impl. Bootstrap'te kanal kurulumu + permission. Kurye ekranında `ref.listen` ile yeni atanan sipariş geldiğinde anında bildirim.
- Files:
  - `lib/core/utils/app_time.dart` [NEW]
  - `test/core/utils/app_time_test.dart` [NEW]
  - `lib/feature/kurye/presentation/kurye_ana_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/core/notifications/local_notification_service.dart`
  - `lib/app/bootstrap.dart`
  - `packages/backend_core/lib/src/siparis_repository.dart`
  - `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
  - `test/helpers/fakes/fake_siparis_repository.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` (e1, e2 yeni testler + e güncellendi)
  - `test/feature/kurye/kurye_ana_page_test.dart` (h0, h1 yeni testler + b/d/g güncellendi)
  - `pubspec.yaml` (flutter_local_notifications eklendi)
- Validation:
  - `flutter analyze lib/feature/operasyon lib/feature/kurye lib/core` → 0 issues (yalnız pre-existing dashboard_stats info'ları)
  - `flutter test test/core/utils/app_time_test.dart` → 6/6 PASS
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → 19/19 PASS
  - `flutter test test/feature/kurye/` → 10/10 PASS
  - RLS doğrulaması: mevcut `operasyon_siparisler FOR ALL` policy DELETE'i kapsıyor; `kurye_siparisler_update` kurye'nin kendi siparişine UPDATE iznini sağlıyor — migration gerekmedi.

### 2026-05-13
- Scope: Üç rol için manuel şifre değiştirme
- Summary:
  - `must_change_password` alanı korunarak müşteri, kurye ve operasyon kullanıcılarının uygulama içinden manuel şifre değiştirebilmesi sağlandı.
  - Auth repository/gateway kontratına `updatePassword` eklendi; Supabase, Firebase, custom API ve mock backend adaptörleri güncellendi.
  - Ortak şifre değiştirme diyaloğu eklendi; müşteri ve kurye app bar aksiyonlarına, operasyon ayarlarına bağlandı.
- Files:
  - `packages/backend_core/lib/src/auth_gateway.dart`
  - `packages/backend_core/lib/src/auth_repository.dart`
  - `packages/backend_core/lib/src/auth_repository_impl.dart`
  - `packages/backend_supabase/lib/src/supabase_auth_gateway.dart`
  - `packages/backend_firebase/lib/src/firebase_auth_gateway.dart`
  - `packages/backend_custom/lib/src/custom_api_auth_gateway.dart`
  - `packages/backend_mock/lib/src/mock_auth_gateway.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/product/navigation/password_change_helper.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_shell_page.dart`
  - `lib/feature/kurye/presentation/kurye_ana_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ayarlar_page.dart`
  - `test/product/auth/auth_repository_impl_test.dart`
  - `test/feature/musteri_siparis/musteri_shell_page_test.dart`
  - `test/feature/kurye/kurye_ana_page_test.dart`
  - `test/feature/operasyon/operasyon_ayarlar_page_test.dart`
  - `test/feature/role_selection/role_selection_page_test.dart`
  - `integration_test/app_smoke_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
- Validation:
  - `dart format` passed for touched Dart files.
  - `flutter test test/product/auth/auth_repository_impl_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart test/feature/musteri_siparis/musteri_shell_page_test.dart test/feature/kurye/kurye_ana_page_test.dart test/feature/role_selection/role_selection_page_test.dart` passed (`21/21`).
  - `flutter analyze` failed with existing repo-wide 14 info/warning issues; no new error remains from this change.

---

### 2026-05-13
- Scope: Müşteri aktif sipariş geçici çift görünme düzeltmesi
- Summary:
  - Müşteri sipariş oluşturduktan sonra realtime stream'i elle invalidate eden yenileme kaldırıldı; Supabase realtime akışı tek kaynak olarak bırakıldı.
  - Aktif sipariş listesi `siparis.id` bazında tekilleştirildi; stream aynı satırı kısa süre iki kez yayınlarsa ekranda tek kart gösterilir.
  - Tekrarlı stream satırlarını yakalayan widget testi eklendi.
- Files:
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `test/feature/musteri_siparis/musteri_siparis_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart test/feature/musteri_siparis/musteri_siparis_page_test.dart` passed.
  - `flutter test test/feature/musteri_siparis/musteri_siparis_page_test.dart` passed (`9/9`).
  - `flutter analyze` failed with existing repo-wide 14 info/warning issues; no new issue reported for touched files.

---

### 2026-05-11
- Scope: Dental müşteri/personel hesapları ve uğrama ilişkilendirmeleri
- Summary:
  - Excel kaynaklı dental müşteri seti Supabase master data'ya taşındı; `MICROLAB`, `DİZEYNDENT`, `DİŞÇİ ERKAN`, `DİŞÇİ LATİF`, `DİŞÇİ NAZİFE`, `DİŞÇİ SADIK`, `DİŞÇİ TASARIM` müşteri kayıtları aktif hale getirildi.
  - Her müşteri için bir müşteri personeli auth hesabı oluşturuldu/güncellendi ve `app_users` ile `musteri_personelleri.user_id` bağlantıları kuruldu.
  - Excel'deki `Cıkıs` ve `U1` uğrama noktaları müşteri bazında `musteri_ugrama` köprüsüne bağlandı; `ART DENT/ARTDENT` ve `ELİTA 2/ELİTA2` normalleştirmeleri uygulandı.
- Files:
  - `BACKLOG.md`
  - Supabase data: `musteriler`, `app_users`, `musteri_personelleri`, `ugramalar`, `musteri_ugrama`
- Validation:
  - 7 oluşturulan/güncellenen auth hesabı password grant ile doğrulandı.
  - 7 müşteri ve 7 personel bağlantısı doğrulandı.
  - Müşteri-uğrama köprü sayıları doğrulandı: MICROLAB 32, DİZEYNDENT 13, DİŞÇİ ERKAN 27, DİŞÇİ LATİF 15, DİŞÇİ NAZİFE 10, DİŞÇİ SADIK 6, DİŞÇİ TASARIM 5.

---

### 2026-05-08
- Scope: Operasyon ekranı kompakt yükseklik düzeni
- Summary:
  - Operasyon ekranında app bar ve desktop özet barı kaldırıldı.
  - Yeni sipariş panelinin başlığı gizlenip iç boşluk/yükseklikleri küçültüldü.
  - Kurye Bekleyenler header yüksekliği kompakt hale getirildi.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter analyze` completed with the repo's existing 14 issues; no new touched-file issue reported.

---

### 2026-04-12
- Scope: Pending hesap akışını app içine alma + bekleyen kullanıcı için hesap silme
- Summary:
  - Pending rol talebi olan fakat henüz profili oluşmamış kullanıcılar için guard ve auth yönlendirme akışı güncellendi; bu kullanıcılar artık ayrı bekleme sayfasında kalmak yerine uygulama içindeki `home` ekranına alınır.
  - `HomePage` bekleyen hesap durumunu taşıyacak şekilde genişletildi; kullanıcı rol talebi özetini görebilir, durumu yenileyebilir, çıkış yapabilir ve hesap silme akışını başlatabilir.
  - Rol talebi gönderildikten sonra kullanıcı doğrudan uygulama içindeki pending `home` durumuna yönlendirilir; operasyon tarafındaki bekleyen rol onayı görünümü değişmeden korunur.
  - Home ve role-selection living doc'ları yeni davranışı yansıtacak şekilde güncellendi.
  - Guard karar mantığı ve pending home davranışı için test kapsamı eklendi.
- Files:
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/feature/home/DOC.md`
  - `lib/feature/home/presentation/SCREENS.md`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/feature/role_selection/DOC.md`
  - `lib/feature/role_selection/presentation/role_selection_page.dart`
  - `test/app/router/guard_role_routing_test.dart`
  - `test/feature/home/home_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/app/router/guards/app_access_guard.dart lib/feature/auth/application/auth_controller.dart lib/feature/role_selection/presentation/role_selection_page.dart lib/feature/home/presentation/home_page.dart test/app/router/guard_role_routing_test.dart test/feature/home/home_page_test.dart` → passed.
  - `flutter test test/app/router/guard_role_routing_test.dart test/feature/home/home_page_test.dart` → passed (`8/8`).
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; bu değişikliğe özgü analyze error yok.
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`, `60.76% pixel diff`).

### 2026-04-17
- Scope: Pending hesap redirect loop düzeltmesi + kurye self-servis seçim kaldırımı
- Summary:
  - `AppAccessGuard` aynı path'e tekrar redirect atmayacak şekilde güncellendi; `/home -> /home` döngüsü kesildi.
  - `RoleSelectionPage` pending ve onaylı taleplerde bekleme ekranını render etmek yerine kullanıcıyı app içine yönlendirecek şekilde güncellendi.
  - Rol seçim formundan `Kurye` self-servis seçeneği kaldırıldı; yeni talepler yalnızca `Müşteri Personeli` olarak açılabiliyor.
  - Widget test kapsamı yeni davranış için genişletildi.
- Files:
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/role_selection/DOC.md`
  - `lib/feature/role_selection/presentation/role_selection_page.dart`
  - `test/feature/home/home_page_test.dart`
  - `test/feature/role_selection/role_selection_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/app/router/guards/app_access_guard.dart lib/feature/role_selection/presentation/role_selection_page.dart test/feature/home/home_page_test.dart test/feature/role_selection/role_selection_page_test.dart` → passed.
  - `flutter test test/app/router/guard_role_routing_test.dart test/feature/home/home_page_test.dart test/feature/role_selection/role_selection_page_test.dart` → passed (`9/9`).
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; bu düzeltmeye özgü analyze error yok.

- Scope: Rol talebi formunda submit state yenilenmemesi düzeltmesi
- Summary:
  - `RoleSelectionPage` form controller'larına listener eklendi; kullanıcı ad/telefon/not alanlarını güncellediğinde widget yeniden çiziliyor.
  - `Talep Gönder` butonu için merkezi `_canSubmit` kontrolü eklendi; isim ve rol seçimi sonrası buton artık doğru şekilde aktifleşiyor.
  - Widget testi genişletildi; kullanıcı rol seçip ad girdikten sonra talep oluşturma akışının gerçekten repository'ye ulaştığı doğrulandı.
- Files:
  - `lib/feature/role_selection/presentation/role_selection_page.dart`
  - `test/feature/role_selection/role_selection_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/feature/role_selection/presentation/role_selection_page.dart test/feature/role_selection/role_selection_page_test.dart` → passed.
  - `flutter test test/feature/role_selection/role_selection_page_test.dart` → passed (`2/2`).

- Scope: Pending kullanıcı için provisional profil + müşteri seçimli rol talebi
- Summary:
  - Rol talebi formuna müşteri seçimi eklendi; self-servis müşteri personeli başvuruları artık hangi müşteri adına açıldığını taşıyor.
  - Supabase role request akışı, başvuru oluşturulurken kullanıcı için `is_active=false` provisional `app_users` profili oluşturacak şekilde genişletildi.
  - Bu provisional profil sayesinde kullanıcı app içinde müşteri akışlarını kullanabilir; operasyon tarafında rol talebi yine `beklemede` olarak görünmeye devam eder.
  - Rol onay ekranı başvurudan gelen müşteri seçimini default olarak kullanacak şekilde güncellendi.
  - Supabase migration ile `role_requests.musteri_id` alanı ve authenticated kullanıcılar için müşteri listesi + kontrollü pending profile insert politikaları eklendi.
- Files:
  - `packages/backend_core/lib/src/domain/role_request.dart`
  - `packages/backend_supabase/lib/src/supabase_role_request_repository.dart`
  - `lib/feature/role_selection/presentation/role_selection_page.dart`
  - `lib/feature/role_selection/DOC.md`
  - `lib/feature/operasyon/presentation/rol_onay_page.dart`
  - `supabase/migrations/20260417173000_pending_profile_role_request_musteri.sql`
  - `test/feature/role_selection/role_selection_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format packages/backend_core/lib/src/domain/role_request.dart packages/backend_supabase/lib/src/supabase_role_request_repository.dart lib/feature/role_selection/presentation/role_selection_page.dart lib/feature/operasyon/presentation/rol_onay_page.dart test/feature/role_selection/role_selection_page_test.dart` → passed.
  - `flutter test test/feature/role_selection/role_selection_page_test.dart test/app/router/guard_role_routing_test.dart test/feature/home/home_page_test.dart` → passed (`10/10`).
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; bu değişikliklere özgü analyze error yok.

### 2026-04-08
- Scope: Operasyon ekranı bugünkü kazanç yanında aktif kurye sayısı
- Summary:
  - `OperasyonEkranPage` desktop özet barında `Bugünkü Kazanç` metriğinin yanına online kurye sayısı eklendi.
  - Operasyon ekran living doc'u özet bar metriğini yansıtacak şekilde güncellendi.
  - Widget test eklendi/güncellendi; desktop özet barda aktif kurye sayısının render edildiği doğrulandı.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/feature/operasyon/presentation/operasyon_ekran_page.dart test/feature/operasyon/operasyon_ekran_page_test.dart` → passed.
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; bu değişikliğe özgü yeni analyzer hatası görünmedi.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → passed (`20/20`).
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`, `%60.76 pixel diff`).

- Scope: Operasyon desktop tablo başlık/satır kolon hizası düzeltmesi
- Summary:
  - Operasyon ekranında desktop bekleyen ve devam eden tablolar için başlık kolonları satırlarla aynı `flex` oranını kullanacak şekilde güncellendi.
  - `SAAT` kolonunda başlık ve değerler merkez hizaya alındı; saat değerleri başlığın tam altında görünecek şekilde hizalama tutarlı hale getirildi.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/feature/operasyon/presentation/operasyon_ekran_page.dart` → passed.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → passed (`19/19`).
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; hizalama değişikliğine özgü yeni analyzer hatası oluşmadı.

- Scope: Operasyon ekranı uzun bekleyen/aktif listelerinde desktop overflow düzeltmesi
- Summary:
  - `OperasyonEkranPage` içinde `Kurye Bekleyenler` ve `Devam Eden İşler` kartları desktop'ta sabit kart yüksekliğini koruyup kendi içlerinde scroll edecek şekilde güncellendi.
  - Kart gövdesi için genişleyebilir layout desteği eklendi; uzun sipariş listeleri artık aşağı doğru taşıp `RenderFlex overflowed` üretmiyor.
  - Operasyon feature/screen living doc'ları masaüstü iç scroll davranışını yansıtacak şekilde güncellendi.
  - Widget testi eklendi; yoğun veri altında iki dispatch panelinin scroll edebildiği ve overflow exception üretmediği doğrulandı.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/feature/operasyon/presentation/operasyon_ekran_page.dart test/feature/operasyon/operasyon_ekran_page_test.dart` → passed.
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; bu overflow düzeltmesine özgü yeni analyzer hatası görünmedi.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → passed (`19/19`).

- Scope: Geçmiş sipariş edit paneline kalıcı faturalandırıldı alanı
- Summary:
  - `Siparis` domain modeline varsayılanı `false` olan kalıcı `faturalandirildi` boolean alanı eklendi; JSON mapping, fake repository ve Supabase create/update akışı bu alanı taşıyacak şekilde güncellendi.
  - `siparisler` tablosuna `faturalandirildi` kolonu ekleyen Supabase migration yazıldı.
  - `OperasyonGecmisPage` düzenleme paneline `Faturalandırıldı` checkbox'ı eklendi; `Kaydet` ile kalıcı olarak siparişe yazılıyor.
  - Geçmiş sipariş listesi son sütununa satır bazlı `Faturalandırıldı` checkbox'ı eklendi; tek tıkla kalıcı güncelleniyor.
  - Geçmiş liste header'ına toplu `Faturalandırıldı` toggle aksiyonu eklendi; filtrelenmiş görünür listeye uygulanıyor.
  - Seçili sipariş özet kartı `Faturalandırıldı: Evet/Hayır` satırıyla genişletildi.
  - Operasyon living doc'ları ve test kapsamı yeni faturalandırma akışı için güncellendi.
- Files:
  - `packages/backend_core/lib/src/domain/siparis.dart`
  - `packages/backend_supabase/lib/src/supabase_siparis_repository.dart`
  - `supabase/migrations/20260408103000_add_faturalandirildi_to_siparisler.sql`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `test/helpers/fakes/fake_siparis_repository.dart`
  - `test/domain/siparis_test.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/domain/siparis_test.dart test/feature/operasyon/operasyon_gecmis_page_test.dart` → passed.
  - `flutter analyze` → failed (`15 issues`): repo genelindeki mevcut info/warning backlog; yeni faturalandırıldı akışına özgü analyze hatası oluşmadı.
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`, `%60.76 pixel diff`).

- Scope: Operasyon ekranı bekleyen sipariş düzenleme + kompakt dropdown iyileştirmeleri
- Summary:
  - Operasyon ekranında kurye bekleyen siparişler için satır/kart bazlı düzenleme aksiyonu eklendi; bekleyen siparişler artık devam eden siparişlerle aynı dialog altyapısı üzerinden güncellenebiliyor.
  - Bekleyen sipariş görünümünde personel adı müşteri kısa adının yanına taşındı; sipariş satırı tek bakışta okunur hale getirildi.
  - Kurye atama dropdown'u için shared `SearchableDropdown` bileşeni genişlik ve kapalı durum metin stili destekleyecek şekilde genişletildi.
  - Operasyon ekranındaki kurye seçimi dropdown'u kompakt genişliğe çekildi; koyu temada kapalı durumdaki seçili isim beyaz gösteriliyor.
  - Geçmiş sipariş ekranında filtre dropdown'ları tam genişlik yerine kompakt genişlikte render ediliyor.
  - Operasyon feature/screen ve shared widget living doc'ları güncellendi; operasyon widget test kapsamı bekleyen sipariş düzenleme ve kompakt filtre genişliği için genişletildi.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `lib/product/widgets/searchable_dropdown.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
  - `BACKLOG.md`
- Validation:
  - `dart format lib/product/widgets/searchable_dropdown.dart lib/feature/operasyon/presentation/operasyon_ekran_page.dart lib/feature/operasyon/presentation/operasyon_gecmis_page.dart test/feature/operasyon/operasyon_ekran_page_test.dart test/feature/operasyon/operasyon_gecmis_page_test.dart` → passed.
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog; yeni değişikliklerden kaynaklanan ek analyze hatası görülmedi.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart test/feature/operasyon/operasyon_gecmis_page_test.dart` → passed.
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`, `%60.76 pixel diff`).

### 2026-04-01
- Scope: 3 rol ekranı için hesap silme akışı (operasyon/kurye/müşteri)
- Summary:
  - Auth kontratına `deleteAccount` eklendi (`AuthGateway`, `AuthRepository`, `AuthRepositoryImpl`) ve analytics event kataloğuna `auth_account_deleted` olayı tanımlandı.
  - `AuthController` içine merkezi `deleteAccount` aksiyonu eklendi; başarı durumunda profil invalidation + login gereksinimi akışı korundu.
  - Backend adapter'lar güncellendi:
    - `mock`: oturumu kapatıp local state'i temizler
    - `custom`: `DELETE /auth/account` çağrısı sonrası oturum temizler
    - `supabase`: `delete_current_user` RPC çağrısı sonrası sign-out
    - `firebase`: mevcut kullanıcıyı silip sign-out
  - Ortak `confirmAndDeleteAccount` helper eklendi; iki adımlı onay dialog'u ve hata snackbar davranışı merkezi hale getirildi.
  - 3 rol ekranında hesap silme aksiyonu eklendi:
    - `OperasyonAyarlarPage`: hesap kartına `Hesabı Sil` butonu
    - `KuryeAnaPage`: app bar aksiyonuna hesap silme ikonu
    - `MusteriShellPage`: app bar aksiyonuna hesap silme ikonu
  - Feature/screen living docs güncellendi (`operasyon`, `kurye`, `musteri_siparis`, `auth`).
  - Test kapsamı genişletildi:
    - Auth repository unit testine `deleteAccount` senaryosu eklendi
    - 3 rol ekranında hesap silme dialog etkileşimi için widget testleri eklendi
    - Integration test auth fake implementasyonları yeni kontrata uyumlandı
- Files:
  - `lib/feature/auth/DOC.md`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ayarlar_page.dart`
  - `lib/feature/kurye/DOC.md`
  - `lib/feature/kurye/presentation/SCREENS.md`
  - `lib/feature/kurye/presentation/kurye_ana_page.dart`
  - `lib/feature/musteri_siparis/DOC.md`
  - `lib/feature/musteri_siparis/presentation/SCREENS.md`
  - `lib/feature/musteri_siparis/presentation/musteri_shell_page.dart`
  - `lib/product/navigation/account_delete_helper.dart`
  - `lib/product/DOC.md`
  - `packages/backend_core/lib/src/auth_gateway.dart`
  - `packages/backend_core/lib/src/auth_repository.dart`
  - `packages/backend_core/lib/src/auth_repository_impl.dart`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `packages/backend_custom/lib/src/custom_api_auth_gateway.dart`
  - `packages/backend_firebase/lib/src/firebase_auth_gateway.dart`
  - `packages/backend_mock/lib/src/mock_auth_gateway.dart`
  - `packages/backend_supabase/lib/src/supabase_auth_gateway.dart`
  - `test/product/auth/auth_repository_impl_test.dart`
  - `test/feature/operasyon/operasyon_ayarlar_page_test.dart`
  - `test/feature/kurye/kurye_ana_page_test.dart`
  - `test/feature/musteri_siparis/musteri_shell_page_test.dart`
  - `integration_test/app_smoke_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/product/auth/auth_repository_impl_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart test/feature/kurye/kurye_ana_page_test.dart test/feature/musteri_siparis/musteri_shell_page_test.dart` → passed.
  - `flutter analyze` → failed (`16 issues`): repo genelindeki mevcut info/warning backlog (yeni hesap silme değişiklikleri kaynaklı ek lint yok).
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`, `%60.76 pixel diff`).

### 2026-03-31 (Devam)
- Scope: Müşteri mobil shell çift app bar düzeltmesi
- Summary:
  - Müşteri mobil shell altında açılan sayfalarda görünen çift app bar problemi giderildi.
  - `ResponsiveScaffold` içine `showAppBar` parametresi eklendi.
  - Müşteri sipariş/geçmiş/uğrama talep sayfalarında mobilde app bar kapatıldı (`showAppBar: !isMobile`), shell app bar tek kaynak olarak bırakıldı.
- Files:
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/feature/musteri_siparis/musteri_shell_page_test.dart test/feature/musteri_siparis/musteri_siparis_page_test.dart` → passed.

### 2026-03-31
- Scope: Tema ve Görsel Kimlik Güncellemesi (Shadcn + Flutter Material)
- Summary:
  - Shadcn UI bileşenlerinin temel renk paleti (base color) `Slate`'ten `Blue`'ya güncellendi.
  - Flutter standart (Material 3) teması marka rengi olan maviye (`AppColors.primary`) göre optimize edildi.
  - `NavigationBarTheme` ve `BottomNavigationBarTheme` güncellendi:
    - Eski (Material 2) görünümlü navigation bar ayarları kaldırıldı.
    - `NavigationBar` için modern indicator ve mavi odaklı ikon/etiket stilleri eklendi.
    - `ColorScheme` üzerinden yüzey renkleri (surfaceVariant) blue-slate tonlarına çekilerek gri/beyaz tekdüzeliği kırıldı.
- Files:
  - `lib/app/app.dart`
  - `lib/core/theme/app_theme.dart`
- Validation:
  - `flutter analyze` ve `flutter test` çalıştırıldı.
  - `MusteriShellPage` ve `OperasyonShellPage` üzerindeki modern alt bar görünümü doğrulandı.

### 2026-03-31 (Devam)
- Scope: Müşteri + Operasyon çıkış/uğrama müşteri-kendisi seçimi ve swap
- Summary:
  - `MusteriSiparisPage` üzerinde operasyonla aynı kurallarla müşteri-kendisi çıkış/uğrama seçimi eklendi.
  - Müşteri kısa adı uğrama listesinde görünür hale getirildi; kayıt yoksa güvenli çözümleme ile oluşturulup siparişte kullanılabiliyor.
  - Hem müşteri hem operasyon sipariş formuna `Çıkış ↔ Uğrama` tek tık swap aksiyonu eklendi.
  - Müşteri ve operasyon ekran testleri yeni davranışları kapsayacak şekilde genişletildi (self-stop ve swap senaryoları).
  - Living docs müşteri/operasyon feature + screen seviyesinde güncellendi.
- Files:
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/musteri_siparis/musteri_siparis_page_test.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `lib/feature/musteri_siparis/DOC.md`
  - `lib/feature/musteri_siparis/presentation/SCREENS.md`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/feature/musteri_siparis/musteri_siparis_page_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart` → passed.
  - `flutter analyze` → failed (`18 issues`): repo genelindeki mevcut info/warning backlog (mevcut `supabase_ugrama_talebi_repository.dart` warning dahil).
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`).

### 2026-03-31
- Scope: Müşteri + Operasyon birleşik uğrama çözümleme ve siparişte "yoksa ekle" akışı
- Summary:
  - Müşteri ve operasyon sipariş formlarında çıkış/uğrama alanları için listede olmayan metin girişleri desteklendi.
  - Ortak `UgramaResolutionService` eklendi; exact eşleşme, isim çakışması (ambiguous) ve yeni kayıt oluşturma akışları merkezi hale getirildi.
  - `TypeaheadField` ham metin değişimini üst katmana aktaracak `onInputChanged` callback'i ile genişletildi.
  - Müşteri sipariş ekranında bilinmeyen uğrama için onay popup'ı, isim çakışması için mevcut seç/yeni oluştur popup'ı eklendi.
  - Operasyon sipariş formunda da aynı popup tabanlı çözümleme akışı etkinleştirildi.
  - `backend_core` içinde yeni uğrama çözümleme kontratı/domain tipleri eklendi; Supabase adaptöründe yeni repository implementasyonu yapıldı.
  - Supabase migration ile `resolve_or_create_ugrama_for_musteri` güvenli RPC fonksiyonu eklendi.
  - Widget ve unit test kapsamı yeni akışları doğrulayacak şekilde güncellendi/genişletildi.
  - Feature/layer dokümanları güncellendi.
- Files:
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/product/widgets/typeahead_field.dart`
  - `lib/product/ugrama/ugrama_resolution_service.dart`
  - `packages/backend_core/lib/src/domain/ugrama_resolution.dart`
  - `packages/backend_core/lib/src/ugrama_resolution_repository.dart`
  - `packages/backend_core/lib/src/backend_module.dart`
  - `packages/backend_core/lib/backend_core.dart`
  - `packages/backend_supabase/lib/src/supabase_ugrama_resolution_repository.dart`
  - `packages/backend_supabase/lib/src/supabase_backend_module.dart`
  - `supabase/migrations/20260331110000_resolve_or_create_ugrama_for_musteri_rpc.sql`
  - `test/product/ugrama/ugrama_resolution_service_test.dart`
  - `test/feature/musteri_siparis/musteri_siparis_page_test.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `lib/feature/musteri_siparis/DOC.md`
  - `lib/feature/musteri_siparis/presentation/SCREENS.md`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/product/DOC.md`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/product/ugrama/ugrama_resolution_service_test.dart test/product/widgets/typeahead_field_test.dart` → passed.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart test/feature/musteri_siparis/musteri_siparis_page_test.dart` → passed.
  - `flutter analyze` → failed (`44 issues`): repo genelindeki mevcut info backlog + pre-existing warning (`packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart`).
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, `goldens/example_feed_page.png`).

### 2026-03-31
- Scope: Operasyon typeahead tıklama seçimi düzeltmesi
- Summary:
  - Operasyon ekranındaki form alanlarında kullanılan `TypeaheadField` overlay seçim davranışı düzeltildi.
  - Öneri satırına mouse/touch tıklandığında focus kaybı nedeniyle overlay erken kapanıp seçim iptal oluyordu; pointer seçim akışı korunarak tıklama ile doğrudan seçim garantilendi.
  - Blur kapanışı kısa gecikmeli güvenli akışa alındı (`120ms`), böylece focus kaybı ile satır tıklaması yarışında seçim kaybolmuyor.
  - Alan zaten odaktayken tekrar tıklamada da öneri overlay'i açılacak şekilde güncellendi; kullanıcı yazı yazmadan tüm seçenekleri görebiliyor.
  - `items` listesi odaktayken sonradan güncellendiğinde overlay otomatik yenileniyor.
  - `didUpdateWidget` sırasında overlay build tetiklenmesi kaynaklı `setState() or markNeedsBuild() called during build` hatası için overlay açma akışı `postFrameCallback` ile güvenli hale getirildi.
  - Bu regresyon için widget testi eklendi: Enter basmadan öneri tıklamasıyla seçim yapılabildiği doğrulandı.
  - Living docs güncellendi (`SCREENS.md`, `WIDGETS.md`) ve etkileşim kontratı netleştirildi.
- Files:
  - `lib/product/widgets/typeahead_field.dart`
  - `test/product/widgets/typeahead_field_test.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/product/widgets/WIDGETS.md`
  - `BACKLOG.md`
- Validation:
  - `flutter test test/product/widgets/typeahead_field_test.dart` → passed.
  - `flutter test test/product/widgets/typeahead_field_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart` → passed.
  - `test/product/widgets/typeahead_field_test.dart` içinde "shows all suggestions on tap when query is empty" senaryosu geçti.
  - `test/product/widgets/typeahead_field_test.dart` içinde "does not throw when items update while field is focused" senaryosu geçti.
  - `flutter analyze` → failed (`42 issues`): repo genelindeki mevcut info lintleri + `packages/backend_supabase/lib/src/supabase_ugrama_talebi_repository.dart` içinde önceden var olan 1 warning.
  - `flutter test` → failed: pre-existing golden mismatch (`test/feature/example_feed/example_feed_page_golden_test.dart`, pixel diff), yeni typeahead testi geçti.

### 2026-03-27
- Scope: Operasyon ekranı mobil layout iyileştirmesi
- Summary:
  - `_buildOrderForm` mobilde dikey layout kullanacak şekilde yeniden düzenlendi: Müşteri ve Personel tam genişlik, Çıkış/Uğrama ve Uğrama1/Not(Rehber) 2'li grid, SİPARİŞ OLUŞTUR butonu tam genişlik.
  - `_buildWaitingPanel` mobilde kart bazlı sipariş listesi kullanacak şekilde refactor edildi: her sipariş checkbox + müşteri/personel/güzergah + saat içeren tıklanabilir kart. Kurye Seç dropdown ve ATA butonu panel altına taşındı.
  - `_buildActivePanel` mobilde kart bazlı sipariş listesi kullanacak şekilde refactor edildi: her aktif iş kurye badge + güzergah + düzenle ikonu + BİTTİ butonu içeren kart.
  - `_buildWaitingCard` ve `_buildActiveCard` yardımcı metotları eklendi.
  - Desktop ve tablet layout'lar değişmedi; mevcut tablo/row yapısı korundu.
  - Tüm mevcut testler korundu; `Key('active_${s.id}')` kart container'ına eklenerek test uyumu sağlandı.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` → 12/12 passed.
  - `flutter test` → 140 passing, 1 failing (pre-existing golden mismatch, unrelated).
  - iPhone 17 Pro simulator üzerinde canlı doğrulama: form tam genişlik dropdown'larla okunabilir, bekleyenler kartları çalışıyor.

### 2026-03-20
- Scope: Müşteri mobil navigasyon shell düzeltmesi
- Summary:
  - Müşteri mobil drawer navigasyonu kaldırılarak `AutoTabsScaffold` tabanlı `MusteriShellPage` eklendi.
  - Müşteri route'ları `/musteri` shell altındaki child route yapısına taşındı; sipariş / geçmiş / uğrama talebi sekmeleri mobilde alt çubuk üzerinden açılıyor.
  - `MusteriSiparisPage`, `MusteriGecmisPage` ve `MusteriUgramaTalepPage` mobilde drawer göstermeyecek şekilde güncellendi; desktop/tablet `ResponsiveScaffold` davranışı korundu.
  - Müşteri tab geçişleri için analytics event kataloğuna `musteri_tab_selected` eklendi.
  - Yeni widget testi ile müşteri shell sekme geçişi doğrulandı; iPhone 15 Pro simulator üzerinde canlı doğrulamada Sipariş → Geçmiş → Uğrama → Sipariş akışı çalıştı.
- Files:
  - `lib/app/router/app_router.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_shell_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_siparis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_gecmis_page.dart`
  - `lib/feature/musteri_siparis/presentation/musteri_ugrama_talep_page.dart`
  - `lib/feature/musteri_siparis/DOC.md`
  - `lib/feature/musteri_siparis/presentation/SCREENS.md`
  - `lib/product/navigation/role_nav_items.dart`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `test/feature/musteri_siparis/musteri_shell_page_test.dart`
- Validation:
  - `flutter analyze` passed with existing repo-wide info/warning backlog only (no new blocking analyzer error).
  - `flutter test` => `140 passing, 1 failing` and the only failure remains pre-existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.
  - Manual simulator verification passed on iPhone 15 Pro simulator: müşteri mobile tabs navigate correctly across sipariş / geçmiş / uğrama screens.

### 2026-03-17
- Scope: Operasyon ekranı günlük ciro hesaplama düzeltmesi
- Summary:
  - `OperasyonEkranPage` desktop özetindeki `BUGÜNKÜ KAZANÇ` alanı sabit `0 TL` yerine canlı hesaplamaya geçirildi.
  - Hesaplama, bugünün tarih aralığında `tamamlandi` siparişlerin `ucret` toplamını kullanıyor.
  - `Bitir` aksiyonu sonrası günlük ciro provider invalidation eklendi; sayfa yenilemeden metrik anında güncelleniyor.
  - Bu davranış için widget test eklendi (`desktop summary shows today revenue...`, `finishing order updates today revenue without manual refresh`).
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.

### 2026-03-16
- Scope: Operasyon koyu drawer/sidebar teması ve responsive tipografi
- Summary:
  - `ResponsiveScaffold` drawer ve desktop sidebar aynı koyu gri palette'e taşındı.
  - Drawer/sidebar metinleri büyütüldü ve ekran genişliğine göre responsive ölçekleme eklendi.
  - Desktop sidebar genişliği sabit değil, ekran genişliğine göre dinamik hale getirildi.
  - `OperasyonEkranPage` tablo başlık/satır yazıları responsive büyütüldü; desktop panel oranları dinamik ayarlanarak ekran alanı daha efektif kullanıldı.
- Files:
  - `lib/product/widgets/WIDGETS.md`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter test test/product/widgets/responsive_scaffold_test.dart` passed.
  - `flutter analyze lib/product/widgets/responsive_scaffold.dart lib/feature/operasyon/presentation/operasyon_ekran_page.dart` failed with info-level lint warnings only (no new blocking analyzer error).

### 2026-03-16
- Scope: Operasyon devam eden sipariş düzenleme akışı
- Summary:
  - `OperasyonEkranPage` aktif satırındaki düzenleme ikonu gerçek aksiyona bağlandı.
  - Devam eden sipariş için düzenleme dialog'u eklendi (kurye, personel, çıkış/uğrama adımları, not alanları).
  - Güncelleme sonrası `siparisStreamActiveProvider` invalidation ile liste anlık yenileme korundu.
  - Operasyon ekranı koyu gri temaya geçirildi; arka plan, kart yüzeyleri ve satır bölücüleri dark palette'e alındı, metin kontrastı açık tonlarla güncellendi.
  - Widget test kapsamına aktif sipariş düzenleme ve kaydetme senaryosu eklendi.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter analyze lib/feature/operasyon/presentation/operasyon_ekran_page.dart test/feature/operasyon/operasyon_ekran_page_test.dart` failed with existing info-level lints (`avoid_redundant_argument_values`) and no new blocking error.
  - `flutter analyze` failed with existing repo-wide info-level lint backlog (latest run: 37 issues).
  - `flutter test` failed only on existing golden mismatch: `test/feature/example_feed/example_feed_page_golden_test.dart`.

### 2026-03-16
- Scope: Operasyon web UX hardening and desktop workflow polish
- Summary:
  - Desktop operasyon sidebar gruplu navigasyon ve kısayol odaklı kullanım için güçlendirildi.
  - `OperasyonDashboardPage` içine desktop hızlı geçiş kartları eklendi; dar kolon taşmaları düzeltildi.
  - `OperasyonEkranPage` desktop özet metrikleri korunurken tablet/mobil davranışı testlerle uyumlu şekilde stabilize edildi.
  - `OperasyonGecmisPage` split-view workbench, arama alanı, durum chip'leri ve side editor paneli ile yenilendi.
  - CRUD workbench list panelleri mobilde sonsuz yükseklik istemeyecek şekilde düzenlendi; `AppSectionCard` dar alanlarda taşmayacak hale getirildi.
  - Operasyon dashboard, dispatch, geçmiş ve müşteri kayıt testleri yeni desktop/mobile kontratına göre güncellendi; desktop geçmiş coverage eklendi.
- Files:
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `lib/feature/operasyon/presentation/musteri_kayit_page.dart`
  - `lib/feature/operasyon/presentation/musteri_personel_kayit_page.dart`
  - `lib/feature/operasyon/presentation/kurye_yonetim_page.dart`
  - `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`
  - `lib/product/widgets/app_section_card.dart`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `test/feature/operasyon/operasyon_dashboard_page_test.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
  - `test/feature/operasyon/musteri_kayit_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
- Validation:
  - `flutter test test/feature/operasyon/operasyon_dashboard_page_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart test/feature/operasyon/operasyon_gecmis_page_test.dart` passed.
  - `flutter test test/feature/operasyon/musteri_kayit_page_test.dart` passed.
  - `flutter test test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart` passed.
  - `flutter test integration_test/operasyon_navigation_smoke_test.dart` passed.
  - `flutter analyze` failed due existing repo info-level issues; latest run reported 32 issues and no new blocking error.
  - `flutter test` failed only on existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.

### 2026-03-16
- Scope: Operasyon mobile bottom navigation shell
- Summary:
  - Operasyon rolü için mobil drawer akışı `AutoTabsScaffold` tab shell yapısına taşındı.
  - Yeni `/operasyon` shell route ve `/operasyon/ayarlar` hub route eklendi.
  - Düşük frekanslı operasyon sayfaları ayarlar stack'i altına alındı.
  - `ResponsiveScaffold` mobil drawer'ı kapatılabilir hale getirildi.
  - Operasyon tab ve ayarlar seçimleri için analytics eventleri eklendi.
  - Operasyon shell ve ayarlar hub için widget testleri eklendi.
- Files:
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_shell_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_ayarlar_page.dart`
  - `lib/feature/operasyon/presentation/*.dart`
  - `lib/product/navigation/role_nav_items.dart`
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `test/app/router/*.dart`
  - `test/feature/operasyon/operasyon_shell_page_test.dart`
  - `test/feature/operasyon/operasyon_ayarlar_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
- Validation:
  - `flutter analyze` failed due pre-existing repo info-level issues; no new analyzer errors from this change.
  - `flutter test test/app/router/custom_route_test.dart test/app/router/guard_role_routing_test.dart test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_ayarlar_page_test.dart` passed.
  - `flutter test integration_test/operasyon_navigation_smoke_test.dart` passed.
  - `flutter test` failed on existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden mismatch.

### 2026-03-15
- Scope: Sprint 1 — Moto Kurye temel altyapı (DB şeması, roller, routing)
- Summary:
  - Supabase PostgreSQL migration dosyası oluşturuldu (9 tablo, RLS, indexler, realtime, PostGIS).
  - `UserRole` enum ve `AppUserProfile` domain modeli eklendi (`backend_core`).
  - `UserProfileRepository` kontratı + Supabase ve Mock implementasyonları eklendi.
  - `BackendModule` kontratına `createUserProfileRepository()` eklendi; tüm backend'ler güncellendi.
  - `CurrentUserProfile` Riverpod provider eklendi (login sonrası rol sorgusu).
  - `CustomRoute` enum'a 9 yeni rol bazlı rota eklendi (müşteri/operasyon/kurye).
  - `AppAccessGuard` rol bazlı erişim kontrolü ve yönlendirme ile güncellendi.
  - `AuthController` login sonrası profil invalidation eklendi.
  - 3 feature placeholder oluşturuldu: `musteri_siparis`, `operasyon`, `kurye` (DOC.md + SCREENS.md + sayfalar).
  - Proje planı `docs/PROJECT_PLAN.md` olarak dokümante edildi.
- Files:
  - `supabase/migrations/001_initial_schema.sql`
  - `packages/backend_core/lib/src/domain/user_role.dart`
  - `packages/backend_core/lib/src/domain/app_user_profile.dart`
  - `packages/backend_core/lib/src/user_profile_repository.dart`
  - `packages/backend_core/lib/src/backend_module.dart`
  - `packages/backend_core/lib/backend_core.dart`
  - `packages/backend_supabase/lib/src/supabase_user_profile_repository.dart`
  - `packages/backend_supabase/lib/src/supabase_backend_module.dart`
  - `packages/backend_mock/lib/src/mock_user_profile_repository.dart`
  - `packages/backend_mock/lib/src/mock_backend_module.dart`
  - `packages/backend_custom/lib/src/custom_backend_module.dart`
  - `packages/backend_firebase/lib/src/firebase_backend_module.dart`
  - `lib/product/user_profile/user_profile_providers.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/app/app.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/feature/musteri_siparis/**`
  - `lib/feature/operasyon/**`
  - `lib/feature/kurye/**`
  - `docs/PROJECT_PLAN.md`
  - `test/domain/user_role_test.dart`
  - `test/app/router/custom_route_test.dart`
  - `test/app/router/guard_role_routing_test.dart`
- Validation:
  - `flutter analyze` passed (0 issues).
  - `flutter test` passed (53 tests).

### 2026-03-08
- Scope: Feature test policy hardening
- Summary:
  - Clarified that new or materially changed features require explicit
    test layers beyond generic repo-wide validation.
  - Added minimum expectations for unit, widget, golden, and smoke
    integration coverage in project docs.
- Files:
  - `AGENTS.md`
  - `docs/DOC_STANDARDS.md`
  - `test/TESTING.md`
  - `BACKLOG.md`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed.

### 2026-03-08
- Scope: Mock backend, runtime service baseline, testing kit, and example vertical slice
- Summary:
  - Added `mock` backend selection via `BACKEND_PROVIDER` and introduced `backend_mock` for zero-setup local flows.
  - Added reusable runtime services for secure storage, connectivity, feature flags, crash reporting, permissions, cache policy, and retry policy.
  - Added shared test helpers, golden test setup, and a runnable macOS smoke `integration_test` flow.
  - Added `example_feed` as the reference vertical slice with remote data source, repository contract, cache/retry composition, controller, page, analytics, and tests.
- Files:
  - `packages/backend_mock/**`
  - `lib/core/environment/**`
  - `lib/core/runtime/**`
  - `lib/product/runtime/**`
  - `lib/product/widgets/**`
  - `lib/feature/example_feed/**`
  - `lib/app/**`, `lib/main*.dart`
  - `test/helpers/**`
  - `test/feature/example_feed/**`
  - `integration_test/app_smoke_test.dart`
  - `pubspec.yaml`, `README.md`, `AGENTS.md`, `BACKLOG.md`, `docs/**`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`43 tests`).
  - `flutter test integration_test/app_smoke_test.dart -d macos` passed.

### 2026-03-08
- Scope: Skeleton foundation
- Summary:
  - Introduced Riverpod 3 app skeleton with `core/product/feature` layers.
  - Added multi-backend auth adapter strategy (`custom`, `supabase`, `firebase`).
  - Added mandatory analytics abstraction with Mixpanel and noop fallback.
  - Added onboarding/auth/home/profile/splash feature flow and router guards.
- Files:
  - `lib/app/**`
  - `lib/core/**`
  - `lib/product/**`
  - `lib/feature/**`
  - `pubspec.yaml`, `analysis_options.yaml`, `README.md`, `AGENTS.md`, `docs/ARCHITECTURE.md`
- Validation:
  - `flutter analyze` passed.

### 2026-03-08
- Scope: Documentation governance and audit rules
- Summary:
  - Enforced doc-first workflow for feature/screen/widget development.
  - Added local docs for all current features and presentation folders.
  - Added doc standards and backlog maintenance rules.
- Files:
  - `docs/DOC_STANDARDS.md`
  - `lib/feature/*/DOC.md`
  - `lib/feature/*/presentation/SCREENS.md`
  - `lib/product/widgets/WIDGETS.md`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `README.md`, `BACKLOG.md`
- Validation:
  - Structural docs added and linked to process rules.

### 2026-03-08
- Scope: AutoRoute migration and centralized access policies
- Summary:
  - Replaced `go_router` with `auto_route`.
  - Added centralized `AppAccessGuard` for onboarding/auth/credit policies.
  - Added `AppNavigationState` + `RouteReevaluationNotifier` for runtime guard re-check.
  - Added network-level 401/credit handling in `DioApiClient` interceptor.
  - Added token refresh strategy contract and backend-based refresh adapters.
  - Added `buy_credit` feature and route.
- Files:
  - `pubspec.yaml`
  - `lib/app/router/**`
  - `lib/core/network/dio_api_client.dart`
  - `lib/product/auth/**`
  - `lib/product/navigation/**`
  - `lib/product/network/api_client_provider.dart`
  - `lib/feature/buy_credit/**`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/feature/onboarding/presentation/onboarding_page.dart`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `README.md`, feature docs
- Validation:
  - `flutter analyze` target: pass.

### 2026-03-08
- Scope: Route enum standardization and project padding tokens
- Summary:
  - Added `ProjectPadding` token structure (`ProjectPadding.all.normal` etc.).
  - Updated feature/screen/widget paddings to use `ProjectPadding` instead of inline `EdgeInsets`.
  - Added `CustomRoute` enum and replaced hardcoded route paths in navigation/guard/router usage.
  - Updated docs to reference `CustomRoute` and `ProjectPadding` standards.
- Files:
  - `lib/core/constants/project_padding.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/feature/**/presentation/*.dart`
  - `lib/product/widgets/app_section_card.dart`
  - `AGENTS.md`, `docs/ARCHITECTURE.md`, `docs/DOC_STANDARDS.md`, feature screen docs
- Validation:
  - `flutter analyze` target: pass.

### 2026-03-08
- Scope: Mandatory test gating rule and baseline tests
- Summary:
  - Added completion rule: do not mark tasks done without running tests.
  - Added requirement to report validation outputs in task summaries.
  - Introduced baseline test suite for routing, padding tokens, and navigation state.
- Files:
  - `AGENTS.md`
  - `docs/DOC_STANDARDS.md`
  - `README.md`
  - `test/app/router/custom_route_test.dart`
  - `test/core/constants/project_padding_test.dart`
  - `test/product/navigation/app_navigation_state_test.dart`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`5 tests`).

### 2026-03-08
- Scope: Centralize screen analytics at navigator level
- Summary:
  - Replaced per-screen `TrackedScreen` wrapper approach.
  - Added router-level `AnalyticsRouteObserver` for automatic `screen_viewed` events.
  - Wired observer into `MaterialApp.router` via `navigatorObservers`.
  - Removed `tracked_screen.dart` and updated related docs.
- Files:
  - `lib/app/router/observers/analytics_route_observer.dart`
  - `lib/app/router/observers/route_observer_providers.dart`
  - `lib/app/app.dart`
  - `lib/feature/**/presentation/*.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `docs/ARCHITECTURE.md`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`5 tests`).

### 2026-03-08
- Scope: Riverpod 3 best-practice hardening and credit policy decoupling
- Summary:
  - Added `core` and `product` layer docs (`lib/core/DOC.md`, `lib/product/DOC.md`).
  - Added configurable `CREDIT_ACCESS_PROVIDER` (`navigationSignal`, `firebaseClaims`, `revenueCat`).
  - Introduced `CreditAccessService` abstraction for guard-level credit decisions.
  - Decoupled insufficient-credit redirect trigger from Dio via provider-based switch.
  - Updated guard to evaluate credit through provider strategy (network signal/Firebase/RevenueCat callback).
  - Applied Riverpod 3 lifecycle and performance improvements (`ref.mounted`, `select`, `ProviderObserver`).
  - Standardized route names through `CustomRoute.<name>.routeName` usage in router config.
- Files:
  - `lib/core/environment/**`
  - `lib/core/DOC.md`
  - `lib/product/DOC.md`
  - `lib/product/credit/**`
  - `lib/product/network/api_client_provider.dart`
  - `lib/core/network/dio_api_client.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/app/router/app_router.dart`
  - `lib/app/router/custom_route.dart`
  - `lib/app/bootstrap.dart`
  - `lib/feature/auth/application/auth_controller.dart`
  - `lib/product/onboarding/onboarding_providers.dart`
  - `lib/feature/auth/presentation/auth_page.dart`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/feature/onboarding/presentation/onboarding_page.dart`
  - `docs/ARCHITECTURE.md`, `docs/DOC_STANDARDS.md`, `README.md`, `AGENTS.md`, `BACKLOG.md`
  - `test/app/router/custom_route_test.dart`
  - `test/core/environment/credit_access_provider_test.dart`
  - `test/product/credit/**`
- Validation:
  - `flutter analyze` passed.
  - `flutter test` passed (`13 tests`).

---

### 2026-03-16 — Operasyon ekranı mobile row stability fixes
- Scope: `feature/operasyon`
- Summary: Fixed `OperasyonEkranPage` runtime issues caused by unconstrained action buttons and unsafe active-order lookups. Active rows now degrade safely in narrow widths, use stable keys for actions, and customer/personnel rendering falls back without `firstWhere` crashes.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `test/feature/operasyon/operasyon_ekran_page_test.dart`
- Validation:
  - `dart analyze lib/feature/operasyon/presentation/operasyon_ekran_page.dart` completed with 4 existing info-level lints.
  - `flutter test test/feature/operasyon/operasyon_ekran_page_test.dart` passed.

---

### 2026-03-16 — mobile-mcp repository add and integration verification
- Scope: `tooling`, `mcp`
- Summary: Added `mobile-mcp` source under `tools/mobile-mcp`, verified local package tests, and confirmed Codex MCP registration/availability for `mobile-mcp`.
- Files:
  - `tools/mobile-mcp` (git clone from `https://github.com/mobile-next/mobile-mcp`)
- Validation:
  - `npx -y @mobilenext/mobile-mcp@latest --help` passed (CLI available).
  - `npm ci` in `tools/mobile-mcp` passed.
  - `npm test` in `tools/mobile-mcp` passed (`11 passing`, `18 pending`).
  - `codex mcp list` shows `mobile-mcp` enabled.
  - `npx -y @mobilenext/mobile-mcp@latest --port 8787` starts SSE server successfully.

---

### 2026-03-16 — Operasyon geçmiş desktop/mobile layout stabilization
- Scope: `feature/operasyon`
- Summary: Fixed `OperasyonGecmisPage` render crashes caused by unbounded button widths and fragile scroll pane layout in the workbench view. Desktop panes now use bounded list views, filter controls degrade responsively, and test selectors were aligned with the current screen contract.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_gecmis_page.dart`
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart`
- Validation:
  - `dart analyze lib/feature/operasyon/presentation/operasyon_gecmis_page.dart` passed.
  - `flutter test test/feature/operasyon/operasyon_gecmis_page_test.dart` passed.

---

### 2026-04-17 — Signup split for new-customer vs existing-customer employee
- Scope: `feature/role_selection`, `feature/home`, `app/router`, `backend_supabase`, `supabase`
- Summary: Split post-signup customer onboarding into two paths: users can now either create a new customer company or join an existing customer as staff. New-customer requests create a provisional `musteriler` record plus linked provisional `app_users` profile; existing-customer staff requests bind to the selected customer immediately. Pending customer users now land on `home` first, where new-customer signups can complete company details and all linked customer users can enter the customer panel before final ops approval.
- Files:
  - `lib/feature/role_selection/DOC.md`
  - `lib/feature/role_selection/presentation/role_selection_page.dart`
  - `lib/feature/home/DOC.md`
  - `lib/feature/home/presentation/SCREENS.md`
  - `lib/feature/home/presentation/home_page.dart`
  - `lib/app/router/guards/app_access_guard.dart`
  - `lib/product/musteri/musteri_providers.dart`
  - `lib/feature/operasyon/presentation/rol_onay_page.dart`
  - `packages/backend_core/lib/src/domain/role_request.dart`
  - `packages/backend_supabase/lib/src/supabase_role_request_repository.dart`
  - `supabase/migrations/20260417173000_pending_profile_role_request_musteri.sql`
  - `test/app/router/guard_role_routing_test.dart`
  - `test/feature/role_selection/role_selection_page_test.dart`
  - `test/feature/home/home_page_test.dart`
- Validation:
  - `flutter test test/app/router/guard_role_routing_test.dart test/feature/role_selection/role_selection_page_test.dart test/feature/home/home_page_test.dart` passed.
  - `flutter analyze` completed with the repo's existing 13 issues; no new analyze error introduced by this change set.

---

### 2026-05-01 — Operasyon masaüstü kullanım düzeltmeleri
- Scope: `feature/operasyon`, `product/widgets`
- Summary: Masaüstü sidebar varsayılanını kompakt ikon moduna aldı, navigasyon sonrası otomatik daralttı, devam eden iş satırlarını dar alanda taşmayacak şekilde yeniden hizaladı, kurye ataması sonrası seçili kurye dropdown'unu temizledi, müşteri listesini Excel benzeri tabloya çevirdi ve uğrama yönetimine müşteri filtresi ekledi.
- Files:
  - `lib/product/widgets/responsive_scaffold.dart`
  - `lib/product/widgets/WIDGETS.md`
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart`
  - `lib/feature/operasyon/presentation/musteri_kayit_page.dart`
  - `lib/feature/operasyon/presentation/ugrama_yonetim_page.dart`
  - `lib/feature/operasyon/presentation/SCREENS.md`
- Validation:
  - `flutter analyze` completed with existing repo issues only: deprecated theme/auth/dashboard_stats info items and two Supabase `rpc` inference warnings; no new issue in touched files.
  - `flutter test test/product/widgets/responsive_scaffold_test.dart test/feature/operasyon/operasyon_ekran_page_test.dart` passed.
  - `flutter test` ran 177 tests; failed only on existing `test/feature/example_feed/example_feed_page_golden_test.dart` golden pixel mismatch unrelated to this change.

---

### 2026-03-16 — Local web debug CSP workaround
- Scope: `tooling`, `docs`
- Summary: Added a dedicated VS Code Chrome launch config and README command for local Flutter web debug in CSP-constrained environments. The workaround uses Chrome development flags only for localhost so production CSP behavior remains unchanged.
- Files:
  - `.vscode/launch.json`
  - `README.md`
- Validation:
  - `python3 -m json.tool .vscode/launch.json` passed.
  - `flutter analyze` completed with the repo's existing 33 info-level issues; no new analyzer error/warning blocker introduced by this tooling change.
  - `flutter test` was started and progressed through 47 passing tests before being stopped manually to avoid waiting on the full suite during tooling verification.

---

### 2026-03-16 — Operasyon default landing + password-gated reports
- Scope: `feature/operasyon`, `app/router`, `core/environment`
- Summary: Changed operasyon default landing to `Operasyon Ekranı`, renamed dashboard access to `Raporlar`, and added a password gate for ciro / kurye performans metrics via `OPERASYON_REPORTS_PASSWORD`. Updated mobile/desktop nav order and refreshed operasyon smoke/widget coverage.
- Files:
  - `lib/core/environment/app_environment.dart`
  - `lib/core/environment/app_environment_keys.dart`
  - `lib/feature/operasyon/DOC.md`
  - `lib/feature/operasyon/presentation/SCREENS.md`
  - `lib/feature/operasyon/presentation/operasyon_dashboard_page.dart`
  - `lib/feature/operasyon/presentation/operasyon_shell_page.dart`
  - `lib/feature/operasyon/providers/report_access_providers.dart`
  - `lib/product/navigation/role_nav_items.dart`
  - `lib/app/router/app_router.dart`
  - `packages/backend_core/lib/src/domain/app_events.dart`
  - `pubspec.yaml`
  - `.env`
  - `test/feature/operasyon/operasyon_dashboard_page_test.dart`
  - `test/feature/operasyon/operasyon_shell_page_test.dart`
  - `integration_test/operasyon_navigation_smoke_test.dart`
  - `test/helpers/widgets/test_app.dart`
  - `test/helpers/providers/test_provider_container.dart`
  - `test/core/environment/app_environment_test.dart`
  - `test/product/network/api_client_provider_test.dart`
  - `test/product/credit/credit_providers_test.dart`
- Validation:
  - `flutter test test/core/environment/app_environment_test.dart test/app/router/custom_route_test.dart test/app/router/guard_role_routing_test.dart test/product/widgets/responsive_scaffold_test.dart test/feature/operasyon/operasyon_shell_page_test.dart test/feature/operasyon/operasyon_dashboard_page_test.dart` passed.
  - `flutter analyze` was attempted; repo still reports existing info-level lint set and should be re-run after long-running integration/device jobs finish.
  - `flutter test integration_test/app_smoke_test.dart integration_test/operasyon_navigation_smoke_test.dart -d macos` was attempted but stalled in CocoaPods/macOS build preparation on this machine.

---

### 2026-03-15 — S04/T02: 3-panel dispatch screen with assignment and finish flows
- Scope: `feature/operasyon`
- Summary: Replaced placeholder OperasyonEkranPage with real 3-panel dispatch screen — order creation (müşteri dropdown → cascading stops), kurye bekleyenler (checkbox + assign), devam edenler (checkbox + finish with auto-pricing/manual fallback). SiparisLog created on every transition. Created FakeSiparisLogRepository.
- Files:
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` (replaced)
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` (new, 5 tests)
  - `test/helpers/fakes/fake_siparis_log_repository.dart` (new)
- Validation:
  - `flutter analyze` passed (0 errors, 0 warnings).
  - `flutter test` passed (86 tests).
  - `flutter build ios --simulator` passed.

---

### 2026-03-15 — S08: Cross-role integration & polish (M001 final slice)
- Scope: `product/services`, `feature/operasyon`, `feature/kurye`, `test/integration`
- Summary: Added OrderAlertService (audioplayers) for sound alerts on new dispatch orders. Applied D027 name resolution to dispatch and courier screens (stops + courier names replace UUIDs). Created 5-test cross-role integration suite proving full order lifecycle. M001 milestone complete — all 18 requirements validated, 123 tests passing.
- Files:
  - `pubspec.yaml` (audioplayers + assets)
  - `assets/sounds/new_order.wav` (new)
  - `lib/product/services/order_alert_service.dart` (new)
  - `lib/feature/operasyon/presentation/operasyon_ekran_page.dart` (alert + names)
  - `lib/feature/kurye/presentation/kurye_ana_page.dart` (name resolution)
  - `test/helpers/fakes/fake_order_alert_service.dart` (new)
  - `test/feature/operasyon/operasyon_ekran_page_test.dart` (3 new tests)
  - `test/feature/kurye/kurye_ana_page_test.dart` (2 new tests)
  - `test/integration/cross_role_lifecycle_test.dart` (new, 5 tests)
- Validation:
  - `flutter analyze` passed (0 errors, 0 warnings).
  - `flutter test` passed (123 tests).
