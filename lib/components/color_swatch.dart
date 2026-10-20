import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../color/rgb.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import 'l10n_format.dart';

extension RgbColor on Rgb {
  Color toColor() => Color.fromARGB(0xFF, r8, g8, b8);
}

extension MixColorDisplay on MixColor {
  /// Siyah sahne üzerinde ekranda görünen renk (opak).
  Color get displayColor => visible.toColor();
}

/// Siyah sahnede ince nötr çerçeveli renk kutusu (§2).
class ColorSwatchBox extends StatelessWidget {
  const ColorSwatchBox({
    required this.color,
    this.caption,
    this.radius = AppRadii.swatch,
    super.key,
  });

  final Color color;
  final String? caption;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.swatchFrame,
          width: AppSizes.swatchFrameWidth,
        ),
      ),
      child: caption == null
          ? null
          : Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SwatchCaption(text: caption!),
              ),
            ),
    );
  }
}

/// Her renk üzerinde okunabilen küçük etiket.
class SwatchCaption extends StatelessWidget {
  const SwatchCaption({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.swatchCaptionScrim,
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.chip)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + AppSpacing.xxs,
        ),
        child: Text(
          text.upperFor(context),
          style: AppText.caption.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
