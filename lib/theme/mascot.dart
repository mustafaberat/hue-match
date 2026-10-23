/// Boya kalemi maskot — CustomPainter, ifade skora göre değişir.
///
/// Düşük skor yüzü asla kızgın değil: ince endişeli kaş, minik gülümseme, ter.
/// Silüet: sağlam konik mum uç, dalgalı kâğıt sargı, uzun gövde, minik kollar.
/// Ucun üstünde yüzen küçük ampul: fikir / hatırladım.
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

  /// Silüete göre tuval — üstte ampul payı; home yerleşimi taşmadan bunu kullanır.
  static Size canvasSize(double size) => Size(size * 1.02, size * 1.32);

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

/// Boya kalemi: sağlam konik uç, kâğıt sargı, dalgalı etiket, yüzen ampul.
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

    _paintIdeaSpark(
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

  void _paintIdeaSpark(
    Canvas canvas, {
    required Offset tip,
    required double w,
    required double h,
    required double sw,
    required Color ink,
    required MascotMood mood,
  }) {
    final bulbC = tip + Offset(w * 0.16, -h * 0.118);
    final r = math.max(6.6, w * 0.115);
    final high = mood == MascotMood.happy;
    final low = mood == MascotMood.encouraging;

    final glowOuter = low
        ? const Color(0x28FFE082)
        : high
        ? const Color(0x55FFE082)
        : const Color(0x38FFE082);
    final glowInner = low
        ? const Color(0x33FFF59D)
        : high
        ? const Color(0x77FFF59D)
        : const Color(0x55FFF59D);
    canvas.drawCircle(
      bulbC,
      r *
          (high
              ? 1.90
              : low
              ? 1.45
              : 1.70),
      Paint()..color = glowOuter,
    );
    canvas.drawCircle(
      bulbC,
      r *
          (high
              ? 1.32
              : low
              ? 1.12
              : 1.22),
      Paint()..color = glowInner,
    );

    final rayColor = low ? const Color(0xCCF9A825) : const Color(0xFFF9A825);
    final ticks = _inkStroke(
      rayColor,
      math.max(low ? 2.6 : 2.0, sw * (low ? 1.05 : 0.85)),
    );
    final rays = high
        ? const [-2.70, -2.20, -1.85, -1.57, -1.28, -0.94, -0.48]
        : low
        ? const [-1.92]
        : const [-2.35, -1.57, -0.78];
    final rayInner = low ? 1.22 : 1.38;
    final rayOuter = high
        ? 2.08
        : low
        ? 1.95
        : 1.92;
    for (final a in rays) {
      final inner =
          bulbC +
          Offset(math.cos(a) * r * rayInner, math.sin(a) * r * rayInner);
      final outer =
          bulbC +
          Offset(math.cos(a) * r * rayOuter, math.sin(a) * r * rayOuter);
      canvas.drawLine(inner, outer, ticks);
    }
    if (high) {
      _sparkle4(canvas, bulbC + Offset(r * 1.52, -r * 0.78), r * 0.38);
      _sparkle4(canvas, bulbC + Offset(-r * 1.28, -r * 0.48), r * 0.26);
    } else if (!low) {
      _sparkle4(canvas, bulbC + Offset(r * 1.42, -r * 0.62), r * 0.28);
    } else {
      _flickerMarks(canvas, bulbC, r, sw);
    }

    final glassFill = low
        ? const Color(0xFFEDCC4E)
        : high
        ? const Color(0xFFFFD54F)
        : const Color(0xFFFFE082);
    final glass = Path()
      ..addOval(Rect.fromCircle(center: bulbC, radius: r))
      ..addOval(
        Rect.fromCenter(
          center: bulbC + Offset(0, r * 0.42),
          width: r * 1.55,
          height: r * 1.15,
        ),
      );
    canvas.drawPath(glass, Paint()..color = glassFill);
    canvas.drawPath(glass, _inkStroke(ink, math.max(1.9, sw * 0.9)));
    canvas.drawOval(
      Rect.fromCenter(
        center: bulbC + Offset(-r * 0.28, -r * 0.18),
        width: r * 0.46,
        height: r * 0.30,
      ),
      Paint()..color = Color(low ? 0x66FFFFFF : 0xAAFFFFFF),
    );

    final filament = Paint()
      ..color = low ? const Color(0xFFB86A20) : const Color(0xFFE65100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, sw * 0.5)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(bulbC.dx - r * 0.26, bulbC.dy + r * 0.22)
        ..quadraticBezierTo(
          bulbC.dx,
          bulbC.dy - r * (low ? 0.12 : 0.32),
          bulbC.dx + r * 0.26,
          bulbC.dy + r * 0.22,
        ),
      filament,
    );

    final baseTop = bulbC + Offset(0, r * 1.10);
    final neck = RRect.fromRectAndRadius(
      Rect.fromCenter(center: baseTop, width: r * 0.78, height: r * 0.38),
      Radius.circular(r * 0.08),
    );
    canvas.drawRRect(neck, Paint()..color = const Color(0xFFD7C4A0));
    canvas.drawRRect(neck, _inkStroke(ink, math.max(1.5, sw * 0.7)));
    for (final t in [-0.07, 0.07]) {
      canvas.drawLine(
        Offset(baseTop.dx - r * 0.24, baseTop.dy + r * t),
        Offset(baseTop.dx + r * 0.24, baseTop.dy + r * t),
        _inkStroke(ink, math.max(1.1, sw * 0.4)),
      );
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

void _flickerMarks(Canvas canvas, Offset bulbC, double r, double sw) {
  final zap = Paint()
    ..color = const Color(0xFFF9A825)
    ..style = PaintingStyle.stroke
    ..strokeWidth = math.max(1.9, sw * 0.72)
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  final right = Path()
    ..moveTo(bulbC.dx + r * 1.18, bulbC.dy + r * 0.12)
    ..lineTo(bulbC.dx + r * 1.58, bulbC.dy - r * 0.22)
    ..lineTo(bulbC.dx + r * 1.34, bulbC.dy - r * 0.06)
    ..lineTo(bulbC.dx + r * 1.82, bulbC.dy - r * 0.58);
  final left = Path()
    ..moveTo(bulbC.dx - r * 1.12, bulbC.dy + r * 0.22)
    ..lineTo(bulbC.dx - r * 1.48, bulbC.dy - r * 0.10)
    ..lineTo(bulbC.dx - r * 1.26, bulbC.dy + r * 0.04)
    ..lineTo(bulbC.dx - r * 1.62, bulbC.dy - r * 0.42);
  canvas.drawPath(right, zap);
  canvas.drawPath(left, zap);
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
