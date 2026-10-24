import 'package:flutter/widgets.dart';

/// İçeriği tam genişlikte yerleştirir; kısa ekranlarda taşmak yerine küçülür.
class ShrinkToFit extends StatelessWidget {
  const ShrinkToFit({
    required this.child,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Align(
        alignment: alignment,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: box.maxWidth, child: child),
        ),
      ),
    );
  }
}
