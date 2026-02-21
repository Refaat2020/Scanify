import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/history_detail_controller.dart';
import '../widgets/document_detail_view.dart';
import '../widgets/face_detail_view.dart';
import '../widgets/history_action_card.dart';
import '../widgets/history_metadata_card.dart';

class HistoryDetailPage extends GetView<HistoryDetailController> {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Obx(() {
        if (controller.item.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        return _buildContent(context);
      }),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image / PDF viewer ─────────────────────────────────────
              SizedBox(
                height: 360,
                child: controller.isFace
                    ? FaceDetailView(
                        resultPath: controller.data.resultPath,
                        originalPath: controller.data.originalImagePath,
                      )
                    : DocumentDetailView(
                        pdfPath: controller.data.resultPath,
                        onOpen: controller.openPdf,
                      ),
              ),

              const SizedBox(height: 8),

              HistoryMetadataCard(controller: controller),

              const SizedBox(height: 16),

              HistoryActionsCard(controller: controller),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.background,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
        onPressed: Get.back,
      ),
      title: Obx(
        () => GradientText(
          controller.item.value?.processingType.label ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      actions: [
        // Share
        IconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          onPressed: controller.shareResult,
          tooltip: 'Share',
        ),
        // Delete
        Obx(
          () => controller.isDeleting.value
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: controller.deleteItem,
                  tooltip: 'Delete',
                ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
