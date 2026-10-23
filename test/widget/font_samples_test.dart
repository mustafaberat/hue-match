import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/config/app_theme.dart';
import 'package:hue_match/config/tokens.dart';
import 'package:hue_match/l10n/app_localizations.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final data = rootBundle.load(path);
    await (FontLoader(family)..addFont(data)).load();
  }

  final body = FontLoader(AppFonts.body);
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    body.addFont(rootBundle.load('assets/fonts/Baloo2-$w.ttf'));
  }
  await body.load();
  await load(AppFonts.display, 'assets/fonts/Nunito-ExtraBold.ttf');
  await load(AppFonts.notoJp, 'assets/fonts/NotoSansJP-Regular.ttf');
  await load(AppFonts.notoKr, 'assets/fonts/NotoSansKR-Regular.ttf');
  await load(AppFonts.notoSc, 'assets/fonts/NotoSansSC-Regular.ttf');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('each locale sample renders in display and body fonts', (
    tester,
  ) async {
    await _loadFonts();
    for (final code in AppLanguages.codes) {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          locale: Locale(code),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Scaffold(
                body: Column(
                  children: [
                    Text(l10n.howToStep1Title, style: AppText.heading),
                    Text(l10n.homeTagline, style: AppText.body),
                    Text(
                      '${l10n.play} ${l10n.bestScore} ${AppLanguages.nativeNames[code]}',
                      style: AppText.bodyStrong,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'locale $code');
      expect(
        find.textContaining(AppLanguages.nativeNames[code]!),
        findsOneWidget,
      );
    }
  });
}
