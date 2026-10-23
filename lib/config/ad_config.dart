/// AdMob kimlikleri (§10). Geliştirmede Google TEST id'leri; release'te gerçek.
///
/// Publisher: ARU Soft `pub-1508520223269936`. Gerçek app + unit'ler henüz
/// oluşturulmadı — oluşturulunca `<TBD>` yerlerini doldur ve
/// `lib/admob/account.json` → `apps[]`'e ekle. `<TBD>` dolmadıkça release de
/// test id'lerini kullanır (yanlışlıkla boş id ile yayın olmasın).
///
/// Play Families: uygulama 5 yaş altı dahil tüm yaşları hedefliyor. Reklam
/// istekleri çocuk yönelimli, rıza yaşı altı ve G içerik derecesi ile
/// kişiselleştirilmez.
library;

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract final class AdConfig {
  static const String publisherId = 'pub-1508520223269936';

  /// `MobileAds.initialize` öncesi ve sonrası uygulanır.
  static RequestConfiguration get familiesRequestConfiguration {
    return RequestConfiguration(
      maxAdContentRating: MaxAdContentRating.g,
      // ignore: deprecated_member_use
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      // ignore: deprecated_member_use
      tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.yes,
      ageRestrictedTreatment: AgeRestrictedTreatment.child,
    );
  }

  static const AdRequest adRequest = AdRequest(nonPersonalizedAds: true);

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
