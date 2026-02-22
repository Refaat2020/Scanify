import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/ocr_result.dart';

class OcrStatsBar extends StatelessWidget {
  final OcrResult result;

  const OcrStatsBar({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _Stat(
            icon: Icons.text_fields_rounded,
            label: '${result.wordCount} words',
          ),
          const SizedBox(width: 12),
          _Stat(
            icon: Icons.segment_rounded,
            label: '${result.blockCount} blocks',
          ),
          const SizedBox(width: 12),
          _Stat(
            icon: Icons.format_size_rounded,
            label: '${result.fullText.length} chars',
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
