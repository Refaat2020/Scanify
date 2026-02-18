import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';

class ImageSourceSheet extends StatelessWidget {
  const ImageSourceSheet({super.key});

  static void show() {
    Get.bottomSheet(
      const ImageSourceSheet(),
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Source',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _SourceOption(
              icon: '📷',
              label: 'Camera',
              subtitle: 'Take a new photo',
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.processing,
                  arguments: {'source': 'camera'},
                );
              },
            ),
            const SizedBox(height: 10),
            _SourceOption(
              icon: '🖼️',
              label: 'Gallery',
              subtitle: 'Pick from your library',
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.processing,
                  arguments: {'source': 'gallery'},
                );
              },
            ),
            const SizedBox(height: 10),

            _SourceOption(
              icon: '📦',
              label: 'Batch Processing',
              subtitle: 'Process multiple images at once',
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.batch);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
