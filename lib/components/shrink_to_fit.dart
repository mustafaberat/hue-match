import 'package:flutter/widgets.dart';

/// İçeriği tam genişlikte yerleştirir; kısa ekranlarda taşmak yerine küçülür.
class ShrinkToFit extends StatelessWidget {
  const ShrinkToFit({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: box.maxWidth, child: child),
        ),
      ),
    );
  }
}
