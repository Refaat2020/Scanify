import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/processing_type_badge.dart';
import '../../../processing/domain/entities/processing_result.dart';

class ResultMetaCard extends StatelessWidget {
  final ProcessingResult result;

  const ResultMetaCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          ProcessingTypeBadge(type: result.type, large: true),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.type.label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Success indicator
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: Colors.greenAccent.shade400,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    if (result.isFace) {
      final count = result.facesDetected ?? 0;
      return '$count face${count != 1 ? 's' : ''} processed';
    }
    return 'PDF exported successfully';
  }
}
