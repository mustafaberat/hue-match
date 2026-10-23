/// Ana sayfa başlığı: her harf ayrı parlak renk, stüdyo kontur/gölgesi.
library;

import 'package:flutter/material.dart';

import '../config/tokens.dart';

class PlayfulTitle extends StatelessWidget {
  const PlayfulTitle(this.text, {super.key});

  final String text;

  static const List<Color> _letters = [
    Color(0xFFE53935),
    Color(0xFFFF6D00),
    Color(0xFFFBC02D),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFF5E35B1),
    Color(0xFFE53935),
  ];

  static const Color _outline = Color(0xFF2A3544);
  static const double _spread = 1.5;

  @override
  Widget build(BuildContext context) {
    const s = _spread;
    final shadows = <Shadow>[
      const Shadow(color: _outline, offset: Offset(-s, 0), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(s, 0), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(0, -s), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(0, s), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(-s, -s), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(s, -s), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(-s, s), blurRadius: 0),
      const Shadow(color: _outline, offset: Offset(s, s), blurRadius: 0),
      Shadow(
        color: AppColors.onBackdropShadow,
        offset: const Offset(0, s + 1),
        blurRadius: 4,
      ),
    ];
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(
          children: [
            for (var i = 0; i < text.length; i++)
              TextSpan(
                text: text[i],
                style: TextStyle(
                  color: _letters[i % _letters.length],
                  shadows: shadows,
                ),
              ),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: AppFonts.display,
          fontFamilyFallback: const ['Baloo2'],
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
