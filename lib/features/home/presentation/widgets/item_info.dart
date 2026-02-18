import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../domain/entities/history_item.dart';

class ItemInfo extends StatelessWidget {
  final HistoryItem item;

  const ItemInfo({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.processingType.label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            DateFormatter.toRelative(item.createdAt),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            FileSizeFormatter.format(item.fileSizeBytes),
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          if (item.isFace && item.facesDetected != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '${item.facesDetected} face${item.facesDetected! > 1 ? 's' : ''} detected',
                style: const TextStyle(
                  color: AppTheme.primarySoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
