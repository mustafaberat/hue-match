/// Oyun sonu (§4.4): toplam / 500, en iyi, yeni rekor vurgusu, 5 tur şeridi.
library;

import 'package:flutter/material.dart';

import '../components/buttons.dart';
import '../components/round_strip.dart';
import '../components/shrink_to_fit.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import '../components/l10n_format.dart';

class GameEndView extends StatelessWidget {
  const GameEndView({
    required this.total,
    required this.maxTotal,
    required this.best,
    required this.isNewBest,
    required this.entries,
    required this.onHome,
    this.onPlayAgain,
    this.isDaily = false,
    super.key,
  });

  final int total;
  final int maxTotal;
  final int best;
  final bool isNewBest;
  final List<StripEntry> entries;
  final VoidCallback onHome;

  /// Günlükte yok — günde tek skor.
  final VoidCallback? onPlayAgain;
  final bool isDaily;

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
                Text(
                  (isDaily ? l10n.dailyResultTitle : l10n.gameOverTitle)
                      .upperFor(context),
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpacing.xl),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total.toDouble()),
                  duration: AppDurations.resultCountUp,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('${value.round()}', style: AppText.displayHuge),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.outOf(maxTotal),
                          style: AppText.heading.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                isNewBest
                    ? const _NewBestChip()
                    : Text(l10n.bestScoreValue(best), style: AppText.body),
                const SizedBox(height: AppSpacing.huge),
                Text(l10n.rounds.upperFor(context), style: AppText.caption),
                const SizedBox(height: AppSpacing.lg),
                RoundStrip(entries: entries),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (onPlayAgain != null) ...[
          PrimaryButton(
            label: l10n.playAgain,
            icon: Icons.replay_rounded,
            onPressed: onPlayAgain,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: l10n.home,
            icon: Icons.home_outlined,
            onPressed: onHome,
          ),
        ] else
          PrimaryButton(
            label: l10n.home,
            icon: Icons.home_outlined,
            onPressed: onHome,
          ),
      ],
    );
  }
}

class _NewBestChip extends StatelessWidget {
  const _NewBestChip();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: AppSizes.iconSmall,
              color: AppColors.accent,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              l10n.newBest,
              style: AppText.small.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
