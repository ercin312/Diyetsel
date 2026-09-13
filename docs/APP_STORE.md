# e-Diyet — App Store Connect yayın checklist

App ID: **6805844542**  
Bundle ID: **com.diyetsel.diyetsel**  
Sürüm: **1.1.0**

## Otomatik doldurulan alanlar

GitHub Action: **Fill App Store listing**

- Ad: `e-Diyet`
- Alt başlık: `Diyetisyenle birlikte ilerle`
- Gizlilik: https://diyetsel-platform.web.app/privacy
- Destek: https://diyetsel-platform.web.app/support
- Pazarlama: https://diyetsel-platform.web.app
- Açıklama, anahtar kelimeler, tanıtım metni, “Bu sürümde neler yeni”
- İnceleme notları + demo hesap (`diyetisyen@diyetsel.app` / `Diyetsel123!`)

## Konsolda senin doldurman gerekenler

1. **Ekran görüntüleri** (iPhone 6.7" zorunlu; 6.3"/5.5" önerilir)
2. **Uygulama Gizliliği** etiketleri:
   - İletişim bilgisi (ad, e-posta, telefon) — Uygulama İşlevselliği, kimliğe bağlı
   - Sağlık ve Fitness (kilo/ölçü, diyet) — Uygulama İşlevselliği, kimliğe bağlı
   - Fotoğraflar (öğün) — Uygulama İşlevselliği
   - Kullanıcı içeriği (sohbet, belgeler)
   - Cihaz kimliği (bildirim jetonu)
3. **Yaş derecesi** anketi: Health & Fitness; tıbbi tedavi yok; sınırsız web tarayıcısı yok
4. **Kategori:** Health & Fitness (ikincil: Lifestyle)
5. **İnceleme telefonu** (Actions secret `ASC_CONTACT_PHONE` veya Connect formu)

Build TestFlight’ta **Processing** bittikten sonra bu sürümü seçip **Submit for Review**.
