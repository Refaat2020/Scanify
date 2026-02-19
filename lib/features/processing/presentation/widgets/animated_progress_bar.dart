import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double progress;

  const AnimatedProgressBar({required this.progress, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (_, value, _) => LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.transparent,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
          ),
        ),
      ),
    );
  }
}
