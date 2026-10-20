/// Karışım rengi ve siyah sahne üzerine alfa (§2).
///
/// görünen = (R, G, B) × A — encoded sRGB uzayında, ekranın alfa
/// karıştırmasıyla aynı. Puan her zaman görünen renk üzerinden hesaplanır.
library;

import '../config/app_config.dart';
import 'rgb.dart';

/// Oyuncunun / hedefin ham slider değerleri.
class MixColor {
  const MixColor({
    required this.r,
    required this.g,
    required this.b,
    required this.alphaPercent,
  });

  static const MixColor initial = MixColor(
    r: GameRules.initialChannel,
    g: GameRules.initialChannel,
    b: GameRules.initialChannel,
    alphaPercent: GameRules.initialAlphaPercent,
  );

  /// 0–255.
  final int r;
  final int g;
  final int b;

  /// 0–100.
  final int alphaPercent;

  double get alpha => alphaPercent / MixerRules.alphaMax;

  /// Siyah üzerine görünen renk (encoded sRGB, 0–1).
  Rgb get visible => compositeOverBlack(Rgb.from8Bit(r, g, b), alpha);

  MixColor copyWith({int? r, int? g, int? b, int? alphaPercent}) => MixColor(
    r: r ?? this.r,
    g: g ?? this.g,
    b: b ?? this.b,
    alphaPercent: alphaPercent ?? this.alphaPercent,
  );

  @override
  bool operator ==(Object other) =>
      other is MixColor &&
      other.r == r &&
      other.g == g &&
      other.b == b &&
      other.alphaPercent == alphaPercent;

  @override
  int get hashCode => Object.hash(r, g, b, alphaPercent);

  @override
  String toString() => 'MixColor($r, $g, $b, $alphaPercent%)';
}

/// Siyah sahne: alfa parlaklık çarpanı olarak davranır.
Rgb compositeOverBlack(Rgb color, double alpha) {
  final a = alpha.clamp(0.0, 1.0);
  return Rgb(color.r * a, color.g * a, color.b * a);
}
