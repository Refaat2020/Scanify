import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_view.dart';
import '../controllers/home_controller.dart';
import 'empty_history_widget.dart';
import 'history_list_item.dart';
import 'history_stats_header.dart';

class HomeBody extends StatelessWidget {
  final HomeController controller;

  const HomeBody(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        );
      }

      if (controller.hasError) {
        return ErrorView(
          message: controller.errorMessage.value,
          onRetry: controller.loadHistory,
        );
      }

      if (!controller.hasHistory) {
        return const EmptyHistoryWidget();
      }

      return RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: AppTheme.surface,
        onRefresh: controller.loadHistory,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: HistoryStatsHeader(
                listLength: controller.historyItems.length,
                faceCount: controller.faceCount,
                docCount: controller.docCount,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = controller.historyItems[index];
                return HistoryListItem(
                  key: ValueKey(item.id),
                  item: item,
                  onDelete: () => controller.deleteItem(item.id),
                );
              }, childCount: controller.historyItems.length),
            ),
            // Bottom padding so FAB doesn't cover last item
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      );
    });
  }
}
