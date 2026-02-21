import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Zoomable image viewer for face processing results.
/// Shows the composite B&W result with pinch-to-zoom.
class FaceDetailView extends StatelessWidget {
  final String resultPath;
  final String originalPath;

  const FaceDetailView({
    super.key,
    required this.resultPath,
    required this.originalPath,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Result'),
                Tab(text: 'Original'),
              ],
            ),
          ),

          // Images
          Expanded(
            child: TabBarView(
              children: [
                _ZoomableImage(path: resultPath),
                _ZoomableImage(path: originalPath),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatelessWidget {
  final String path;
  const _ZoomableImage({required this.path});

  @override
  Widget build(BuildContext context) {
    final file = File(path);
    if (!file.existsSync()) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: AppTheme.textMuted,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'Image not found',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 5.0,
      child: Center(child: Image.file(file, fit: BoxFit.contain)),
    );
  }
}
