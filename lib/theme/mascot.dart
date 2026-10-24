/// Boya kalemi maskot — CustomPainter, ifade skora göre değişir.
///
/// Düşük skor yüzü asla kızgın değil: ince endişeli kaş, minik gülümseme, ter.
/// Silüet: sağlam konik mum uç, dalgalı kâğıt sargı, uzun gövde, minik kollar.
/// Ucun üstünde Renk Yörüngesi: kesik elips + kırmızı / sarı / mavi damla.
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

  /// Silüete göre tuval — uç üstünde renk yörüngesi; kollar ve el taşmaz.
  static Size canvasSize(double size) => Size(size * 1.06, size * 1.36);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: canvasSize(size),
        painter: CrayonBuddyPainter(
          mood: mood,
          tint: bodyColor,
          crayonSize: size,
        ),
      ),
    );
  }
}

/// Boya kalemi: sağlam konik uç, kâğıt sargı, dalgalı etiket, renk yörüngesi.
class CrayonBuddyPainter extends CustomPainter {
  CrayonBuddyPainter({required this.mood, required this.crayonSize, this.tint});

  final MascotMood mood;
  final Color? tint;
  final double crayonSize;

  @override
  void paint(Canvas canvas, Size size) {
    final w = crayonSize * 0.90;
    final h = crayonSize;
    final ox = (size.width - w) / 2;
    final oy = size.height - h;
    canvas.save();
    canvas.translate(ox, oy);
    _paintCrayon(canvas, w, h);
    canvas.restore();
  }

  void _paintCrayon(Canvas canvas, double w, double h) {
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
    final cx = w * 0.50;
    final bodyW = w * 0.42;
    final left = cx - bodyW / 2;
    final right = cx + bodyW / 2;
    final bothArms = mood != MascotMood.happy;

    _crayonArm(
      canvas,
      Path()
        ..moveTo(left + w * 0.03, h * 0.58)
        ..quadraticBezierTo(
          left - w * 0.08,
          h * 0.62,
          left - w * 0.11,
          h * 0.72,
        ),
      Offset(left - w * 0.11, h * 0.73),
      w,
      sw,
      ink,
      armFill,
      stroke,
    );
    if (bothArms) {
      _crayonArm(
        canvas,
        Path()
          ..moveTo(right - w * 0.03, h * 0.58)
          ..quadraticBezierTo(
            right + w * 0.10,
            h * 0.62,
            right + w * 0.13,
            h * 0.73,
          ),
        Offset(right + w * 0.13, h * 0.74),
        w,
        sw,
        ink,
        armFill,
        stroke,
      );
    }

    final paperTop = h * 0.22;
    final paperBot = h * 0.975;
    final paperBody = RRect.fromRectAndCorners(
      Rect.fromLTRB(left, paperTop, right, paperBot),
      topLeft: Radius.circular(w * 0.04),
      topRight: Radius.circular(w * 0.04),
      bottomLeft: Radius.circular(w * 0.09),
      bottomRight: Radius.circular(w * 0.09),
    );
    canvas.drawRRect(paperBody, Paint()..color = paper);
    canvas.drawRRect(paperBody, stroke);

    canvas.save();
    canvas.clipRRect(paperBody);
    canvas.drawRect(Rect.fromLTWH(left, paperTop, bodyW, h * 0.045), waxFill);
    canvas.drawRect(
      Rect.fromLTWH(left, h * 0.90, bodyW, paperBot - h * 0.90),
      Paint()..color = paperEdge,
    );
    _wavyStripe(canvas, left, bodyW, h, y: h * 0.66, color: _tint(wax, 1.06));
    _wavyStripe(canvas, left, bodyW, h, y: h * 0.86, color: _tint(wax, 0.90));
    canvas.restore();
    canvas.drawRRect(paperBody, stroke);
    canvas.drawLine(
      Offset(left, paperTop + h * 0.045),
      Offset(right, paperTop + h * 0.045),
      stroke,
    );

    final tipPeak = _paintIntactTip(
      canvas,
      cx: cx,
      h: h,
      bodyW: bodyW,
      paperTop: paperTop,
      wax: wax,
      darkWax: darkWax,
      sw: sw,
      stroke: stroke,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - bodyW * 0.20, h * 0.415),
        width: w * 0.11,
        height: h * 0.055,
      ),
      Paint()..color = const Color(0x66FFFFFF),
    );

    _paintPairFace(
      canvas: canvas,
      left: Offset(cx - bodyW * 0.20, h * 0.435),
      right: Offset(cx + bodyW * 0.20, h * 0.435),
      eyeR: w * 0.078,
      mouth: Offset(cx, h * 0.525),
      mouthW: w * 0.18,
      mouthH: h * 0.07,
      mood: mood,
      ink: ink,
      stroke: stroke,
      blush: const Color(0x55E07A3A),
      tongue: const Color(0xFFE07A3A),
      sweatAt: Offset(left - w * 0.04, h * 0.32),
      handAt: bothArms ? null : Offset(right + w * 0.15, h * 0.62),
    );

    _paintColourOrbit(
      canvas,
      tip: tipPeak,
      w: w,
      h: h,
      sw: sw,
      ink: ink,
      mood: mood,
    );
  }

  Offset _paintIntactTip(
    Canvas canvas, {
    required double cx,
    required double h,
    required double bodyW,
    required double paperTop,
    required Color wax,
    required bool darkWax,
    required double sw,
    required Paint stroke,
  }) {
    final tipY = h * 0.012;
    final baseY = paperTop + h * 0.012;
    final cone = Path()
      ..moveTo(cx - bodyW / 2, baseY)
      ..lineTo(cx, tipY)
      ..lineTo(cx + bodyW / 2, baseY)
      ..close();
    canvas.drawPath(cone, Paint()..color = wax);
    canvas.drawPath(
      Path()
        ..moveTo(cx, tipY)
        ..lineTo(cx + bodyW / 2, baseY)
        ..lineTo(cx + bodyW * 0.06, baseY)
        ..close(),
      Paint()..color = _tint(wax, 0.80),
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - bodyW * 0.22, baseY - (baseY - tipY) * 0.10)
        ..lineTo(cx - bodyW * 0.04, tipY + (baseY - tipY) * 0.32)
        ..lineTo(cx + bodyW * 0.06, baseY - (baseY - tipY) * 0.10),
      Paint()..color = const Color(0x66FFFFFF),
    );
    canvas.drawPath(cone, stroke);
    if (darkWax) _lightRimPath(canvas, cone, sw);
    return Offset(cx, tipY);
  }

  void _paintColourOrbit(
    Canvas canvas, {
    required Offset tip,
    required double w,
    required double h,
    required double sw,
    required Color ink,
    required MascotMood mood,
  }) {
    final high = mood == MascotMood.happy;
    final low = mood == MascotMood.encouraging;
    final cy = tip.dy - h * (low ? 0.10 : 0.125);
    final cx = tip.dx;
    final rx = w * (low ? 0.24 : 0.30);
    final ry = w * (low ? 0.07 : 0.085);
    final rot = low ? 0.12 : -0.10;
    final dropR =
        w *
        (high
            ? 0.064
            : low
            ? 0.05
            : 0.058);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rot);
    canvas.drawPath(
      _dashedOval(
        Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2),
        dash: sw * 1.2,
        gap: sw * 1.4,
      ),
      Paint()
        ..color = const Color(0x733E2A1A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 0.75
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    const red = Color(0xFFFF5A5F);
    const yellow = Color(0xFFFFC93C);
    const blue = Color(0xFF3D8BFF);
    final drops = low
        ? const [
            (math.pi * 0.92, red, -0.2),
            (math.pi * 0.40, yellow, 0.1),
            (math.pi * 0.08, blue, 0.35),
          ]
        : const [
            (math.pi * 1.0, red, -0.25),
            (math.pi * 1.5, yellow, 0.0),
            (math.pi * 0.02, blue, 0.25),
          ];
    final cosR = math.cos(rot);
    final sinR = math.sin(rot);
    for (final (angle, color, tilt) in drops) {
      final ex = math.cos(angle) * rx;
      final ey = math.sin(angle) * ry;
      _paintOrbitDrop(
        canvas,
        x: cx + ex * cosR - ey * sinR,
        y: cy + ex * sinR + ey * cosR,
        r: dropR,
        tilt: tilt,
        fill: color,
        ink: ink,
        sw: sw,
      );
    }

    if (high) {
      _sparkle4(canvas, Offset(cx + rx * 1.12, cy - ry * 1.9), w * 0.05);
      _sparkle4(canvas, Offset(cx - rx * 1.15, cy - ry * 1.6), w * 0.035);
    } else if (!low) {
      _sparkle4(canvas, Offset(cx + rx * 1.1, cy - ry * 1.7), w * 0.04);
    }
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
    double left,
    double bodyW,
    double h, {
    required double y,
    required Color color,
  }) {
    final path = Path()..moveTo(left - 2, y);
    const steps = 10;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final x = left - 2 + (bodyW + 4) * t;
      path.lineTo(x, y + math.sin(t * math.pi * 3) * h * 0.016);
    }
    for (var i = steps; i >= 0; i--) {
      final t = i / steps;
      final x = left - 2 + (bodyW + 4) * t;
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
      old.mood != mood || old.tint != tint || old.crayonSize != crayonSize;
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

/// Ortak yüz. Encouraging = ince endişeli kaş + minik gülücük + ter — asla çatık/kızgın.
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
      _worriedBrows(canvas, left, right, eyeR, ink);
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
  }
}

/// İnce, kısa, endişeli-tatlı kaş: iç uçlar kalkık, yumuşak yay — asla kalın/çatık.
void _worriedBrows(
  Canvas canvas,
  Offset left,
  Offset right,
  double r,
  Color ink,
) {
  final brow = Paint()
    ..color = ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.15, r * 0.14)
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final lb = Path()
    ..moveTo(left.dx - r * 0.46, left.dy - r * 1.16)
    ..quadraticBezierTo(
      left.dx - r * 0.04,
      left.dy - r * 1.34,
      left.dx + r * 0.36,
      left.dy - r * 1.50,
    );
  final rb = Path()
    ..moveTo(right.dx - r * 0.36, right.dy - r * 1.50)
    ..quadraticBezierTo(
      right.dx + r * 0.04,
      right.dy - r * 1.34,
      right.dx + r * 0.46,
      right.dy - r * 1.16,
    );
  canvas.drawPath(lb, brow);
  canvas.drawPath(rb, brow);
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

Path _dashedOval(Rect oval, {required double dash, required double gap}) {
  final source = Path()..addOval(oval);
  final dest = Path();
  for (final metric in source.computeMetrics()) {
    var distance = 0.0;
    var draw = true;
    while (distance < metric.length) {
      final next = math.min(distance + (draw ? dash : gap), metric.length);
      if (draw) {
        dest.addPath(metric.extractPath(distance, next), Offset.zero);
      }
      distance = next;
      draw = !draw;
    }
  }
  return dest;
}

void _paintOrbitDrop(
  Canvas canvas, {
  required double x,
  required double y,
  required double r,
  required double tilt,
  required Color fill,
  required Color ink,
  required double sw,
}) {
  canvas.save();
  canvas.translate(x, y);
  canvas.rotate(tilt);
  final drop = Path()
    ..moveTo(0, -1.35 * r)
    ..cubicTo(0.55 * r, -0.6 * r, r, -0.1 * r, r, 0.25 * r)
    ..arcTo(
      Rect.fromCircle(center: Offset(0, 0.25 * r), radius: r),
      0,
      math.pi,
      false,
    )
    ..cubicTo(-r, -0.1 * r, -0.55 * r, -0.6 * r, 0, -1.35 * r)
    ..close();
  canvas.drawPath(drop, Paint()..color = fill);
  canvas.drawPath(drop, _inkStroke(ink, sw * 0.8));
  canvas.save();
  canvas.translate(-0.35 * r, 0.05 * r);
  canvas.rotate(-0.4);
  canvas.drawOval(
    Rect.fromCenter(center: Offset.zero, width: 0.44 * r, height: 0.64 * r),
    Paint()..color = const Color(0xB3FFFFFF),
  );
  canvas.restore();
  canvas.restore();
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
