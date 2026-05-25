import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../home/domain/entities/history_item.dart';
import '../../../home/domain/usecases/delete_history_item.dart';

class HistoryDetailController extends GetxController {
  final DeleteHistoryItem _deleteHistoryItem;

  HistoryDetailController({required DeleteHistoryItem deleteHistoryItem})
    : _deleteHistoryItem = deleteHistoryItem;

  final Rx<HistoryItem?> item = Rx<HistoryItem?>(null);
  final RxBool isDeleting = false.obs;

  HistoryItem get data => item.value!;

  bool get isDocument => item.value?.isDocument ?? false;
  bool get isFace => item.value?.isFace ?? false;

  bool get resultFileExists => File(item.value?.resultPath ?? '').existsSync();
  bool get originalFileExists =>
      File(item.value?.originalImagePath ?? '').existsSync();

  String get formattedDate =>
      DateFormatter.toFull(item.value?.createdAt ?? DateTime.now());

  String get formattedSize =>
      FileSizeFormatter.format(item.value?.fileSizeBytes ?? 0);

  String get facesLabel {
    final count = item.value?.facesDetected ?? 0;
    return '$count face${count != 1 ? 's' : ''} detected';
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onReady() {
    super.onReady();
    item.value = Get.arguments as HistoryItem?;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> openPdf() async {
    final path = item.value?.resultPath;
    if (path == null || !File(path).existsSync()) {
      Get.snackbar(
        'Error',
        'PDF file not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      Get.snackbar(
        'Error',
        'Could not open PDF: ${result.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> shareResult() async {
    final path = item.value?.resultPath;
    if (path == null || !File(path).existsSync()) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path)],
        subject: item.value?.processingType.label ?? 'Result',
      ),
    );
  }

  Future<void> copyPathToClipboard() async {
    final path = item.value?.resultPath ?? '';
    await Clipboard.setData(ClipboardData(text: path));
    Get.snackbar(
      'Copied',
      'File path copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void extractText() {
    final imagePath = item.value?.originalImagePath;
    if (imagePath == null) return;
    Get.toNamed(AppRoutes.ocr, arguments: imagePath);
  }

  Future<void> deleteItem() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF22222E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete this item?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently remove the record and its file from your device.',
          style: TextStyle(color: Color(0xFFA0A0A8), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B6B75)),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isDeleting.value = true;
    final result = await _deleteHistoryItem(
      DeleteHistoryItemParams(id: data.id),
    );

    result.fold(
      (failure) {
        isDeleting.value = false;
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) {
        // Navigate back to home — list will auto-refresh via HomeController
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }
}
