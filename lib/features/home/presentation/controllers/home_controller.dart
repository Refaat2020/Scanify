import 'package:get/get.dart';

import '../../../../core/enums/processing_type.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/usecases/delete_history_item.dart';
import '../../domain/usecases/get_history.dart';

class HomeController extends GetxController {
  final GetHistory _getHistory;
  final DeleteHistoryItem _deleteHistoryItem;

  HomeController({
    required GetHistory getHistory,
    required DeleteHistoryItem deleteHistoryItem,
  }) : _getHistory = getHistory,
       _deleteHistoryItem = deleteHistoryItem;

  final RxList<HistoryItem> historyItems = <HistoryItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await _getHistory(NoParams());

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (items) {
        historyItems.assignAll(items);
        isLoading.value = false;
      },
    );
  }

  Future<void> deleteItem(String id) async {
    historyItems.removeWhere((item) => item.id == id);

    final result = await _deleteHistoryItem(DeleteHistoryItemParams(id: id));

    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        loadHistory();
        Get.snackbar(
          'Error',
          failure.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
      (_) {
        // Success — UI already updated optimistically
      },
    );
  }

  /// Called after processing completes to refresh the list
  void onProcessingComplete() => loadHistory();

  bool get hasHistory => historyItems.isNotEmpty;
  bool get hasError => errorMessage.value.isNotEmpty;

  int get faceCount =>
      historyItems.where((i) => i.processingType == ProcessingType.face).length;

  int get docCount => historyItems
      .where((i) => i.processingType == ProcessingType.document)
      .length;
}
