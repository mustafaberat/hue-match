/// Hue Match — görsel token'lar. Widget'larda sayı / renk / süre yazılmaz.
///
/// UI koyu nötr (renkler doğru okunsun), tek sıcak aksan: mercan #FF7A59.
library;

import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Uygulama zemini — nötr, hafif sıcak olmayan neredeyse siyah.
  static const Color background = Color(0xFF0B0B0D);

  /// Renk sahnesi (§2): saf siyah.
  static const Color stage = Color(0xFF000000);

  /// Renk kutusu çerçevesi (§2).
  static const Color swatchFrame = Color(0xFF2A2A2A);

  static const Color surface = Color(0xFF141417);
  static const Color surfaceHigh = Color(0xFF1C1C20);
  static const Color surfacePressed = Color(0xFF24242A);
  static const Color outline = Color(0xFF26262B);
  static const Color outlineStrong = Color(0xFF3A3A41);

  static const Color textPrimary = Color(0xFFF5F5F4);
  static const Color textSecondary = Color(0xFFA6A6AD);
  static const Color textMuted = Color(0xFF6A6A72);

  static const Color accent = Color(0xFFFF7A59);
  static const Color accentPressed = Color(0xFFE8684A);
  static const Color onAccent = Color(0xFF1B0D08);
  static const Color accentSoft = Color(0x26FF7A59);

  static const Color sliderThumb = Color(0xFFFFFFFF);
  static const Color sliderThumbShadow = Color(0x66000000);
  static const Color scrim = Color(0xCC000000);
  static const Color hintBubble = Color(0xFFF5F5F4);
  static const Color onHintBubble = Color(0xFF111113);
  static const Color swatchCaptionScrim = Color(0x8C000000);
  static const Color bannerPlaceholder = Color(0xFF111114);

  /// Kanal kimlik noktaları (renge ek olarak harf + ikon da var, §7).
  static const Color channelR = Color(0xFFFF5A52);
  static const Color channelG = Color(0xFF3DDC84);
  static const Color channelB = Color(0xFF4C8DFF);
  static const Color channelA = Color(0xFFE6E6E6);
}

abstract final class AppFonts {
  /// Gövde / UI.
  static const String body = 'Manrope';

  /// Büyük skor, başlık, sayı.
  static const String display = 'SpaceGrotesk';
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

  /// Ekran yatay kenar boşluğu.
  static const double screen = 24;

  /// Pratik modunda hedef ↔ önizleme boşluğu (§4.2).
  static const double swatchGap = 8;
}

abstract final class AppRadii {
  static const double swatch = 20;
  static const double swatchSmall = 14;
  static const double button = 18;
  static const double card = 20;
  static const double chip = 999;
  static const double track = 999;
  static const double stage = 28;
}

abstract final class AppSizes {
  static const double maxContentWidth = 480;
  static const double buttonHeight = 58;
  static const double buttonHeightSmall = 46;
  static const double iconButton = 44;
  static const double icon = 22;
  static const double iconSmall = 18;
  static const double topBarHeight = 56;
  static const double roundSegmentWidth = 18;
  static const double roundSegmentHeight = 3;

  static const double swatchFrameWidth = 1;
  static const double homeSwatch = 216;
  static const double homeSwatchMaxFraction = 0.56;

  static const double revealBarHeight = 3;
  static const double revealBarWidthFraction = 0.6;

  static const double sliderRowHeight = 52;
  static const double sliderTrackHeight = 14;
  static const double sliderTrackHeightFine = 20;
  static const double sliderThumb = 28;
  static const double sliderThumbFine = 34;
  static const double sliderThumbBorder = 3;
  static const double sliderLabelWidth = 34;
  static const double sliderValueWidth = 44;

  static const double resultSwatchMax = 168;
  static const double scoreDisplay = 104;
  static const double totalDisplay = 72;

  static const double stripDot = 48;
  static const double stripDotSmall = 40;

  static const double pageDot = 6;
  static const double pageDotActive = 20;

  static const double hintArrow = 10;
  static const double hintMaxWidth = 280;

  static const double handIcon = 40;

  static const double bannerHeight = 50;
  static const double bannerWidth = 320;

  static const double settingsRowMinHeight = 60;
  static const double segmentHeight = 40;
  static const double settingsDividerIndent = 54;
  static const double revealSwatchMaxHeightFraction = 0.7;

  /// Hafıza modunda çubukların kapladığı sabit yükseklik. Gösterim ve
  /// karıştırma aynı yüksekliği ayırır; renk karesi yer değiştirmez.
  static const double memoryDock =
      sliderRowHeight * 4 + buttonHeight + AppSpacing.xl * 2;
}

abstract final class AppDurations {
  /// Home karesi bir tam hue turu (§9: ~8 s).
  static const Duration homeHueCycle = Duration(seconds: 8);

  /// Gösterim bitince hedef kare fade-out (§4.1).
  static const Duration revealFade = Duration(milliseconds: 200);

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration resultCountUp = Duration(milliseconds: 700);

  /// How-to demo döngüsü.
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
