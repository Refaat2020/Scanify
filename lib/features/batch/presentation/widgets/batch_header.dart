import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/batch_controller.dart';

class BatchHeader extends StatelessWidget {
  final BatchController controller;

  const BatchHeader({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 6),
          Text(
            '${controller.totalCount} images selected',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: controller.pickImages,
            icon: const Icon(
              Icons.add_rounded,
              size: 16,
              color: AppTheme.primary,
            ),
            label: const Text(
              'Add more',
              style: TextStyle(color: AppTheme.primary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
