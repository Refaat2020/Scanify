import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OcrErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const OcrErrorBody({required this.message, required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 20),
            const Text(
              'Extraction failed',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.primary,
              ),
              label: const Text(
                'Go back',
                style: TextStyle(color: AppTheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
