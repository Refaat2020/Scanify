import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HistoryStatsHeader extends StatelessWidget {
  final int listLength;
  final int faceCount;
  final int docCount;

  const HistoryStatsHeader({
    super.key,
    required this.listLength,
    required this.docCount,
    required this.faceCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _StatChip(
            icon: '👤',
            label: '$faceCount face${faceCount != 1 ? 's' : ''}',
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          _StatChip(
            icon: '📄',
            label: '$docCount doc${docCount != 1 ? 's' : ''}',
            color: AppTheme.accent,
          ),
          const Spacer(),
          Text(
            '$listLength total',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
