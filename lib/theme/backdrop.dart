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

  void _paintStudio(Canvas canvas, Size size) {
    _splat(
      canvas,
      Offset(size.width * 0.04, size.height * 0.08),
      16,
      const Color(0xE6E53935),
    );
    _splat(
      canvas,
      Offset(size.width * 0.94, size.height * 0.10),
      14,
      const Color(0xE21E88E5),
    );
    _splat(
      canvas,
      Offset(size.width * 0.06, size.height * 0.92),
      18,
      const Color(0xE243A047),
    );
    _splat(
      canvas,
      Offset(size.width * 0.95, size.height * 0.90),
      15,
      const Color(0xE2FFB300),
    );
    _crayon(
      canvas,
      Offset(size.width * 0.04, size.height * 0.96),
      13,
      2.8,
      const Color(0xFFE53935),
    );
    _crayon(
      canvas,
      Offset(size.width * 0.96, size.height * 0.96),
      12,
      -2.9,
      const Color(0xFF1E88E5),
    );
    _palette(canvas, Offset(size.width * 0.08, size.height * 0.97), 14);
    _brushDecor(canvas, Offset(size.width * 0.93, size.height * 0.97), 12);
    _dot(
      canvas,
      Offset(size.width * 0.10, size.height * 0.04),
      4,
      const Color(0xFFFF6D00),
    );
    _dot(
      canvas,
      Offset(size.width * 0.90, size.height * 0.04),
      5,
      const Color(0xFF8E24AA),
    );
    _dot(
      canvas,
      Offset(size.width * 0.03, size.height * 0.14),
      4,
      const Color(0xFF43A047),
    );
    _dot(
      canvas,
      Offset(size.width * 0.97, size.height * 0.16),
      4,
      const Color(0xFFE53935),
    );
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
    canvas.drawOval(oval, Paint()..color = const Color(0xFFFFF3E0));
    canvas.drawCircle(
      c + Offset(-r * 0.7, 0),
      r * 0.42,
      Paint()..color = const Color(0xFFFFF3E0),
    );
    const dots = [
      Color(0xFFE53935),
      Color(0xFFFFB300),
      Color(0xFF43A047),
      Color(0xFF1E88E5),
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
      Paint()..color = const Color(0xFFD4A056),
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
      Paint()..color = const Color(0xFFB0BEC5),
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
      Paint()..color = const Color(0xFF2B6CFF),
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
