/// AdMob: Home banner + oyun sonu interstitial (Click Battle `AdService` deseni).
///
/// Play Families (5 yaş altı dahil): TFCD + TFUA + max rating G, NPA.
/// Web'de ve `FLUTTER_TEST` altında MobileAds hiç başlatılmaz.
/// Karıştırma ve sonuç ekranında reklam yok (§10).
library;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/ad_config.dart';
import '../config/app_config.dart';

/// §10: ilk oyunda yok, en fazla 2 oyunda 1, en az 90 s arayla. Saf mantık.
class InterstitialPolicy {
  InterstitialPolicy({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  int _gamesFinished = 0;
  int _gamesSinceLastAd = 0;
  DateTime? _lastShownAt;

  void recordGameFinished() {
    _gamesFinished++;
    _gamesSinceLastAd++;
  }

  bool get shouldShow {
    if (_gamesFinished < AdRules.gamesPerInterstitial) {
      return false;
    }
    if (_gamesSinceLastAd < AdRules.gamesPerInterstitial) {
      return false;
    }
    final last = _lastShownAt;
    if (last != null && _clock().difference(last) < AdRules.minInterval) {
      return false;
    }
    return true;
  }

  void recordShown() {
    _gamesSinceLastAd = 0;
    _lastShownAt = _clock();
  }
}

class AdService extends ChangeNotifier {
  AdService({InterstitialPolicy? policy})
    : policy = policy ?? InterstitialPolicy();

  final InterstitialPolicy policy;

  BannerAd? _banner;
  bool _bannerLoaded = false;
  InterstitialAd? _interstitial;
  bool _interstitialLoading = false;
  bool _initialized = false;

  static bool get isSupported {
    if (kIsWeb) return false;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  BannerAd? get banner => _bannerLoaded ? _banner : null;

  void initialize() {
    if (_initialized || !isSupported) return;
    _initialized = true;
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await _applyFamiliesRequestConfiguration();
      await MobileAds.instance.initialize();
      await _applyFamiliesRequestConfiguration();
      _loadBanner();
      _loadInterstitial();
    } catch (_) {
      // Reklam altyapısı yoksa oyun reklamsız devam eder.
    }
  }

  Future<void> _applyFamiliesRequestConfiguration() {
    return MobileAds.instance.updateRequestConfiguration(
      AdConfig.familiesRequestConfiguration,
    );
  }

  void _loadBanner() {
    _banner?.dispose();
    _bannerLoaded = false;
    _banner = BannerAd(
      adUnitId: AdConfig.homeBanner,
      size: AdSize.banner,
      request: AdConfig.adRequest,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _bannerLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          _banner = null;
          _bannerLoaded = false;
          notifyListeners();
        },
      ),
    )..load();
  }

  void _loadInterstitial() {
    if (!_initialized || _interstitialLoading || _interstitial != null) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConfig.gameEndInterstitial,
      request: AdConfig.adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _interstitialLoading = false;
        },
        onAdFailedToLoad: (_) {
          _interstitialLoading = false;
        },
      ),
    );
  }

  /// Oyun sonu sayacı. Oyun sonu ekranı açılınca çağrılır.
  void recordGameFinished() => policy.recordGameFinished();

  /// Oyun sonu → Ana sayfa / Tekrar oyna. Kural izin vermezse veya reklam
  /// hazır değilse beklemeden döner.
  Future<void> maybeShowGameEndInterstitial() async {
    if (!_initialized || !policy.shouldShow) return;
    if (_interstitial == null) {
      _loadInterstitial();
      await Future<void>.delayed(AdRules.loadGrace);
      if (_interstitial == null) return;
    }
    final ad = _interstitial!;
    _interstitial = null;
    final completer = Completer<void>();
    void finish() {
      if (!completer.isCompleted) completer.complete();
      _loadInterstitial();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        finish();
      },
    );
    policy.recordShown();
    try {
      await ad.show();
    } catch (_) {
      finish();
    }
    return completer.future.timeout(AdRules.showTimeout, onTimeout: () {});
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitial?.dispose();
    super.dispose();
  }
}
