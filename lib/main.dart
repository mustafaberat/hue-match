import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'app_scope.dart';
import 'config/tokens.dart';
import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  final services = AppServices(
    settings: SettingsService(),
    stats: StatsService(),
    ads: AdService(),
  );
  // Başlangıçta hiçbir hata/askı runApp'i engellememeli: aksi hâlde uygulama
  // splash ekranında takılı kalır. Hata olursa varsayılan ayarlarla açılır.
  await _guarded('orientation', () {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  });
  await _guarded('settings.load', services.settings.load);
  await _guarded('stats.load', services.stats.load);
  try {
    services.ads.initialize();
  } catch (error, stack) {
    debugPrint('startup ads.initialize failed: $error\n$stack');
  }

  runApp(HueMatchApp(services: services));
}

Future<void> _guarded(String label, Future<void> Function() step) async {
  try {
    await step().timeout(AppDurations.startupStepTimeout);
  } catch (error, stack) {
    debugPrint('startup $label failed: $error\n$stack');
  }
}
