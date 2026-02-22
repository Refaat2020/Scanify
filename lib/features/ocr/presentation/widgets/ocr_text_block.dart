import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class OcrTextBlock extends StatelessWidget {
  final String text;
  final int blockIndex;
  final String searchQuery;

  const OcrTextBlock({
    super.key,
    required this.text,
    required this.blockIndex,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block index label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Block ${blockIndex + 1}',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Text content with optional highlighting
          searchQuery.trim().isEmpty
              ? Text(
                  text,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                )
              : _HighlightedText(text: text, query: searchQuery),
        ],
      ),
    );
  }
}

/// Highlights all occurrences of [query] in [text]
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.6,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            backgroundColor: Color(0xFFFFE066),
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }
}
