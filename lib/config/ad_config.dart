/// AdMob kimlikleri (§10). Geliştirmede Google TEST id'leri; release'te gerçek.
///
/// Publisher: ARU Soft `pub-1508520223269936`. Gerçek app + unit'ler henüz
/// oluşturulmadı — oluşturulunca `<TBD>` yerlerini doldur ve
/// `lib/admob/account.json` → `apps[]`'e ekle. `<TBD>` dolmadıkça release de
/// test id'lerini kullanır (yanlışlıkla boş id ile yayın olmasın).
library;

import 'package:flutter/foundation.dart';

abstract final class AdConfig {
  static const String publisherId = 'pub-1508520223269936';

  // --- Google test ids -----------------------------------------------------
  static const String testAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713';
  static const String testAppIdIos = 'ca-app-pub-3940256099942544~1458002511';
  static const String testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // --- Release ids (TBD) ---------------------------------------------------
  static const String _tbd = '<TBD>';
  static const String releaseAppId = 'ca-app-pub-1508520223269936~$_tbd';
  static const String releaseHomeBanner = 'ca-app-pub-1508520223269936/$_tbd';
  static const String releaseGameEndInterstitial =
      'ca-app-pub-1508520223269936/$_tbd';

  /// V2: Hafıza modunda ekstra "Tekrar göster".
  static const String releaseReplayRewarded =
      'ca-app-pub-1508520223269936/$_tbd';

  static bool _ready(String id) => !id.contains(_tbd);

  static String _pick(String release, String test) =>
      kReleaseMode && _ready(release) ? release : test;

  static String get homeBanner => _pick(releaseHomeBanner, testBanner);

  static String get gameEndInterstitial =>
      _pick(releaseGameEndInterstitial, testInterstitial);
}
