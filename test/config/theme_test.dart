import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/components/buttons.dart';
import 'package:hue_match/config/tokens.dart';
import 'package:hue_match/theme/mascot.dart';

void main() {
  test('paint studio tokens', () {
    expect(AppFonts.body, 'Baloo2');
    expect(AppFonts.display, 'Nunito');
    expect(
      AppFonts.fallback,
      containsAll(['Baloo2', 'NotoSansJP', 'NotoSansKR', 'NotoSansSC']),
    );
    expect(AppColors.accent, const Color(0xFF2B6CFF));
    expect(AppRadii.button, 999);
    expect(AppRadii.card, 28);
    expect(AppSizes.shadowBlur, 18);
    expect(AppSizes.outlineWidth, 0);
    expect(AppColors.textOnBackdrop.computeLuminance(), lessThan(0.25));
    expect(
      AppColors.swatchFrame.computeLuminance(),
      inInclusiveRange(0.35, 0.75),
    );
  });

  test('mascot mood follows score bands', () {
    expect(mascotMoodForScore(92), MascotMood.happy);
    expect(mascotMoodForScore(60), MascotMood.ok);
    expect(mascotMoodForScore(40), MascotMood.encouraging);
    expect(mascotMoodForScore(400, max: 500), MascotMood.happy);
    expect(mascotMoodForScore(200, max: 500), MascotMood.encouraging);
  });

  test('mascot canvas leaves room above the crayon for the idea bulb', () {
    const size = 88.0;
    final canvas = ThemeMascot.canvasSize(size);
    expect(canvas.height, greaterThan(size));
    expect(canvas.width, greaterThan(size * 0.90));
  });

  test('dark crayon tints are lifted, mid colours stay', () {
    const midBlue = Color(0xFF2B6CFF);
    expect(cheerfulCrayonTint(midBlue), midBlue);
    expect(crayonNeedsCheer(midBlue), isFalse);

    const darkPurple = Color(0xFF2D1B4E);
    expect(crayonNeedsCheer(darkPurple), isTrue);
    final lifted = cheerfulCrayonTint(darkPurple);
    expect(
      lifted.computeLuminance(),
      greaterThan(darkPurple.computeLuminance()),
    );
    expect(HSVColor.fromColor(lifted).value, greaterThanOrEqualTo(0.7));
    expect(HSVColor.fromColor(lifted).saturation, greaterThan(0.4));

    const nearBlack = Color(0xFF0A0A12);
    final blackLifted = cheerfulCrayonTint(nearBlack);
    expect(HSVColor.fromColor(blackLifted).value, greaterThanOrEqualTo(0.7));
    expect(HSVColor.fromColor(blackLifted).saturation, greaterThan(0.4));
  });

  test('button text contrasts on light and dark fills', () {
    expect(
      foregroundOn(const Color(0xFFF5E6A8)).computeLuminance(),
      lessThan(0.3),
    );
    expect(
      foregroundOn(const Color(0xFF2D1B4E)).computeLuminance(),
      greaterThan(0.7),
    );
    expect(foregroundOn(AppColors.accent).computeLuminance(), greaterThan(0.7));
  });
}
