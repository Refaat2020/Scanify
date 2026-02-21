import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/processing_type_badge.dart';
import '../controllers/history_detail_controller.dart';
import 'detail_meta_row.dart';

class HistoryMetadataCard extends StatelessWidget {
  final HistoryDetailController controller;

  const HistoryMetadataCard({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Text(
                  'Details',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                ProcessingTypeBadge(
                  type: controller.data.processingType,
                  large: true,
                ),
              ],
            ),

            const SizedBox(height: 4),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            const SizedBox(height: 4),

            // Meta rows
            DetailMetaRow(
              icon: Icons.calendar_today_outlined,
              label: 'DATE',
              value: controller.formattedDate,
            ),
            DetailMetaRow(
              icon: Icons.data_usage_outlined,
              label: 'FILE SIZE',
              value: controller.formattedSize,
            ),
            if (controller.isFace)
              DetailMetaRow(
                icon: Icons.face_outlined,
                label: 'FACES DETECTED',
                value: controller.facesLabel,
                valueColor: AppTheme.primary,
              ),
            DetailMetaRow(
              icon: Icons.insert_drive_file_outlined,
              label: 'FILE PATH',
              value: controller.data.resultPath.split('/').last,
              valueColor: AppTheme.textSecondary,
              onTap: controller.copyPathToClipboard,
            ),
          ],
        ),
      ),
    );
  }
}
