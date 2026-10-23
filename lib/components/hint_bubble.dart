import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/tokens.dart';

/// Tek seferlik coach mark; alttaki hedefi oku ile gösterir.
class HintBubble extends StatelessWidget {
  const HintBubble({
    required this.text,
    required this.actionLabel,
    required this.onAction,
    this.arrowFraction = 0.5,
    super.key,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  /// Okun yatay konumu (0 sol, 1 sağ).
  final double arrowFraction;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSizes.hintMaxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.hintBubble,
              borderRadius: BorderRadius.circular(AppRadii.swatchSmall),
              boxShadow: [
                BoxShadow(
                  color: AppColors.sliderThumbShadow,
                  blurRadius: AppSpacing.xxl,
                  offset: const Offset(0, AppSpacing.sm),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.brightness_6_rounded,
                    size: AppSizes.icon,
                    color: AppColors.onHintBubble,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      text,
                      style: AppText.small.copyWith(
                        color: AppColors.onHintBubble,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.accentPressed,
                      textStyle: AppText.small.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(actionLabel),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment(arrowFraction * 2 - 1, 0),
            child: CustomPaint(
              size: const Size(AppSizes.hintArrow * 2, AppSizes.hintArrow),
              painter: _ArrowPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.hintBubble);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
