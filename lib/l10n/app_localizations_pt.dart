// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Hue Match';

  @override
  String get homeTagline => 'See it. Remember it. Mix it.';

  @override
  String get play => 'Play';

  @override
  String get daily => 'Daily';

  @override
  String get dailySubtitle => 'Same 5 colors for everyone today';

  @override
  String dailyDone(int score, int max) {
    return 'Today $score / $max';
  }

  @override
  String get dailyComeBack => 'New colors tomorrow';

  @override
  String dailyHeader(String date) {
    return 'Daily · $date';
  }

  @override
  String get modeMemory => 'Memory';

  @override
  String get modePractice => 'Practice';

  @override
  String modeMemoryHint(int seconds) {
    return 'See it for $seconds s, then mix from memory';
  }

  @override
  String get modePracticeHint => 'The target stays visible while you mix';

  @override
  String get bestScore => 'Best';

  @override
  String bestScoreValue(int score) {
    return 'Best $score';
  }

  @override
  String outOf(int max) {
    return '/ $max';
  }

  @override
  String get noBestYet => 'No score yet';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to play';

  @override
  String roundOf(int current, int total) {
    return 'Round $current/$total';
  }

  @override
  String scoreValue(int score) {
    return 'Score $score';
  }

  @override
  String get revealPrompt => 'Remember this color';

  @override
  String get yourColor => 'Your color';

  @override
  String get target => 'Target';

  @override
  String get you => 'You';

  @override
  String get confirm => 'Confirm';

  @override
  String get showAgain => 'Show again';

  @override
  String get showAgainCost => '−10%';

  @override
  String get fineTune => 'Fine tune';

  @override
  String get firstRunHint =>
      'A = brightness. It fades your color toward black.';

  @override
  String get gotIt => 'Got it';

  @override
  String get labelPerfect => 'Perfect';

  @override
  String get labelSoClose => 'So close';

  @override
  String get labelGood => 'Good';

  @override
  String get labelNotBad => 'Not bad';

  @override
  String get labelFarOff => 'Far off';

  @override
  String get diffBrightness => 'Brightness';

  @override
  String get diffTitle => 'Your color vs target';

  @override
  String get replayPenaltyApplied => 'Show again used · ×0.9';

  @override
  String get nextRound => 'Next round';

  @override
  String get seeSummary => 'See total';

  @override
  String get gameOverTitle => 'Game over';

  @override
  String get dailyResultTitle => 'Daily challenge';

  @override
  String get newBest => 'New best';

  @override
  String get playAgain => 'Play again';

  @override
  String get home => 'Home';

  @override
  String get rounds => 'Rounds';

  @override
  String get quitTitle => 'Leave this game?';

  @override
  String get quitBody => 'Your progress in this game will be lost.';

  @override
  String get quitConfirm => 'Leave';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get sectionGame => 'Game';

  @override
  String get sectionGeneral => 'General';

  @override
  String get sectionAbout => 'About';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsColorBlind => 'Color-blind mode';

  @override
  String get settingsColorBlindHint => 'Targets avoid the red–green axis';

  @override
  String get settingsRevealTime => 'Memory time';

  @override
  String get settingsRevealTimeHint => 'How long the target is shown';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get settingsShowValues => 'Show values';

  @override
  String get settingsShowValuesHint => 'Numbers next to the sliders';

  @override
  String get settingsRandomStart => 'Random start';

  @override
  String get settingsRandomStartHint => 'Sliders start at random values';

  @override
  String get settingsPrivacy => 'Privacy policy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get howToStep1Title => 'Remember the color';

  @override
  String get howToStep1Body => 'You\'ll see a color. Look closely.';

  @override
  String get howToStep2Title => 'Mix';

  @override
  String get howToStep2Body =>
      'Set the color with R, G, B and the brightness with A.';

  @override
  String get howToStep3Title => 'Confirm';

  @override
  String get howToStep3Body => 'The closer you get, the more points you score.';

  @override
  String get howToStep4Title => '5 rounds';

  @override
  String get howToStep4Body => 'Make the highest score in 5 rounds.';

  @override
  String get howToNext => 'Next';

  @override
  String get howToSkip => 'Skip';

  @override
  String get playNow => 'Play now';

  @override
  String get channelRed => 'Red';

  @override
  String get channelGreen => 'Green';

  @override
  String get channelBlue => 'Blue';

  @override
  String get channelAlpha => 'Brightness';

  @override
  String sliderSemantics(String channel, int value) {
    return '$channel $value';
  }

  @override
  String get adPlaceholder => 'Ad';

  @override
  String percentValue(String value) {
    return '$value%';
  }

  @override
  String get fineTuneHint => 'Long-press a slider to fine tune';

  @override
  String get dailyLocked => 'Played today';
}
