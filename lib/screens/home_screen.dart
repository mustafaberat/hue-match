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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowHowTo());
  }

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

  Future<void> _maybeShowHowTo() async {
    final settings = AppScope.of(context).settings;
    if (settings.howToSeen || !mounted) return;
    await settings.setHowToSeen(true);
    if (mounted) _openHowTo();
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

    return Scaffold(
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
                listenable: Listenable.merge([settings, services.stats]),
                builder: (context, _) {
                  final best = services.stats.bestFor(settings.mode);
                  return Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Expanded(
                        child: ShrinkToFit(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HueSquare(
                                animation: _hue,
                                hueOverride: widget.hueOverride,
                              ),
                              const SizedBox(
                                height: AppSpacing.xxxl + AppSpacing.sm,
                              ),
                              Text(
                                l10n.appTitle,
                                textAlign: TextAlign.center,
                                style: AppText.title,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                l10n.homeTagline,
                                textAlign: TextAlign.center,
                                style: AppText.body,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Segmented<GameMode>(
                        options: {
                          GameMode.memory: l10n.modeMemory,
                          GameMode.practice: l10n.modePractice,
                        },
                        selected: settings.mode,
                        onChanged: settings.setMode,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        settings.mode == GameMode.memory
                            ? l10n.modeMemoryHint(settings.revealSeconds)
                            : l10n.modePracticeHint,
                        textAlign: TextAlign.center,
                        style: AppText.small.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      PrimaryButton(
                        label: l10n.play,
                        icon: Icons.play_arrow_rounded,
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
                      const SizedBox(height: AppSpacing.xl),
                      _BestRow(best: best),
                      const SizedBox(height: AppSpacing.md),
                      widget.bannerOverride ?? const _HomeBanner(),
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

class _HueSquare extends StatelessWidget {
  const _HueSquare({required this.animation, this.hueOverride});

  final Animation<double> animation;
  final double? hueOverride;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = [
          AppSizes.homeSwatch,
          constraints.maxWidth * AppSizes.homeSwatchMaxFraction,
        ].reduce((a, b) => a < b ? a : b);
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final hue =
                hueOverride ?? animation.value * HomeSwatchStyle.fullTurn;
            final color = oklchToRgbGamutMapped(
              Oklch(HomeSwatchStyle.lightness, HomeSwatchStyle.chroma, hue),
            ).toColor();
            return SizedBox.square(
              dimension: side,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.stage,
                  borderRadius: BorderRadius.circular(AppRadii.stage),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ColorSwatchBox(color: color),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BestRow extends StatelessWidget {
  const _BestRow({required this.best});

  final int best;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.emoji_events_outlined,
          size: AppSizes.iconSmall,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        if (best > 0) ...[
          Text(l10n.bestScore, style: AppText.small),
          const SizedBox(width: AppSpacing.sm),
          Text('$best', style: AppText.number),
          const SizedBox(width: AppSpacing.xs),
          Text(
            l10n.outOf(GameRules.maxGameScore),
            style: AppText.small.copyWith(color: AppColors.textMuted),
          ),
        ] else
          Text(l10n.noBestYet, style: AppText.small),
      ],
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
