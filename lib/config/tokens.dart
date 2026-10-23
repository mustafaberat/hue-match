/// HueMind görsel token'lar. Widget'larda sayı / renk / süre yazılmaz.
///
/// Boya Atölyesi / Paint Studio — krem kâğıt, ana renkler, boya kalemi maskot.
library;

import 'package:flutter/material.dart';

enum MascotMood { happy, ok, encouraging }

abstract final class AppColors {
  static const Color background = Color(0xFFF3EDE0);
  static const List<Color> backgroundGradient = [
    Color(0xFFFFF6E8),
    Color(0xFFEAF3FA),
    Color(0xFFD5E8F4),
  ];

  /// Nötr kuyu — renk örneklerinin çerçevesi. Karar vermeyi bozmaz.
  static const Color stage = Color(0xFFF6F3EE);

  /// A kanalı gradyanı her zaman siyah üzerinde (skor ile aynı).
  static const Color mixBackdrop = Color(0xFF000000);

  static const Color swatchFrame = Color(0xFFB9B3A8);
  static const Color surface = Color(0xFFFFFCF6);
  static const Color surfaceHigh = Color(0xFFFFF4E4);
  static const Color surfacePressed = Color(0xFFE8DCC8);
  static const Color outline = Color(0xFFE2D6C4);
  static const Color outlineStrong = Color(0xFFC9BCA8);
  static const Color textPrimary = Color(0xFF2A3544);
  static const Color textSecondary = Color(0xFF546070);
  static const Color textMuted = Color(0xFF8A8378);

  /// Backdrop (gökyüzü) üstündeki yazı — kart/plaka içi değil.
  static const Color textOnBackdrop = Color(0xFF2A3544);
  static const Color textOnBackdropMuted = Color(0xFF3E4A58);
  static const Color onBackdropShadow = Color(0x66FFFFFF);
  static const Color accent = Color(0xFF2B6CFF);
  static const Color accentPressed = Color(0xFF1E54D4);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentSoft = Color(0x332B6CFF);
  static const Color sliderThumb = Color(0xFFFFFFFF);
  static const Color sliderThumbShadow = Color(0x33000000);
  static const Color scrim = Color(0x66000000);
  static const Color hintBubble = Color(0xFFFFFCF6);
  static const Color onHintBubble = Color(0xFF2A3544);
  static const Color swatchCaptionScrim = Color(0x8C000000);
  static const Color bannerPlaceholder = Color(0xFFF3E9D8);
  static const Color channelR = Color(0xFFE53935);
  static const Color channelG = Color(0xFF43A047);
  static const Color channelB = Color(0xFF1E88E5);
  static const Color channelA = Color(0xFF8A8378);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color pressOverlay = Color(0x22000000);
  static const Color shadowTint = Color(0x402B6CFF);
}

abstract final class AppFonts {
  static const String body = 'Baloo2';
  static const String display = 'Chewy';
}

abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
  static const double screen = 24;
  static const double swatchGap = 8;
}

abstract final class AppRadii {
  static const double swatch = 24;
  static const double swatchSmall = 16;
  static const double button = 999;
  static const double card = 28;
  static const double chip = 999;
  static const double track = 999;
  static const double stage = 32;
}

abstract final class AppSizes {
  static const double maxContentWidth = 480;
  static const double buttonHeight = 64;
  static const double buttonHeightSmall = 50;
  static const double iconButton = 52;
  static const double icon = 24;
  static const double iconSmall = 20;
  static const double topBarHeight = 56;
  static const double roundSegmentWidth = 18;
  static const double roundSegmentHeight = 5;

  static const double swatchFrameWidth = 2;
  static const double outlineWidth = 0;
  static const double swatchMat = 8;
  static const double shadowBlur = 18;
  static const double shadowY = 8;

  static const double homeSwatch = 200;
  static const double homeSwatchMaxFraction = 0.50;
  static const double mascot = 88;
  static const double mascotHome = 148;
  static const double mascotResult = 116;
  static const double mascotEnd = 152;
  static const double mascotHowTo = 104;

  /// Home'da maskot çerçeveye bu kadar girer (paspartu, renk dolgusuna değil).
  static const double homeMascotOverlap = swatchFrameWidth + swatchMat;

  /// Maskot swatch köşesinin biraz altında oturur (ayak / sepet görünür).
  static const double homeMascotSitBelow = 12;

  static const double revealBarHeight = 6;
  static const double revealBarWidthFraction = 0.6;

  static const double sliderRowHeight = 52;
  static const double sliderTrackHeight = 16;
  static const double sliderTrackHeightFine = 22;
  static const double sliderThumb = 30;
  static const double compareMark = 16;
  static const double sliderThumbFine = 36;
  static const double sliderThumbBorder = 3;
  static const double sliderLabelWidth = 34;
  static const double sliderValueWidth = 44;

  static const double resultSwatchMax = 160;
  static const double scoreDisplay = 96;
  static const double totalDisplay = 68;

  static const double stripDot = 48;
  static const double stripDotSmall = 40;

  static const double pageDot = 8;
  static const double pageDotActive = 22;

  static const double hintArrow = 10;
  static const double hintMaxWidth = 280;

  static const double handIcon = 40;

  static const double bannerHeight = 50;
  static const double bannerWidth = 320;

  static const double settingsRowMinHeight = 64;
  static const double segmentHeight = 44;
  static const double settingsDividerIndent = 54;
  static const double revealSwatchMaxHeightFraction = 0.7;

  /// Hafıza modunda çubukların kapladığı sabit yükseklik.
  static const double memoryDock =
      sliderRowHeight * 4 + buttonHeight + AppSpacing.xl * 2;
}

abstract final class AppShadows {
  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.shadowTint,
      blurRadius: AppSizes.shadowBlur,
      offset: const Offset(0, AppSizes.shadowY),
    ),
  ];

  static List<BoxShadow> get button => AppShadows.card;

  static List<BoxShadow> get thumb => [
    BoxShadow(
      color: AppColors.sliderThumbShadow,
      blurRadius: AppSpacing.sm,
      offset: const Offset(0, AppSpacing.xxs),
    ),
  ];

  /// Gökyüzü üstündeki yazı / ikon.
  static List<Shadow> get onBackdrop => [
    Shadow(
      color: AppColors.onBackdropShadow,
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}

abstract final class AppBorders {
  static BorderSide get swatch => BorderSide(
    color: AppColors.swatchFrame,
    width: AppSizes.swatchFrameWidth,
  );
}

abstract final class AppDurations {
  static const Duration homeHueCycle = Duration(seconds: 8);
  static const Duration revealFade = Duration(milliseconds: 200);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration resultCountUp = Duration(milliseconds: 700);
  static const Duration howToLoop = Duration(milliseconds: 3200);
}

/// Home hue karesi — sabit L / C ile OKLCh'de döner.
abstract final class HomeSwatchStyle {
  static const double lightness = 0.72;
  static const double chroma = 0.15;
  static const double fullTurn = 360;
}

abstract final class AppOpacity {
  static const double disabled = 0.38;
  static const double mutedDiff = 0.45;
}

MascotMood mascotMoodForScore(int score, {int max = 100}) {
  final t = max <= 0 ? 0.0 : score / max;
  if (t >= 0.8) return MascotMood.happy;
  if (t >= 0.5) return MascotMood.ok;
  return MascotMood.encouraging;
}
