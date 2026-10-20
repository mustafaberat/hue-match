import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

class HueMatchApp extends StatelessWidget {
  const HueMatchApp({required this.services, this.home, super.key});

  final AppServices services;

  /// Ekran görüntüsü aracı belirli bir ekranı doğrudan açar.
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ListenableBuilder(
        listenable: services.settings,
        builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: buildAppTheme(),
          locale: Locale(services.settings.languageCode),
          supportedLocales: [
            for (final code in AppLanguages.codes) Locale(code),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: home ?? const HomeScreen(),
        ),
      ),
    );
  }
}
