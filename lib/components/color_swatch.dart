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

/// Nötr paspartu + çerçeve; dolgu oyunun rengi (karar vermeyi bozmaz).
class ColorSwatchBox extends StatelessWidget {
  const ColorSwatchBox({
    required this.color,
    this.caption,
    this.radius,
    super.key,
  });

  final Color color;
  final String? caption;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? AppRadii.swatch;
    final mat = AppSizes.swatchMat;
    return AnimatedContainer(
      duration: AppDurations.fast,
      decoration: BoxDecoration(
        color: AppColors.stage,
        borderRadius: BorderRadius.circular(r),
        border: Border.fromBorderSide(AppBorders.swatch),
        boxShadow: AppShadows.card,
      ),
      padding: EdgeInsets.all(mat),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular((r - mat).clamp(4, r)),
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
      decoration: BoxDecoration(
        color: AppColors.swatchCaptionScrim,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.chip)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + AppSpacing.xxs,
        ),
        child: Text(
          text.upperFor(context),
          style: AppText.caption.copyWith(color: AppColors.onDark),
        ),
      ),
    );
  }
}
