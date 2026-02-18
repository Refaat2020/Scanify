import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scanify/core/constants/app_constants.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_text.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_body.dart';
import '../widgets/image_source_sheet.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: HomeBody(controller),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.background,
      titleSpacing: 20,
      title: const GradientText(
        AppConstants.appName,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      actions: [
        Obx(() {
          if (!controller.hasHistory) return const SizedBox.shrink();
          return IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: controller.loadHistory,
            tooltip: 'Refresh',
            color: AppTheme.textSecondary,
          );
        }),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: ImageSourceSheet.show,
      backgroundColor: AppTheme.primary,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}
