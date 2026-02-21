import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/history_item.dart';

class ItemThumbnail extends StatelessWidget {
  final HistoryItem item;

  const ItemThumbnail({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      child: SizedBox(
        width: 76,
        height: 76,
        child: item.isDocument ? _docThumb() : _imageThumb(),
      ),
    );
  }

  Widget _imageThumb() {
    final file = File(item.resultPath);
    return file.existsSync()
        ? Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _fallback(),
          )
        : _fallback();
  }

  Widget _docThumb() {
    return Container(
      color: AppTheme.primary.withValues(alpha: 0.08),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              color: AppTheme.primary,
              size: 26,
            ),
            SizedBox(height: 2),
            Text(
              'PDF',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Text(
          item.processingType.icon,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
