/// Hafıza modu gösterimi (§4.1): büyük hedef kare + ince azalan süre çubuğu.
library;

import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../components/color_swatch.dart';
import '../components/reveal_bar.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';

class RevealView extends StatelessWidget {
  const RevealView({required this.target, required this.remaining, super.key});

  final MixColor target;

  /// 1 → 0; gösterimin kalan oranı.
  final double remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = constraints.maxWidth.clamp(
                0.0,
                constraints.maxHeight,
              );
              return Center(
                child: SizedBox.square(
                  dimension: side,
                  child: ColorSwatchBox(color: target.displayColor),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: AppSizes.memoryDock,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              RevealBar(remaining: remaining),
              const SizedBox(height: AppSpacing.lg),
              Text(l10n.revealPrompt, style: AppText.body),
            ],
          ),
        ),
      ],
    );
  }
}
