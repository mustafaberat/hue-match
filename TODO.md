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
