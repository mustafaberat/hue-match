/// Boya kalemi maskot — CustomPainter, ifade skora göre değişir.
///
/// Düşük skor yüzü asla kızgın değil: kalkık kaş, minik üzgün-gülümseme, ter.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

/// Wax this dark reads gloomy; lift value and add a light rim.
const double _darkWaxLuminance = 0.14;

bool crayonNeedsCheer(Color color) =>
    color.computeLuminance() < _darkWaxLuminance;

/// Keep hue; lift very dark tints so the crayon stays cheerful and readable.
Color cheerfulCrayonTint(Color color) {
  if (!crayonNeedsCheer(color)) return color;
  final hsv = HSVColor.fromColor(color);
  var hue = hsv.hue;
  var sat = hsv.saturation;
  if (sat < 0.20) {
    sat = 0.55;
    if (hsv.value < 0.15) hue = 275;
  } else {
    sat = (sat * 0.92).clamp(0.48, 0.82);
  }
  return HSVColor.fromAHSV(1, hue, sat, 0.74).toColor();
}

class ThemeMascot extends StatelessWidget {
  const ThemeMascot({
    required this.mood,
    this.size = AppSizes.mascot,
    this.bodyColor,
    super.key,
  });

  final MascotMood mood;
  final double size;
  final Color? bodyColor;

  /// Silüete göre tuval — home yerleşimi taşmadan bunu kullanır.
  static Size canvasSize(double size) => Size(size * 0.78, size);

  /// Tuvalin solundaki boşluk — home overlap bunu ekler ki gövde çerçeveye değsin.
  static double homeLeftInset(double size) => canvasSize(size).width * 0.12;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: canvasSize(size),
        painter: CrayonBuddyPainter(mood: mood, tint: bodyColor),
      ),
    );
  }
}

/// Boya kalemi: sivri renkli uç, kâğıt sargı, dalgalı etiket, minik kollar.
class CrayonBuddyPainter extends CustomPainter {
  CrayonBuddyPainter({required this.mood, this.tint});

  final MascotMood mood;
  final Color? tint;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ink = const Color(0xFF3E2A1A);
    final sw = math.max(2.4, w * 0.032);
    final stroke = _inkStroke(ink, sw);
    final rawWax = tint ?? const Color(0xFF2B6CFF);
    final darkWax = crayonNeedsCheer(rawWax);
    final wax = cheerfulCrayonTint(rawWax);
    const paper = Color(0xFFFFF6E4);
    const paperEdge = Color(0xFFE8D7B8);
    final armFill = Paint()..color = paper;
    final waxFill = Paint()..color = wax;

    _crayonArm(
      canvas,
      Path()
        ..moveTo(w * 0.18, h * 0.60)
        ..quadraticBezierTo(w * 0.11, h * 0.64, w * 0.10, h * 0.71),
      Offset(w * 0.10, h * 0.72),
      w,
      sw,
      ink,
      armFill,
      stroke,
    );
    if (mood == MascotMood.ok) {
      _crayonArm(
        canvas,
        Path()
          ..moveTo(w * 0.58, h * 0.60)
          ..quadraticBezierTo(w * 0.72, h * 0.64, w * 0.76, h * 0.74),
        Offset(w * 0.76, h * 0.75),
        w,
        sw,
        ink,
        armFill,
        stroke,
      );
    }

    final paperBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.14, h * 0.32, w * 0.48, h * 0.62),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(paperBody, Paint()..color = paper);
    canvas.drawRRect(paperBody, stroke);

    final neck = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.20, w * 0.44, h * 0.14),
      const Radius.circular(2),
    );
    canvas.drawRRect(neck, waxFill);
    canvas.drawRRect(neck, stroke);
    if (darkWax) _lightRimRRect(canvas, neck, sw);

    canvas.save();
    canvas.clipRRect(paperBody);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.32, w * 0.48, h * 0.06),
      waxFill,
    );
    canvas.drawRect(
      Rect.fromLTWH(w * 0.14, h * 0.82, w * 0.48, h * 0.12),
      Paint()..color = paperEdge,
    );
    _wavyStripe(canvas, w, h, y: h * 0.42, color: _tint(wax, 1.06));
    _wavyStripe(canvas, w, h, y: h * 0.76, color: _tint(wax, 0.90));
    canvas.restore();
    canvas.drawRRect(paperBody, stroke);
    canvas.drawLine(
      Offset(w * 0.14, h * 0.38),
      Offset(w * 0.62, h * 0.38),
      stroke,
    );

    final tip = Path()
      ..moveTo(w * 0.18, h * 0.22)
      ..quadraticBezierTo(w * 0.24, h * 0.06, w * 0.38, h * 0.01)
      ..quadraticBezierTo(w * 0.52, h * 0.06, w * 0.58, h * 0.22)
      ..close();
    canvas.drawPath(tip, Paint()..color = _tint(wax, 1.12));
    canvas.drawPath(tip, stroke);
    if (darkWax) _lightRimPath(canvas, tip, sw);
    final point = Path()
      ..moveTo(w * 0.32, h * 0.09)
      ..lineTo(w * 0.38, h * 0.01)
      ..lineTo(w * 0.44, h * 0.09)
      ..close();
    canvas.drawPath(point, waxFill);
    canvas.drawPath(point, stroke);
    if (darkWax) _lightRimPath(canvas, point, sw);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.28, h * 0.48),
        width: w * 0.12,
        height: h * 0.08,
      ),
      Paint()..color = const Color(0x66FFFFFF),
    );
    if (darkWax) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.30, h * 0.12),
          width: w * 0.10,
          height: h * 0.055,
        ),
        Paint()..color = const Color(0x99FFFFFF),
      );
    }

    _paintPairFace(
      canvas: canvas,
      left: Offset(w * 0.28, h * 0.54),
      right: Offset(w * 0.48, h * 0.54),
      eyeR: w * 0.09,
      mouth: Offset(w * 0.38, h * 0.66),
      mouthW: w * 0.20,
      mouthH: h * 0.09,
      mood: mood,
      ink: ink,
      stroke: stroke,
      blush: const Color(0x55E07A3A),
      tongue: const Color(0xFFE07A3A),
      sweatAt: Offset(w * 0.10, h * 0.28),
      sparkleAt: Offset(w * 0.70, h * 0.12),
      handAt: mood == MascotMood.ok ? null : Offset(w * 0.78, h * 0.58),
    );
  }

  void _crayonArm(
    Canvas canvas,
    Path path,
    Offset hand,
    double w,
    double sw,
    Color ink,
    Paint fill,
    Paint stroke,
  ) {
    canvas.drawPath(
      path,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.10 + sw
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = fill.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.10
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(hand, w * 0.07, fill);
    canvas.drawCircle(hand, w * 0.07, stroke);
  }

  void _wavyStripe(
    Canvas canvas,
    double w,
    double h, {
    required double y,
    required Color color,
  }) {
    final path = Path()..moveTo(w * 0.12, y);
    const steps = 10;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = w * 0.12 + w * 0.52 * t;
      path.lineTo(x, y + math.sin(t * math.pi * 3) * h * 0.016);
    }
    for (var i = steps; i >= 0; i--) {
      final t = i / steps;
      final x = w * 0.12 + w * 0.52 * t;
      path.lineTo(
        x,
        y + h * 0.05 + math.sin(t * math.pi * 3 + 0.4) * h * 0.016,
      );
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CrayonBuddyPainter old) =>
      old.mood != mood || old.tint != tint;
}

Paint _inkStroke(Color ink, double width) {
  return Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
}

Paint _lightRimPaint(double sw) {
  return Paint()
    ..color = const Color(0xE6FFF8E8)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.4, sw * 0.55)
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
}

void _lightRimPath(Canvas canvas, Path path, double sw) {
  canvas.drawPath(path, _lightRimPaint(sw));
}

void _lightRimRRect(Canvas canvas, RRect rect, double sw) {
  canvas.drawRRect(rect, _lightRimPaint(sw));
}

/// Ortak yüz. Encouraging = kalkık kaş + minik gülücük + ter — asla çatık/kızgın.
void _paintPairFace({
  required Canvas canvas,
  required Offset left,
  required Offset right,
  required double eyeR,
  required Offset mouth,
  required double mouthW,
  required double mouthH,
  required MascotMood mood,
  required Color ink,
  required Paint stroke,
  required Color blush,
  required Color tongue,
  Offset? sweatAt,
  Offset? sparkleAt,
  Offset? handAt,
}) {
  final white = Paint()..color = const Color(0xFFFFFFF6);
  for (final c in [left, right]) {
    canvas.drawCircle(c, eyeR, white);
    canvas.drawCircle(c, eyeR, stroke);
  }
  canvas.drawCircle(
    left + Offset(0, eyeR * 1.15),
    eyeR * 0.42,
    Paint()..color = blush,
  );
  canvas.drawCircle(
    right + Offset(0, eyeR * 1.15),
    eyeR * 0.42,
    Paint()..color = blush,
  );

  switch (mood) {
    case MascotMood.happy:
      for (final c in [left, right]) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: eyeR * 0.55),
          0.15,
          math.pi - 0.3,
          false,
          stroke,
        );
      }
      final smile = Path()
        ..addArc(
          Rect.fromCenter(center: mouth, width: mouthW, height: mouthH),
          0.15,
          math.pi - 0.3,
        );
      canvas.drawPath(smile, stroke);
      canvas.drawOval(
        Rect.fromCenter(
          center: mouth + Offset(0, mouthH * 0.28),
          width: mouthW * 0.42,
          height: mouthH * 0.38,
        ),
        Paint()..color = tongue,
      );
      _sparkle4(
        canvas,
        sparkleAt ?? right + Offset(eyeR * 1.6, -eyeR * 1.3),
        eyeR * 0.42,
      );
      if (handAt != null) {
        _waveHand(canvas, handAt, eyeR * 1.7, stroke);
      }
    case MascotMood.ok:
      for (final c in [left, right]) {
        canvas.drawCircle(c, eyeR * 0.38, Paint()..color = ink);
        canvas.drawCircle(
          c + Offset(-eyeR * 0.16, -eyeR * 0.18),
          eyeR * 0.14,
          Paint()..color = const Color(0xFFFFFFFF),
        );
      }
      final proud = Path()
        ..addArc(
          Rect.fromCenter(
            center: mouth,
            width: mouthW * 0.72,
            height: mouthH * 0.70,
          ),
          0.25,
          math.pi - 0.5,
        );
      canvas.drawPath(proud, stroke);
    case MascotMood.encouraging:
      for (final c in [left, right]) {
        canvas.drawCircle(
          c + Offset(0, -eyeR * 0.06),
          eyeR * 0.34,
          Paint()..color = ink,
        );
        canvas.drawCircle(
          c + Offset(-eyeR * 0.12, -eyeR * 0.20),
          eyeR * 0.12,
          Paint()..color = const Color(0xFFFFFFFF),
        );
      }
      _raisedBrows(canvas, left, right, eyeR, stroke);
      final oops = Path()
        ..moveTo(mouth.dx - mouthW * 0.26, mouth.dy)
        ..quadraticBezierTo(
          mouth.dx,
          mouth.dy + mouthH * 0.32,
          mouth.dx + mouthW * 0.26,
          mouth.dy,
        );
      canvas.drawPath(oops, stroke);
      _sweatDrop(
        canvas,
        sweatAt ?? left + Offset(-eyeR * 1.55, -eyeR * 0.2),
        eyeR * 0.72,
        stroke,
      );
      _sparkle4(
        canvas,
        sparkleAt ?? right + Offset(eyeR * 1.55, -eyeR * 1.15),
        eyeR * 0.38,
      );
      if (handAt != null) {
        _waveHand(canvas, handAt, eyeR * 1.7, stroke);
      }
  }
}

/// Kalkık kaş: iç uçlar aşağı düşmez (çatık / kızgın değil).
void _raisedBrows(
  Canvas canvas,
  Offset left,
  Offset right,
  double r,
  Paint stroke,
) {
  final lb = Path()
    ..moveTo(left.dx - r * 0.85, left.dy - r * 1.05)
    ..quadraticBezierTo(
      left.dx - r * 0.05,
      left.dy - r * 1.55,
      left.dx + r * 0.55,
      left.dy - r * 1.12,
    );
  final rb = Path()
    ..moveTo(right.dx - r * 0.55, right.dy - r * 1.12)
    ..quadraticBezierTo(
      right.dx + r * 0.05,
      right.dy - r * 1.55,
      right.dx + r * 0.85,
      right.dy - r * 1.05,
    );
  canvas.drawPath(lb, stroke);
  canvas.drawPath(rb, stroke);
}

void _sweatDrop(Canvas canvas, Offset c, double r, Paint stroke) {
  final drop = Path()
    ..moveTo(c.dx, c.dy - r)
    ..cubicTo(
      c.dx + r * 0.75,
      c.dy - r * 0.15,
      c.dx + r * 0.55,
      c.dy + r * 0.7,
      c.dx,
      c.dy + r,
    )
    ..cubicTo(
      c.dx - r * 0.55,
      c.dy + r * 0.7,
      c.dx - r * 0.75,
      c.dy - r * 0.15,
      c.dx,
      c.dy - r,
    );
  canvas.drawPath(drop, Paint()..color = const Color(0xFFB3E5FC));
  canvas.drawPath(drop, stroke);
  canvas.drawOval(
    Rect.fromCenter(
      center: c + Offset(-r * 0.18, -r * 0.15),
      width: r * 0.28,
      height: r * 0.22,
    ),
    Paint()..color = const Color(0xAAFFFFFF),
  );
}

void _sparkle4(Canvas canvas, Offset c, double r) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final a = -math.pi / 2 + i * math.pi / 4;
    final rad = i.isEven ? r : r * 0.28;
    final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  path.close();
  canvas.drawPath(path, Paint()..color = const Color(0xFFFFF59D));
  canvas.drawPath(
    path,
    Paint()
      ..color = const Color(0xCCF9A825)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1,
  );
}

void _waveHand(Canvas canvas, Offset c, double s, Paint stroke) {
  const skin = Color(0xFFFFE0B2);
  canvas.save();
  canvas.translate(c.dx, c.dy);
  canvas.rotate(-0.35);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: s * 0.85, height: s * 0.70),
      Radius.circular(s * 0.28),
    ),
    Paint()..color = skin,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: s * 0.85, height: s * 0.70),
      Radius.circular(s * 0.28),
    ),
    stroke,
  );
  for (var i = 0; i < 3; i++) {
    final x = -s * 0.22 + i * s * 0.22;
    canvas.drawCircle(Offset(x, -s * 0.42), s * 0.14, Paint()..color = skin);
    canvas.drawCircle(Offset(x, -s * 0.42), s * 0.14, stroke);
  }
  canvas.restore();
}

Color _tint(Color c, double factor) {
  final h = HSVColor.fromColor(c);
  return h
      .withValue((h.value * factor).clamp(0.18, 1.0))
      .withSaturation(
        (h.saturation * (factor < 1 ? 1.08 : 0.65)).clamp(0.0, 1.0),
      )
      .toColor();
}
