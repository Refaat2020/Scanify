import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';
import '../controllers/batch_controller.dart';

class BatchBottomActions extends StatelessWidget {
  final BatchController controller;

  const BatchBottomActions({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Obx(() {
        if (controller.isComplete) {
          return AppButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onTap: controller.onDone,
          );
        }

        if (controller.isProcessing.value) {
          return AppButton(
            label: 'Processing...',
            isLoading: true,
            onTap: null,
          );
        }

        return AppButton(
          label: 'Start Batch',
          icon: Icons.play_arrow_rounded,
          onTap: controller.startBatch,
        );
      }),
    );
  }
}
