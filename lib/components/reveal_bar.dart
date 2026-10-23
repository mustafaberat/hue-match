import 'package:flutter/material.dart';

import '../config/tokens.dart';

/// İnce süre çubuğu, lineer azalır (§4.1). Geri sayım sayısı yok.
class RevealBar extends StatelessWidget {
  const RevealBar({required this.remaining, super.key});

  /// 1 → 0.
  final double remaining;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: AppSizes.revealBarWidthFraction,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.track),
        child: SizedBox(
          height: AppSizes.revealBarHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: AppColors.outlineStrong),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: remaining.clamp(0.0, 1.0),
                child: ColoredBox(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
