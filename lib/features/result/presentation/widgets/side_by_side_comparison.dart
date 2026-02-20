import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class SideBySideComparison extends StatelessWidget {
  final String beforePath;
  final String afterPath;

  const SideBySideComparison({
    super.key,
    required this.beforePath,
    required this.afterPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Panel(
            path: beforePath,
            label: 'Before',
            labelColor: AppTheme.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _Panel(
            path: afterPath,
            label: 'After',
            labelColor: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String path;
  final String label;
  final Color labelColor;

  const _Panel({
    required this.path,
    required this.label,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    final file = File(path);
    if (!file.existsSync()) {
      return Container(
        color: AppTheme.surface,
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppTheme.textMuted,
            size: 32,
          ),
        ),
      );
    }
    return Image.file(file, fit: BoxFit.cover, width: double.infinity);
  }
}
