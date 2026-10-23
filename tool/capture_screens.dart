/// HueMind ekran görüntüleri — Boya Atölyesi.
///
/// Run: `flutter test tool/capture_screens.dart`
/// Out: `play/design-options/*.png` — 1080×2340 (393×851 dp @ 2.75), Türkçe.
///
/// Durum deterministik. 06 koyu mor hedef — maskotun karanlık renkte
/// neşeli kaldığını doğrulamak için.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/app.dart';
import 'package:hue_match/app_scope.dart';
import 'package:hue_match/color/composite.dart';
import 'package:hue_match/color/scoring.dart';
import 'package:hue_match/components/game_header.dart';
import 'package:hue_match/components/l10n_format.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/config/app_theme.dart';
import 'package:hue_match/config/tokens.dart';
import 'package:hue_match/engine/match_engine.dart';
import 'package:hue_match/game/game_end_view.dart';
import 'package:hue_match/game/game_screen.dart';
import 'package:hue_match/game/mixer_view.dart';
import 'package:hue_match/game/reveal_view.dart';
import 'package:hue_match/game/round_result_view.dart';
import 'package:hue_match/l10n/app_localizations.dart';
import 'package:hue_match/screens/home_screen.dart';
import 'package:hue_match/screens/how_to_play_screen.dart';
import 'package:hue_match/screens/settings_screen.dart';
import 'package:hue_match/services/ad_service.dart';
import 'package:hue_match/services/settings_service.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _outRoot = 'play/design-options';
const Size _physical = Size(1080, 2340);
const double _dpr = 2.75;
const double _topInsetDp = 28;
const double _bottomInsetDp = 16;

final DateTime _today = DateTime(2026, 10, 19);
const double _homeHue = 205;
const int _bestScore = 412;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('design shots', (tester) async {
    await tester.runAsync(_loadFonts);
    _setView(tester);

    final targets = MatchEngine.dailyTargets(_today);

    Future<void> shoot(String name, Widget screen) async {
      final services = await _services(tester);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: HueMatchApp(services: services, home: screen),
        ),
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await _writePng(tester, key, '$_outRoot/$name.png');
      await tester.pumpWidget(const SizedBox.shrink());
    }

    final home = HomeScreen(
      hueOverride: _homeHue,
      bannerOverride: const _BannerPlaceholder(),
    );
    await shoot('01-home', home);

    final revealTarget = targets[1];
    await shoot(
      '02-reveal',
      _Game(
        round: 2,
        score: 87,
        child: RevealView(target: revealTarget, remaining: 0.58, onSkip: () {}),
      ),
    );

    final midMix = MixColor(
      r: (revealTarget.r * 0.8).round(),
      g: (revealTarget.g * 0.9 + 20).round().clamp(0, 255),
      b: (revealTarget.b * 1.1).round().clamp(0, 255),
      alphaPercent: 82,
    );
    await shoot(
      '03-mixer',
      _Game(
        round: 2,
        score: 87,
        child: MixerView(
          mode: GameMode.memory,
          target: revealTarget,
          mix: midMix,
          canReplay: true,
          onMixChanged: (_) {},
          onConfirm: () {},
          onReplay: () {},
        ),
      ),
    );

    const practiceTarget = MixColor(r: 236, g: 150, b: 72, alphaPercent: 86);
    await shoot(
      '04-mixer-practice',
      _Game(
        round: 3,
        score: 164,
        child: MixerView(
          mode: GameMode.practice,
          target: practiceTarget,
          mix: MixColor(
            r: (practiceTarget.r * 0.85 + 18).round().clamp(0, 255),
            g: (practiceTarget.g * 0.92).round(),
            b: practiceTarget.b,
            alphaPercent: practiceTarget.alphaPercent,
          ),
          showValues: true,
          onMixChanged: (_) {},
          onConfirm: () {},
        ),
      ),
    );

    final high = _resultWithScore(targets[3], 92);
    await shoot(
      '06-round-result-high',
      _Game(
        round: 4,
        score: 251 + high.score,
        child: RoundResultView(result: high, isLastRound: false, onNext: () {}),
      ),
    );

    // Capture-only: teal/green target so low-score shots aren't pink/lilac.
    const lowTarget = MixColor(r: 18, g: 166, b: 118, alphaPercent: 88);
    final low = _resultWithScore(lowTarget, 40);
    await shoot(
      '07-round-result-low',
      _Game(
        round: 1,
        score: low.score,
        child: RoundResultView(result: low, isLastRound: false, onNext: () {}),
      ),
    );

    const endScores = [84, 91, 67, 98, 76];
    final endResults = [
      for (var i = 0; i < targets.length; i++)
        _resultWithScore(targets[i], endScores[i]),
    ];
    final endTotal = endResults.fold<int>(0, (s, r) => s + r.score);
    await shoot(
      '08-game-end',
      GameFrame(
        child: GameEndView(
          total: endTotal,
          maxTotal: GameRules.maxGameScore,
          best: endTotal,
          isNewBest: true,
          entries: stripEntries(endResults),
          onHome: () {},
          onPlayAgain: () {},
        ),
      ),
    );

    const howToProgress = [0.42, 0.32, 1.0, 1.0];
    for (var i = 0; i < HowToPlayScreen.stepCount; i++) {
      await shoot(
        '09-howto-step${i + 1}',
        HowToPlayScreen(initialPage: i, demoProgress: howToProgress[i]),
      );
    }

    await shoot('10-settings', SettingsScreen(versionOverride: '0.1.0 (1)'));
  });
}

class _Game extends StatelessWidget {
  const _Game({required this.round, required this.score, required this.child});

  final int round;
  final int score;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GameFrame(
      header: GameHeader(
        roundNumber: round,
        roundCount: GameRules.roundsPerGame,
        score: score,
        onClose: () {},
      ),
      child: child,
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.bannerWidth,
      height: AppSizes.bannerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bannerPlaceholder,
        borderRadius: BorderRadius.circular(AppRadii.swatchSmall),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        AppLocalizations.of(context).adPlaceholder.upperFor(context),
        style: AppText.caption,
      ),
    );
  }
}

RoundResult _resultWithScore(MixColor target, int wanted) {
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
  final engine = MatchEngine(targets: [target]);
  return engine.submit(best!);
}

Future<AppServices> _services(WidgetTester tester) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: 'tr',
    AppPrefsKeys.onboardingDone: true,
    AppPrefsKeys.bestMemory: _bestScore,
  });
  final services = AppServices(
    settings: SettingsService(),
    stats: StatsService(),
    ads: AdService(),
    clock: () => _today,
  );
  await tester.runAsync(services.load);
  return services;
}

void _setView(WidgetTester tester) {
  tester.view.physicalSize = _physical;
  tester.view.devicePixelRatio = _dpr;
  tester.view.padding = const FakeViewPadding(
    top: _topInsetDp * _dpr,
    bottom: _bottomInsetDp * _dpr,
  );
  tester.view.viewPadding = const FakeViewPadding(
    top: _topInsetDp * _dpr,
    bottom: _bottomInsetDp * _dpr,
  );
  addTearDown(tester.view.reset);
}

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');

  Future<ByteData> bytes(String path) async =>
      ByteData.sublistView(await File(path).readAsBytes());

  final icons = FontLoader('MaterialIcons')
    ..addFont(
      bytes(
        '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ),
    );
  await icons.load();

  final baloo = FontLoader('Baloo2');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    baloo.addFont(bytes('assets/fonts/Baloo2-$w.ttf'));
  }
  await baloo.load();

  await (FontLoader(
    'Chewy',
  )..addFont(bytes('assets/fonts/Chewy-Regular.ttf'))).load();

  final roboto = FontLoader('Roboto')
    ..addFont(bytes('assets/fonts/Baloo2-Medium.ttf'));
  await roboto.load();
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  final bytes = await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
  final file = File(path)..parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}
