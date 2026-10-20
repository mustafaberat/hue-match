import 'package:flutter_test/flutter_test.dart';
import 'package:hue_match/color/composite.dart';
import 'package:hue_match/color/seeded_random.dart';
import 'package:hue_match/config/app_config.dart';
import 'package:hue_match/engine/match_engine.dart';

void main() {
  group('daily seed', () {
    test('same date ⇒ same targets', () {
      final day = DateTime(2026, 10, 19);
      final a = MatchEngine.dailyTargets(day);
      final b = MatchEngine.dailyTargets(DateTime(2026, 10, 19, 23, 59));
      expect(a, equals(b));
      expect(MatchEngine.daily(day).mode, GameMode.memory);
      expect(MatchEngine.daily(day).isDaily, isTrue);
    });

    test('different dates ⇒ different targets', () {
      final a = MatchEngine.dailyTargets(DateTime(2026, 10, 19));
      final b = MatchEngine.dailyTargets(DateTime(2026, 10, 20));
      expect(a, isNot(equals(b)));
    });

    test('seed is yyyymmdd', () {
      expect(GeneratorConfig.dailySeed(DateTime(2026, 1, 2)), 20260102);
    });

    test('SeededRandom is deterministic', () {
      final a = SeededRandom(42);
      final b = SeededRandom(42);
      for (var i = 0; i < 100; i++) {
        expect(a.nextDouble(), b.nextDouble());
      }
      final r = SeededRandom(1);
      for (var i = 0; i < 1000; i++) {
        final v = r.nextDouble();
        expect(v, inInclusiveRange(0, 1));
        expect(r.nextInt(5), inInclusiveRange(0, 4));
      }
    });
  });

  group('engine', () {
    const targets = [
      MixColor(r: 200, g: 40, b: 40, alphaPercent: 100),
      MixColor(r: 40, g: 200, b: 40, alphaPercent: 80),
      MixColor(r: 40, g: 40, b: 200, alphaPercent: 60),
      MixColor(r: 220, g: 220, b: 60, alphaPercent: 90),
      MixColor(r: 120, g: 120, b: 120, alphaPercent: 50),
    ];

    test('5 perfect rounds total 500', () {
      final engine = MatchEngine(targets: targets);
      expect(engine.maxTotal, GameRules.maxGameScore);
      for (final t in targets) {
        expect(engine.isFinished, isFalse);
        final result = engine.submit(t);
        expect(result.score, 100);
      }
      expect(engine.isFinished, isTrue);
      expect(engine.totalScore, 500);
      expect(() => engine.submit(targets.first), throwsStateError);
    });

    test('totals add up and replay penalty applies to one round only', () {
      final engine = MatchEngine(targets: targets);
      expect(engine.useReplay(), isTrue);
      expect(engine.useReplay(), isFalse);
      final first = engine.submit(targets[0]);
      expect(first.score, 90);
      expect(first.replayUsed, isTrue);
      expect(engine.canReplay, isTrue);

      final second = engine.submit(MixColor.initial);
      expect(second.replayUsed, isFalse);
      var expected = first.score + second.score;
      for (final t in targets.skip(2)) {
        expected += engine.submit(t).score;
      }
      expect(engine.totalScore, expected);
    });

    test('practice mode has no replay', () {
      final engine = MatchEngine(targets: targets, mode: GameMode.practice);
      expect(engine.canReplay, isFalse);
      expect(engine.useReplay(), isFalse);
    });

    test('random engine generates a full game', () {
      final engine = MatchEngine.random(random: SeededRandom(3));
      expect(engine.targets, hasLength(GameRules.roundsPerGame));
    });
  });
}
