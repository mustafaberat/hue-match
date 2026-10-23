import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import 'color_swatch.dart';
import 'l10n_format.dart';

/// Hedef ve oyuncu rengi yan yana, eşit kare (§4.3).
class ResultPair extends StatelessWidget {
  const ResultPair({
    required this.target,
    required this.player,
    required this.targetLabel,
    required this.playerLabel,
    this.maxSide = AppSizes.resultSwatchMax,
    this.onBackdrop = false,
    super.key,
  });

  final MixColor target;
  final MixColor player;
  final String targetLabel;
  final String playerLabel;
  final double maxSide;
  final bool onBackdrop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = ((constraints.maxWidth - AppSpacing.md) / 2).clamp(
          0.0,
          maxSide,
        );
        Widget cell(Color color, String label) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: side,
              child: ColorSwatchBox(color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            onBackdrop
                ? SkyCaption(label.upperFor(context))
                : Text(label.upperFor(context), style: AppText.caption),
          ],
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cell(target.displayColor, targetLabel),
            const SizedBox(width: AppSpacing.md),
            cell(player.displayColor, playerLabel),
          ],
        );
      },
    );
  }
}
