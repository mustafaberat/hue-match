import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import 'color_swatch.dart';

class StripEntry {
  const StripEntry({
    required this.target,
    required this.player,
    required this.score,
  });

  final MixColor target;
  final MixColor player;
  final int score;
}

/// 5 turun mini şeridi: hedef | sen yarım-yarım daire + puan (§4.4).
class RoundStrip extends StatelessWidget {
  const RoundStrip({
    required this.entries,
    this.dotSize = AppSizes.stripDot,
    this.onBackdrop = false,
    super.key,
  });

  final List<StripEntry> entries;
  final double dotSize;
  final bool onBackdrop;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final entry in entries)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SplitDot(
                left: entry.target.displayColor,
                right: entry.player.displayColor,
                size: dotSize,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${entry.score}',
                style: onBackdrop
                    ? AppText.onSky(AppText.number)
                    : AppText.number,
              ),
            ],
          ),
      ],
    );
  }
}

class SplitDot extends StatelessWidget {
  const SplitDot({
    required this.left,
    required this.right,
    required this.size,
    super.key,
  });

  final Color left;
  final Color right;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SplitDotPainter(left, right),
    );
  }
}

class _SplitDotPainter extends CustomPainter {
  _SplitDotPainter(this.left, this.right);

  final Color left;
  final Color right;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawArc(rect, math.pi / 2, math.pi, true, Paint()..color = left);
    canvas.drawArc(rect, -math.pi / 2, math.pi, true, Paint()..color = right);
    canvas.drawCircle(
      rect.center,
      size.width / 2,
      Paint()
        ..color = AppColors.swatchFrame
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.swatchFrameWidth,
    );
  }

  @override
  bool shouldRepaint(_SplitDotPainter old) =>
      old.left != left || old.right != right;
}
