/// En iyi skor (mod başına) ve günlük skorlar (günde bir kayıt).
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../engine/match_engine.dart';

class GameOutcome {
  const GameOutcome({
    required this.total,
    required this.best,
    required this.isNewBest,
  });

  final int total;
  final int best;
  final bool isNewBest;
}

class StatsService extends ChangeNotifier {
  SharedPreferences? _prefs;

  int bestMemory = 0;
  int bestPractice = 0;
  int gamesPlayed = 0;
  final Map<String, int> _daily = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    bestMemory = prefs.getInt(AppPrefsKeys.bestMemory) ?? 0;
    bestPractice = prefs.getInt(AppPrefsKeys.bestPractice) ?? 0;
    gamesPlayed = prefs.getInt(AppPrefsKeys.gamesPlayed) ?? 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith(AppPrefsKeys.dailyScorePrefix)) {
        final value = prefs.getInt(key);
        if (value != null) _daily[key] = value;
      }
    }
    notifyListeners();
  }

  int bestFor(GameMode mode) =>
      mode == GameMode.memory ? bestMemory : bestPractice;

  static String dailyKey(DateTime date) =>
      '${AppPrefsKeys.dailyScorePrefix}${GeneratorConfig.dailySeed(date)}';

  int? dailyScore(DateTime date) => _daily[dailyKey(date)];

  /// Günlük oyunlar mod en iyisini de günceller (Hafıza modu).
  Future<GameOutcome> recordGame({
    required GameMode mode,
    required int total,
    DateTime? dailyDate,
  }) async {
    final previousBest = bestFor(mode);
    final isNewBest = total > previousBest;
    gamesPlayed++;
    if (isNewBest) {
      if (mode == GameMode.memory) {
        bestMemory = total;
      } else {
        bestPractice = total;
      }
    }
    if (dailyDate != null && dailyScore(dailyDate) == null) {
      _daily[dailyKey(dailyDate)] = total;
      await _prefs?.setInt(dailyKey(dailyDate), total);
    }
    notifyListeners();
    await _prefs?.setInt(AppPrefsKeys.gamesPlayed, gamesPlayed);
    await _prefs?.setInt(
      mode == GameMode.memory
          ? AppPrefsKeys.bestMemory
          : AppPrefsKeys.bestPractice,
      bestFor(mode),
    );
    return GameOutcome(
      total: total,
      best: bestFor(mode),
      isNewBest: isNewBest && previousBest > 0,
    );
  }
}
