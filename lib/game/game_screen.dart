/// Oyun akışı: gösterim → karıştırma → sonuç → (5 tur) → oyun sonu.
///
/// Arka plana geçince Hafıza gösterimi donar, dönünce kaldığı yerden sürer.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_scope.dart';
import '../color/composite.dart';
import '../components/game_header.dart';
import '../components/round_strip.dart';
import '../config/app_config.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../l10n/app_localizations.dart';
import '../services/stats_service.dart';
import 'game_end_view.dart';
import 'mixer_view.dart';
import 'reveal_view.dart';
import 'round_result_view.dart';

enum GamePhase { reveal, mixing, result, end }

class GameScreen extends StatefulWidget {
  const GameScreen({required this.engine, this.dailyDate, super.key});

  final MatchEngine engine;
  final DateTime? dailyDate;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _reveal = AnimationController(vsync: this)
    ..addStatusListener(_onRevealStatus);
  late final AppServices _services = AppScope.of(context);
  final math.Random _random = math.Random();

  MatchEngine get _engine => widget.engine;
  GamePhase _phase = GamePhase.mixing;
  bool _replaying = false;
  MixColor _mix = MixColor.initial;
  RoundResult? _lastResult;
  GameOutcome? _outcome;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      _startRound();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reveal.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_phase != GamePhase.reveal) return;
    if (state == AppLifecycleState.resumed) {
      if (!_reveal.isCompleted) _reveal.forward();
    } else {
      _reveal.stop();
    }
  }

  int get _revealSeconds => widget.dailyDate != null
      ? GameRules.dailyRevealSeconds
      : _services.settings.revealSeconds;

  void _startRound() {
    _mix = _services.settings.randomStart ? _randomMix() : MixColor.initial;
    _replaying = false;
    if (_engine.mode == GameMode.memory) {
      _phase = GamePhase.reveal;
      _reveal.duration = Duration(seconds: _revealSeconds);
      _reveal.forward(from: 0);
    } else {
      _phase = GamePhase.mixing;
    }
  }

  MixColor _randomMix() => MixColor(
    r: _random.nextInt(MixerRules.channelMax + 1),
    g: _random.nextInt(MixerRules.channelMax + 1),
    b: _random.nextInt(MixerRules.channelMax + 1),
    alphaPercent:
        MixerRules.randomStartAlphaMin +
        _random.nextInt(
          MixerRules.alphaMax - MixerRules.randomStartAlphaMin + 1,
        ),
  );

  void _onRevealStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _phase == GamePhase.reveal) {
      setState(() {
        _phase = GamePhase.mixing;
        _replaying = false;
      });
    }
  }

  void _onReplay() {
    if (!_engine.useReplay()) return;
    setState(() {
      _phase = GamePhase.reveal;
      _replaying = true;
    });
    _reveal.duration = const Duration(milliseconds: GameRules.replayMillis);
    _reveal.forward(from: 0);
  }

  void _onConfirm() {
    final services = _services;
    final result = _engine.submit(_mix);
    if (!services.settings.onboardingDone) {
      services.settings.setOnboardingDone(true);
    }
    setState(() {
      _lastResult = result;
      _phase = GamePhase.result;
    });
  }

  Future<void> _onNext() async {
    if (!_engine.isFinished) {
      setState(_startRound);
      return;
    }
    final outcome = await _services.stats.recordGame(
      mode: _engine.mode,
      total: _engine.totalScore,
      dailyDate: widget.dailyDate,
    );
    _services.ads.recordGameFinished();
    if (!mounted) return;
    setState(() {
      _outcome = outcome;
      _phase = GamePhase.end;
    });
  }

  Future<void> _goHome() async {
    await _services.ads.maybeShowGameEndInterstitial();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _playAgain() async {
    await _services.ads.maybeShowGameEndInterstitial();
    if (!mounted) return;
    final settings = _services.settings;
    Navigator.of(context).pushReplacement(
      gameRoute(
        MatchEngine.random(
          mode: _engine.mode,
          colorBlindSafe: settings.colorBlindMode,
        ),
      ),
    );
  }

  Future<void> _onClose() async {
    if (_phase == GamePhase.end) {
      await _goHome();
      return;
    }
    final wasRevealing = _reveal.isAnimating;
    _reveal.stop();
    final leave = await showQuitDialog(context);
    if (!mounted) return;
    if (leave) {
      Navigator.of(context).pop();
    } else if (wasRevealing) {
      _reveal.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _services.settings;
    final showingResult = _phase == GamePhase.result || _phase == GamePhase.end;
    final roundNumber = showingResult
        ? _engine.results.length
        : _engine.roundNumber;

    final Widget body = switch (_phase) {
      GamePhase.reveal => AnimatedBuilder(
        key: ValueKey('reveal-${_engine.roundIndex}-$_replaying'),
        animation: _reveal,
        builder: (context, _) => RevealView(
          target: _engine.currentTarget,
          remaining: 1 - _reveal.value,
        ),
      ),
      GamePhase.mixing => ListenableBuilder(
        key: ValueKey('mix-${_engine.roundIndex}'),
        listenable: settings,
        builder: (context, _) => MixerView(
          mode: _engine.mode,
          target: _engine.currentTarget,
          mix: _mix,
          onMixChanged: (m) => setState(() => _mix = m),
          onConfirm: _onConfirm,
          showValues: settings.showValues,
          canReplay: _engine.canReplay,
          onReplay: _onReplay,
          showHint: !settings.onboardingDone,
          onHintDismissed: () => settings.setOnboardingDone(true),
        ),
      ),
      GamePhase.result => RoundResultView(
        key: ValueKey('result-${_engine.roundIndex}'),
        result: _lastResult!,
        isLastRound: _engine.isFinished,
        onNext: _onNext,
      ),
      GamePhase.end => GameEndView(
        key: const ValueKey('end'),
        total: _engine.totalScore,
        maxTotal: _engine.maxTotal,
        best: _outcome?.best ?? _engine.totalScore,
        isNewBest: _outcome?.isNewBest ?? false,
        entries: stripEntries(_engine.results),
        isDaily: _engine.isDaily,
        onHome: _goHome,
        onPlayAgain: _engine.isDaily ? null : _playAgain,
      ),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onClose();
      },
      child: GameFrame(
        header: _phase == GamePhase.end
            ? null
            : GameHeader(
                roundNumber: roundNumber,
                roundCount: _engine.roundCount,
                score: _engine.totalScore,
                onClose: _onClose,
                badge: dailyBadge(context, widget.dailyDate),
              ),
        child: AnimatedSwitcher(duration: AppDurations.revealFade, child: body),
      ),
    );
  }
}

/// Oyun ekranlarının ortak iskeleti: siyah sahne, güvenli alan, kenar boşluğu.
class GameFrame extends StatelessWidget {
  const GameFrame({required this.child, this.header, super.key});

  final Widget? header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  if (header != null) ...[
                    header!,
                    const SizedBox(height: AppSpacing.xl),
                  ],
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<StripEntry> stripEntries(List<RoundResult> results) => [
  for (final r in results)
    StripEntry(target: r.target, player: r.player, score: r.score),
];

String? dailyBadge(BuildContext context, DateTime? date) {
  if (date == null) return null;
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).toLanguageTag();
  return l10n.dailyHeader(DateFormat.MMMd(locale).format(date));
}

Route<void> gameRoute(MatchEngine engine, {DateTime? dailyDate}) =>
    PageRouteBuilder<void>(
      transitionDuration: AppDurations.medium,
      reverseTransitionDuration: AppDurations.medium,
      pageBuilder: (context, animation, secondaryAnimation) =>
          GameScreen(engine: engine, dailyDate: dailyDate),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );

Future<bool> showQuitDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.quitTitle),
      content: Text(l10n.quitBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.quitConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
