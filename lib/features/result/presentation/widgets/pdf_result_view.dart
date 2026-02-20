import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../core/widgets/app_button.dart';

class PdfResultView extends StatelessWidget {
  final String pdfPath;
  final int fileSizeBytes;

  const PdfResultView({
    super.key,
    required this.pdfPath,
    required this.fileSizeBytes,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = pdfPath.split('/').last;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // PDF icon
        Container(
          width: 120,
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf_rounded,
                color: AppTheme.primary,
                size: 52,
              ),
              const SizedBox(height: 8),
              const Text(
                'PDF',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // File name
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            fileName,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          FileSizeFormatter.format(fileSizeBytes),
          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),

        const SizedBox(height: 8),

        // File exists indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              File(pdfPath).existsSync()
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              size: 14,
              color: File(pdfPath).existsSync()
                  ? Colors.greenAccent.shade400
                  : Colors.redAccent,
            ),
            const SizedBox(width: 5),
            Text(
              File(pdfPath).existsSync() ? 'Saved to device' : 'File not found',
              style: TextStyle(
                color: File(pdfPath).existsSync()
                    ? Colors.greenAccent.shade400
                    : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const Spacer(),

        // Open PDF button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AppButton(
            label: 'Open PDF',
            icon: Icons.open_in_new_rounded,
            onTap: () => _openPdf(context),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _openPdf(BuildContext context) async {
    if (!File(pdfPath).existsSync()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PDF file not found')));
      return;
    }
    final result = await OpenFilex.open(pdfPath);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open PDF: ${result.message}')),
      );
    }
  }
}
