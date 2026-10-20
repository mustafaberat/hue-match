import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/tokens.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _AppButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      background: AppColors.accent,
      pressed: AppColors.accentPressed,
      foreground: AppColors.onAccent,
    );
  }
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
      border: AppColors.outline,
    );
  }
}

class _AppButton extends StatelessWidget {
  const _AppButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.pressed,
    required this.foreground,
    this.icon,
    this.subtitle,
    this.border,
    this.height = AppSizes.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color pressed;
  final Color foreground;
  final IconData? icon;
  final String? subtitle;
  final Color? border;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : AppOpacity.disabled,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
            side: border == null ? BorderSide.none : BorderSide(color: border!),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            highlightColor: pressed,
            splashColor: pressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: foreground, size: AppSizes.icon),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Flexible(
                    child: subtitle == null
                        ? Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.button.copyWith(color: foreground),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.small.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                subtitle!,
                                maxLines: 1,
                                style: AppText.small.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        shape: const CircleBorder(side: BorderSide(color: AppColors.outline)),
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
