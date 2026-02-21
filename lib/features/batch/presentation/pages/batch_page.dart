import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/batch_controller.dart';
import '../widgets/batch_queue.dart';
import '../widgets/empty_batch.dart';

class BatchPage extends GetView<BatchController> {
  const BatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return EmptyBatch(onSelectImages: controller.pickImages);
        }
        return BatchQueue(controller: controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      leading: Obx(
        () => controller.isProcessing.value
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                onPressed: Get.back,
              ),
      ),
      title: const GradientText(
        'Batch Processing',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        Obx(() {
          if (controller.items.isEmpty || controller.isProcessing.value) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: Colors.redAccent,
            ),
            onPressed: controller.clearAll,
            tooltip: 'Clear all',
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }
}
