/// How to play (§8): gerçek bileşenlerle animasyonlu 4 adım.
/// Home "?" ve Ayarlar'dan açılır; ilk açılışta otomatik (Geç ile atlanır).
library;

import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../color/composite.dart';
import '../color/oklab.dart';
import '../color/scoring.dart';
import '../components/buttons.dart';
import '../components/color_swatch.dart';
import '../components/l10n_format.dart';
import '../components/result_pair.dart';
import '../components/reveal_bar.dart';
import '../components/round_strip.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../game/channel_slider.dart';
import '../game/game_screen.dart';
import '../l10n/app_localizations.dart';

/// Demo verileri — gerçek skor eğrisinden bağımsız, sabit örnekler.
abstract final class HowToDemo {
  static const MixColor target = MixColor(
    r: 64,
    g: 170,
    b: 160,
    alphaPercent: 100,
  );
  static const MixColor close = MixColor(
    r: 80,
    g: 176,
    b: 150,
    alphaPercent: 96,
  );
  static const int mixFromR = 40;
  static const int mixToR = 220;
  static const MixColor mixBase = MixColor(
    r: 40,
    g: 120,
    b: 190,
    alphaPercent: 90,
  );
  static const int resultScore = 87;
  static const int total = 412;
  static const List<int> stripScores = [92, 78, 64, 95, 83];
  static const List<Oklch> stripHues = [
    Oklch(0.68, 0.14, 20),
    Oklch(0.80, 0.12, 95),
    Oklch(0.55, 0.06, 240),
    Oklch(0.62, 0.15, 150),
    Oklch(0.50, 0.16, 300),
  ];

  /// Şeritte "sen" yarısı için küçük sapma.
  static const double stripLightnessOffset = 0.04;

  static const double revealSwatch = 240;
  static const double mixSwatchHeight = 132;
  static const double resultSwatch = 140;
  static const double handOffsetX = 14;
  static const double handOffsetY = 6;
}

class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({this.initialPage = 0, this.demoProgress, super.key});

  final int initialPage;

  /// Sabit demo karesi (0–1) — ekran görüntüsünde animasyonu dondurur.
  final double? demoProgress;

  static const int stepCount = 4;

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pages = PageController(
    initialPage: widget.initialPage,
  );
  late final AnimationController _demo = AnimationController(
    vsync: this,
    duration: AppDurations.howToLoop,
  );
  late int _page = widget.initialPage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final frozen =
        widget.demoProgress != null || MediaQuery.disableAnimationsOf(context);
    if (frozen) {
      _demo.value = widget.demoProgress ?? 1;
      _demo.stop();
    } else if (!_demo.isAnimating) {
      _demo.repeat();
    }
  }

  @override
  void dispose() {
    _pages.dispose();
    _demo.dispose();
    super.dispose();
  }

  bool get _isLast => _page == HowToPlayScreen.stepCount - 1;

  void _next() => _pages.nextPage(
    duration: AppDurations.medium,
    curve: Curves.easeOutCubic,
  );

  void _close() => Navigator.of(context).maybePop();

  void _playNow() {
    final settings = AppScope.of(context).settings;
    final navigator = Navigator.of(context);
    navigator.popUntil((route) => route.isFirst);
    navigator.push(
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
    final steps = [
      (l10n.howToStep1Title, l10n.howToStep1Body),
      (l10n.howToStep2Title, l10n.howToStep2Body),
      (l10n.howToStep3Title, l10n.howToStep3Body),
      (l10n.howToStep4Title, l10n.howToStep4Body),
    ];

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
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: AppSizes.iconButton,
                    child: Row(
                      children: [
                        _PageDots(
                          count: HowToPlayScreen.stepCount,
                          current: _page,
                        ),
                        const Spacer(),
                        if (!_isLast)
                          TextButton(
                            onPressed: _close,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              textStyle: AppText.bodyStrong,
                            ),
                            child: Text(l10n.howToSkip),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: steps.length,
                      onPageChanged: (p) => setState(() => _page = p),
                      itemBuilder: (context, index) => _Step(
                        index: index,
                        title: steps[index].$1,
                        body: steps[index].$2,
                        demo: AnimatedBuilder(
                          animation: _demo,
                          builder: (context, _) => _demoFor(index, _demo.value),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_isLast) ...[
                    PrimaryButton(
                      label: l10n.playNow,
                      icon: Icons.play_arrow_rounded,
                      onPressed: _playNow,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SecondaryButton(label: l10n.close, onPressed: _close),
                  ] else
                    PrimaryButton(
                      label: l10n.howToNext,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoFor(int index, double t) => switch (index) {
    0 => _RememberDemo(t: t),
    1 => _MixDemo(t: t),
    2 => _ResultDemo(t: t),
    _ => _StripDemo(t: t),
  };
}

class _Step extends StatelessWidget {
  const _Step({
    required this.index,
    required this.title,
    required this.body,
    required this.demo,
  });

  final int index;
  final String title;
  final String body;
  final Widget demo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.stage,
                borderRadius: BorderRadius.circular(AppRadii.stage),
                border: Border.all(color: AppColors.outline),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: LayoutBuilder(
                  builder: (context, box) => Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(width: box.maxWidth, child: demo),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Text(
          '${index + 1} / ${HowToPlayScreen.stepCount}',
          style: AppText.caption.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: AppText.title),
        const SizedBox(height: AppSpacing.md),
        Text(body, style: AppText.body),
      ],
    );
  }
}

class _RememberDemo extends StatelessWidget {
  const _RememberDemo({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: HowToDemo.revealSwatch,
          child: ColorSwatchBox(color: HowToDemo.target.displayColor),
        ),
        const SizedBox(height: AppSpacing.xxl),
        RevealBar(remaining: 1 - t),
      ],
    );
  }
}

class _MixDemo extends StatelessWidget {
  const _MixDemo({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final eased = Curves.easeInOutCubic.transform(
      t < 0.5 ? t * 2 : (1 - t) * 2,
    );
    final r =
        (HowToDemo.mixFromR + (HowToDemo.mixToR - HowToDemo.mixFromR) * eased)
            .round();
    final mix = HowToDemo.mixBase.copyWith(r: r);

    Widget slider(MixChannel c) =>
        ChannelSlider(channel: c, mix: mix, onChanged: (_) {}, enabled: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth =
            constraints.maxWidth -
            AppSizes.sliderLabelWidth -
            AppSizes.sliderValueWidth;
        final thumbX =
            AppSizes.sliderLabelWidth +
            AppSizes.sliderThumb / 2 +
            (trackWidth - AppSizes.sliderThumb) * r / MixerRules.channelMax;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: HowToDemo.mixSwatchHeight,
                  width: double.infinity,
                  child: ColorSwatchBox(color: mix.displayColor),
                ),
                const SizedBox(height: AppSpacing.md),
                slider(MixChannel.r),
                slider(MixChannel.g),
                slider(MixChannel.b),
                slider(MixChannel.a),
              ],
            ),
            Positioned(
              left: thumbX - HowToDemo.handOffsetX,
              top:
                  HowToDemo.mixSwatchHeight +
                  AppSpacing.md +
                  AppSizes.sliderRowHeight / 2 +
                  HowToDemo.handOffsetY,
              child: const IgnorePointer(
                child: Icon(
                  Icons.touch_app_rounded,
                  size: AppSizes.handIcon,
                  color: AppColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: AppColors.sliderThumbShadow,
                      blurRadius: AppSpacing.sm,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultDemo extends StatelessWidget {
  const _ResultDemo({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shown = (HowToDemo.resultScore * Curves.easeOutCubic.transform(t))
        .round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ResultPair(
          target: HowToDemo.target,
          player: HowToDemo.close,
          targetLabel: l10n.target,
          playerLabel: l10n.you,
          maxSide: HowToDemo.resultSwatch,
        ),
        const SizedBox(height: AppSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$shown', style: AppText.displayLarge),
            const SizedBox(width: AppSpacing.md),
            Text(
              l10n.scoreLabel(labelFor(HowToDemo.resultScore)),
              style: AppText.label.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}

class _StripDemo extends StatelessWidget {
  const _StripDemo({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = [
      for (var i = 0; i < HowToDemo.stripScores.length; i++)
        StripEntry(
          target: _mixFrom(HowToDemo.stripHues[i]),
          player: _mixFrom(
            Oklch(
              HowToDemo.stripHues[i].l + HowToDemo.stripLightnessOffset,
              HowToDemo.stripHues[i].c,
              HowToDemo.stripHues[i].h,
            ),
          ),
          score: HowToDemo.stripScores[i],
        ),
    ];
    final shown = (HowToDemo.total * Curves.easeOutCubic.transform(t)).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RoundStrip(entries: entries, dotSize: AppSizes.stripDotSmall),
        const SizedBox(height: AppSpacing.xxxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('$shown', style: AppText.displayLarge),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.outOf(GameRules.maxGameScore),
              style: AppText.heading.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  static MixColor _mixFrom(Oklch lch) {
    final rgb = oklchToRgbGamutMapped(lch);
    return MixColor(
      r: rgb.r8,
      g: rgb.g8,
      b: rgb.b8,
      alphaPercent: MixerRules.alphaMax,
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          AnimatedContainer(
            duration: AppDurations.medium,
            width: i == current ? AppSizes.pageDotActive : AppSizes.pageDot,
            height: AppSizes.pageDot,
            decoration: BoxDecoration(
              color: i == current ? AppColors.accent : AppColors.outlineStrong,
              borderRadius: BorderRadius.circular(AppRadii.track),
            ),
          ),
          if (i < count - 1)
            const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
        ],
      ],
    );
  }
}
