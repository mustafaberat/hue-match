/// Karıştırma (§4.2): canlı önizleme + R/G/B/A çubukları + Onayla.
///
/// Pratik modunda hedef önizlemenin hemen üstünde, eşit boyutta, 8 dp arayla.
library;

import 'package:flutter/material.dart';

import '../color/composite.dart';
import '../components/buttons.dart';
import '../components/color_swatch.dart';
import '../components/hint_bubble.dart';
import '../config/tokens.dart';
import '../engine/match_engine.dart';
import '../l10n/app_localizations.dart';
import 'channel_slider.dart';

class MixerView extends StatefulWidget {
  const MixerView({
    required this.mode,
    required this.target,
    required this.mix,
    required this.onMixChanged,
    required this.onConfirm,
    this.showValues = false,
    this.canReplay = false,
    this.onReplay,
    this.showHint = false,
    this.onHintDismissed,
    super.key,
  });

  final GameMode mode;
  final MixColor target;
  final MixColor mix;
  final ValueChanged<MixColor> onMixChanged;
  final VoidCallback onConfirm;
  final bool showValues;
  final bool canReplay;
  final VoidCallback? onReplay;
  final bool showHint;
  final VoidCallback? onHintDismissed;

  @override
  State<MixerView> createState() => _MixerViewState();
}

class _MixerViewState extends State<MixerView> {
  final LayerLink _alphaLink = LayerLink();
  bool _fine = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final practice = widget.mode == GameMode.practice;

    Widget slider(MixChannel channel) => ChannelSlider(
      channel: channel,
      mix: widget.mix,
      onChanged: widget.onMixChanged,
      showValue: widget.showValues,
      onFineChanged: (v) => setState(() => _fine = v),
    );

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: practice
                        ? Column(
                            children: [
                              Expanded(
                                child: ColorSwatchBox(
                                  color: widget.target.displayColor,
                                  caption: l10n.target,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.swatchGap),
                              Expanded(
                                child: ColorSwatchBox(
                                  color: widget.mix.displayColor,
                                  caption: l10n.yourColor,
                                ),
                              ),
                            ],
                          )
                        : LayoutBuilder(
                            builder: (context, c) {
                              final side = c.maxWidth.clamp(0.0, c.maxHeight);
                              return Center(
                                child: SizedBox.square(
                                  dimension: side,
                                  child: ColorSwatchBox(
                                    color: widget.mix.displayColor,
                                    caption: l10n.yourColor,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: AppSpacing.md,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: _fine ? 1 : 0,
                        duration: AppDurations.fast,
                        child: SwatchCaption(text: l10n.fineTune),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: practice ? null : AppSizes.memoryDock,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  slider(MixChannel.r),
                  slider(MixChannel.g),
                  slider(MixChannel.b),
                  CompositedTransformTarget(
                    link: _alphaLink,
                    child: slider(MixChannel.a),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      if (widget.mode == GameMode.memory) ...[
                        Expanded(
                          child: SecondaryButton(
                            label: l10n.showAgain,
                            icon: Icons.visibility_outlined,
                            subtitle: widget.canReplay
                                ? l10n.showAgainCost
                                : null,
                            onPressed: widget.canReplay ? widget.onReplay : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: PrimaryButton(
                          label: l10n.confirm,
                          icon: Icons.check_rounded,
                          onPressed: widget.onConfirm,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.showHint)
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: _alphaLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              child: HintBubble(
                text: l10n.firstRunHint,
                actionLabel: l10n.gotIt,
                onAction: widget.onHintDismissed ?? () {},
              ),
            ),
          ),
      ],
    );
  }
}
