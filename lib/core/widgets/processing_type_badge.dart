import 'package:flutter/material.dart';

import '../enums/processing_type.dart';
import '../theme/app_theme.dart';

class ProcessingTypeBadge extends StatelessWidget {
  final ProcessingType type;
  final bool large;

  const ProcessingTypeBadge({
    super.key,
    required this.type,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDoc = type == ProcessingType.document;
    final color = isDoc ? AppTheme.accent : AppTheme.primary;
    final label = isDoc ? 'DOC' : 'FACE';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 10 : 8,
        vertical: large ? 5 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(type.icon, style: TextStyle(fontSize: large ? 13 : 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: large ? 12 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
