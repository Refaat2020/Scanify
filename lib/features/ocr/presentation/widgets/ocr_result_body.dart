import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/ocr_controller.dart';
import 'ocr_search_bar.dart';
import 'ocr_stats_bar.dart';
import 'ocr_text_block.dart';

class OcrResultBody extends StatelessWidget {
  final OcrController controller;

  const OcrResultBody({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats
        Obx(() => OcrStatsBar(result: controller.data)),

        // Search bar
        Obx(
          () => OcrSearchBar(
            onChanged: controller.onSearchChanged,
            onNext: controller.nextMatch,
            onPrevious: controller.previousMatch,
            onClear: controller.clearSearch,
            matchCount: controller.searchMatches.length,
            currentMatch: controller.currentMatchIndex.value,
          ),
        ),

        // Text blocks
        Expanded(
          child: Obx(() {
            final blocks = controller.filteredBlocks;
            final query = controller.searchQuery.value;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 32),
              itemCount: blocks.length,
              itemBuilder: (_, i) => OcrTextBlock(
                key: ValueKey(i),
                text: blocks[i].text,
                blockIndex: i,
                searchQuery: query,
              ),
            );
          }),
        ),
      ],
    );
  }
}
