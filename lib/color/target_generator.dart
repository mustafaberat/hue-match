/// Hedef renk üretimi (§6).
///
/// 1. OKLCh'de L, C, h üret → sRGB gamut dışıysa yeniden dene (max 100).
/// 2. A ∈ [0.35, 1.0] seç; RGB = görünen / A (taşarsa A yükselir).
/// 3. Ardışık hedefler arasında ΔE ≥ 0.15; 5 turda en az 1 düşük,
///    en az 1 yüksek kroma.
/// Renk körü modunda |a| küçük tutulur ve ardışık kural deutan + protan
/// simülasyonunda da sağlanır (Hue Hunt ile aynı yaklaşım).
library;

import 'dart:math' as math;

import '../config/app_config.dart';
import 'composite.dart';
import 'cvd.dart';
import 'distance.dart';
import 'oklab.dart';
import 'rgb.dart';

enum ChromaBand { low, high, any }

class TargetGenerator {
  TargetGenerator({math.Random? random, this.colorBlindSafe = false})
    : _random = random ?? math.Random();

  final math.Random _random;
  final bool colorBlindSafe;

  /// [count] hedef; kroma çeşitliliği ve ardışık ΔE kuralı uygulanır.
  List<MixColor> generateSet(int count) {
    final bands = _bandsFor(count);
    final targets = <MixColor>[];
    for (final band in bands) {
      final previous = targets.isEmpty ? null : targets.last;
      targets.add(generate(band: band, previous: previous));
    }
    return targets;
  }

  MixColor generate({ChromaBand band = ChromaBand.any, MixColor? previous}) {
    for (var attempt = 0; attempt < GeneratorConfig.maxAttempts; attempt++) {
      final visible = _randomVisible(band);
      if (visible == null) {
        continue;
      }
      final mix = _toMix(visible);
      if (_isAcceptable(mix, previous)) {
        return mix;
      }
    }
    return _fallback(previous);
  }

  /// İlk iki tur garanti düşük / yüksek, gerisi serbest; sonra karıştır.
  List<ChromaBand> _bandsFor(int count) {
    final bands = List<ChromaBand>.generate(count, (i) {
      if (i == 0) return ChromaBand.low;
      if (i == 1) return ChromaBand.high;
      return ChromaBand.any;
    });
    bands.shuffle(_random);
    return bands;
  }

  Rgb? _randomVisible(ChromaBand band) {
    final (cMin, cMax) = switch (band) {
      ChromaBand.low => (
        GeneratorConfig.chromaMin,
        GeneratorConfig.lowChromaMax,
      ),
      ChromaBand.high => (
        GeneratorConfig.highChromaMin,
        GeneratorConfig.chromaMax,
      ),
      ChromaBand.any => (GeneratorConfig.chromaMin, GeneratorConfig.chromaMax),
    };
    final l = _range(
      GeneratorConfig.lightnessMin,
      GeneratorConfig.lightnessMax,
    );
    final c = _range(cMin, cMax);
    final h = _random.nextDouble() * 360;
    final lab = Oklch(l, c, h).toOklab();
    if (colorBlindSafe && lab.a.abs() > GeneratorConfig.colorBlindMaxA) {
      return null;
    }
    if (!isOklabInGamut(lab)) {
      return null;
    }
    return oklabToRgb(lab).clamped();
  }

  /// Görünen rengi slider değerlerine çevirir. A %1 adımlı, RGB tam sayı.
  MixColor _toMix(Rgb visible) {
    final steps = GeneratorConfig.alphaSteps;
    final minA = (GeneratorConfig.alphaMin * steps).round();
    final maxA = (GeneratorConfig.alphaMax * steps).round();
    var alphaPercent = minA + _random.nextInt(maxA - minA + 1);

    final peak = math.max(visible.r, math.max(visible.g, visible.b));
    final required = (peak * steps).ceil();
    if (alphaPercent < required) {
      alphaPercent = math.min(required, maxA);
    }
    final a = alphaPercent / steps;
    int channel(double v) =>
        (v / a * MixerRules.channelMax).round().clamp(0, MixerRules.channelMax);
    return MixColor(
      r: channel(visible.r),
      g: channel(visible.g),
      b: channel(visible.b),
      alphaPercent: alphaPercent,
    );
  }

  bool _isAcceptable(MixColor mix, MixColor? previous) {
    final lab = rgbToOklab(mix.visible);
    if (lab.l < GeneratorConfig.lightnessMin - _lightnessSlack) {
      return false;
    }
    if (previous == null) {
      return true;
    }
    final a = mix.visible;
    final b = previous.visible;
    if (rgbOklabDistance(a, b) < GeneratorConfig.minConsecutiveDeltaE) {
      return false;
    }
    if (colorBlindSafe) {
      for (final type in CvdType.values) {
        if (cvdOklabDistance(a, b, type) <
            GeneratorConfig.minConsecutiveDeltaE) {
          return false;
        }
      }
    }
    return true;
  }

  MixColor _fallback(MixColor? previous) {
    final palette = GeneratorConfig.fallbackPalette
        .where(
          (lch) =>
              !colorBlindSafe ||
              lch.toOklab().a.abs() <= GeneratorConfig.colorBlindFallbackMaxA,
        )
        .toList();
    final candidates = palette.isEmpty
        ? GeneratorConfig.fallbackPalette
        : palette;
    final start = _random.nextInt(candidates.length);
    for (var i = 0; i < candidates.length; i++) {
      final lch = candidates[(start + i) % candidates.length];
      final mix = _toMix(oklchToRgbGamutMapped(lch));
      if (previous == null ||
          rgbOklabDistance(mix.visible, previous.visible) >=
              GeneratorConfig.minConsecutiveDeltaE) {
        return mix;
      }
    }
    return _toMix(oklchToRgbGamutMapped(candidates[start]));
  }

  double _range(double min, double max) =>
      min + _random.nextDouble() * (max - min);

  /// 8-bit yuvarlama L'yi çok az oynatabilir.
  static const double _lightnessSlack = 0.01;
}
