import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class StepIndicators extends StatelessWidget {
  final double progress;
  final bool isFace;

  const StepIndicators({
    required this.progress,
    required this.isFace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // 5 visual steps for both pipelines
    const totalSteps = 5;
    final activeStep = (progress * totalSteps).floor().clamp(0, totalSteps);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isActive = i < activeStep;
        final isCurrent = i == activeStep - 1;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary
                : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
