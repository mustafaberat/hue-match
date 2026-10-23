/// Kalıcı ayarlar (§9) + onboarding bayrakları. Dil değişince UI anında güncellenir.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../engine/match_engine.dart';

class SettingsService extends ChangeNotifier {
  SharedPreferences? _prefs;

  /// null → cihaz dili (desteklenmiyorsa İngilizce).
  String? languageOverride;
  bool colorBlindMode = false;
  int revealSeconds = GameRules.defaultRevealSeconds;
  bool showValues = false;
  bool randomStart = false;
  GameMode mode = GameMode.memory;
  bool onboardingDone = false;

  String get languageCode => languageOverride ?? deviceLanguage();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _prefs = prefs;
    final lang = prefs.getString(AppPrefsKeys.language);
    languageOverride = AppLanguages.nativeNames.containsKey(lang) ? lang : null;
    colorBlindMode = prefs.getBool(AppPrefsKeys.colorBlindMode) ?? false;
    final seconds = prefs.getInt(AppPrefsKeys.revealSeconds);
    revealSeconds = GameRules.revealSecondsOptions.contains(seconds)
        ? seconds!
        : GameRules.defaultRevealSeconds;
    showValues = prefs.getBool(AppPrefsKeys.showValues) ?? false;
    randomStart = prefs.getBool(AppPrefsKeys.randomStart) ?? false;
    final modeName = prefs.getString(AppPrefsKeys.gameMode);
    mode = GameMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => GameMode.memory,
    );
    onboardingDone = prefs.getBool(AppPrefsKeys.onboardingDone) ?? false;
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    if (!AppLanguages.nativeNames.containsKey(code)) return;
    languageOverride = code;
    notifyListeners();
    await _prefs?.setString(AppPrefsKeys.language, code);
  }

  Future<void> setColorBlindMode(bool value) => _setBool(
    AppPrefsKeys.colorBlindMode,
    value,
    () => colorBlindMode = value,
  );

  Future<void> setShowValues(bool value) =>
      _setBool(AppPrefsKeys.showValues, value, () => showValues = value);

  Future<void> setRandomStart(bool value) =>
      _setBool(AppPrefsKeys.randomStart, value, () => randomStart = value);

  Future<void> setOnboardingDone(bool value) => _setBool(
    AppPrefsKeys.onboardingDone,
    value,
    () => onboardingDone = value,
  );

  Future<void> setRevealSeconds(int value) async {
    if (!GameRules.revealSecondsOptions.contains(value)) return;
    revealSeconds = value;
    notifyListeners();
    await _prefs?.setInt(AppPrefsKeys.revealSeconds, value);
  }

  Future<void> setMode(GameMode value) async {
    mode = value;
    notifyListeners();
    await _prefs?.setString(AppPrefsKeys.gameMode, value.name);
  }

  Future<void> _setBool(String key, bool value, VoidCallback apply) async {
    apply();
    notifyListeners();
    await _prefs?.setBool(key, value);
  }

  static String deviceLanguage() {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return AppLanguages.nativeNames.containsKey(code)
        ? code
        : AppLanguages.fallback;
  }
}
