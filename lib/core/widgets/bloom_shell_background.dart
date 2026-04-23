import 'package:flutter/material.dart';

class BloomShellBackground extends StatelessWidget {
  const BloomShellBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.09),
            scheme.tertiary.withValues(alpha: 0.07),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: child,
    );
  }
}
