import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

class EmptyBatch extends StatelessWidget {
  final VoidCallback onSelectImages;

  const EmptyBatch({required this.onSelectImages, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('📦', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No images selected',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select multiple images from your gallery to process them all at once.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              label: 'Select Images',
              icon: Icons.photo_library_outlined,
              onTap: onSelectImages,
              fullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}
