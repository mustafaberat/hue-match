import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Verilirse düğme bu renkte olur (ana sayfada ortadaki kare).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final background = color ?? AppColors.accent;
    return _AppButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      background: background,
      pressed: Color.alphaBlend(AppColors.pressOverlay, background),
      foreground: foregroundOn(background),
      emphasized: true,
    );
  }
}

/// Solda bir renk, sağda diğeri. Sonuç ekranında hedef → senin rengin.
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    required this.left,
    required this.right,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color left;
  final Color right;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final mid = Color.lerp(left, right, 0.5)!;
    return _AppButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      background: mid,
      pressed: Color.alphaBlend(AppColors.pressOverlay, mid),
      foreground: foregroundOn(mid),
      gradient: [left, right],
      emphasized: true,
    );
  }
}

/// Dark text on light fills, white on dark — works for round-colour buttons.
Color foregroundOn(Color background) {
  final lum = background.computeLuminance();
  const dark = AppColors.textPrimary;
  const light = AppColors.onDark;
  return _contrastRatio(lum, dark.computeLuminance()) >=
          _contrastRatio(lum, light.computeLuminance())
      ? dark
      : light;
}

double _contrastRatio(double a, double b) {
  final hi = a > b ? a : b;
  final lo = a > b ? b : a;
  return (hi + 0.05) / (lo + 0.05);
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.subtitle,
    this.height = AppSizes.buttonHeight,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// İkinci satır (örn. "−%10"); varsa etiket küçülür.
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _AppButton(
      label: label,
      icon: icon,
      subtitle: subtitle,
      height: height,
      onPressed: onPressed,
      background: AppColors.surfaceHigh,
      pressed: AppColors.surfacePressed,
      foreground: AppColors.textPrimary,
      emphasized: false,
    );
  }
}

class _AppButton extends StatefulWidget {
  const _AppButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.pressed,
    required this.foreground,
    required this.emphasized,
    this.icon,
    this.subtitle,
    this.gradient,
    this.height = AppSizes.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color pressed;
  final Color foreground;
  final bool emphasized;
  final IconData? icon;
  final String? subtitle;
  final List<Color>? gradient;
  final double height;

  @override
  State<_AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<_AppButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : AppOpacity.disabled,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: widget.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _down = true) : null,
          onTapUp: enabled
              ? (_) {
                  setState(() => _down = false);
                  widget.onPressed?.call();
                }
              : null,
          onTapCancel: enabled ? () => setState(() => _down = false) : null,
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: widget.gradient == null
                    ? (_down ? widget.pressed : widget.background)
                    : null,
                gradient: widget.gradient == null
                    ? null
                    : LinearGradient(colors: widget.gradient!),
                borderRadius: BorderRadius.circular(AppRadii.button),
                border: widget.emphasized
                    ? null
                    : Border.all(color: AppColors.outline),
                boxShadow: _down ? const [] : AppShadows.button,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.foreground,
                        size: AppSizes.icon,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(child: _label(widget.foreground)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(Color foreground) {
    if (widget.subtitle == null) {
      return Text(
        widget.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.button.copyWith(color: foreground),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.small.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          widget.subtitle!,
          maxLines: 1,
          style: AppText.small.copyWith(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadowTint,
        shape: CircleBorder(side: BorderSide(color: AppColors.outline)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox.square(
            dimension: AppSizes.iconButton,
            child: Icon(
              icon,
              size: AppSizes.icon,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
