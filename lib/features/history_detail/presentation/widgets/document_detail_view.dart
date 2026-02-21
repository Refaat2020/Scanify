import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';

class DocumentDetailView extends StatelessWidget {
  final String pdfPath;
  final VoidCallback onOpen;

  const DocumentDetailView({
    super.key,
    required this.pdfPath,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final exists = File(pdfPath).existsSync();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated PDF card
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 140,
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      blurRadius: 32,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppTheme.primary,
                      size: 60,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'PDF',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              pdfPath.split('/').last,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  exists
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: 13,
                  color: exists
                      ? Colors.greenAccent.shade400
                      : Colors.redAccent,
                ),
                const SizedBox(width: 5),
                Text(
                  exists ? 'Saved to device' : 'File not found',
                  style: TextStyle(
                    color: exists
                        ? Colors.greenAccent.shade400
                        : Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            AppButton(
              label: 'Open PDF',
              icon: Icons.open_in_new_rounded,
              onTap: exists ? onOpen : null,
            ),
          ],
        ),
      ),
    );
  }
}
