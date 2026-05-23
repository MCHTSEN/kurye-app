# Push Notification — Kullanıcı Setup Adımları

> Ben backend + Flutter implementasyonunu yapıyorum. Bu dosyadaki adımlar **sana** ait — bunları sırayla yap, hazır olduğunda bana haber ver.

## Bundle ID'ler (Firebase Console'a kayıt için)

| Platform | Bundle ID |
|---|---|
| iOS | `com.lukeristudio.kuryem` |
| Android | `com.kuryem.lukeristudio` |

⚠️ Bu ikisi **farklı** — Firebase Console'da iki ayrı app olarak ekleyeceksin.

---

## 1. FlutterFire CLI ile Firebase Project Oluştur

### Hazırlık
```bash
# FlutterFire CLI kurulu mu kontrol et
which flutterfire || dart pub global activate flutterfire_cli

# Firebase CLI kurulu mu
which firebase || npm install -g firebase-tools

# Google hesabıyla login
firebase login
```

> ⚠️ CLAUDE.md gereği hangi Google hesabını kullanacağını **sana bırakıyorum**. Önerim: app store/production hesabınla aynı olsun (uzun vadeli destek için).

### Configure
```bash
cd /Users/mucahitsen/kurye-app
flutterfire configure
```

İnteraktif sorularda:
- **Select a Firebase project**: `<Create a new project>` → isim: `kuryem-prod` (veya tercihin)
- **Which platforms?**: `ios` + `android` seç (web/macOS gerek yok şimdilik)
- **Which iOS bundle id?**: `com.lukeristudio.kuryem` (otomatik algılar)
- **Which Android application id?**: `com.kuryem.lukeristudio` (otomatik algılar)

Çıktı dosyaları:
- `lib/firebase_options.dart` (NEW)
- `ios/Runner/GoogleService-Info.plist` (NEW)
- `android/app/google-services.json` (NEW)

> Bu dosyalar oluştuğunda bana **"firebase config hazır"** de.

---

## 2. APNs Auth Key (.p8) Oluştur ve Firebase'e Yükle

### Apple Developer Portal
1. https://developer.apple.com/account/resources/authkeys/list
2. **+** → "Apple Push Notifications service (APNs)" check → Continue
3. Key Name: `Kuryem APNs` → Register → **Download** (.p8 dosyası)
4. Bu sayfada görünen **Key ID** ve **Team ID**'yi not al (Team ID sağ üstte de var)

⚠️ **.p8 dosyasını kaybedersen tekrar indiremezsin** — güvenli yere koy (Keychain veya 1Password).

### Firebase Console'a yükle
1. https://console.firebase.google.com/project/_/settings/cloudmessaging
2. **Apple app configuration** → iOS app altında **APNs Authentication Key** → **Upload**
3. Aç:
   - **APNs auth key file (.p8)**: indirdiğin dosya
   - **Key ID**: Apple Developer'dan
   - **Team ID**: Apple Developer'dan
4. **Upload**

> Bu adım bitince bana **"APNs yüklendi"** de.

---

## 3. Xcode Capabilities (iOS push'u aktive et)

```bash
open ios/Runner.xcworkspace
```

Xcode'da:
1. Sol panelden **Runner** project'i seç
2. Target listesinden **Runner** seç
3. **Signing & Capabilities** sekmesi
4. **+ Capability** butonu:
   - "Push Notifications" ekle
   - "Background Modes" ekle → açılan listede **"Remote notifications"** check'le

Xcode otomatik olarak şunları günceller:
- `ios/Runner/Runner.entitlements` → `aps-environment` key
- `ios/Runner/Info.plist` → `UIBackgroundModes` → `remote-notification`

> Build edip hata vermediğini görmek için: Xcode'da **Cmd+B**. Hata varsa bana ekran görüntüsü gönder.

> Bu adım bitince bana **"Xcode capability hazır"** de.

---

## 4. Service Account Key (Edge Function FCM gönderimi için)

Edge Function FCM HTTP v1 API'sini çağırırken Google service account JSON'a ihtiyaç duyar.

1. https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk
2. **Generate new private key** → Confirm → JSON dosyası indir
3. Dosyayı güvenli bir yere koy (örn: `~/Downloads/kuryem-prod-service-account.json`)

⚠️ **Bu JSON repoya commit edilmemeli** — .gitignore zaten korumalı ama yine de dikkat.

Sonra Supabase secret olarak ekle:
```bash
# Proje dizininde
cd /Users/mucahitsen/kurye-app

# Service account JSON'u secret olarak set et
supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat ~/Downloads/kuryem-prod-service-account.json)"

# Project ID (Firebase Console > Project Settings > General > Project ID)
supabase secrets set FCM_PROJECT_ID=kuryem-prod
```

> Bu adım bitince bana **"FCM secrets set"** de.

---

## 5. Supabase Migration Apply

Ben migration dosyasını yazacağım. Hazır olduğunda:

```bash
cd /Users/mucahitsen/kurye-app
supabase db push
```

Eğer MCP/CLI issue olursa, ben curl ile manuel apply yardımcı olurum.

---

## 6. Supabase Edge Function Deploy

Ben function kodunu yazacağım. Hazır olduğunda:

```bash
cd /Users/mucahitsen/kurye-app
supabase functions deploy send-push-on-assign
```

---

## 7. Database Webhook Setup (Supabase Dashboard)

1. Supabase Dashboard → senin projen → **Database** → **Webhooks** → **Create a new hook**
2. **Name**: `send_push_on_kurye_assign`
3. **Table**: `siparisler`
4. **Events**: `INSERT` + `UPDATE` her ikisi de check
5. **Type**: `HTTP Request`
6. **Method**: `POST`
7. **URL**: `https://<your-project-ref>.supabase.co/functions/v1/send-push-on-assign`
   - Project ref'i Supabase Dashboard > Settings > API'dan al
8. **HTTP Headers**:
   - `Authorization`: `Bearer <SUPABASE_SERVICE_ROLE_KEY>` (Settings > API'dan kopyala)
   - `Content-Type`: `application/json`
9. **HTTP Params**: boş bırak
10. **Confirm**

> Test için: Manuel olarak siparişlerden birinin kurye_id'sini güncelle ve **Edge Function logs**'ta tetiklendiğini gör:
> ```bash
> supabase functions logs send-push-on-assign --tail
> ```

> Bu adım bitince bana **"Webhook hazır"** de.

---

## Genel Akış (özet)

```
1. flutterfire configure              → "firebase config hazır"
2. APNs .p8 oluştur + Firebase'e yükle → "APNs yüklendi"
3. Xcode capabilities                  → "Xcode capability hazır"
4. Service account + supabase secrets  → "FCM secrets set"
5. supabase db push                    → (sıra benim implementasyondan sonra)
6. supabase functions deploy           → (sıra benim implementasyondan sonra)
7. Webhook setup (Supabase Dashboard)  → "Webhook hazır"
```

Adım 1-4'ü hemen başlatabilirsin — ben 5 ve 6'nın kodunu paralel yazıyorum.
