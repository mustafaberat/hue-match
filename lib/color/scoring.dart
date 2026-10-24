/// ΔE → puan ve fark açıklaması (§5).
library;

import 'dart:math' as math;

import '../config/app_config.dart';
import 'composite.dart';
import 'distance.dart';
import 'oklab.dart';

enum ScoreLabel { perfect, soClose, good, notBad, farOff }

/// Görünen iki renk arasındaki OKLab ΔE.
double visibleDeltaE(MixColor target, MixColor player) =>
    rgbOklabDistance(target.visible, player.visible);

/// s = 100 × clamp(1 − ΔE / ΔE_max, 0, 1) ^ γ — yuvarlanmamış.
double rawScore(
  double deltaE, {
  double deltaEMax = ScoringConfig.deltaEMax,
  double gamma = ScoringConfig.gamma,
}) {
  final t = (1 - deltaE / deltaEMax).clamp(0.0, 1.0);
  return GameRules.maxRoundScore * math.pow(t, gamma).toDouble();
}

/// Yuvarlanmış puan, "Tekrar göster" cezası yok.
int scoreBeforeReplay(double deltaE) =>
    rawScore(deltaE).round().clamp(0, GameRules.maxRoundScore);

/// Tur puanı. "Tekrar göster" kullanıldıysa ×0.9 sonra yuvarla.
int roundScore(double deltaE, {bool replayUsed = false}) {
  final raw = rawScore(deltaE);
  final penalized = replayUsed ? raw * GameRules.replayPenalty : raw;
  return penalized.round().clamp(0, GameRules.maxRoundScore);
}

ScoreLabel labelFor(int score) {
  if (score >= ScoringConfig.perfectMin) return ScoreLabel.perfect;
  if (score >= ScoringConfig.soCloseMin) return ScoreLabel.soClose;
  if (score >= ScoringConfig.goodMin) return ScoreLabel.good;
  if (score >= ScoringConfig.notBadMin) return ScoreLabel.notBad;
  return ScoreLabel.farOff;
}

enum DiffChannel { r, g, b, brightness }

class ChannelDiff {
  const ChannelDiff({
    required this.channel,
    required this.value,
    required this.magnitude,
    this.highlighted = false,
  });

  final DiffChannel channel;

  /// R/G/B: oyuncu − hedef (0–255 birimi). Parlaklık: yüzde puan.
  final int value;

  /// Kanallar arası karşılaştırma için 0–1 normalize büyüklük.
  final double magnitude;
  final bool highlighted;

  ChannelDiff withHighlight(bool value) => ChannelDiff(
    channel: channel,
    value: this.value,
    magnitude: magnitude,
    highlighted: value,
  );
}

/// §5.3: oyuncunun görünen rengi hedefin A'sına bölünür, hedef RGB ile
/// karşılaştırılır; parlaklık farkı OKLab L farkından yüzde.
/// En büyük [ScoringConfig.highlightedDiffs] fark vurgulanır.
List<ChannelDiff> explainDifference(MixColor target, MixColor player) {
  final visible = player.visible;
  final targetA = target.alpha;
  int normalized(double v) => targetA <= 0
      ? 0
      : (v / targetA * MixerRules.channelMax).round().clamp(
          0,
          MixerRules.channelMax,
        );

  final dr = normalized(visible.r) - target.r;
  final dg = normalized(visible.g) - target.g;
  final db = normalized(visible.b) - target.b;
  final dl = rgbToOklab(visible).l - rgbToOklab(target.visible).l;
  final brightness = (dl * _percent).round();

  final diffs = [
    ChannelDiff(
      channel: DiffChannel.r,
      value: dr,
      magnitude: dr.abs() / MixerRules.channelMax,
    ),
    ChannelDiff(
      channel: DiffChannel.g,
      value: dg,
      magnitude: dg.abs() / MixerRules.channelMax,
    ),
    ChannelDiff(
      channel: DiffChannel.b,
      value: db,
      magnitude: db.abs() / MixerRules.channelMax,
    ),
    ChannelDiff(
      channel: DiffChannel.brightness,
      value: brightness,
      magnitude: dl.abs(),
    ),
  ];

  final ranked = [...diffs]..sort((x, y) => y.magnitude.compareTo(x.magnitude));
  final top = ranked
      .take(ScoringConfig.highlightedDiffs)
      .where((d) => d.value != 0)
      .map((d) => d.channel)
      .toSet();
  return [for (final d in diffs) d.withHighlight(top.contains(d.channel))];
}

const double _percent = 100;
