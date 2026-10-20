/// Saf Dart maç akışı: 5 tur, puan toplamı, günlük seed. Flutter bağımlılığı yok.
library;

import 'dart:math' as math;

import '../color/composite.dart';
import '../color/scoring.dart';
import '../color/seeded_random.dart';
import '../color/target_generator.dart';
import '../config/app_config.dart';

enum GameMode { memory, practice }

class RoundResult {
  const RoundResult({
    required this.target,
    required this.player,
    required this.deltaE,
    required this.score,
    required this.replayUsed,
    required this.diffs,
  });

  final MixColor target;
  final MixColor player;
  final double deltaE;
  final int score;
  final bool replayUsed;
  final List<ChannelDiff> diffs;

  ScoreLabel get label => labelFor(score);
}

class MatchEngine {
  MatchEngine({
    required List<MixColor> targets,
    this.mode = GameMode.memory,
    this.isDaily = false,
  }) : targets = List.unmodifiable(targets),
       assert(targets.isNotEmpty);

  factory MatchEngine.random({
    GameMode mode = GameMode.memory,
    bool colorBlindSafe = false,
    math.Random? random,
  }) {
    final generator = TargetGenerator(
      random: random,
      colorBlindSafe: colorBlindSafe,
    );
    return MatchEngine(
      targets: generator.generateSet(GameRules.roundsPerGame),
      mode: mode,
    );
  }

  /// Aynı tarih → aynı 5 renk (her platformda). Her zaman Hafıza modu.
  factory MatchEngine.daily(DateTime date, {bool colorBlindSafe = false}) {
    return MatchEngine(
      targets: dailyTargets(date, colorBlindSafe: colorBlindSafe),
      mode: GameMode.memory,
      isDaily: true,
    );
  }

  static List<MixColor> dailyTargets(
    DateTime date, {
    bool colorBlindSafe = false,
  }) {
    final generator = TargetGenerator(
      random: SeededRandom(GeneratorConfig.dailySeed(date)),
      colorBlindSafe: colorBlindSafe,
    );
    return generator.generateSet(GameRules.roundsPerGame);
  }

  final List<MixColor> targets;
  final GameMode mode;
  final bool isDaily;

  final List<RoundResult> _results = [];
  int _replaysUsed = 0;

  List<RoundResult> get results => List.unmodifiable(_results);
  int get roundCount => targets.length;
  int get roundIndex => _results.length;
  int get roundNumber => math.min(roundIndex + 1, roundCount);
  bool get isFinished => _results.length >= targets.length;
  MixColor get currentTarget => targets[math.min(roundIndex, roundCount - 1)];
  int get totalScore => _results.fold(0, (sum, r) => sum + r.score);
  int get maxTotal => roundCount * GameRules.maxRoundScore;

  bool get canReplay =>
      mode == GameMode.memory &&
      !isFinished &&
      _replaysUsed < GameRules.replaysPerRound;
  bool get replayUsedThisRound => _replaysUsed > 0;

  /// "Tekrar göster" hakkını kullanır. Hak yoksa false.
  bool useReplay() {
    if (!canReplay) {
      return false;
    }
    _replaysUsed++;
    return true;
  }

  RoundResult submit(MixColor player) {
    if (isFinished) {
      throw StateError('Match is finished');
    }
    final target = currentTarget;
    final deltaE = visibleDeltaE(target, player);
    final used = replayUsedThisRound;
    final result = RoundResult(
      target: target,
      player: player,
      deltaE: deltaE,
      score: roundScore(deltaE, replayUsed: used),
      replayUsed: used,
      diffs: explainDifference(target, player),
    );
    _results.add(result);
    _replaysUsed = 0;
    return result;
  }
}
