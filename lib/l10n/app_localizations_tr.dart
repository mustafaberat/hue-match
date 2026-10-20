// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Renk Eşle';

  @override
  String get homeTagline => 'Gör. Hatırla. Karıştır.';

  @override
  String get play => 'Oyna';

  @override
  String get daily => 'Günlük';

  @override
  String get dailySubtitle => 'Bugün herkese aynı 5 renk';

  @override
  String dailyDone(int score, int max) {
    return 'Bugün $score / $max';
  }

  @override
  String get dailyComeBack => 'Yarın yeni renkler';

  @override
  String dailyHeader(String date) {
    return 'Günlük · $date';
  }

  @override
  String get modeMemory => 'Hafıza';

  @override
  String get modePractice => 'Pratik';

  @override
  String modeMemoryHint(int seconds) {
    return '$seconds sn gör, sonra hafızadan karıştır';
  }

  @override
  String get modePracticeHint => 'Karıştırırken hedef görünür kalır';

  @override
  String get bestScore => 'En iyi';

  @override
  String bestScoreValue(int score) {
    return 'En iyi $score';
  }

  @override
  String outOf(int max) {
    return '/ $max';
  }

  @override
  String get noBestYet => 'Henüz skor yok';

  @override
  String get settings => 'Ayarlar';

  @override
  String get howToPlay => 'Nasıl oynanır';

  @override
  String roundOf(int current, int total) {
    return 'Tur $current/$total';
  }

  @override
  String scoreValue(int score) {
    return 'Puan $score';
  }

  @override
  String get revealPrompt => 'Bu rengi hatırla';

  @override
  String get yourColor => 'Senin rengin';

  @override
  String get target => 'Hedef';

  @override
  String get you => 'Sen';

  @override
  String get confirm => 'Onayla';

  @override
  String get showAgain => 'Tekrar göster';

  @override
  String get showAgainCost => '−%10';

  @override
  String get fineTune => 'İnce ayar';

  @override
  String get firstRunHint => 'A = parlaklık. Siyaha doğru soldurur.';

  @override
  String get gotIt => 'Anladım';

  @override
  String get labelPerfect => 'Kusursuz';

  @override
  String get labelSoClose => 'Çok yakın';

  @override
  String get labelGood => 'İyi';

  @override
  String get labelNotBad => 'Fena değil';

  @override
  String get labelFarOff => 'Uzak';

  @override
  String get diffBrightness => 'Parlaklık';

  @override
  String get diffTitle => 'Hedefe göre rengin';

  @override
  String get replayPenaltyApplied => 'Tekrar göster kullanıldı · ×0.9';

  @override
  String get nextRound => 'Sonraki tur';

  @override
  String get seeSummary => 'Sonucu gör';

  @override
  String get gameOverTitle => 'Oyun bitti';

  @override
  String get dailyResultTitle => 'Günlük meydan okuma';

  @override
  String get newBest => 'Yeni rekor';

  @override
  String get playAgain => 'Tekrar oyna';

  @override
  String get home => 'Ana sayfa';

  @override
  String get rounds => 'Turlar';

  @override
  String get quitTitle => 'Oyundan çıkılsın mı?';

  @override
  String get quitBody => 'Bu oyundaki ilerlemen kaybolacak.';

  @override
  String get quitConfirm => 'Çık';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get close => 'Kapat';

  @override
  String get back => 'Geri';

  @override
  String get sectionGame => 'Oyun';

  @override
  String get sectionGeneral => 'Genel';

  @override
  String get sectionAbout => 'Hakkında';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsColorBlind => 'Renk körü modu';

  @override
  String get settingsColorBlindHint =>
      'Hedefler kırmızı–yeşil ekseninden kaçınır';

  @override
  String get settingsRevealTime => 'Hafıza süresi';

  @override
  String get settingsRevealTimeHint => 'Hedefin gösterilme süresi';

  @override
  String secondsShort(int seconds) {
    return '$seconds sn';
  }

  @override
  String get settingsShowValues => 'Değerleri göster';

  @override
  String get settingsShowValuesHint => 'Çubukların yanında sayılar';

  @override
  String get settingsRandomStart => 'Rastgele başla';

  @override
  String get settingsRandomStartHint => 'Çubuklar rastgele değerlerle başlar';

  @override
  String get settingsPrivacy => 'Gizlilik politikası';

  @override
  String get settingsVersion => 'Sürüm';

  @override
  String get howToStep1Title => 'Rengi hatırla';

  @override
  String get howToStep1Body => 'Bir renk göreceksin. İyi bak.';

  @override
  String get howToStep2Title => 'Karıştır';

  @override
  String get howToStep2Body => 'R, G, B ile rengi, A ile parlaklığı ayarla.';

  @override
  String get howToStep3Title => 'Onayla';

  @override
  String get howToStep3Body => 'Ne kadar yakınsan o kadar puan.';

  @override
  String get howToStep4Title => '5 tur';

  @override
  String get howToStep4Body => '5 turda en yüksek skoru yap.';

  @override
  String get howToNext => 'İleri';

  @override
  String get howToSkip => 'Geç';

  @override
  String get playNow => 'Şimdi oyna';

  @override
  String get channelRed => 'Kırmızı';

  @override
  String get channelGreen => 'Yeşil';

  @override
  String get channelBlue => 'Mavi';

  @override
  String get channelAlpha => 'Parlaklık';

  @override
  String sliderSemantics(String channel, int value) {
    return '$channel $value';
  }

  @override
  String get adPlaceholder => 'Reklam';

  @override
  String percentValue(String value) {
    return '%$value';
  }

  @override
  String get fineTuneHint => 'İnce ayar için çubuğa uzun bas';

  @override
  String get dailyLocked => 'Bugün oynandı';
}
