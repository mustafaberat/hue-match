/// HueMind — oyun kuralları, puan eğrisi, üretim aralıkları ve kimlik.
///
/// Görsel token'lar (renk, boşluk, süre) `tokens.dart` içindedir.
library;

import '../color/oklab.dart';

// ---------------------------------------------------------------------------
// Kimlik
// ---------------------------------------------------------------------------

abstract final class AppIdentity {
  static const String appName = 'HueMind';
  static const String developer = 'ARU SOFT';
  static const String packageId = 'com.arusoft.huematch';
  static const String privacyPolicyUrl =
      'https://arusoft.vercel.app/privacy/hue-match';
}

// ---------------------------------------------------------------------------
// Diller
// ---------------------------------------------------------------------------

/// MOBILE_APP_RULES §2 sırası. Değer: dilin kendi adı (çevrilmez).
abstract final class AppLanguages {
  static const String fallback = 'en';

  static const Map<String, String> nativeNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português',
    'zh': '简体中文',
    'ja': '日本語',
    'de': 'Deutsch',
    'fr': 'Français',
    'ko': '한국어',
    'it': 'Italiano',
    'tr': 'Türkçe',
  };

  static List<String> get codes => nativeNames.keys.toList(growable: false);
}

// ---------------------------------------------------------------------------
// Kalıcı kayıt anahtarları
// ---------------------------------------------------------------------------

abstract final class AppPrefsKeys {
  static const String language = 'language';
  static const String colorBlindMode = 'color_blind_mode';
  static const String revealSeconds = 'reveal_seconds';
  static const String showValues = 'show_values';
  static const String randomStart = 'random_start';
  static const String gameMode = 'game_mode';
  static const String onboardingDone = 'onboarding_done';
  static const String bestMemory = 'best_memory';
  static const String bestPractice = 'best_practice';
  static const String dailyScorePrefix = 'daily_';
  static const String gamesPlayed = 'games_played';
}

// ---------------------------------------------------------------------------
// Oyun kuralları
// ---------------------------------------------------------------------------

abstract final class GameRules {
  static const int roundsPerGame = 5;
  static const int maxRoundScore = 100;
  static const int maxGameScore = roundsPerGame * maxRoundScore;

  /// Hafıza modu gösterim süresi seçenekleri (s). Varsayılan 3.
  static const List<int> revealSecondsOptions = [2, 3, 5];
  static const int defaultRevealSeconds = 3;

  /// Günlük meydan okuma her zaman Hafıza modu ve sabit süre — herkes eşit.
  static const int dailyRevealSeconds = 3;

  /// "Tekrar göster": tur başına 1 hak, 1 s, puan ×0.9.
  static const int replaysPerRound = 1;
  static const int replayMillis = 1000;
  static const double replayPenalty = 0.9;

  /// Karıştırıcı başlangıç değerleri (nötr gri, tam parlaklık).
  static const int initialChannel = 128;
  static const int initialAlphaPercent = 100;
}

/// Slider aralıkları ve ince ayar.
abstract final class MixerRules {
  static const int channelMax = 255;
  static const int alphaMax = 100;

  /// Uzun basınca hareket çarpanı.
  static const double fineTuneFactor = 0.25;

  /// Rastgele başlangıçta A alt sınırı (%), çok karanlık başlamasın.
  static const int randomStartAlphaMin = 40;
}

// ---------------------------------------------------------------------------
// Puanlama (§5)
// ---------------------------------------------------------------------------

abstract final class ScoringConfig {
  static const double deltaEMax = 0.36;
  static const double gamma = 1.2;

  /// Etiket alt sınırları (§4.3).
  static const int perfectMin = 98;
  static const int soCloseMin = 90;
  static const int goodMin = 75;
  static const int notBadMin = 50;

  /// Fark açıklamasında vurgulanan en büyük fark sayısı.
  static const int highlightedDiffs = 2;
}

// ---------------------------------------------------------------------------
// Hedef üretimi (§6, §7)
// ---------------------------------------------------------------------------

abstract final class GeneratorConfig {
  static const double lightnessMin = 0.35;
  static const double lightnessMax = 0.90;
  static const double chromaMin = 0.04;
  static const double chromaMax = 0.30;

  /// Düşük kroma (gri / pastel) kovası.
  static const double lowChromaMax = 0.08;

  /// Yüksek kroma (canlı) kovası.
  static const double highChromaMin = 0.18;

  static const double alphaMin = 0.35;
  static const double alphaMax = 1.0;

  /// A slider %1 adımlı — hedef de aynı adımda, böylece tam eşleme mümkün.
  static const int alphaSteps = 100;

  static const int maxAttempts = 100;

  /// Ardışık hedefler arasında en az bu kadar OKLab ΔE.
  static const double minConsecutiveDeltaE = 0.15;

  /// Renk körü modunda hedefin |a| (kırmızı-yeşil) üst sınırı.
  static const double colorBlindMaxA = 0.04;

  /// Yedek palette renk körü modunda kabul edilen |a|.
  static const double colorBlindFallbackMaxA = 0.08;

  /// Üretim 100 denemede tutmazsa sırayla denenir. Hepsi sRGB gamut içinde
  /// ve ardışık ikililer ΔE ≥ 0.15. Renk körü modunda |a| küçük olanlar seçilir.
  static const List<Oklch> fallbackPalette = [
    Oklch(0.62, 0.17, 255), // mavi
    Oklch(0.82, 0.12, 95), // hardal
    Oklch(0.48, 0.05, 230), // arduvaz
    Oklch(0.70, 0.16, 35), // mercan
    Oklch(0.58, 0.12, 155), // yeşil
    Oklch(0.86, 0.05, 280), // lila gri
    Oklch(0.45, 0.14, 300), // erik
  ];

  /// Günlük seed: yyyymmdd.
  static int dailySeed(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;
}

// ---------------------------------------------------------------------------
// Reklam frekansı (§10)
// ---------------------------------------------------------------------------

abstract final class AdRules {
  /// En fazla N oyunda 1 interstitial.
  static const int gamesPerInterstitial = 2;
  static const Duration minInterval = Duration(seconds: 90);

  /// Yüklenmemiş reklam için bekleme üst sınırı.
  static const Duration loadGrace = Duration(milliseconds: 800);
  static const Duration showTimeout = Duration(seconds: 6);
}
