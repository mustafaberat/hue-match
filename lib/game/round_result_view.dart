/// Tur sonucu (§4.3): yan yana kareler, büyük puan + etiket, kanal farkları.
library;

import 'package:flutter/material.dart';

import '../components/buttons.dart';
import '../components/l10n_format.dart';
import '../components/result_pair.dart';
import '../components/shrink_to_fit.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../l10n/app_localizations.dart';

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
                ),
                const SizedBox(height: AppSpacing.huge),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: result.score.toDouble()),
                  duration: AppDurations.resultCountUp,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) =>
                      Text('${value.round()}', style: AppText.displayHuge),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.scoreLabel(result.label), style: AppText.label),
                if (result.replayUsed) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.replayPenaltyApplied, style: AppText.small),
                ],
                const SizedBox(height: AppSpacing.xxxl),
                Text(l10n.diffTitle.upperFor(context), style: AppText.caption),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final diff in result.diffs)
                      _DiffChip(
                        text: l10n.diffText(diff),
                        highlighted: diff.highlighted,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: isLastRound ? l10n.seeSummary : l10n.nextRound,
          icon: Icons.arrow_forward_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _DiffChip extends StatelessWidget {
  const _DiffChip({required this.text, required this.highlighted});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: highlighted ? AppColors.surfaceHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: highlighted ? AppColors.outlineStrong : AppColors.outline,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Text(
          text,
          style: AppText.number.copyWith(
            fontSize: AppText.small.fontSize,
            color: highlighted ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
