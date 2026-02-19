import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

class ProcessingErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const ProcessingErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('⚠️', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Processing failed',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Try Again',
            onTap: onRetry,
            icon: Icons.refresh_rounded,
          ),
          const SizedBox(height: 12),
          AppButton.secondary(label: 'Cancel', onTap: onCancel),
        ],
      ),
    );
  }
}
