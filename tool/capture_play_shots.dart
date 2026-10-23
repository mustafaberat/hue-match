/// Play Store visuals: real HueMind UI + framed marketing stills.
///
/// Run: `APP_ROOT=. ../lib/scripts/generate_game_images.sh`
/// Out:
///   play/gorseller/{lang}/01-*.png          phone 1080×1920
///   play/gorseller/{lang}/tablet/01-*.png   tablet 1440×2560
///   play/gorseller/{lang}/feature.png       1024×500
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:hue_match/game/round_result_view.dart';
import 'package:hue_match/l10n/app_localizations.dart';
import 'package:hue_match/screens/home_screen.dart';
import 'package:hue_match/services/ad_service.dart';
import 'package:hue_match/services/settings_service.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size _phoneCanvas = Size(1080, 1920);
const Size _tabletCanvas = Size(1440, 2560);
const Size _featureCanvas = Size(1024, 500);
const String _outRoot = 'play/gorseller';

const List<String> _fontFallback = [
  'Hiragino Sans GB',
  'Hiragino Sans',
  'PingFang SC',
  'Apple SD Gothic Neo',
  'Apple Color Emoji',
];

const Map<String, Map<String, String>> _phoneSlogans = {
  'en': {
    'home': 'MIX FROM MEMORY',
    'mixer': 'MATCH THE COLOR',
    'practice': 'SEE AND MIX',
    'result': 'HOW CLOSE ARE YOU?',
    'end': 'FIVE ROUNDS TO 500',
  },
  'es': {
    'home': 'MÉZCLALO DE MEMORIA',
    'mixer': 'ACIERTO EL COLOR',
    'practice': 'MIRA Y MEZCLA',
    'result': '¿QUÉ TAN CERCA?',
    'end': 'CINCO RONDAS, 500',
  },
  'pt': {
    'home': 'MISTURE DE MEMÓRIA',
    'mixer': 'ACERTE A COR',
    'practice': 'VEJA E MISTURE',
    'result': 'QUÃO PERTO VOCÊ CHEGOU?',
    'end': 'CINCO RODADAS ATÉ 500',
  },
  'zh': {
    'home': '凭记忆调色',
    'mixer': '把颜色调准',
    'practice': '看着调色',
    'result': '有多接近？',
    'end': '五轮满分 500',
  },
  'ja': {
    'home': '記憶で色を作る',
    'mixer': '色を合わせる',
    'practice': '見ながら混ぜる',
    'result': 'どこまで近づいた？',
    'end': '5ラウンドで500点',
  },
  'de': {
    'home': 'AUS DEM GEDÄCHTNIS',
    'mixer': 'TRIFF DIE FARBE',
    'practice': 'SEHEN UND MISCHEN',
    'result': 'WIE NAH BIST DU?',
    'end': 'FÜNF RUNDEN AUF 500',
  },
  'fr': {
    'home': 'MÉLANGE DE MÉMOIRE',
    'mixer': 'VISÉ LA COULEUR',
    'practice': 'VOIS ET MÉLANGE',
    'result': 'SI PROCHE ?',
    'end': 'CINQ MANCHES, 500',
  },
  'ko': {
    'home': '기억으로 색을 맞춰',
    'mixer': '색을 맞추세요',
    'practice': '보면서 섞기',
    'result': '얼마나 가까웠나요?',
    'end': '5라운드, 500점',
  },
  'it': {
    'home': 'MESCOLA A MEMORIA',
    'mixer': 'INDOVINA IL COLORE',
    'practice': 'GUARDA E MESCOLA',
    'result': 'QUANTO SEI VICINO?',
    'end': 'CINQUE TURNI, 500',
  },
  'tr': {
    'home': 'HAFIZADAN KARIŞTIR',
    'mixer': 'RENGİ YAKALA',
    'practice': 'GÖR VE KARIŞTIR',
    'result': 'NE KADAR YAKINSIN?',
    'end': 'BEŞ TUR, 500 PUAN',
  },
};

const Map<String, String> _tabletSlogan = {
  'en': 'BUILT FOR BIG SCREENS',
  'es': 'PENSADO PARA PANTALLA GRANDE',
  'pt': 'FEITO PARA TELA GRANDE',
  'zh': '为大屏而生',
  'ja': '大画面向け',
  'de': 'FÜR GROSSE BILDSCHIRME',
  'fr': 'PENSÉ POUR GRAND ÉCRAN',
  'ko': '큰 화면에 최적화',
  'it': 'PER SCHERMI GRANDI',
  'tr': 'BÜYÜK EKRAN İÇİN',
};

const Map<String, String> _featureTagline = {
  'en': 'See it. Remember it. Mix it.',
  'es': 'Míralo. Recuérdalo. Mézclalo.',
  'pt': 'Veja. Lembre. Misture.',
  'zh': '看见。记住。调色。',
  'ja': '見て。覚えて。混ぜる。',
  'de': 'Sehen. Merken. Mischen.',
  'fr': 'Vois. Mémorise. Mélange.',
  'ko': '보고. 기억하고. 섞으세요.',
  'it': 'Guardalo. Ricordalo. Mescolalo.',
  'tr': 'Gör. Hatırla. Karıştır.',
};

final DateTime _today = DateTime(2026, 10, 19);
const double _homeHue = 205;
const int _bestScore = 412;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Play gorsellerini yaz (phone/tablet/feature)', (tester) async {
    await tester.runAsync(_loadFonts);

    final targets = MatchEngine.dailyTargets(_today);
    final revealTarget = targets[1];
    final midMix = MixColor(
      r: (revealTarget.r * 0.8).round(),
      g: (revealTarget.g * 0.9 + 20).round().clamp(0, 255),
      b: (revealTarget.b * 1.1).round().clamp(0, 255),
      alphaPercent: 82,
    );
    const practiceTarget = MixColor(r: 236, g: 150, b: 72, alphaPercent: 86);
    final high = _resultWithScore(targets[3], 92);
    const endScores = [84, 91, 67, 98, 76];
    final endResults = [
      for (var i = 0; i < targets.length; i++)
        _resultWithScore(targets[i], endScores[i]),
    ];
    final endTotal = endResults.fold<int>(0, (s, r) => s + r.score);

    for (final lang in AppLanguages.codes) {
      final phone = _phoneSlogans[lang]!;
      final shots = <_ShotSpec>[
        _ShotSpec(
          id: '01-home',
          slogan: phone['home']!,
          build: (_) => HomeScreen(
            hueOverride: _homeHue,
            bannerOverride: const _BannerPlaceholder(),
          ),
        ),
        _ShotSpec(
          id: '02-mixer',
          slogan: phone['mixer']!,
          build: (_) => _Game(
            round: 2,
            score: 87,
            child: MixerView(
              mode: GameMode.memory,
              target: revealTarget,
              mix: midMix,
              canReplay: true,
              showValues: true,
              onMixChanged: (_) {},
              onConfirm: () {},
              onReplay: () {},
            ),
          ),
        ),
        _ShotSpec(
          id: '03-practice',
          slogan: phone['practice']!,
          build: (_) => _Game(
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
        ),
        _ShotSpec(
          id: '04-result',
          slogan: phone['result']!,
          build: (_) => _Game(
            round: 4,
            score: 251 + high.score,
            child: RoundResultView(
              result: high,
              isLastRound: false,
              onNext: () {},
            ),
          ),
        ),
        _ShotSpec(
          id: '05-end',
          slogan: phone['end']!,
          build: (_) => GameFrame(
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
        ),
      ];

      for (final entry in shots) {
        await _shotFramed(
          tester,
          lang: lang,
          canvas: _phoneCanvas,
          outPath: '$_outRoot/$lang/${entry.id}.png',
          slogan: entry.slogan,
          buildPhone: entry.build,
        );
      }

      final tabletPitch = _tabletSlogan[lang]!;
      for (final entry in shots) {
        await _shotFramed(
          tester,
          lang: lang,
          canvas: _tabletCanvas,
          outPath: '$_outRoot/$lang/tablet/${entry.id}.png',
          slogan: tabletPitch,
          buildPhone: entry.build,
        );
      }

      await _shotFeature(tester, lang: lang, tagline: _featureTagline[lang]!);
    }
  }, timeout: const Timeout(Duration(minutes: 20)));
}

class _ShotSpec {
  const _ShotSpec({
    required this.id,
    required this.slogan,
    required this.build,
  });
  final String id;
  final String slogan;
  final Widget Function(BuildContext) build;
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
        style: AppText.caption.copyWith(fontFamilyFallback: _fontFallback),
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

Future<void> _loadFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  expect(root, isNotNull, reason: 'FLUTTER_ROOT yok');
  final dir = '$root/bin/cache/artifacts/material_fonts';
  final home = Platform.environment['HOME'] ?? '';

  Future<ByteData> fileBytes(String path) async {
    final file = File(path);
    expect(file.existsSync(), isTrue, reason: 'Font yok: $path');
    return ByteData.sublistView(await file.readAsBytes());
  }

  Future<void> load(String family, String path) async {
    final loader = FontLoader(family)..addFont(fileBytes(path));
    await loader.load();
  }

  Future<void> loadIfExists(String family, String path) async {
    if (File(path).existsSync()) await load(family, path);
  }

  await load('MaterialIcons', '$dir/MaterialIcons-Regular.otf');
  await load('Roboto', 'assets/fonts/Manrope-Medium.ttf');

  final body = FontLoader(AppFonts.body);
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    body.addFont(fileBytes('assets/fonts/Baloo2-$w.ttf'));
  }
  await body.load();

  await (FontLoader(
    AppFonts.display,
  )..addFont(fileBytes('assets/fonts/Chewy-Regular.ttf'))).load();

  // Widget test sistem fontunu kullanmaz; CJK ve emoji aksi halde □.
  await load(
    'Apple Color Emoji',
    '/System/Library/Fonts/Apple Color Emoji.ttc',
  );
  await load('Hiragino Sans GB', '/System/Library/Fonts/Hiragino Sans GB.ttc');
  await load('Hiragino Sans', '/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc');
  await load(
    'Apple SD Gothic Neo',
    '/System/Library/Fonts/AppleSDGothicNeo.ttc',
  );
  await loadIfExists('PingFang SC', '/System/Library/Fonts/PingFang.ttc');
  await loadIfExists(
    'CupertinoIcons',
    '$home/.pub-cache/hosted/pub.dev/cupertino_icons-1.0.9/assets/CupertinoIcons.ttf',
  );
}

Future<AppServices> _services(WidgetTester tester, String lang) async {
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues({
    AppPrefsKeys.language: lang,
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

Future<void> _shotFramed(
  WidgetTester tester, {
  required String lang,
  required Size canvas,
  required String outPath,
  required String slogan,
  required Widget Function(BuildContext) buildPhone,
}) async {
  _setView(tester, canvas);
  final frameKey = GlobalKey();
  const phoneLogical = Size(390, 844);
  final services = await _services(tester, lang);

  await tester.pumpWidget(
    RepaintBoundary(
      key: frameKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StoreFrame(
          slogan: slogan,
          phone: _phoneHost(phoneLogical, services, buildPhone),
        ),
      ),
    ),
  );
  await _pumpFrames(tester);
  await tester.pump(const Duration(milliseconds: 100));
  await _writePng(tester, frameKey, outPath);
  await tester.pumpWidget(const SizedBox.shrink());
}

Widget _phoneHost(
  Size phoneLogical,
  AppServices services,
  Widget Function(BuildContext) buildPhone,
) {
  final theme = _themeWithFallback();
  return MediaQuery(
    data: MediaQueryData(
      size: phoneLogical,
      devicePixelRatio: 1,
      padding: EdgeInsets.zero,
      viewPadding: EdgeInsets.zero,
      viewInsets: EdgeInsets.zero,
    ),
    child: SizedBox(
      width: phoneLogical.width,
      height: phoneLogical.height,
      child: AppScope(
        services: services,
        child: ListenableBuilder(
          listenable: services.settings,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            locale: Locale(services.settings.languageCode),
            supportedLocales: [
              for (final code in AppLanguages.codes) Locale(code),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return DefaultTextStyle.merge(
                style: const TextStyle(fontFamilyFallback: _fontFallback),
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: Builder(builder: buildPhone),
          ),
        ),
      ),
    ),
  );
}

ThemeData _themeWithFallback() {
  final base = buildAppTheme();
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamilyFallback: _fontFallback),
    primaryTextTheme: base.primaryTextTheme.apply(
      fontFamilyFallback: _fontFallback,
    ),
  );
}

Future<void> _shotFeature(
  WidgetTester tester, {
  required String lang,
  required String tagline,
}) async {
  _setView(tester, _featureCanvas);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _FeatureGraphic(tagline: tagline),
      ),
    ),
  );
  await tester.pump();
  await _writePng(tester, key, '$_outRoot/$lang/feature.png');
  await tester.pumpWidget(const SizedBox.shrink());
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void _setView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding.zero;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPadding);
}

Future<Uint8List?> _pngBytes(WidgetTester tester, GlobalKey key) {
  return tester.binding.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data!.buffer.asUint8List();
  });
}

Future<void> _writePng(WidgetTester tester, GlobalKey key, String path) async {
  final bytes = await _pngBytes(tester, key);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
}

class _StoreFrame extends StatelessWidget {
  const _StoreFrame({required this.slogan, required this.phone});

  final String slogan;
  final Widget phone;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFD6EAF8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(
              color: const Color(0xFF7EC8E8).withValues(alpha: 0.55),
              size: 320,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -80,
            child: _GlowBlob(
              color: const Color(0xFFA8D8F0).withValues(alpha: 0.5),
              size: 280,
            ),
          ),
          Positioned(
            top: 220,
            left: 40,
            child: Transform.rotate(
              angle: -0.28,
              child: Icon(
                Icons.palette_outlined,
                size: 72,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
          Positioned(
            bottom: 180,
            right: 36,
            child: Icon(
              Icons.tonality,
              size: 64,
              color: AppColors.accent.withValues(alpha: 0.45),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 28, 36, 40),
              child: Column(
                children: [
                  Text(
                    slogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontFamilyFallback: _fontFallback,
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B2A4A),
                      letterSpacing: 0.6,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 9 / 19.5,
                        child: _DeviceBezel(child: phone),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBezel extends StatelessWidget {
  const _DeviceBezel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: const Color(0xFF2A2A32), width: 10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2A4A).withValues(alpha: 0.28),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({required this.tagline});
  final String tagline;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(
            left: -40,
            top: -60,
            child: _GlowBlob(color: Color(0x33FF7A59), size: 280),
          ),
          const Positioned(
            right: -20,
            bottom: -80,
            child: _GlowBlob(color: Color(0x224C8DFF), size: 260),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Row(
              children: [
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                const SizedBox(width: 36),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HueMind',
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontFamilyFallback: _fontFallback,
                          fontSize: 64,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.0,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tagline,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontFamilyFallback: _fontFallback,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
