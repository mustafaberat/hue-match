import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/app.dart';
import 'package:hue_match/app_scope.dart';
import 'package:hue_match/color/composite.dart';
import 'package:hue_match/color/scoring.dart';
import 'package:hue_match/components/game_header.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/engine/match_engine.dart';
import 'package:hue_match/game/game_end_view.dart';
import 'package:hue_match/game/game_screen.dart';
import 'package:hue_match/game/mixer_view.dart';
import 'package:hue_match/game/round_result_view.dart';
import 'package:hue_match/screens/home_screen.dart';
import 'package:hue_match/screens/how_to_play_screen.dart';
import 'package:hue_match/screens/settings_screen.dart';
import 'package:hue_match/services/ad_service.dart';
import 'package:hue_match/services/settings_service.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _reduceMotion(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

Future<AppServices> _services() async {
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
  return services;
}

void _setSize(WidgetTester tester, Size logical) {
  tester.view.physicalSize = logical;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 20);
  tester.view.viewPadding = const FakeViewPadding(top: 20);
  addTearDown(tester.view.reset);
}

Widget _game(Widget child) {
  return GameFrame(
    header: GameHeader(
      roundNumber: 2,
      roundCount: GameRules.roundsPerGame,
      score: 87,
      onClose: () {},
    ),
    child: child,
  );
}

RoundResult _result(MixColor target, int wanted) {
  MixColor? best;
  var bestGap = 1 << 30;
  for (var step = 0; step <= 160; step++) {
    for (final dir in const [(1, 0, -1), (-1, 1, 0), (0, -1, 1)]) {
      final candidate = target.copyWith(
        r: (target.r + dir.$1 * step).clamp(0, 255),
        g: (target.g + dir.$2 * step ~/ 2).clamp(0, 255),
        b: (target.b + dir.$3 * step).clamp(0, 255),
        alphaPercent: (target.alphaPercent - step ~/ 8).clamp(0, 100),
      );
      final gap = (roundScore(visibleDeltaE(target, candidate)) - wanted).abs();
      if (gap < bestGap) {
        bestGap = gap;
        best = candidate;
      }
    }
    if (bestGap == 0) break;
  }
  return MatchEngine(targets: [target]).submit(best!);
}

Future<void> _pumpScreen(WidgetTester tester, Size size, Widget screen) async {
  _setSize(tester, size);
  final services = await _services();
  final overflows = <String>[];
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('overflowed') || text.contains('OVERFLOW')) {
      overflows.add(text);
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
  await tester.pumpWidget(HueMatchApp(services: services, home: screen));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  expect(tester.takeException(), isNull);
  expect(overflows, isEmpty, reason: overflows.join('\n'));
}

void main() {
  const sizes = [Size(320, 568), Size(375, 667)];

  final target = MixColor(r: 64, g: 170, b: 160, alphaPercent: 100);
  final mix = MixColor(r: 80, g: 176, b: 150, alphaPercent: 96);

  for (final size in sizes) {
    final label = '${size.width.toInt()}x${size.height.toInt()}';

    testWidgets('home $label does not overflow', (tester) async {
      _reduceMotion(tester);
      await _pumpScreen(tester, size, const HomeScreen(hueOverride: 205));
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('mixer $label does not overflow', (tester) async {
      _reduceMotion(tester);
      await _pumpScreen(
        tester,
        size,
        _game(
          MixerView(
            mode: GameMode.memory,
            target: target,
            mix: mix,
            canReplay: true,
            onMixChanged: (_) {},
            onConfirm: () {},
            onReplay: () {},
          ),
        ),
      );
      expect(find.byType(MixerView), findsOneWidget);
    });

    testWidgets('round result $label does not overflow', (tester) async {
      _reduceMotion(tester);
      final result = _result(target, 72);
      await _pumpScreen(
        tester,
        size,
        _game(
          RoundResultView(result: result, isLastRound: false, onNext: () {}),
        ),
      );
      expect(find.byType(RoundResultView), findsOneWidget);
    });

    testWidgets('game end $label does not overflow', (tester) async {
      _reduceMotion(tester);
      final results = [
        for (final score in const [84, 91, 67, 98, 76]) _result(target, score),
      ];
      await _pumpScreen(
        tester,
        size,
        GameFrame(
          child: GameEndView(
            total: 416,
            maxTotal: GameRules.maxGameScore,
            best: 416,
            isNewBest: true,
            entries: stripEntries(results),
            onHome: () {},
            onPlayAgain: () {},
          ),
        ),
      );
      expect(find.byType(GameEndView), findsOneWidget);
    });

    testWidgets('how-to $label does not overflow', (tester) async {
      _reduceMotion(tester);
      await _pumpScreen(
        tester,
        size,
        const HowToPlayScreen(initialPage: 0, demoProgress: 0.42),
      );
      expect(find.byType(HowToPlayScreen), findsOneWidget);
    });

    testWidgets('settings $label does not overflow', (tester) async {
      _reduceMotion(tester);
      await _pumpScreen(
        tester,
        size,
        const SettingsScreen(versionOverride: '0.1.0 (1)'),
      );
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  }
}
