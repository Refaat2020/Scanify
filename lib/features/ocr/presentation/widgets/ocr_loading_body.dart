import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/ocr_controller.dart';

class OcrLoadingBody extends StatelessWidget {
  final OcrController controller;

  const OcrLoadingBody({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated text scan icon
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 40)),
            ),
          ),

          const SizedBox(height: 28),

          const GradientText(
            'Reading text...',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 8),

          Obx(
            () => Text(
              controller.currentStep.value,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ),

          const SizedBox(height: 24),

          // Progress bar
          Obx(
            () => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: controller.progress.value),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, value, _) => ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  backgroundColor: AppTheme.surface,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
