# RFC V1 — Hue Match

Tek kişilik renk eşleme oyunu. Bir renk gösterilir, oyuncu **R / G / B / Alfa** çubuklarıyla aynı rengi yapmaya çalışır, yakınlığa göre puan alır. Backend yok, offline. Flutter, Android / iOS / web.

Kimlik: **Hue Match** (TR: **Renk Eşle**), ARU SOFT, `com.arusoft.huematch`.
Hue Hunt’ın kardeşi (aynı renk motoru / OKLab yardımcıları paylaşılabilir).
Ortak kurallar: `lib/MOBILE_APP_RULES.md`.

---

## 1. Oyun özü

1. Hedef renk gösterilir.
2. Oyuncu 4 çubukla kendi rengini karıştırır: **R**, **G**, **B** (0–255) ve **A** (alfa / parlaklık, %0–100).
3. **Onayla** → hedef ile oyuncunun rengi yan yana açılır, yakınlık puanı (0–100) verilir.
4. Bir oyun = **5 tur**, toplam puan **/ 500**. En iyi skor kaydedilir.

Portrait sabit. Timer yok (V1).

---

## 2. Alfa nasıl çalışır (önemli)

Renk her zaman **sabit siyah sahne** üzerinde gösterilir. Görünen renk:

```
görünen = (R, G, B) × A        # siyah üzerine alfa = parlaklık çarpanı
```

- Böylece alfa kullanıcıya “parlaklık / soluklaşma” olarak hissedilir (istenen davranış).
- **Puan görünen renk üzerinden hesaplanır**, ham slider değerleri üzerinden değil. Aynı görünümü farklı kombinasyonla (ör. RGB yüksek + A düşük, ya da RGB düşük + A yüksek) yakalayan oyuncu aynı puanı alır — haksız kayıp yok.
- Hedef üretiminde `A ∈ [0.35, 1.0]` (çok karanlık hedefler oynanmaz).

Sahne rengi `#000000`, renk kutusunun etrafında ince nötr çerçeve (`#2A2A2A`) — kutunun sınırı görünsün.

---

## 3. Modlar

| Mod | Hedef ne zaman görünür | Zorluk |
|---|---|---|
| **Hafıza** (varsayılan) | Tur başında **3 s** gösterilir, sonra gizlenir; karıştırma sırasında görünmez | Orta–zor |
| **Pratik** | Karıştırma boyunca hedef üst yarıda görünür | Kolay |

- Hafıza modunda gösterim süresi ayarlanabilir: 2 / **3** / 5 s.
- Hafıza modunda tur başına 1 kez **“Tekrar göster”** (1 s) hakkı; kullanılırsa o turun puanı ×0.9. (V2’de rewarded reklam ile ekstra hak.)
- Sayısal değerler (ör. `R 128`) varsayılan **gizli**; Ayarlar → “Değerleri göster” ile açılır. Açıkken Hafıza modu puanı değişmez (oyuncu zaten hedef sayıyı bilmiyor).

---

## 4. Ekran yerleşimi

### 4.1 Gösterim (Hafıza modu, 3 s)

```
┌──────────────────────────┐
│ Tur 2/5         Puan 164 │
│                          │
│   ┌──────────────────┐   │
│   │                  │   │
│   │   HEDEF RENK     │   │  ← büyük kare, siyah sahne
│   │                  │   │
│   └──────────────────┘   │
│   ▬▬▬▬▬▬▬▬▬▬▬▬▬▬░░░░░░   │  ← ince süre çubuğu (lineer azalır)
│      “Bu rengi hatırla”  │
└──────────────────────────┘
```

Süre çubuğu sade; geri sayım sayısı yok. Bitince hedef kare **kısa (200 ms) fade-out**, yerine oyuncunun karışım karesi gelir.

### 4.2 Karıştırma

```
┌──────────────────────────┐
│ Tur 2/5         Puan 164 │
│   ┌──────────────────┐   │
│   │   SENİN RENGİN   │   │  ← canlı önizleme
│   └──────────────────┘   │
│  R ━━━━━━━━●━━━━━━━  ●   │
│  G ━━━━●━━━━━━━━━━━  ●   │
│  B ━━━━━━━━━━━●━━━━  ●   │
│  A ━━━━━━━━━━━━━━●━  ◐   │
│                          │
│       [  ONAYLA  ]       │
└──────────────────────────┘
```

- Çubuk izleri kendi kanalının gradyanını gösterir (R çubuğu: o anki G,B ile R=0→255). Kullanıcı kaydırınca ne olacağını görür.
- A çubuğu izi: mevcut renk → siyah gradyanı.
- Başlangıç değerleri: `R=G=B=128, A=100%` (nötr gri). Ayarlar → “Rastgele başla” seçeneği.
- Hassas ayar: çubuğa uzun basınca ince ayar modu (hareket ×0.25), haptic tık her 16 birimde.
- Pratik modunda hedef kare önizlemenin hemen üstünde, eşit boyutta, aralarında 8 dp boşluk.

### 4.3 Tur sonucu

- Hedef ve oyuncu rengi **yan yana**, eşit kare.
- Büyük puan (ör. **87**) + kısa etiket:

| Puan | Etiket (TR / EN) |
|---|---|
| 98–100 | Kusursuz / Perfect |
| 90–97 | Çok yakın / So close |
| 75–89 | İyi / Good |
| 50–74 | Fena değil / Not bad |
| 0–49 | Uzak / Far off |

- Altında kanal farkı satırları: “R +18 · G −4 · B +30 · Parlaklık −12%” (görünen renge göre değil, en yakın eşdeğer A ile normalize edilmiş açıklama; bkz. §5.3).
- **Sonraki tur** butonu. 5. turdan sonra **Oyun sonu**.

### 4.4 Oyun sonu

- Toplam **/ 500**, en iyi skor, yeni rekor ise kısa vurgu.
- 5 turun mini şeridi: her turda hedef | sen yarım-yarım daire + puan.
- **Tekrar oyna** (büyük), Ana sayfa, Paylaş (V2).

---

## 5. Puanlama

### 5.1 Mesafe

Görünen iki rengi (sRGB, siyah üzerine alfa uygulanmış) **OKLab**’a çevir, Öklid mesafesi `ΔE`:

```
ΔE = sqrt((L1-L2)² + (a1-a2)² + (b1-b2)²)
```

OKLab’da ~0.02 fark gözle zor ayırt edilir.

### 5.2 Puan eğrisi

```
s = 100 × clamp(1 − ΔE / ΔE_max, 0, 1) ^ γ
ΔE_max = 0.30, γ = 1.5   # app_config.dart’ta ayarlanabilir
```

| ΔE | Puan (yaklaşık) |
|---|---|
| 0.00 | 100 |
| 0.02 | 90 |
| 0.05 | 76 |
| 0.10 | 54 |
| 0.20 | 19 |
| ≥ 0.30 | 0 |

Puan tam sayıya yuvarlanır. “Tekrar göster” kullanıldıysa ×0.9 sonra yuvarla.

### 5.3 Fark açıklaması

Kullanıcıya “R +18” gibi geri bildirim verirken ham slider farkı yanıltıcı olabilir (alfa yüzünden). Yöntem: oyuncunun görünen rengini, hedefin A değeriyle bölünmüş RGB’ye dönüştür (`R' = görünen_R / A_hedef`, 0–255 clamp) ve hedef RGB ile farkını göster; parlaklık farkı OKLab `L` farkından yüzde olarak. Sadece en büyük 2 farkı vurgula, diğerleri soluk.

---

## 6. Hedef renk üretimi

- `RGB` uniform değil: OKLCh’de `L ∈ [0.35, 0.90]`, `C ∈ [0.04, 0.30]`, `h ∈ [0, 360)` üret → sRGB gamut içinde değilse yeniden dene (max 100, sonra fallback palet).
- Ardından `A ∈ [0.35, 1.0]` seç; RGB’yi `görünen / A` olacak şekilde ayarla (gamut dışına taşarsa A’yı artır).
- Bir oyun içinde ardışık hedefler arasında `ΔE ≥ 0.15` (benzer renk peş peşe gelmesin).
- 5 turdan en az 1’i düşük kroma (gri/pastel), en az 1’i yüksek kroma (canlı).
Günlük meydan okuma yok.

---

## 7. Renk körü desteği

Oyunun kendisi renk algısı olduğu için tam erişilebilirlik mümkün değil; yine de:

- Ayarlar → **Renk körü modu**: hedef üretimi kırmızı-yeşil (OKLab `a`) ekseninde düşük tutulur; ağırlık parlaklık ve mavi-sarı (`b`) ekseninde. Hue Hunt’taki kuralla aynı.
- Sonuç ekranında sayısal kanal farkı her zaman yazılı (renge güvenmeden geri bildirim).
- Çubuklarda kanal adı harfle (R/G/B/A) ve ikonla; sadece renge dayalı değil.

---

## 8. How to play (oyun içi)

Ayrı metin sayfası değil; gerçek bileşenlerle animasyonlu 4 adım. Home’daki “?” ve Ayarlar’dan açılır, ilk açılışta otomatik (skip edilebilir).

1. **Rengi hatırla.** Hedef kare + azalan süre çubuğu. — “Bir renk göreceksin. İyi bak.”
2. **Karıştır.** El ikonu R çubuğunu kaydırır, önizleme değişir. — “R, G, B ile rengi, A ile parlaklığı ayarla.”
3. **Onayla.** Yan yana kareler + “87 · Çok yakın”. — “Ne kadar yakınsan o kadar puan.”
4. **5 tur.** Mini şerit + “412 / 500”. — “5 turda en yüksek skoru yap.”

Son adımda **Şimdi oyna** ve **Kapat**.

### 8.1 İlk oyun onboarding

İlk karıştırma ekranında A çubuğu üstünde tek seferlik ipucu: “A = parlaklık. Siyaha doğru soldurur.” İlk onaydan sonra kaybolur. `onboarding_done`.

---

## 9. Ekranlar

| Ekran | İçerik |
|---|---|
| **Home** | Ad, hue karesi, Hafıza / Pratik, **Oyna**, altında Ayarlar, onun altında Nasıl oynanır, en iyi skor. Altta banner |
| **Oyun** | §4.1–4.3 |
| **Oyun sonu** | §4.4 |
| **Ayarlar** | Dil (10), ses, titreşim, renk körü modu, hafıza süresi, değerleri göster, rastgele başla, How to play, gizlilik politikası, sürüm |

Ses ve titreşim yok. Ayarlarda da bu anahtarlar yok.

---

## 10. Reklam (AdMob)

Publisher: **ARU Soft**, `pub-1508520223269936` (`lib/admob/account.json`). AdMob uygulaması ve unit’ler **yeni oluşturulacak**, sonra `account.json` → `apps[]`’e eklenir.

| Unit | Tür | Yerleşim | ID |
|---|---|---|---|
| `home_banner` | Banner (adaptive) | Home alt kısmı | `ca-app-pub-1508520223269936/<TBD>` |
| `game_end_interstitial` | Interstitial | Oyun sonu → Ana sayfa / Tekrar oyna | `ca-app-pub-1508520223269936/<TBD>` |
| `replay_rewarded` (V2) | Rewarded | Hafıza modunda ekstra “Tekrar göster” | `ca-app-pub-1508520223269936/<TBD>` |
| AdMob App ID | — | Manifest + `gma_ad_services_config.xml` + iOS `Info.plist` | `ca-app-pub-1508520223269936~<TBD>` |

Geliştirmede Google test ID’leri; release’te gerçek ID, `lib/config/ad_config.dart` içinde `kReleaseMode` ile.

Kurallar:
- **Karıştırma ekranında reklam yok** (çubuklara yakın banner = yanlış tıklama riski + renk algısını bozar).
- Sonuç ekranında da yok; renk karşılaştırması temiz kalmalı.
- Interstitial: en fazla **2 oyunda 1**, en az 90 s arayla, ilk oyunda hiç yok. Yüklenmezse beklemeden devam (Click Battle `AdService` deseni).
- `FLUTTER_TEST` ortamında MobileAds başlatılmaz.

---

## 11. Kod yapısı

```
lib/
  main.dart
  app.dart
  config/
    app_config.dart     # tur sayısı, hafıza süresi, ΔE_max, γ, üretim aralıkları
    ad_config.dart
  color/
    oklab.dart          # sRGB ↔ linear ↔ OKLab / OKLCh (Hue Hunt ile ortak)
    composite.dart      # siyah üzerine alfa
    target_generator.dart
    scoring.dart        # ΔE → puan, fark açıklaması
  engine/
    match_engine.dart   # saf Dart: tur akışı, puan toplamı, günlük seed
  game/
    reveal_view.dart
    mixer_view.dart
    channel_slider.dart # gradyan izli slider + ince ayar
    round_result_view.dart
    game_end_view.dart
  screens/
    home_screen.dart
    settings_screen.dart
    how_to_play_screen.dart
  services/
    ad_service.dart
    settings_service.dart
    stats_service.dart  # en iyi skor, günlük skorlar
  l10n/ app_*.arb       # 10 dil
```

- Ekranda magic number / ham string yok.
- Unit test: OKLab dönüşümü (bilinen değerler), siyah üzeri composite, farklı RGB+A kombinasyonlarının aynı puanı alması, puan eğrisi tablosu (§5.2), üretimde gamut ve ardışık ΔE kuralı, günlük seed’in deterministik olması.
- Background’a geçince Hafıza modunda gösterim duraklar (süre çubuğu donar), geri dönünce kaldığı yerden devam.

---

## 12. Mağaza

- Kısa açıklama (EN): “See a color, mix it from memory with RGB and brightness. How close can you get?”
- Kısa açıklama (TR): “Rengi gör, RGB ve parlaklıkla aynısını yap. Ne kadar yaklaşabilirsin?”
- Headline (`MOBILE_APP_RULES.md` §7’ye eklenecek): EN **MATCH THE COLOR** / TR **RENGİ EŞLE**.
- `{ACCENT_COLOR}`: hedef rengine göre değişebilir; marka için `#FF7A59` (sıcak mercan) veya Hue Hunt aksanı.
- `{GAME_UI_DESCRIPTION}`: “a large color swatch on a black stage, four minimal gradient sliders labeled R, G, B and A below, a score of 92 shown next to the target and player colors side by side”.

---

## 13. Kabul checklist

- [ ] Hafıza modu: 3 s gösterim → gizlenir → karıştır → onay → puan
- [ ] Pratik modu: hedef sürekli görünür
- [ ] Alfa siyah üzerinde parlaklık gibi davranır; puan görünen renkten hesaplanır
- [ ] Aynı görünen renk = aynı puan (farklı RGB/A kombinasyonu)
- [ ] Puan eğrisi §5.2 tablosuyla uyumlu (unit test)
- [ ] 5 tur → toplam / 500, en iyi skor kalıcı
- [ ] Hafıza modunda renk karesi gösterim ve karıştırmada aynı yerde
- [ ] Renk körü modu, değerleri göster, ince ayar
- [ ] Karıştırma ve sonuç ekranında reklam yok; interstitial frekans sınırı
- [ ] `MOBILE_APP_RULES.md` §8 checklist
