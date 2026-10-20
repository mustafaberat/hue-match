/// Gradyan izli kanal çubuğu (§4.2).
///
/// İz, o anki diğer kanallarla bu kanalın 0→max gidişini siyah sahne üzerinde
/// gösterir; A izi siyah → mevcut renk. Uzun basınca ince ayar (×0.25).
library;

import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../components/color_swatch.dart';
import '../components/l10n_format.dart';
import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../config/tokens.dart';
import '../l10n/app_localizations.dart';

enum MixChannel { r, g, b, a }

extension MixChannelInfo on MixChannel {
  String get letter => switch (this) {
    MixChannel.r => 'R',
    MixChannel.g => 'G',
    MixChannel.b => 'B',
    MixChannel.a => 'A',
  };

  int get max =>
      this == MixChannel.a ? MixerRules.alphaMax : MixerRules.channelMax;

  Color get identity => switch (this) {
    MixChannel.r => AppColors.channelR,
    MixChannel.g => AppColors.channelG,
    MixChannel.b => AppColors.channelB,
    MixChannel.a => AppColors.channelA,
  };

  /// Renge güvenmeyen ikon (§7): her kanal farklı şekil.
  IconData get icon => switch (this) {
    MixChannel.r => Icons.change_history_rounded,
    MixChannel.g => Icons.crop_square_rounded,
    MixChannel.b => Icons.circle_outlined,
    MixChannel.a => Icons.brightness_6_rounded,
  };

  int valueOf(MixColor mix) => switch (this) {
    MixChannel.r => mix.r,
    MixChannel.g => mix.g,
    MixChannel.b => mix.b,
    MixChannel.a => mix.alphaPercent,
  };

  MixColor apply(MixColor mix, int value) {
    final v = value.clamp(0, max);
    return switch (this) {
      MixChannel.r => mix.copyWith(r: v),
      MixChannel.g => mix.copyWith(g: v),
      MixChannel.b => mix.copyWith(b: v),
      MixChannel.a => mix.copyWith(alphaPercent: v),
    };
  }

  String name(AppLocalizations l10n) => switch (this) {
    MixChannel.r => l10n.channelRed,
    MixChannel.g => l10n.channelGreen,
    MixChannel.b => l10n.channelBlue,
    MixChannel.a => l10n.channelAlpha,
  };

  String formatValue(AppLocalizations l10n, int value) =>
      this == MixChannel.a ? l10n.percent(value) : '$value';
}

class ChannelSlider extends StatefulWidget {
  const ChannelSlider({
    required this.channel,
    required this.mix,
    required this.onChanged,
    this.showValue = false,
    this.onFineChanged,
    this.enabled = true,
    super.key,
  });

  final MixChannel channel;
  final MixColor mix;
  final ValueChanged<MixColor> onChanged;
  final bool showValue;
  final ValueChanged<bool>? onFineChanged;
  final bool enabled;

  @override
  State<ChannelSlider> createState() => _ChannelSliderState();
}

class _ChannelSliderState extends State<ChannelSlider> {
  bool _fine = false;
  double _fineAnchorValue = 0;
  double _fineAnchorX = 0;
  double _trackWidth = 1;

  MixChannel get _channel => widget.channel;
  int get _value => _channel.valueOf(widget.mix);

  void _setValue(double raw) {
    final next = raw.round().clamp(0, _channel.max);
    if (next == _value) return;
    widget.onChanged(_channel.apply(widget.mix, next));
  }

  double _valueAt(double dx) {
    final usable = _trackWidth - AppSizes.sliderThumb;
    final t = ((dx - AppSizes.sliderThumb / 2) / usable).clamp(0.0, 1.0);
    return t * _channel.max;
  }

  void _setFine(bool value) {
    if (_fine == value) return;
    setState(() => _fine = value);
    widget.onFineChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final value = _value;
    final mix = widget.mix;
    final start = _channel == MixChannel.a
        ? AppColors.stage
        : _channel.apply(mix, 0).displayColor;
    final end = _channel.apply(mix, _channel.max).displayColor;
    final fraction = value / _channel.max;

    return Semantics(
      label: l10n.sliderSemantics(_channel.name(l10n), value),
      slider: true,
      value: _channel.formatValue(l10n, value),
      child: SizedBox(
        height: AppSizes.sliderRowHeight,
        child: Row(
          children: [
            SizedBox(
              width: AppSizes.sliderLabelWidth,
              child: Text(
                _channel.letter,
                style: AppText.channelLetter.copyWith(
                  color: _fine ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _trackWidth = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: widget.enabled
                        ? (d) => _setValue(_valueAt(d.localPosition.dx))
                        : null,
                    onHorizontalDragUpdate: widget.enabled
                        ? (d) => _fine
                              ? _setValue(
                                  _value +
                                      d.delta.dx /
                                          _trackWidth *
                                          _channel.max *
                                          MixerRules.fineTuneFactor,
                                )
                              : _setValue(_valueAt(d.localPosition.dx))
                        : null,
                    onLongPressStart: widget.enabled
                        ? (d) {
                            _fineAnchorValue = _value.toDouble();
                            _fineAnchorX = d.localPosition.dx;
                            _setFine(true);
                          }
                        : null,
                    onLongPressMoveUpdate: widget.enabled
                        ? (d) => _setValue(
                            _fineAnchorValue +
                                (d.localPosition.dx - _fineAnchorX) /
                                    _trackWidth *
                                    _channel.max *
                                    MixerRules.fineTuneFactor,
                          )
                        : null,
                    onLongPressEnd: (_) => _setFine(false),
                    onLongPressCancel: () => _setFine(false),
                    child: _Track(
                      start: start,
                      end: end,
                      fraction: fraction,
                      fine: _fine,
                      width: constraints.maxWidth,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: AppSizes.sliderValueWidth,
              child: Align(
                alignment: Alignment.centerRight,
                child: widget.showValue
                    ? Text(
                        _channel.formatValue(l10n, value),
                        style: AppText.number.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Icon(
                        _channel.icon,
                        size: AppSizes.iconSmall,
                        color: _channel.identity,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Track extends StatelessWidget {
  const _Track({
    required this.start,
    required this.end,
    required this.fraction,
    required this.fine,
    required this.width,
  });

  final Color start;
  final Color end;
  final double fraction;
  final bool fine;
  final double width;

  @override
  Widget build(BuildContext context) {
    final trackHeight = fine
        ? AppSizes.sliderTrackHeightFine
        : AppSizes.sliderTrackHeight;
    final thumb = fine ? AppSizes.sliderThumbFine : AppSizes.sliderThumb;
    final usable = width - AppSizes.sliderThumb;
    final center = AppSizes.sliderThumb / 2 + usable * fraction;

    return Stack(
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: AppDurations.fast,
          height: trackHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.track),
            border: Border.all(color: AppColors.outline),
            gradient: LinearGradient(colors: [start, end]),
          ),
        ),
        Positioned(
          left: center - thumb / 2,
          width: thumb,
          height: thumb,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sliderThumb,
              border: fine
                  ? Border.all(
                      color: AppColors.accent,
                      width: AppSizes.sliderThumbBorder,
                    )
                  : null,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.sliderThumbShadow,
                  blurRadius: AppSpacing.sm,
                  offset: Offset(0, AppSpacing.xxs),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
