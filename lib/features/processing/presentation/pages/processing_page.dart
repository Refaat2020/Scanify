import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanify/features/processing/presentation/widgets/processing_error_widget.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/processing_controller.dart';
import '../widgets/processing_body.dart';

class ProcessingPage extends GetView<ProcessingController> {
  const ProcessingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Obx(() {
            if (controller.hasError.value) {
              return ProcessingErrorWidget(
                message: controller.errorMessage.value,
                onRetry: controller.retry,
                onCancel: Get.back,
              );
            }
            return ProcessingBody(controller: controller);
          }),
        ),
      ),
    );
  }
}
