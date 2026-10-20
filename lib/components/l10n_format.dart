import 'package:flutter/widgets.dart';

import '../color/scoring.dart';
import '../l10n/app_localizations.dart';

/// Tipografik eksi; "-" yerine "−".
const String _minus = '\u2212';
const String _plus = '+';

extension HueMatchStrings on AppLocalizations {
  String scoreLabel(ScoreLabel label) => switch (label) {
    ScoreLabel.perfect => labelPerfect,
    ScoreLabel.soClose => labelSoClose,
    ScoreLabel.good => labelGood,
    ScoreLabel.notBad => labelNotBad,
    ScoreLabel.farOff => labelFarOff,
  };

  String signed(int value) {
    if (value > 0) return '$_plus$value';
    if (value < 0) return '$_minus${value.abs()}';
    return '$value';
  }

  String percent(int value) => percentValue('$value');

  String signedPercent(int value) {
    if (value == 0) return percent(0);
    final sign = value > 0 ? _plus : _minus;
    return '$sign${percent(value.abs())}';
  }

  /// "R +18", "Parlaklık −12%".
  String diffText(ChannelDiff diff) => switch (diff.channel) {
    DiffChannel.r => 'R ${signed(diff.value)}',
    DiffChannel.g => 'G ${signed(diff.value)}',
    DiffChannel.b => 'B ${signed(diff.value)}',
    DiffChannel.brightness => '$diffBrightness ${signedPercent(diff.value)}',
  };
}

/// Türkçede i → İ, ı → I; Dart `toUpperCase` dil bilmez.
const Set<String> _dottedILanguages = {'tr', 'az'};

extension LocaleUpper on String {
  String upperFor(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final source = _dottedILanguages.contains(lang)
        ? replaceAll('i', 'İ').replaceAll('ı', 'I')
        : this;
    return source.toUpperCase();
  }
}
