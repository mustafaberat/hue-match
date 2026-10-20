import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/app.dart';
import 'package:hue_match/app_scope.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/game/mixer_view.dart';
import 'package:hue_match/game/reveal_view.dart';
import 'package:hue_match/game/round_result_view.dart';
import 'package:hue_match/services/ad_service.dart';
import 'package:hue_match/services/settings_service.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Home karesi sonsuz döner; Reduce Motion açıkken durur (pumpAndSettle için).
void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<AppServices> _services(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: 'en',
    AppPrefsKeys.howToSeen: true,
    ...prefs,
  });
  final services = AppServices(
    settings: SettingsService(),
    stats: StatsService(),
    ads: AdService(),
  );
  await services.load();
  return services;
}

void main() {
  testWidgets('memory round: reveal → mixer → result', (tester) async {
    _reduceMotion(tester);
    final services = await _services({});
    await tester.pumpWidget(HueMatchApp(services: services));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RevealView), findsOneWidget);
    expect(find.text('Remember this color'), findsOneWidget);

    await tester.pump(const Duration(seconds: GameRules.defaultRevealSeconds));
    await tester.pumpAndSettle();
    expect(find.byType(MixerView), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(find.byType(RoundResultView), findsOneWidget);
    expect(find.text('Next round'), findsOneWidget);
    expect(services.settings.onboardingDone, isTrue);
  });

  testWidgets('practice: target visible, 5 rounds to game end', (tester) async {
    _reduceMotion(tester);
    final services = await _services({
      AppPrefsKeys.gameMode: 'practice',
      AppPrefsKeys.onboardingDone: true,
    });
    await tester.pumpWidget(HueMatchApp(services: services));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    for (var round = 0; round < GameRules.roundsPerGame; round++) {
      expect(find.text('TARGET'), findsOneWidget);
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      final isLast = round == GameRules.roundsPerGame - 1;
      await tester.tap(find.text(isLast ? 'See total' : 'Next round'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Play again'), findsOneWidget);
    expect(services.stats.gamesPlayed, 1);
    expect(services.stats.bestPractice, greaterThanOrEqualTo(0));
  });

  testWidgets('language switches live', (tester) async {
    _reduceMotion(tester);
    final services = await _services({});
    await tester.pumpWidget(HueMatchApp(services: services));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
    await services.settings.setLanguage('tr');
    await tester.pumpAndSettle();
    expect(find.text('Oyna'), findsOneWidget);
    expect(find.text('Renk Eşle'), findsOneWidget);
  });

  group('interstitial policy', () {
    test('none in first game, max 1 per 2 games, 90 s apart', () {
      var now = DateTime(2026);
      final policy = InterstitialPolicy(clock: () => now);
      policy.recordGameFinished();
      expect(policy.shouldShow, isFalse);
      policy.recordGameFinished();
      expect(policy.shouldShow, isTrue);
      policy.recordShown();
      policy.recordGameFinished();
      expect(policy.shouldShow, isFalse);
      policy.recordGameFinished();
      now = now.add(const Duration(seconds: 30));
      expect(policy.shouldShow, isFalse);
      now = now.add(AdRules.minInterval);
      expect(policy.shouldShow, isTrue);
    });
  });
}
