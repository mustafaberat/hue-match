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
    fontFamilyFallback: AppFonts.fallback,
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _CountingScore(score: score, reduce: reduce),
            ),
          ),
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

/// Dört kanal. Hedef: içi boş çentik; Sen: aynı biçimde dolu siyah.
class _CompareTracks extends StatelessWidget {
  const _CompareTracks({required this.target, required this.player});

  final MixColor target;
  final MixColor player;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const ValueKey('compareTracks'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _CompareNotch(filled: false),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.target, style: AppText.onSky(AppText.small)),
            const SizedBox(width: AppSpacing.xl),
            const _CompareNotch(filled: true),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.you, style: AppText.onSky(AppText.small)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final channel in MixChannel.values)
          _CompareTrack(channel: channel, target: target, player: player),
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
                  const youW = AppSizes.compareNotchWidth;
                  const youH = AppSizes.compareNotchHeight;
                  const tgtW = AppSizes.compareTargetNotchWidth;
                  const tgtH = AppSizes.compareTargetNotchHeight;
                  final usable = constraints.maxWidth - tgtW;
                  double at(int value) =>
                      tgtW / 2 + usable * (value / channel.max);
                  final youX = at(channel.valueOf(player));
                  final targetX = at(channel.valueOf(target));
                  final trackTop =
                      (_compareRowHeight - AppSizes.sliderTrackHeight) / 2;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: trackTop,
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
                        left: youX - youW / 2,
                        top: (_compareRowHeight - youH) / 2,
                        child: const _CompareNotch(filled: true),
                      ),
                      Positioned(
                        left: targetX - tgtW / 2,
                        top: (_compareRowHeight - tgtH) / 2,
                        child: const _CompareNotch(filled: false),
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

const double _compareRowHeight =
    AppSizes.compareTargetNotchHeight + AppSpacing.sm;

class _CompareNotch extends StatelessWidget {
  const _CompareNotch({required this.filled});

  final bool filled;

  Size get _size => filled
      ? const Size(AppSizes.compareNotchWidth, AppSizes.compareNotchHeight)
      : const Size(
          AppSizes.compareTargetNotchWidth,
          AppSizes.compareTargetNotchHeight,
        );

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: _size,
      painter: _NotchPainter(filled: filled),
    );
  }
}

/// Sen = dolu siyah; Hedef = biraz büyük, içi gerçekten boş. Hale dışarıda.
class _NotchPainter extends CustomPainter {
  _NotchPainter({required this.filled});

  final bool filled;

  static const Color _ink = Color(0xFF1A1A1A);
  static const Color _halo = Color(0xF2FFF8E8);

  @override
  void paint(Canvas canvas, Size size) {
    const strokeW = AppSizes.compareNotchStroke;
    const haloW = AppSizes.compareNotchHalo;
    final pad = haloW + strokeW / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad, pad, size.width - pad * 2, size.height - pad * 2),
      const Radius.circular(AppSizes.compareNotchRadius),
    );
    canvas.drawRRect(
      rrect.inflate(strokeW / 2 + haloW / 2),
      Paint()
        ..color = _halo
        ..style = PaintingStyle.stroke
        ..strokeWidth = haloW
        ..strokeJoin = StrokeJoin.round,
    );
    if (filled) {
      canvas.drawRRect(rrect, Paint()..color = _ink);
    }
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = _ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_NotchPainter old) => old.filled != filled;
}
