import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class PlaceholderPreview extends StatelessWidget {
  const PlaceholderPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('placeholder'),
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Center(child: Text('🖼️', style: TextStyle(fontSize: 56))),
    );
  }
}
