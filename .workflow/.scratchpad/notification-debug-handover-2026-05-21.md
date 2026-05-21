# Kurye App — Notification Debug Handover (2026-05-21)

## Bağlam — Önceki Session

5 aşamada büyük iyileştirme yapıldı (4 ayrı commit). Genel iş tamam; **sadece local notification iOS'ta foreground+background çalışmıyor**. Layout fix dahil her şey OK.

## Commit Tarihçesi (yeniden referans için)

```
205fcb3 fix(notifications): iOS foreground'da bildirim banner'ı göster  ← son denenen
cdc2475 debug: kurye notification akışına diagnostic loglar
104e317 fix(notifications): bootstrap'te permission iste, iOS prompt'u tetikle
59bb9cb fix: tablet'te operasyon dispatch layout patlaması + Android bildirim izni
d451dcf feat: TR saatler, sipariş silme, toplu bitirme, kurye iş bitirme + bildirim
```

## Notification Sorunu — Son Durum

### ✅ Doğrulanan

Test akışı (kullanıcı 06:08 civarı paylaştı):
```
[KuryeOrderNotif] initState permission check — granted=true
[KuryeOrderNotif] stream change — prevCount=null nextCount=4
[KuryeOrderNotif] stream change — prevCount=4 nextCount=5
[KuryeOrderNotif] new orders detected: 1 → show()
[KuryeOrderNotif] show() completed
```

Yani:
- iOS auth alındı (`granted=true`)
- Stream realtime çalışıyor (Supabase 4→5 emit)
- `ref.listen` callback tetikleniyor
- Diff hesabı doğru (1 yeni sipariş tespit edildi)
- `_plugin.show()` exception ATMIYOR — başarıyla return ediyor

### ❌ Sorun

Plugin'e show() çağrısı başarılı olduğu halde **iOS'ta bildirim UI'a düşmüyor — hem foreground hem arka planda**.

### Denenen Çözümler

1. `AndroidManifest.xml`'e `POST_NOTIFICATIONS` permission eklendi (commit 59bb9cb)
2. Bootstrap'te `init()` sonrası explicit `requestPermission()` (commit 104e317)
3. iOS init'te `DarwinInitializationSettings()` defaults → permission auto-prompt
4. `DarwinNotificationDetails`'a `presentAlert/Badge/Sound/Banner/List=true` (commit 205fcb3) — **son deneme**

## Sonraki Session İçin Denenecekler

Sıralı, en olası → en az olası:

### 1. Plugin Versiyonu — kritik şüphe (BAŞLA BURADAN)

Pubspec: `flutter_local_notifications: ^18.0.1`. Plugin 18.x'te iOS 14+ için known issue olabilir. **19.x veya 21.x** denenmeli.

```bash
# Pubspec güncelle, pod install yenile
flutter clean && flutter pub get && cd ios && pod install --repo-update && cd ..
```

### 2. timezone Dependency Eksik

flutter_local_notifications scheduled notifications için `timezone` paketi ister. `show()` instant olduğu için **şart değil** ama plugin bazı sürümlerinde init'te zorunlu. Pubspec'e `timezone: ^0.10.1` ekleyip `tz.initializeTimeZones()` bootstrap'te çağırılmalı.

### 3. iOS Provisioning / Capability — Real Device İse

Real device'da iOS local notification için **Push Notifications capability gerekmez** (local olduğu için), AMA `Background Modes → Remote notifications` bazen etkisi olur. Xcode'da `ios/Runner.xcworkspace` aç → Signing & Capabilities → kontrol et.

### 4. Banner Style Cihaz Ayarlarında "None" Olabilir

iOS Ayarlar → Bildirimler → Kuryem (uygulama gelmiş olmalı, çünkü `granted=true`):
- "İzin Ver" açık mı?
- Banner Style: **Temporary** veya **Persistent** olmalı (None ise sessiz gelir)
- Sounds: Açık
- Show Previews: Always
- Show in Notification Center: Açık
- Lock Screen: Açık

### 5. UNUserNotificationCenter Delegate (AppDelegate)

iOS `AppDelegate.swift`'te `UNUserNotificationCenter.current().delegate = self` eklenmiş mi? Plugin 18.x bazen bunu otomatik yapmıyor. `ios/Runner/AppDelegate.swift`'i kontrol et:

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(...) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(...)
  }
}
```

### 6. iOS Simulator vs Real Device

Kullanıcı **real iPhone**'da test ediyor (log'da `Mucahit's iPhone`). Simulator'da bildirimler farklı davranır ama real cihazda tüm path çalışmalı.

### 7. Background — App Suspended

iOS arka planda bildirim için local notification yine UNUserNotificationCenter ile. App suspend olduğunda Supabase Realtime bağlantı kopar → stream emit gelmez → bildirim hiç tetiklenmez. **Bu beklenen davranış**. Çözüm: push notification (Firebase/APNs) gerekli, local notification yetmez. Kullanıcıya bu açıklanmalı.

## Önemli Dosya Konumları

| Dosya | Rol |
|---|---|
| `lib/core/notifications/local_notification_service.dart` | Plugin entegrasyonu |
| `lib/app/bootstrap.dart` | init + permission istek noktası |
| `lib/feature/kurye/presentation/kurye_ana_page.dart` | ref.listen — stream → show() |
| `lib/product/notifications/notification_providers.dart` | Riverpod provider |
| `android/app/src/main/AndroidManifest.xml` | POST_NOTIFICATIONS izni eklendi |
| `ios/Runner/AppDelegate.swift` | Delegate kontrolü gerekebilir |
| `ios/Runner/Info.plist` | Şu an config eklenmedi (gerek olmayabilir) |
| `pubspec.yaml` | flutter_local_notifications: ^18.0.1 |

## Test Hesapları

```
Email: mucahit@bursamotokurye.com   Şifre: 14842267m  (Mücahit Şen, login için kullanılan)
Email: ismail@bursamotokurye.com    Şifre: 14842267i
Email: ozkan@bursamotokurye.com     Şifre: 14842267o
Email: adem@bursamotokurye.com      Şifre: 14842267a
Email: yigit@bursamotokurye.com     Şifre: 14842267y

Auth user IDs:
  Mücahit: de66bd45-5536-4886-970e-419679b68b65
  (kuryeler.id farklı, bkz BACKLOG.md)
```

Operasyon test: `ops@test.com` / `Test1234!`
Müşteri: `musteri@test.com` / `Test1234!`

## Diğer Açık Konular (notification dışı)

- **Pre-existing test failures** (benim değişikliklerimle ilgisi yok):
  - `test/feature/example_feed/example_feed_page_golden_test.dart` (golden mismatch)
  - `test/feature/operasyon/operasyon_gecmis_page_test.dart` (f) desktop workbench
- **Aşama 4'te plan etmiş ama yapmamıştım**: `_OrderProgressRow` operasyon kartına eklendi ama kurye'nin "İşi Bitir" akışı henüz manuel UAT yapılmadı (test geçti). Real device'da test edilmeli.

## Çalışma Dizini + Branch

```
cwd: /Users/mucahitsen/kurye-app
branch: development
remote: HEAD ahead of main (push gerekirse user karar verir)
```

## Build Komutu

```bash
flutter run -t lib/main_supabase.dart --dart-define-from-file=.env.dev
```

Hot restart = **R** (büyük). r küçük = hot reload, bootstrap'i yeniden çalıştırmaz.
