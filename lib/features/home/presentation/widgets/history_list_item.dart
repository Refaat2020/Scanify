import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/processing_type_badge.dart';
import '../../domain/entities/history_item.dart';
import 'item_info.dart';
import 'item_swipe_background.dart';
import 'item_thumnail.dart';

class HistoryListItem extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback onDelete;

  const HistoryListItem({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: const ItemSwipeBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.historyDetail, arguments: item),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              ItemThumbnail(item: item),
              const SizedBox(width: 14),
              Expanded(child: ItemInfo(item: item)),
              ProcessingTypeBadge(type: item.processingType),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete item?',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'This will permanently remove the record and its associated file.',
          style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
