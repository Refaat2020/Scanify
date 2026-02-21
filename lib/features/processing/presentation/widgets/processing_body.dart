import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/enums/processing_type.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/processing_controller.dart';
import 'animated_progress_bar.dart';
import 'image_preview.dart';
import 'placeholder_preview.dart';
import 'step_indicators.dart';

class ProcessingBody extends StatelessWidget {
  const ProcessingBody({required this.controller, super.key});
  final ProcessingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Image preview thumbnail
          Obx(() {
            final path = controller.originalImagePath.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: path.isNotEmpty
                  ? ImagePreview(path: path)
                  : const PlaceholderPreview(),
            );
          }),

          const SizedBox(height: 36),

          // Title
          Obx(() {
            final type = controller.detectedType.value;
            return GradientText(
              type == null ? 'Processing...' : type.label,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            );
          }),

          const SizedBox(height: 8),

          // Step label
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                controller.currentStep.value,
                key: ValueKey(controller.currentStep.value),
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Progress bar
          Obx(() => AnimatedProgressBar(progress: controller.progress.value)),

          const SizedBox(height: 12),

          // Progress percentage
          Obx(
            () => Text(
              '${(controller.progress.value * 100).toInt()}%',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Spacer(),

          // Step indicators
          Obx(
            () => StepIndicators(
              progress: controller.progress.value,
              isFace: controller.detectedType.value == ProcessingType.face,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
