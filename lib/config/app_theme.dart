/// Tema ve metin stilleri. Widget'lar burada tanımlı stilleri kullanır.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/backdrop.dart';
import 'tokens.dart';

export '../theme/backdrop.dart';
export '../theme/mascot.dart';
export '../theme/playful_title.dart';

abstract final class AppText {
  static const List<String> _fallback = ['Baloo2'];

  static TextStyle get displayHuge => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: _fallback,
    fontSize: AppSizes.scoreDisplay,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -2,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayLarge => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: _fallback,
    fontSize: AppSizes.totalDisplay,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get title => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: _fallback,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  static TextStyle get heading => TextStyle(
    fontFamily: AppFonts.display,
    fontFamilyFallback: _fallback,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get label => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get body => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodyStrong => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get small => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.15,
    color: AppColors.textSecondary,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.4,
    color: AppColors.textMuted,
  );

  static TextStyle get button => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.0,
  );

  static TextStyle get number => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textPrimary,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle get channelLetter => TextStyle(
    fontFamily: AppFonts.body,
    fontFamilyFallback: _fallback,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  /// Gökyüzü üstüne oturan yazı (WCAG AA-ish). Kart/plaka içinde kullanma.
  static TextStyle onSky(TextStyle base, {bool muted = false}) => base.copyWith(
    color: muted ? AppColors.textOnBackdropMuted : AppColors.textOnBackdrop,
    shadows: AppShadows.onBackdrop,
    fontWeight: FontWeight.w700,
  );
}

/// Kısa etiket: gökyüzü üstünde gölgeli koyu yazı.
class SkyCaption extends StatelessWidget {
  const SkyCaption(this.text, {this.textAlign, this.style, super.key});

  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.center,
      style: AppText.onSky(style ?? AppText.caption, muted: true),
    );
  }
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.accent,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    outline: AppColors.outline,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
    scaffoldBackgroundColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    dividerColor: AppColors.outline,
    textTheme: TextTheme(
      bodyMedium: AppText.body,
      bodyLarge: AppText.bodyStrong,
      titleLarge: AppText.heading,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.onAccent
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.surfaceHigh,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.outlineStrong,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      dragHandleColor: AppColors.outlineStrong,
    ),
  );
}

/// Renkli zemin + kenar süsü. Tüm tam ekranlar bunu kullanır.
class ThemedScaffold extends StatelessWidget {
  const ThemedScaffold({required this.body, super.key});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    const overlay = SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [const ThemeBackdrop(), body],
        ),
      ),
    );
  }
}

BoxDecoration appCardDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? AppColors.surface,
    borderRadius: BorderRadius.circular(AppRadii.card),
    border: Border.all(color: AppColors.outline),
    boxShadow: AppShadows.card,
  );
}
