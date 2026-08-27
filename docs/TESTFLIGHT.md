# Diyetsel → TestFlight (GitHub)

App Store Connect app ID: **6805844542**  
Bundle ID: **com.diyetsel.diyetsel**

## 1) Apple’da yeni provisioning profile

1. [Certificates, Identifiers & Profiles → Profiles](https://developer.apple.com/account/resources/profiles/list) → **+**
2. **App Store Connect** (Distribution) → Continue
3. App ID: `com.diyetsel.diyetsel`
4. Apple Distribution certificate seç
5. Profile adı: örn. `Diyetsel App Store`
6. Generate → **Download** (`.mobileprovision`)

> Distribution `.p12` ve App Store Connect API Key daha önce dieton/Kresim için vardıysa **aynısını** kullanabilirsin.  
> **Yeni olan sadece** bu uygulamanın provisioning profile’ı.

## 2) GitHub Secrets

Repo → **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Ne |
|--------|----|
| `IOS_TEAM_ID` | Apple Developer → Membership → Team ID |
| `IOS_DISTRIBUTION_CERT_BASE64` | Distribution `.p12` base64 |
| `IOS_DISTRIBUTION_CERT_PASSWORD` | `.p12` şifresi |
| `IOS_PROVISIONING_PROFILE_BASE64` | `Diyetsel App Store.mobileprovision` base64 |
| `IOS_PROVISIONING_PROFILE_NAME` | Profilin **tam adı** (örn. `Diyetsel App Store`) |
| `APP_STORE_CONNECT_KEY_ID` | Users and Access → Integrations → Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID) |
| `APP_STORE_CONNECT_KEY_CONTENT` | `.p8` içeriği (PEM) veya base64 |

### Base64 (Windows PowerShell)

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\Distribution.p12")) | Set-Clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\Diyetsel_App_Store.mobileprovision")) | Set-Clipboard
```

## 3) Repo + workflow

1. Kodu GitHub’a push et (`ercin312/diyetsel` önerilir)
2. Secrets’ları ekle
3. **Actions → iOS TestFlight → Run workflow**
4. Bitince [App Store Connect → Diyetsel → TestFlight](https://appstoreconnect.apple.com/apps/6805844542/testflight/ios)
5. Internal Testing grubuna testçi ekle / davet gönder

Processing genelde 5–30 dakika sürer.
