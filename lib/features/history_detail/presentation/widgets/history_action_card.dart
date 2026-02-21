import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/history_detail_controller.dart';

class HistoryActionsCard extends StatelessWidget {
  final HistoryDetailController controller;

  const HistoryActionsCard({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            // Share
            _ActionTile(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: controller.shareResult,
            ),

            Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
              indent: 56,
            ),

            // document only
            if (controller.isDocument) ...[
              _ActionTile(
                icon: Icons.text_snippet_outlined,
                label: 'Extract Text (OCR)',
                onTap: controller.extractText,
              ),

              Divider(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
                indent: 56,
              ),
              _ActionTile(
                icon: Icons.open_in_new_rounded,
                label: 'Open PDF',
                onTap: controller.openPdf,
              ),

              if (controller.isDocument)
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.06),
                  indent: 56,
                ),
            ],

            // Copy path
            _ActionTile(
              icon: Icons.copy_outlined,
              label: 'Copy file path',
              onTap: controller.copyPathToClipboard,
            ),

            Divider(
              height: 1,
              color: Colors.white.withValues(alpha: 0.06),
              indent: 56,
            ),

            // Delete
            _ActionTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: Colors.redAccent,
              onTap: controller.deleteItem,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: effectiveColor, size: 18),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
