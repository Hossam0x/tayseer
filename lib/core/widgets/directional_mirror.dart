import 'package:flutter/material.dart';

/// يعكس الـ child أفقياً لما اتجاه التطبيق يكون LTR (إنجليزي، فرنساوي، إلخ)
/// ويسيبه زي ما هو في RTL (عربي)
///
/// مثال:
/// ```dart
/// DirectionalMirror(child: Icon(Icons.subdirectory_arrow_left))
/// DirectionalMirror(child: Icon(Icons.arrow_forward))
/// ```
class DirectionalMirror extends StatelessWidget {
  final Widget child;

  const DirectionalMirror({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    if (!isLtr) return child;
    return Transform.scale(scaleX: -1, child: child);
  }
}
