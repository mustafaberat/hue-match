import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hue Match'**
  String get appTitle;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'See it. Remember it. Mix it.'**
  String get homeTagline;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @dailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Same 5 colors for everyone today'**
  String get dailySubtitle;

  /// No description provided for @dailyDone.
  ///
  /// In en, this message translates to:
  /// **'Today {score} / {max}'**
  String dailyDone(int score, int max);

  /// No description provided for @dailyComeBack.
  ///
  /// In en, this message translates to:
  /// **'New colors tomorrow'**
  String get dailyComeBack;

  /// No description provided for @dailyHeader.
  ///
  /// In en, this message translates to:
  /// **'Daily · {date}'**
  String dailyHeader(String date);

  /// No description provided for @modeMemory.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get modeMemory;

  /// No description provided for @modePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get modePractice;

  /// No description provided for @modeMemoryHint.
  ///
  /// In en, this message translates to:
  /// **'See it for {seconds} s, then mix from memory'**
  String modeMemoryHint(int seconds);

  /// No description provided for @modePracticeHint.
  ///
  /// In en, this message translates to:
  /// **'The target stays visible while you mix'**
  String get modePracticeHint;

  /// No description provided for @bestScore.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get bestScore;

  /// No description provided for @bestScoreValue.
  ///
  /// In en, this message translates to:
  /// **'Best {score}'**
  String bestScoreValue(int score);

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'/ {max}'**
  String outOf(int max);

  /// No description provided for @noBestYet.
  ///
  /// In en, this message translates to:
  /// **'No score yet'**
  String get noBestYet;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @roundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {current}/{total}'**
  String roundOf(int current, int total);

  /// No description provided for @scoreValue.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String scoreValue(int score);

  /// No description provided for @revealPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remember this color'**
  String get revealPrompt;

  /// No description provided for @yourColor.
  ///
  /// In en, this message translates to:
  /// **'Your color'**
  String get yourColor;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @showAgain.
  ///
  /// In en, this message translates to:
  /// **'Show again'**
  String get showAgain;

  /// No description provided for @showAgainCost.
  ///
  /// In en, this message translates to:
  /// **'−10%'**
  String get showAgainCost;

  /// No description provided for @fineTune.
  ///
  /// In en, this message translates to:
  /// **'Fine tune'**
  String get fineTune;

  /// No description provided for @firstRunHint.
  ///
  /// In en, this message translates to:
  /// **'A = brightness. It fades your color toward black.'**
  String get firstRunHint;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @labelPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get labelPerfect;

  /// No description provided for @labelSoClose.
  ///
  /// In en, this message translates to:
  /// **'So close'**
  String get labelSoClose;

  /// No description provided for @labelGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get labelGood;

  /// No description provided for @labelNotBad.
  ///
  /// In en, this message translates to:
  /// **'Not bad'**
  String get labelNotBad;

  /// No description provided for @labelFarOff.
  ///
  /// In en, this message translates to:
  /// **'Far off'**
  String get labelFarOff;

  /// No description provided for @diffBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get diffBrightness;

  /// No description provided for @diffTitle.
  ///
  /// In en, this message translates to:
  /// **'Your color vs target'**
  String get diffTitle;

  /// No description provided for @replayPenaltyApplied.
  ///
  /// In en, this message translates to:
  /// **'Show again used · ×0.9'**
  String get replayPenaltyApplied;

  /// No description provided for @nextRound.
  ///
  /// In en, this message translates to:
  /// **'Next round'**
  String get nextRound;

  /// No description provided for @seeSummary.
  ///
  /// In en, this message translates to:
  /// **'See total'**
  String get seeSummary;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOverTitle;

  /// No description provided for @dailyResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge'**
  String get dailyResultTitle;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'New best'**
  String get newBest;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @quitTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this game?'**
  String get quitTitle;

  /// No description provided for @quitBody.
  ///
  /// In en, this message translates to:
  /// **'Your progress in this game will be lost.'**
  String get quitBody;

  /// No description provided for @quitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get quitConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @sectionGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get sectionGame;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAbout;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get settingsSound;

  /// No description provided for @settingsHaptics.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsHaptics;

  /// No description provided for @settingsColorBlind.
  ///
  /// In en, this message translates to:
  /// **'Color-blind mode'**
  String get settingsColorBlind;

  /// No description provided for @settingsColorBlindHint.
  ///
  /// In en, this message translates to:
  /// **'Targets avoid the red–green axis'**
  String get settingsColorBlindHint;

  /// No description provided for @settingsRevealTime.
  ///
  /// In en, this message translates to:
  /// **'Memory time'**
  String get settingsRevealTime;

  /// No description provided for @settingsRevealTimeHint.
  ///
  /// In en, this message translates to:
  /// **'How long the target is shown'**
  String get settingsRevealTimeHint;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @settingsShowValues.
  ///
  /// In en, this message translates to:
  /// **'Show values'**
  String get settingsShowValues;

  /// No description provided for @settingsShowValuesHint.
  ///
  /// In en, this message translates to:
  /// **'Numbers next to the sliders'**
  String get settingsShowValuesHint;

  /// No description provided for @settingsRandomStart.
  ///
  /// In en, this message translates to:
  /// **'Random start'**
  String get settingsRandomStart;

  /// No description provided for @settingsRandomStartHint.
  ///
  /// In en, this message translates to:
  /// **'Sliders start at random values'**
  String get settingsRandomStartHint;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacy;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @howToStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Remember the color'**
  String get howToStep1Title;

  /// No description provided for @howToStep1Body.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see a color. Look closely.'**
  String get howToStep1Body;

  /// No description provided for @howToStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get howToStep2Title;

  /// No description provided for @howToStep2Body.
  ///
  /// In en, this message translates to:
  /// **'Set the color with R, G, B and the brightness with A.'**
  String get howToStep2Body;

  /// No description provided for @howToStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get howToStep3Title;

  /// No description provided for @howToStep3Body.
  ///
  /// In en, this message translates to:
  /// **'The closer you get, the more points you score.'**
  String get howToStep3Body;

  /// No description provided for @howToStep4Title.
  ///
  /// In en, this message translates to:
  /// **'5 rounds'**
  String get howToStep4Title;

  /// No description provided for @howToStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Make the highest score in 5 rounds.'**
  String get howToStep4Body;

  /// No description provided for @howToNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get howToNext;

  /// No description provided for @howToSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get howToSkip;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play now'**
  String get playNow;

  /// No description provided for @channelRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get channelRed;

  /// No description provided for @channelGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get channelGreen;

  /// No description provided for @channelBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get channelBlue;

  /// No description provided for @channelAlpha.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get channelAlpha;

  /// No description provided for @sliderSemantics.
  ///
  /// In en, this message translates to:
  /// **'{channel} {value}'**
  String sliderSemantics(String channel, int value);

  /// No description provided for @adPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ad'**
  String get adPlaceholder;

  /// No description provided for @percentValue.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentValue(String value);

  /// No description provided for @fineTuneHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a slider to fine tune'**
  String get fineTuneHint;

  /// No description provided for @dailyLocked.
  ///
  /// In en, this message translates to:
  /// **'Played today'**
  String get dailyLocked;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
