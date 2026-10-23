import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';
import 'buttons.dart';

/// "Tur 2/5 ······ Puan 164" + kapat. Tur ilerlemesi ince segmentlerle.
class GameHeader extends StatelessWidget {
  const GameHeader({
    required this.roundNumber,
    required this.roundCount,
    required this.score,
    required this.onClose,
    this.badge,
    super.key,
  });

  final int roundNumber;
  final int roundCount;
  final int score;
  final VoidCallback? onClose;

  /// Örn. "Günlük · 19 Eki".
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      height: AppSizes.topBarHeight,
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.close_rounded,
            onPressed: onClose,
            tooltip: l10n.home,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [l10n.roundOf(roundNumber, roundCount), ?badge].join('  ·  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.onSky(AppText.small),
                ),
                const SizedBox(height: AppSpacing.sm),
                RoundProgress(current: roundNumber, total: roundCount),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(l10n.scoreValue(score), style: AppText.onSky(AppText.number)),
        ],
      ),
    );
  }
}

class RoundProgress extends StatelessWidget {
  const RoundProgress({required this.current, required this.total, super.key});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (var i = 1; i <= total; i++) ...[
            AnimatedContainer(
              duration: AppDurations.medium,
              width: AppSizes.roundSegmentWidth,
              height: AppSizes.roundSegmentHeight,
              decoration: BoxDecoration(
                color: i < current
                    ? AppColors.textSecondary
                    : i == current
                    ? AppColors.accent
                    : AppColors.outlineStrong,
                borderRadius: BorderRadius.circular(AppRadii.track),
              ),
            ),
            if (i < total) const SizedBox(width: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
