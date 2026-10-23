/// Stüdyo arka planı — yalnızca CustomPainter, orijinal çizim.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

/// Scaffold arkasındaki gradyan + kenar süsü. İçerik alanına taşmaz.
class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: ThemeBackdropPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class ThemeBackdropPainter extends CustomPainter {
  ThemeBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintStudio(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ).createShader(rect),
    );
  }

  /// Kenar bandı: kare / çubuk / düğme / yazının arkasında durmaz.
  void _paintStudio(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _splat(canvas, Offset(w * 0.045, h * 0.055), 14, const Color(0x88E53935));
    _splat(canvas, Offset(w * 0.95, h * 0.06), 12, const Color(0x7A1E88E5));
    _splat(canvas, Offset(w * 0.055, h * 0.94), 15, const Color(0x7A43A047));
    _splat(canvas, Offset(w * 0.95, h * 0.93), 13, const Color(0x7AFFB300));

    _drip(canvas, Offset(w * 0.14, h * 0.012), 16, const Color(0x55E53935));
    _drip(canvas, Offset(w * 0.86, h * 0.01), 13, const Color(0x4D1E88E5));

    _brushStroke(
      canvas,
      Offset(w * 0.01, h * 0.04),
      Offset(w * 0.10, h * 0.09),
      6,
      const Color(0x401E88E5),
    );
    _brushStroke(
      canvas,
      Offset(w * 0.99, h * 0.045),
      Offset(w * 0.90, h * 0.10),
      5,
      const Color(0x40E53935),
    );

    _squiggle(
      canvas,
      Offset(w * 0.07, h * 0.12),
      16,
      0.35,
      const Color(0x55E53935),
    );
    _squiggle(
      canvas,
      Offset(w * 0.93, h * 0.13),
      15,
      -0.4,
      const Color(0x551E88E5),
    );
    _star(canvas, Offset(w * 0.11, h * 0.045), 5.5, const Color(0x88FFB300));
    _star(canvas, Offset(w * 0.89, h * 0.05), 5, const Color(0x778E24AA));
    _star(canvas, Offset(w * 0.08, h * 0.88), 5, const Color(0x6643A047));
    _star(canvas, Offset(w * 0.92, h * 0.87), 5.5, const Color(0x66E53935));
    _spiral(canvas, Offset(w * 0.055, h * 0.155), 7, const Color(0x4D1E88E5));
    _spiral(canvas, Offset(w * 0.945, h * 0.16), 6.5, const Color(0x4DE53935));

    _crayon(
      canvas,
      Offset(w * 0.045, h * 0.965),
      12,
      2.8,
      const Color(0xCCE53935),
    );
    _crayon(
      canvas,
      Offset(w * 0.955, h * 0.965),
      11,
      -2.9,
      const Color(0xCC1E88E5),
    );
    _palette(canvas, Offset(w * 0.09, h * 0.975), 13);
    _brushDecor(canvas, Offset(w * 0.92, h * 0.975), 11);
    _dot(canvas, Offset(w * 0.11, h * 0.035), 3.5, const Color(0xAAFF6D00));
    _dot(canvas, Offset(w * 0.89, h * 0.04), 4, const Color(0xAA8E24AA));
    _dot(canvas, Offset(w * 0.025, h * 0.14), 3.5, const Color(0xAA43A047));
    _dot(canvas, Offset(w * 0.975, h * 0.15), 3.5, const Color(0xAAE53935));
  }

  void _splat(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    const n = 7;
    for (var i = 0; i < n; i++) {
      final a = i * math.pi * 2 / n;
      final rad = r * (i.isEven ? 1.0 : 0.62);
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.quadraticBezierTo(
          c.dx + math.cos(a - math.pi / n) * r * 0.45,
          c.dy + math.sin(a - math.pi / n) * r * 0.45,
          p.dx,
          p.dy,
        );
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      c + Offset(r * 0.7, r * 0.35),
      r * 0.18,
      Paint()..color = color,
    );
    canvas.drawCircle(
      c + Offset(-r * 0.55, r * 0.5),
      r * 0.12,
      Paint()..color = color,
    );
  }

  void _drip(Canvas canvas, Offset c, double s, Color color) {
    final drop = Path()
      ..moveTo(c.dx - s * 0.22, c.dy)
      ..quadraticBezierTo(c.dx - s * 0.18, c.dy + s * 0.55, c.dx, c.dy + s)
      ..quadraticBezierTo(
        c.dx + s * 0.18,
        c.dy + s * 0.55,
        c.dx + s * 0.22,
        c.dy,
      )
      ..close();
    canvas.drawPath(drop, Paint()..color = color);
    canvas.drawCircle(
      c + Offset(s * 0.28, s * 0.72),
      s * 0.10,
      Paint()..color = color,
    );
    canvas.drawCircle(
      c + Offset(-s * 0.22, s * 0.48),
      s * 0.07,
      Paint()..color = color,
    );
  }

  void _brushStroke(
    Canvas canvas,
    Offset a,
    Offset b,
    double width,
    Color color,
  ) {
    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + 6);
    final path = Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _squiggle(Canvas canvas, Offset c, double s, double rot, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final path = Path()..moveTo(-s, 0);
    for (var i = 0; i <= 8; i++) {
      final t = i / 8;
      path.lineTo(-s + s * 2 * t, math.sin(t * math.pi * 3) * s * 0.28);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final a = -math.pi / 2 + i * math.pi / 4;
      final rad = i.isEven ? r : r * 0.32;
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _spiral(Canvas canvas, Offset c, double r, Color color) {
    final path = Path();
    const turns = 2.2;
    const steps = 28;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final a = t * math.pi * 2 * turns;
      final rad = r * t;
      final p = c + Offset(math.cos(a) * rad, math.sin(a) * rad);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  void _crayon(Canvas canvas, Offset c, double s, double rot, Color color) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: s * 0.42, height: s * 1.7),
      Radius.circular(s * 0.12),
    );
    canvas.drawRRect(body, Paint()..color = color);
    final tip = Path()
      ..moveTo(-s * 0.16, -s * 0.82)
      ..lineTo(0, -s * 1.15)
      ..lineTo(s * 0.16, -s * 0.82)
      ..close();
    canvas.drawPath(tip, Paint()..color = _shift(color, 1.15));
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -s * 0.55),
        width: s * 0.42,
        height: s * 0.18,
      ),
      Paint()..color = const Color(0x33FFFFFF),
    );
    canvas.restore();
  }

  void _palette(Canvas canvas, Offset c, double r) {
    final oval = Rect.fromCenter(center: c, width: r * 2.2, height: r * 1.5);
    canvas.drawOval(oval, Paint()..color = const Color(0xB3FFF3E0));
    canvas.drawCircle(
      c + Offset(-r * 0.7, 0),
      r * 0.42,
      Paint()..color = const Color(0xB3FFF3E0),
    );
    const dots = [
      Color(0x99E53935),
      Color(0x99FFB300),
      Color(0x9943A047),
      Color(0x991E88E5),
    ];
    for (var i = 0; i < dots.length; i++) {
      final a = -0.8 + i * 0.55;
      canvas.drawCircle(
        c + Offset(math.cos(a) * r * 0.55, math.sin(a) * r * 0.28),
        r * 0.18,
        Paint()..color = dots[i],
      );
    }
  }

  void _brushDecor(Canvas canvas, Offset c, double s) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, s * 0.2),
          width: s * 0.22,
          height: s * 1.1,
        ),
        Radius.circular(s * 0.1),
      ),
      Paint()..color = const Color(0x99D4A056),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -s * 0.35),
          width: s * 0.32,
          height: s * 0.18,
        ),
        Radius.circular(s * 0.04),
      ),
      Paint()..color = const Color(0x99B0BEC5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(0, -s * 0.62),
          width: s * 0.36,
          height: s * 0.42,
        ),
        Radius.circular(s * 0.08),
      ),
      Paint()..color = const Color(0x992B6CFF),
    );
    canvas.restore();
  }

  void _dot(Canvas canvas, Offset c, double r, Color color) {
    canvas.drawCircle(c, r, Paint()..color = color);
  }

  Color _shift(Color c, double factor) {
    final h = HSVColor.fromColor(c);
    return h.withValue((h.value * factor).clamp(0.2, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
