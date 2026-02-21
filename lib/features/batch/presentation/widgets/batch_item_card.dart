import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/batch_job_item.dart';

class BatchItemCard extends StatelessWidget {
  final BatchJobItem item;
  final VoidCallback? onRemove;

  const BatchItemCard({super.key, required this.item, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          // Thumbnail
          _Thumbnail(path: item.imagePath),
          const SizedBox(width: 12),
          // Info
          Expanded(child: _buildInfo()),
          // Status icon
          _buildStatusIcon(),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final fileName = item.imagePath.split('/').last;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _statusLabel,
            style: TextStyle(
              color: _statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (item.isPending) {
      return Icon(Icons.schedule_outlined, size: 18, color: AppTheme.textMuted);
    }
    if (item.isProcessing) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppTheme.primary,
        ),
      );
    }
    if (item.isCompleted) {
      return Icon(
        Icons.check_circle_rounded,
        size: 20,
        color: Colors.greenAccent.shade400,
      );
    }
    if (item.isFailed) {
      return const Icon(Icons.error_rounded, size: 20, color: Colors.redAccent);
    }
    return const SizedBox.shrink();
  }

  String get _statusLabel {
    if (item.isPending) return 'Waiting...';
    if (item.isProcessing) return 'Processing...';
    if (item.isCompleted) {
      return item.detectedType?.label ?? 'Completed';
    }
    if (item.isFailed) return item.errorMessage ?? 'Failed';
    return '';
  }

  Color get _statusColor {
    if (item.isPending) return AppTheme.textMuted;
    if (item.isProcessing) return AppTheme.primary;
    if (item.isCompleted) return Colors.greenAccent.shade400;
    if (item.isFailed) return Colors.redAccent;
    return AppTheme.textMuted;
  }
}

class _Thumbnail extends StatelessWidget {
  final String path;
  const _Thumbnail({required this.path});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: SizedBox(
        width: 60,
        height: 60,
        child: File(path).existsSync()
            ? Image.file(File(path), fit: BoxFit.cover)
            : Container(
                color: AppTheme.surface,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppTheme.textMuted,
                ),
              ),
      ),
    );
  }
}
