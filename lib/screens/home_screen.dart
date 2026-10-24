/// Home: yavaşça hue değiştiren tek kare, mod, Oyna, Ayarlar, Nasıl oynanır.
/// Altta banner — oyunun başka hiçbir yerinde banner yok.
library;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../app_scope.dart';
import '../color/oklab.dart';
import '../components/buttons.dart';
import '../components/color_swatch.dart';
import '../components/segmented.dart';
import '../components/shrink_to_fit.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../game/game_screen.dart';
import '../l10n/app_localizations.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.hueOverride, this.bannerOverride, super.key});

  /// Sabit hue (derece) — ekran görüntüsü için animasyonu durdurur.
  final double? hueOverride;

  /// Banner yerine gösterilecek widget (ekran görüntüsü yer tutucu).
  final Widget? bannerOverride;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hue = AnimationController(
    vsync: this,
    duration: AppDurations.homeHueCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.hueOverride != null || reduceMotion) {
      _hue.stop();
    } else if (!_hue.isAnimating) {
      _hue.repeat();
    }
  }

  @override
  void dispose() {
    _hue.dispose();
    super.dispose();
  }

  void _openHowTo() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const HowToPlayScreen(),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _play() {
    final settings = AppScope.of(context).settings;
    Navigator.of(context).push(
      gameRoute(
        MatchEngine.random(
          mode: settings.mode,
          colorBlindSafe: settings.colorBlindMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final services = AppScope.of(context);
    final settings = services.settings;

    return ThemedScaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.md,
              ),
              child: ListenableBuilder(
                listenable: Listenable.merge([settings, services.stats, _hue]),
                builder: (context, _) {
                  final best = services.stats.bestFor(settings.mode);
                  final hue =
                      widget.hueOverride ??
                      _hue.value * HomeSwatchStyle.fullTurn;
                  final swatch = homeSwatchColor(hue);
                  return Column(
                    children: [
                      Expanded(
                        child: ShrinkToFit(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HueSquare(color: swatch),
                              const SizedBox(height: AppSpacing.lg),
                              PlayfulTitle(l10n.appTitle),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.homeTagline,
                                textAlign: TextAlign.center,
                                style: AppText.onSky(AppText.body),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // Skor yokken de aynı yeri kaplar (hayalet):
                              // mod değişince başlık ve butonlar kaymaz.
                              Visibility(
                                key: const ValueKey('home-best-score'),
                                visible: best > 0,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SkyCaption(l10n.bestScore),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '$best ${l10n.outOf(GameRules.maxGameScore)}',
                                      textAlign: TextAlign.center,
                                      style: AppText.onSky(AppText.number),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Segmented<GameMode>(
                                options: {
                                  GameMode.memory: l10n.modeMemory,
                                  GameMode.practice: l10n.modePractice,
                                },
                                selected: settings.mode,
                                onChanged: settings.setMode,
                                selectedColor: swatch,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              // İki ipucu üst üste: yükseklik her zaman
                              // uzun olanınki, satır sayısı farkı kaydırmaz.
                              Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  for (final mode in GameMode.values)
                                    Visibility(
                                      visible: settings.mode == mode,
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      child: SkyCaption(
                                        mode == GameMode.memory
                                            ? l10n.modeMemoryHint(
                                                settings.revealSeconds,
                                              )
                                            : l10n.modePracticeHint,
                                        style: AppText.small,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              PrimaryButton(
                                label: l10n.play,
                                icon: Icons.play_arrow_rounded,
                                color: swatch,
                                onPressed: _play,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SecondaryButton(
                                label: l10n.settings,
                                icon: Icons.tune_rounded,
                                onPressed: _openSettings,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SecondaryButton(
                                label: l10n.howToPlay,
                                icon: Icons.question_mark_rounded,
                                onPressed: _openHowTo,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: widget.bannerOverride ?? const _HomeBanner(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color homeSwatchColor(double hue) => oklchToRgbGamutMapped(
  Oklch(HomeSwatchStyle.lightness, HomeSwatchStyle.chroma, hue),
).toColor();

class _HueSquare extends StatelessWidget {
  const _HueSquare({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = [
          AppSizes.homeSwatch,
          constraints.maxWidth * AppSizes.homeSwatchMaxFraction,
        ].reduce((a, b) => a < b ? a : b);
        final mascotSize = AppSizes.mascotHome;
        final peek = mascotSize * AppSizes.homeMascotPeekFraction;
        final mascotCanvas = ThemeMascot.canvasSize(mascotSize);
        final boxW = side > mascotCanvas.width ? side : mascotCanvas.width;
        return SizedBox(
          height: side + peek,
          width: boxW,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned(
                top: 0,
                width: mascotCanvas.width,
                height: mascotCanvas.height,
                child: ThemeMascot(
                  mood: MascotMood.happy,
                  size: mascotSize,
                  bodyColor: color,
                ),
              ),
              Positioned(
                left: (boxW - side) / 2,
                top: peek,
                child: SizedBox.square(
                  dimension: side,
                  child: ColorSwatchBox(color: color),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeBanner extends StatelessWidget {
  const _HomeBanner();

  @override
  Widget build(BuildContext context) {
    final ads = AppScope.of(context).ads;
    return ListenableBuilder(
      listenable: ads,
      builder: (context, _) {
        final banner = ads.banner;
        if (banner == null) return const SizedBox.shrink();
        return SizedBox(
          width: banner.size.width.toDouble(),
          height: banner.size.height.toDouble(),
          child: AdWidget(ad: banner),
        );
      },
    );
  }
}
