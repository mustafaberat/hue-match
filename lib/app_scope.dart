/// Servislere ağaç boyunca erişim.
library;

import 'package:flutter/widgets.dart';

import 'services/ad_service.dart';
import 'services/settings_service.dart';
import 'services/stats_service.dart';

class AppServices {
  AppServices({
    required this.settings,
    required this.stats,
    required this.ads,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final SettingsService settings;
  final StatsService stats;
  final AdService ads;

  /// Günlük meydan okuma tarihi; ekran görüntülerinde sabitlenir.
  final DateTime Function() clock;

  Future<void> load() async {
    await settings.load();
    await stats.load();
  }
}

class AppScope extends InheritedWidget {
  const AppScope({required this.services, required super.child, super.key});

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
