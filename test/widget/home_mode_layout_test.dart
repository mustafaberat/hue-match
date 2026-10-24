import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/app.dart';
import 'package:hue_match/app_scope.dart';
import 'package:hue_match/components/buttons.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/engine/match_engine.dart';
import 'package:hue_match/screens/home_screen.dart';
import 'package:hue_match/services/ad_service.dart';
import 'package:hue_match/services/settings_service.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:hue_match/theme/playful_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hafıza ↔ Pratik geçişinde ana sayfa hiç kaymamalı. Pratik'te skor yok
/// (0) ama "En iyi skor" satırı hayalet olarak aynı yeri kaplar.
void main() {
  for (final size in const [Size(320, 568), Size(393, 851)]) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('home layout is identical in memory and practice $label', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      SharedPreferences.setMockInitialValues({
        AppPrefsKeys.language: 'tr',
        AppPrefsKeys.onboardingDone: true,
        AppPrefsKeys.bestMemory: 412,
      });
      final services = AppServices(
        settings: SettingsService(),
        stats: StatsService(),
        ads: AdService(),
      );
      await services.load();
      await services.settings.setMode(GameMode.memory);

      await tester.pumpWidget(
        HueMatchApp(
          services: services,
          home: const HomeScreen(
            hueOverride: 205,
            bannerOverride: SizedBox(width: 320, height: 50),
          ),
        ),
      );
      await tester.pump();

      Rect title() => tester.getRect(find.byType(PlayfulTitle));
      Rect play() => tester.getRect(find.byType(PrimaryButton));
      Rect best() =>
          tester.getRect(find.byKey(const ValueKey('home-best-score')));

      final memory = (title(), play(), best());
      expect(find.textContaining('412'), findsOneWidget);

      await tester.tap(find.text('Pratik'));
      await tester.pumpAndSettle();
      expect(services.settings.mode, GameMode.practice);
      expect(services.stats.bestFor(GameMode.practice), 0);
      final practice = (title(), play(), best());

      expect(practice.$1, memory.$1, reason: 'title moved');
      expect(practice.$2, memory.$2, reason: 'Oyna button moved');
      // Genişlik rakam sayısına göre değişebilir; dikey yer sabit kalmalı.
      expect(practice.$3.top, memory.$3.top, reason: 'best-score slot moved');
      expect(
        practice.$3.height,
        memory.$3.height,
        reason: 'best-score slot changed height',
      );

      await tester.tap(find.text('Hafıza'));
      await tester.pumpAndSettle();
      expect(title(), memory.$1);
      expect(play(), memory.$2);
      expect(tester.takeException(), isNull);
    });
  }
}
