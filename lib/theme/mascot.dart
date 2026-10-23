/// Boya kalemi maskot — CustomPainter, ifade skora göre değişir.
///
/// Düşük skor yüzü asla kızgın değil: kalkık kaş, minik üzgün-gülümseme, ter.
/// Silüet: konik uç (menteşeli kapak), dalgalı kâğıt sargı, uzun gövde.
/// Uç biraz kalkık; kıvrımlı pembe beyin aralıktan bakar.
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
  static Size canvasSize(double size) => Size(size * 0.90, size);

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

/// Boya kalemi: konik uç, menteşeli kapak, beyin, kâğıt sargı, dalgalı etiket.
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
    final cx = w * 0.50;
    final bodyW = w * 0.42;
    final left = cx - bodyW / 2;
    final right = cx + bodyW / 2;

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
    if (mood == MascotMood.ok) {
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
      topLeft: Radius.circular(w * 0.055),
      topRight: Radius.circular(w * 0.055),
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

    _paintOpeningBrainAndTip(
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
      sweatAt: Offset(left - w * 0.04, h * 0.30),
      sparkleAt: Offset(right + w * 0.05, h * 0.04),
      handAt: mood == MascotMood.ok ? null : Offset(right + w * 0.15, h * 0.62),
    );
  }

  void _paintOpeningBrainAndTip(
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
    final opening = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, paperTop + h * 0.006),
          width: bodyW * 0.90,
          height: h * 0.05,
        ),
      );
    canvas.drawPath(opening, Paint()..color = _tint(wax, 1.12));
    canvas.drawPath(opening, stroke);
    if (darkWax) _lightRimPath(canvas, opening, sw);

    final hinge = Offset(cx + bodyW / 2, paperTop + h * 0.002);
    final coneH = paperTop - h * 0.008;
    canvas.save();
    canvas.translate(hinge.dx, hinge.dy);
    canvas.rotate(-0.16);
    final cone = Path()
      ..moveTo(0, 0)
      ..lineTo(-bodyW, 0)
      ..lineTo(-bodyW / 2, -coneH)
      ..close();
    canvas.drawPath(cone, Paint()..color = wax);
    canvas.drawPath(
      Path()
        ..moveTo(-bodyW / 2, -coneH)
        ..lineTo(0, 0)
        ..lineTo(-bodyW * 0.38, 0)
        ..close(),
      Paint()..color = _tint(wax, 0.80),
    );
    canvas.drawPath(
      Path()
        ..moveTo(-bodyW * 0.72, -coneH * 0.10)
        ..lineTo(-bodyW * 0.54, -coneH * 0.68)
        ..lineTo(-bodyW * 0.44, -coneH * 0.10),
      Paint()..color = const Color(0x66FFFFFF),
    );
    canvas.drawPath(cone, stroke);
    if (darkWax) _lightRimPath(canvas, cone, sw);
    canvas.restore();
    canvas.drawCircle(
      hinge,
      math.max(1.8, bodyW * 0.055),
      Paint()..color = wax,
    );
    canvas.drawCircle(hinge, math.max(1.8, bodyW * 0.055), stroke);

    _paintBrain(
      canvas,
      center: Offset(cx, paperTop + h * 0.062),
      rw: bodyW * 0.40,
      rh: h * 0.095,
      sw: sw,
    );
  }

  void _paintBrain(
    Canvas canvas, {
    required Offset center,
    required double rw,
    required double rh,
    required double sw,
  }) {
    const brain = Color(0xFFFF7FB2);
    const brainShade = Color(0xFFD44E8C);
    const brainLit = Color(0xFFFFD0E6);
    const brainLine = Color(0xFFB03A72);
    final fill = Paint()..color = brain;
    final outline = _inkStroke(brainLine, math.max(1.6, sw * 0.75));

    final leftC = center + Offset(-rw * 0.30, rh * 0.04);
    final rightC = center + Offset(rw * 0.30, rh * 0.04);
    final lobe = Size(rw * 1.20, rh * 1.95);
    canvas.drawOval(
      Rect.fromCenter(center: leftC, width: lobe.width, height: lobe.height),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: rightC, width: lobe.width, height: lobe.height),
      fill,
    );

    final bumpR = math.max(2.2, rw * 0.28);
    for (final lobeC in [leftC, rightC]) {
      canvas.drawCircle(lobeC + Offset(-rw * 0.18, -rh * 0.72), bumpR, fill);
      canvas.drawCircle(
        lobeC + Offset(rw * 0.20, -rh * 0.78),
        bumpR * 0.9,
        fill,
      );
      canvas.drawCircle(lobeC + Offset(0, rh * 0.78), bumpR * 0.85, fill);
    }

    canvas.drawPath(_brainOutline(center, rw, rh), outline);

    final fold = Paint()
      ..color = brainLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, sw * 0.70)
      ..strokeCap = StrokeCap.round;
    final gyri = Paint()
      ..color = brainShade
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.3, sw * 0.55)
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(center.dx, center.dy - rh * 0.85)
        ..cubicTo(
          center.dx - rw * 0.10,
          center.dy - rh * 0.10,
          center.dx + rw * 0.08,
          center.dy + rh * 0.25,
          center.dx,
          center.dy + rh * 0.82,
        ),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(leftC.dx - rw * 0.15, leftC.dy - rh * 0.35)
        ..cubicTo(
          leftC.dx + rw * 0.05,
          leftC.dy - rh * 0.70,
          leftC.dx + rw * 0.28,
          leftC.dy - rh * 0.05,
          leftC.dx + rw * 0.18,
          leftC.dy + rh * 0.35,
        ),
      gyri,
    );
    canvas.drawPath(
      Path()
        ..moveTo(leftC.dx - rw * 0.08, leftC.dy + rh * 0.10)
        ..quadraticBezierTo(
          leftC.dx + rw * 0.18,
          leftC.dy + rh * 0.55,
          leftC.dx + rw * 0.32,
          leftC.dy + rh * 0.15,
        ),
      gyri,
    );
    canvas.drawPath(
      Path()
        ..moveTo(rightC.dx - rw * 0.18, rightC.dy - rh * 0.30)
        ..cubicTo(
          rightC.dx + rw * 0.08,
          rightC.dy - rh * 0.72,
          rightC.dx + rw * 0.32,
          rightC.dy - rh * 0.02,
          rightC.dx + rw * 0.10,
          rightC.dy + rh * 0.38,
        ),
      gyri,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: leftC + Offset(-rw * 0.12, -rh * 0.35),
        width: rw * 0.42,
        height: rh * 0.32,
      ),
      Paint()..color = brainLit,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: rightC + Offset(-rw * 0.06, -rh * 0.40),
        width: rw * 0.28,
        height: rh * 0.20,
      ),
      Paint()..color = const Color(0x66FFFFFF),
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

Path _brainOutline(Offset c, double rw, double rh) {
  return Path()
    ..moveTo(c.dx, c.dy - rh * 0.08)
    ..cubicTo(
      c.dx - rw * 0.22,
      c.dy - rh * 1.05,
      c.dx - rw * 0.95,
      c.dy - rh * 0.85,
      c.dx - rw,
      c.dy - rh * 0.10,
    )
    ..cubicTo(
      c.dx - rw * 1.05,
      c.dy + rh * 0.55,
      c.dx - rw * 0.55,
      c.dy + rh * 1.02,
      c.dx - rw * 0.16,
      c.dy + rh * 0.72,
    )
    ..quadraticBezierTo(
      c.dx,
      c.dy + rh * 0.38,
      c.dx + rw * 0.16,
      c.dy + rh * 0.72,
    )
    ..cubicTo(
      c.dx + rw * 0.55,
      c.dy + rh * 1.02,
      c.dx + rw * 1.05,
      c.dy + rh * 0.55,
      c.dx + rw,
      c.dy - rh * 0.10,
    )
    ..cubicTo(
      c.dx + rw * 0.95,
      c.dy - rh * 0.85,
      c.dx + rw * 0.22,
      c.dy - rh * 1.05,
      c.dx,
      c.dy - rh * 0.08,
    )
    ..close();
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
