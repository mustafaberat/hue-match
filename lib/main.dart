import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'app_scope.dart';
import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

  final services = AppServices(
    settings: SettingsService(),
    stats: StatsService(),
    ads: AdService(),
  );
  await services.load();
  services.ads.initialize();

  runApp(HueMatchApp(services: services));
}
