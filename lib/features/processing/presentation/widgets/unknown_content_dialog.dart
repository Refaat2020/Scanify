import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/enums/processing_type.dart';

class UnknownContentDialog extends StatelessWidget {
  const UnknownContentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF22222E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59FF).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤔', style: TextStyle(fontSize: 30)),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Content not recognised',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No faces or document text were detected. Choose how you\'d like to process this image:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFA0A0A8),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Face option
            _ChoiceButton(
              emoji: '👤',
              label: 'Process as Face',
              subtitle: 'Apply B&W filter to detected regions',
              color: const Color(0xFF9B59FF),
              onTap: () => Get.back(result: ProcessingType.face),
            ),

            const SizedBox(height: 10),

            // Document option
            _ChoiceButton(
              emoji: '📄',
              label: 'Process as Document',
              subtitle: 'Enhance and export as PDF',
              color: const Color(0xFF00C9A7),
              onTap: () => Get.back(result: ProcessingType.document),
            ),

            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B6B75), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B6B75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
