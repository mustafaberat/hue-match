import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/color/composite.dart';
import 'package:hue_match/color/distance.dart';
import 'package:hue_match/color/oklab.dart';
import 'package:hue_match/color/rgb.dart';
import 'package:hue_match/color/scoring.dart';
import 'package:hue_match/color/seeded_random.dart';
import 'package:hue_match/color/target_generator.dart';
import 'package:hue_match/config/app_config.dart';

const _eps = 1e-3;

void main() {
  group('OKLab', () {
    test('known reference values (Ottosson)', () {
      final white = rgbToOklab(const Rgb(1, 1, 1));
      expect(white.l, closeTo(1.0, _eps));
      expect(white.a, closeTo(0, _eps));
      expect(white.b, closeTo(0, _eps));

      final black = rgbToOklab(const Rgb(0, 0, 0));
      expect(black.l, closeTo(0, _eps));

      final red = rgbToOklab(const Rgb(1, 0, 0));
      expect(red.l, closeTo(0.62796, _eps));
      expect(red.a, closeTo(0.22486, _eps));
      expect(red.b, closeTo(0.12585, _eps));

      final blue = rgbToOklab(const Rgb(0, 0, 1));
      expect(blue.l, closeTo(0.45201, _eps));
      expect(blue.a, closeTo(-0.03246, _eps));
      expect(blue.b, closeTo(-0.31153, _eps));
    });

    test('sRGB ↔ linear ↔ OKLab round trip', () {
      final random = Random(7);
      for (var i = 0; i < 200; i++) {
        final rgb = Rgb(
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
        );
        final back = oklabToRgb(rgbToOklab(rgb));
        expect(back.r, closeTo(rgb.r, 1e-5));
        expect(back.g, closeTo(rgb.g, 1e-5));
        expect(back.b, closeTo(rgb.b, 1e-5));
        final lin = linearRgbToSrgb(srgbToLinearRgb(rgb));
        expect(lin.r, closeTo(rgb.r, 1e-9));
      }
    });

    test('OKLCh ↔ OKLab', () {
      const lab = Oklab(0.7, 0.1, -0.05);
      final back = lab.toOklch().toOklab();
      expect(back.a, closeTo(lab.a, 1e-12));
      expect(back.b, closeTo(lab.b, 1e-12));
      expect(lab.toOklch().h, inInclusiveRange(0, 360));
    });

    test('gamut mapping keeps result in sRGB', () {
      final mapped = oklchToRgbGamutMapped(const Oklch(0.7, 0.4, 260));
      expect(mapped.inGamut, isTrue);
    });
  });

  group('composite over black', () {
    test('alpha is a brightness multiplier', () {
      final v = compositeOverBlack(const Rgb(1, 0.5, 0.2), 0.5);
      expect(v.r, closeTo(0.5, 1e-12));
      expect(v.g, closeTo(0.25, 1e-12));
      expect(v.b, closeTo(0.1, 1e-12));
      expect(compositeOverBlack(const Rgb(1, 1, 1), 0).r, 0);
      expect(compositeOverBlack(const Rgb(1, 1, 1), 1).r, 1);
    });

    test('equal visible color ⇒ equal score', () {
      const target = MixColor(r: 120, g: 60, b: 30, alphaPercent: 100);
      const brightLowA = MixColor(r: 240, g: 120, b: 60, alphaPercent: 50);
      const exact = MixColor(r: 120, g: 60, b: 30, alphaPercent: 100);
      expect(visibleDeltaE(target, brightLowA), closeTo(0, 1e-9));
      expect(
        roundScore(visibleDeltaE(target, brightLowA)),
        roundScore(visibleDeltaE(target, exact)),
      );
      expect(roundScore(visibleDeltaE(target, brightLowA)), 100);
    });
  });

  group('score curve §5.2', () {
    const table = [
      (0.0, 100),
      (0.02, 90),
      (0.05, 76),
      (0.10, 54),
      (0.20, 19),
      (0.30, 0),
    ];
    for (final (deltaE, score) in table) {
      test('ΔE $deltaE → $score', () {
        expect(roundScore(deltaE), score);
      });
    }

    test('beyond max is 0, replay ×0.9', () {
      expect(roundScore(0.5), 0);
      expect(roundScore(0, replayUsed: true), 90);
      expect(
        roundScore(0.02, replayUsed: true),
        (rawScore(0.02) * 0.9).round(),
      );
    });

    test('labels', () {
      expect(labelFor(100), ScoreLabel.perfect);
      expect(labelFor(98), ScoreLabel.perfect);
      expect(labelFor(97), ScoreLabel.soClose);
      expect(labelFor(90), ScoreLabel.soClose);
      expect(labelFor(89), ScoreLabel.good);
      expect(labelFor(75), ScoreLabel.good);
      expect(labelFor(74), ScoreLabel.notBad);
      expect(labelFor(50), ScoreLabel.notBad);
      expect(labelFor(49), ScoreLabel.farOff);
      expect(labelFor(0), ScoreLabel.farOff);
    });
  });

  group('difference explanation §5.3', () {
    test('normalizes player visible by target A', () {
      const target = MixColor(r: 200, g: 100, b: 50, alphaPercent: 50);
      const player = MixColor(r: 100, g: 50, b: 25, alphaPercent: 100);
      final diffs = explainDifference(target, player);
      expect(diffs.every((d) => d.value == 0), isTrue);
      expect(diffs.any((d) => d.highlighted), isFalse);
    });

    test('highlights the two largest', () {
      const target = MixColor(r: 100, g: 100, b: 100, alphaPercent: 100);
      const player = MixColor(r: 160, g: 104, b: 40, alphaPercent: 100);
      final diffs = explainDifference(target, player);
      final r = diffs.firstWhere((d) => d.channel == DiffChannel.r);
      final b = diffs.firstWhere((d) => d.channel == DiffChannel.b);
      final g = diffs.firstWhere((d) => d.channel == DiffChannel.g);
      expect(r.value, 60);
      expect(b.value, -60);
      expect(r.highlighted && b.highlighted, isTrue);
      expect(g.highlighted, isFalse);
      expect(diffs.where((d) => d.highlighted).length, 2);
    });
  });

  group('target generator §6', () {
    for (final colorBlind in [false, true]) {
      test('gamut, ranges and consecutive ΔE (colorBlind=$colorBlind)', () {
        for (var seed = 0; seed < 60; seed++) {
          final generator = TargetGenerator(
            random: SeededRandom(seed),
            colorBlindSafe: colorBlind,
          );
          final set = generator.generateSet(GameRules.roundsPerGame);
          expect(set, hasLength(GameRules.roundsPerGame));
          for (var i = 0; i < set.length; i++) {
            final t = set[i];
            expect(t.alpha, inInclusiveRange(GeneratorConfig.alphaMin, 1.0));
            for (final c in [t.r, t.g, t.b]) {
              expect(c, inInclusiveRange(0, 255));
            }
            expect(t.visible.inGamut, isTrue);
            if (i > 0) {
              expect(
                rgbOklabDistance(t.visible, set[i - 1].visible),
                greaterThanOrEqualTo(GeneratorConfig.minConsecutiveDeltaE),
              );
            }
          }
          if (!colorBlind) {
            final chromas = set
                .map((t) => rgbToOklab(t.visible).toOklch().c)
                .toList();
            expect(
              chromas.any((c) => c <= GeneratorConfig.lowChromaMax + 0.01),
              isTrue,
            );
            expect(
              chromas.any((c) => c >= GeneratorConfig.highChromaMin - 0.01),
              isTrue,
            );
          } else {
            for (final t in set) {
              expect(
                rgbToOklab(t.visible).a.abs(),
                lessThanOrEqualTo(GeneratorConfig.colorBlindFallbackMaxA),
              );
            }
          }
        }
      });
    }
  });
}
