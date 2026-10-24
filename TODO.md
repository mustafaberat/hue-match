# HueMind — Yapılacaklar

## En iyi skor
- [x] En iyi skor şu an cihazda yerel tutuluyor (SharedPreferences, mod başına):
  - Hafıza modu: `best_memory` (`AppPrefsKeys.bestMemory`)
  - Pratik modu: `best_practice` (`AppPrefsKeys.bestPractice`)
  - Kayıt: `lib/services/stats_service.dart` → `StatsService.recordGame()` (oyun sonunda, skor daha yüksekse)
  - Okuma: `StatsService.load()`; ana ekran `lib/screens/home_screen.dart` içinde `services.stats.bestFor(settings.mode)` ile gösteriyor.
- [ ] İleride en iyi skorun veritabanından alınması planlanıyor (şimdilik veritabanı/backend bağlantısı yok).

## Ses ve titreşim
- [x] Ses ve titreşim tamamen kaldırıldı:
  - `FeedbackService` (ve `AppServices.feedback`) silindi; oyun ekranındaki çağrılar kaldırıldı.
  - Kaydırıcıdaki ince ayar "haptic tık" geri çağrısı (`onFineTick`) ve ilgili sabitler kaldırıldı.
  - Ayarlardaki ses/titreşim alanları, SharedPreferences anahtarları (`sound`, `haptic`) ve `settingsSound` / `settingsHaptics` çevirileri kaldırıldı.

## APK boyutu
- [ ] Release APK ~53 MB, biraz küçültülmeli (şimdilik değil):
  - Evrensel APK 3 ABI içeriyor (armeabi-v7a, arm64-v8a, x86_64); test için `flutter build apk --release --split-per-abi` ile her biri ~18–20 MB olur. Play'e zaten AAB gidiyor (ABI'ye göre bölünür).
  - Baloo2 5 ağırlık × ~420 KB; kullanılmayan ağırlıkları çıkar veya fontları alt kümeye (subset) indir.
  - `play/` ve `design/` görselleri pakete girmiyor, sorun değil; `assets/` altını kontrol et.

## Android release açılış hatası (çözüldü)
- [x] Release APK splash'te takılıyordu: R8, shared_preferences_android 2.5.x'in JNI ile çağrılan Kotlin metodlarını (ve kotlin.coroutines sınıflarını) siliyordu → `SharedPreferences.getInstance` NoSuchMethodError → `runApp` hiç çalışmıyordu. `android/app/proguard-rules.pro` keep kuralları + `main.dart` başlangıç korumaları (hata/zaman aşımı runApp'i engellemez).
