import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hue_match/config/ad_config.dart';

void main() {
  test(
    'Families policy: G rating, child-directed, under-age, non-personalized',
    () {
      final config = AdConfig.familiesRequestConfiguration;
      expect(config.maxAdContentRating, MaxAdContentRating.g);
      // ignore: deprecated_member_use
      expect(
        config.tagForChildDirectedTreatment,
        TagForChildDirectedTreatment.yes,
      );
      // ignore: deprecated_member_use
      expect(config.tagForUnderAgeOfConsent, TagForUnderAgeOfConsent.yes);
      expect(config.ageRestrictedTreatment, AgeRestrictedTreatment.child);
      expect(AdConfig.adRequest.nonPersonalizedAds, isTrue);
    },
  );

  test('release ids stay TODO until real AdMob units exist', () {
    expect(AdConfig.releaseAppId, contains('<TBD>'));
    expect(AdConfig.releaseHomeBanner, contains('<TBD>'));
    expect(AdConfig.releaseGameEndInterstitial, contains('<TBD>'));
    expect(AdConfig.homeBanner, AdConfig.testBanner);
    expect(AdConfig.gameEndInterstitial, AdConfig.testInterstitial);
  });
}
