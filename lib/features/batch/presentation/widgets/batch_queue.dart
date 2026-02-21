import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/batch_controller.dart';
import 'batch_bottom_actions.dart';
import 'batch_header.dart';
import 'batch_item_card.dart';
import 'batch_progress_summary.dart';

class BatchQueue extends StatelessWidget {
  final BatchController controller;

  const BatchQueue({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress summary
        Obx(
          () => controller.hasStarted.value
              ? BatchProgressSummary(
                  total: controller.totalCount,
                  completed: controller.completedCount.value,
                  failed: controller.failedCount.value,
                  progress: controller.progress,
                )
              : BatchHeader(controller: controller),
        ),

        // List of items
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final item = controller.items[i];
                return BatchItemCard(
                  key: ValueKey(item.id),
                  item: item,
                  onRemove: controller.isProcessing.value
                      ? null
                      : () => controller.removeItem(item.id),
                );
              },
            ),
          ),
        ),

        // Bottom actions
        BatchBottomActions(controller: controller),
      ],
    );
  }
}
