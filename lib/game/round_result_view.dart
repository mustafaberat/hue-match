/// Tur sonucu (§4.3): yan yana kareler, büyük puan + etiket, kanal farkları.
library;

import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../components/buttons.dart';
import '../components/color_swatch.dart';
import '../components/l10n_format.dart';
import '../components/result_pair.dart';
import '../components/shrink_to_fit.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../l10n/app_localizations.dart';
import 'channel_slider.dart';

class RoundResultView extends StatelessWidget {
  const RoundResultView({
    required this.result,
    required this.isLastRound,
    required this.onNext,
    super.key,
  });

  final RoundResult result;
  final bool isLastRound;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: ShrinkToFit(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ResultPair(
                  target: result.target,
                  player: result.player,
                  targetLabel: l10n.target,
                  playerLabel: l10n.you,
                  onBackdrop: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                _RoundScore(
                  score: result.score,
                  before: result.replayUsed ? result.scoreBeforeReplay : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                ThemeMascot(
                  mood: mascotMoodForScore(result.score),
                  bodyColor: result.player.displayColor,
                  size: AppSizes.mascotResult,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.closeness, style: AppText.onSky(AppText.label)),
                const SizedBox(height: AppSpacing.xl),
                _CompareTracks(target: result.target, player: result.player),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GradientButton(
          label: isLastRound ? l10n.seeSummary : l10n.nextRound,
          icon: Icons.arrow_forward_rounded,
          left: result.target.displayColor,
          right: result.player.displayColor,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// Sonuç her zaman ortada, aynı boyda. Show again varsa eski puan solda küçük.
class _RoundScore extends StatelessWidget {
  const _RoundScore({required this.score, required this.before});

  final int score;
  final int? before;

  static TextStyle get _aside => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1,
    letterSpacing: -0.4,
    color: AppColors.textOnBackdropMuted,
    shadows: AppShadows.onBackdrop,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final struck = before == null
        ? null
        : _StruckPercent(text: l10n.percent(before!), draw: !reduce);
    return Semantics(
      label: before == null
          ? l10n.percent(score)
          : '${l10n.percent(before!)} ${l10n.percent(score)}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxl),
                child: struck,
              ),
            ),
          ),
          _CountingScore(score: score, reduce: reduce),
          const Expanded(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}

class _CountingScore extends StatelessWidget {
  const _CountingScore({required this.score, required this.reduce});

  final int score;
  final bool reduce;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final end = Text(
      l10n.percent(score),
      style: AppText.onSky(AppText.displayHuge),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduce ? score.toDouble() : 0, end: score.toDouble()),
      duration: reduce ? Duration.zero : AppDurations.resultCountUp,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: child),
          Text(
            l10n.percent(value.round()),
            style: AppText.onSky(AppText.displayHuge),
          ),
        ],
      ),
      child: end,
    );
  }
}

class _StruckPercent extends StatelessWidget {
  const _StruckPercent({required this.text, required this.draw});

  final String text;
  final bool draw;

  @override
  Widget build(BuildContext context) {
    final number = Text(text, style: _RoundScore._aside);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: draw ? 0 : 1, end: 1),
      duration: draw ? AppDurations.slow : Duration.zero,
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Stack(
        alignment: Alignment.center,
        children: [
          child!,
          Positioned.fill(
            child: Align(
              child: FractionallySizedBox(
                widthFactor: t,
                alignment: Alignment.centerLeft,
                child: ColoredBox(
                  color: AppColors.accent,
                  child: const SizedBox(height: 2),
                ),
              ),
            ),
          ),
        ],
      ),
      child: number,
    );
  }
}

/// Dört kanal. Hedef çubuğun üstünde kısa çentik, sen çubuğu kesen çizgi.
class _CompareTracks extends StatelessWidget {
  const _CompareTracks({required this.target, required this.player});

  final MixColor target;
  final MixColor player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendMark(height: _tickHeight, label: l10n.target),
            const SizedBox(width: AppSpacing.xl),
            _LegendMark(height: _tickHeight * 2, label: l10n.you),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final channel in MixChannel.values)
          _CompareTrack(channel: channel, target: target, player: player),
      ],
    );
  }
}

class _LegendMark extends StatelessWidget {
  const _LegendMark({required this.height, required this.label});

  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GuideLine(height: height),
        const SizedBox(width: AppSpacing.sm),
        Text(label, style: AppText.onSky(AppText.small)),
      ],
    );
  }
}

class _CompareTrack extends StatelessWidget {
  const _CompareTrack({
    required this.channel,
    required this.target,
    required this.player,
  });

  final MixChannel channel;
  final MixColor target;
  final MixColor player;

  @override
  Widget build(BuildContext context) {
    final start = channel == MixChannel.a
        ? AppColors.mixBackdrop
        : channel.apply(player, 0).displayColor;
    final end = channel.apply(player, channel.max).displayColor;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: SizedBox(
        height: _compareRowHeight,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.sliderLabelWidth,
              child: Text(
                channel.letter,
                style: AppText.onSky(AppText.channelLetter),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final usable = constraints.maxWidth - _lineWidth;
                  double at(int value) =>
                      _lineWidth / 2 + usable * (value / channel.max);
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _tickHeight,
                        height: AppSizes.sliderTrackHeight,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadii.track),
                            border: Border.all(color: AppColors.outline),
                            gradient: LinearGradient(colors: [start, end]),
                          ),
                        ),
                      ),
                      Positioned(
                        left: at(channel.valueOf(player)) - _lineWidth / 2,
                        top: _tickHeight - _needleOverhang,
                        child: const _GuideLine(height: _needleHeight),
                      ),
                      Positioned(
                        left: at(channel.valueOf(target)) - _lineWidth / 2,
                        top: 0,
                        child: const _GuideLine(height: _tickHeight),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              width: AppSizes.sliderValueWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  channel.icon,
                  size: AppSizes.iconSmall,
                  color: channel.identity,
                  shadows: AppShadows.onBackdrop,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const double _lineWidth = 2;
const double _tickHeight = 8;
const double _needleOverhang = 6;
const double _needleHeight = AppSizes.sliderTrackHeight + _needleOverhang * 2;
const double _compareRowHeight =
    _tickHeight + AppSizes.sliderTrackHeight + _needleOverhang;

class _GuideLine extends StatelessWidget {
  const _GuideLine({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _lineWidth,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.sliderThumb,
        boxShadow: const [
          BoxShadow(color: Color(0xFF000000), blurRadius: 0, spreadRadius: 1),
        ],
      ),
    );
  }
}
