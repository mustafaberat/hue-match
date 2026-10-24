import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../config/tokens.dart';
import 'buttons.dart';

/// Minimal iki/üç seçenekli toggle (mod seçimi, hafıza süresi).
class Segmented<T> extends StatelessWidget {
  const Segmented({
    required this.options,
    required this.selected,
    required this.onChanged,
    this.height = AppSizes.segmentHeight,
    this.selectedColor,
    super.key,
  });

  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  /// Verilirse seçili dilim bu renk (home'da Oyna ile aynı).
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final active = selectedColor ?? AppColors.accent;
    final onActive = selectedColor == null
        ? AppColors.onAccent
        : foregroundOn(active);
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final entry in options.entries)
            Expanded(
              child: Semantics(
                selected: entry.key == selected,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(entry.key),
                  child: AnimatedContainer(
                    duration: AppDurations.fast,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: entry.key == selected
                          ? active
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.chip),
                    ),
                    child: Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.small.copyWith(
                        fontWeight: FontWeight.w800,
                        color: entry.key == selected
                            ? onActive
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
