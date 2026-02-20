import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/result_controller.dart';
import '../widgets/pdf_result_view.dart';
import '../widgets/result_meta_card.dart';
import '../widgets/side_by_side_comparison.dart';

class ResultPage extends GetView<ResultController> {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.result.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        return controller.isFace
            ? _FaceResultBody(controller: controller)
            : _DocumentResultBody(controller: controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Obx(
        () => GradientText(
          controller.isFace ? 'Face Result' : 'PDF Created',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      actions: [
        // Share button
        Obx(
          () => IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppTheme.textSecondary,
            ),
            onPressed: controller.result.value != null
                ? controller.onShare
                : null,
            tooltip: 'Share',
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// ── Face result body ──────────────────────────────────────────────────────────

class _FaceResultBody extends StatelessWidget {
  final ResultController controller;
  const _FaceResultBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image comparison area
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: SideBySideComparison(
              beforePath: controller.data.originalImagePath,
              afterPath: controller.data.resultPath,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Metadata card
        Obx(() => ResultMetaCard(result: controller.data)),

        const SizedBox(height: 20),

        // Done button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onTap: controller.onDone,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Document result body ──────────────────────────────────────────────────────

class _DocumentResultBody extends StatelessWidget {
  final ResultController controller;
  const _DocumentResultBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(
            () => PdfResultView(
              pdfPath: controller.data.resultPath,
              fileSizeBytes: controller.data.fileSizeBytes,
            ),
          ),
        ),

        // Metadata card
        Obx(() => ResultMetaCard(result: controller.data)),

        const SizedBox(height: 20),

        // Done button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onTap: controller.onDone,
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
