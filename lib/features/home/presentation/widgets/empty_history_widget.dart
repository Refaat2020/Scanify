import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../widgets/image_source_sheet.dart';

class EmptyHistoryWidget extends StatelessWidget {
  const EmptyHistoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('📷', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No images yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Capture a photo or pick one from your gallery to start processing.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Get Started',
              fullWidth: false,
              icon: Icons.add_rounded,
              onTap: ImageSourceSheet.show,
            ),
          ],
        ),
      ),
    );
  }
}
