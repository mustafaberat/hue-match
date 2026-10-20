import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/engine/match_engine.dart';
import 'package:hue_match/services/stats_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('best score is stored locally and survives a reload', () async {
    SharedPreferences.setMockInitialValues({});
    final stats = StatsService();
    await stats.load();
    expect(stats.bestFor(GameMode.memory), 0);

    await stats.recordGame(mode: GameMode.memory, total: 320);
    await stats.recordGame(mode: GameMode.memory, total: 210);
    expect(stats.bestFor(GameMode.memory), 320);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt(AppPrefsKeys.bestMemory), 320);

    final reloaded = StatsService();
    await reloaded.load();
    expect(reloaded.bestFor(GameMode.memory), 320);
    expect(reloaded.bestFor(GameMode.practice), 0);
  });
}
