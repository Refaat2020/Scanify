import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class BatchProgressSummary extends StatelessWidget {
  final int total;
  final int completed;
  final int failed;
  final double progress;

  const BatchProgressSummary({
    super.key,
    required this.total,
    required this.completed,
    required this.failed,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final pending = total - completed - failed;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                label: 'Total',
                value: total.toString(),
                color: AppTheme.textPrimary,
              ),
              _Stat(
                label: 'Pending',
                value: pending.toString(),
                color: AppTheme.textMuted,
              ),
              _Stat(
                label: 'Done',
                value: completed.toString(),
                color: Colors.greenAccent.shade400,
              ),
              _Stat(
                label: 'Failed',
                value: failed.toString(),
                color: Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppTheme.background,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}
