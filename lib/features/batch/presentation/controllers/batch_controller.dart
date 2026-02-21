import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../home/domain/entities/history_item.dart';
import '../../../home/domain/usecases/save_history_item.dart';
import '../../domain/entities/batch_job_item.dart';
import '../../domain/usecases/process_batch_images.dart';

class BatchController extends GetxController {
  final ImagePicker _picker;
  final ProcessBatchImage _processBatchImage;
  final SaveHistoryItem _saveHistoryItem;

  BatchController({
    required ImagePicker picker,
    required ProcessBatchImage processBatchImage,
    required SaveHistoryItem saveHistoryItem,
  }) : _picker = picker,
       _processBatchImage = processBatchImage,
       _saveHistoryItem = saveHistoryItem;

  final RxList<BatchJobItem> items = <BatchJobItem>[].obs;
  final RxBool isProcessing = false.obs;
  final RxBool hasStarted = false.obs;
  final RxInt completedCount = 0.obs;
  final RxInt failedCount = 0.obs;

  int get totalCount => items.length;
  int get pendingCount =>
      items.where((i) => i.isPending || i.isProcessing).length;
  double get progress => totalCount == 0
      ? 0
      : (completedCount.value + failedCount.value) / totalCount;
  bool get isComplete => hasStarted.value && pendingCount == 0;
  bool get hasFailures => failedCount.value > 0;

  Future<void> pickImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 2048,
        maxHeight: 2048,
      );

      if (files.isEmpty) return;

      // Convert to batch items
      convertTOBatchItems(files);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to select images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void convertTOBatchItems(List<XFile> files) {
    final batch = files.map((f) {
      return BatchJobItem(
        id: const Uuid().v4(),
        imagePath: f.path,
        status: BatchJobStatus.pending,
      );
    }).toList();

    items.assignAll(batch);
  }

  void removeItem(String id) {
    if (isProcessing.value) return; // can't remove during processing
    items.removeWhere((i) => i.id == id);
  }

  void clearAll() {
    if (isProcessing.value) return;
    items.clear();
    _resetCounters();
  }

  Future<void> startBatch() async {
    if (items.isEmpty || isProcessing.value) return;

    isProcessing.value = true;
    hasStarted.value = true;
    _resetCounters();

    for (int i = 0; i < items.length; i++) {
      await _processItem(i);
    }

    isProcessing.value = false;

    // Show completion snackbar
    Get.snackbar(
      'Batch Complete',
      '${completedCount.value} succeeded, ${failedCount.value} failed',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _processItem(int index) async {
    final item = items[index];

    // Mark as processing
    items[index] = item.copyWith(status: BatchJobStatus.processing);

    final result = await _processBatchImage(
      ProcessBatchImageParams(imagePath: item.imagePath),
    );

    await result.fold(
      (failure) async {
        // Failed
        items[index] = item.copyWith(
          status: BatchJobStatus.failed,
          errorMessage: failure.message,
        );
        failedCount.value++;
      },
      (output) async {
        // Success — save to history
        final historyItem = HistoryItem(
          id: const Uuid().v4(),
          processingType: output.type,
          originalImagePath: output.originalImagePath,
          resultPath: output.resultPath,
          createdAt: DateTime.now(),
          fileSizeBytes: output.fileSizeBytes,
          facesDetected: output.facesDetected,
        );

        await _saveHistoryItem(SaveHistoryItemParams(item: historyItem));

        items[index] = item.copyWith(
          status: BatchJobStatus.completed,
          detectedType: output.type,
          resultPath: output.resultPath,
        );
        completedCount.value++;
      },
    );
  }

  void _resetCounters() {
    completedCount.value = 0;
    failedCount.value = 0;
  }

  void onDone() => Get.offAllNamed(AppRoutes.home);
}
