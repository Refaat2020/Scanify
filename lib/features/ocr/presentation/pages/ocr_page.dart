import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/ocr_controller.dart';
import '../widgets/ocr_empty_body.dart';
import '../widgets/ocr_error_body.dart';
import '../widgets/ocr_loading_body.dart';
import '../widgets/ocr_result_body.dart';

class OcrPage extends GetView<OcrController> {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return OcrLoadingBody(controller: controller);
        }

        if (controller.hasError.value) {
          return OcrErrorBody(
            message: controller.errorMessage.value,
            onBack: Get.back,
          );
        }

        if (!controller.hasResult) {
          return const OcrEmptyBody();
        }

        return OcrResultBody(controller: controller);
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        onPressed: Get.back,
      ),
      title: const GradientText(
        'OCR Extraction',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        // Copy all
        Obx(
          () => controller.hasResult
              ? IconButton(
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: controller.copyAll,
                  tooltip: 'Copy all',
                )
              : const SizedBox.shrink(),
        ),
        // Share
        Obx(
          () => controller.hasResult
              ? IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                  onPressed: controller.shareText,
                  tooltip: 'Share',
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
