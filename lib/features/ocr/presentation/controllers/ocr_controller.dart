import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/usecases/extract_text.dart';

class OcrController extends GetxController {
  final ExtractText _extractText;

  OcrController({required ExtractText extractText})
    : _extractText = extractText;

  final Rx<OcrResult?> result = Rx<OcrResult?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;

  // Search state
  final RxString searchQuery = ''.obs;
  final RxList<String> searchMatches = <String>[].obs;
  final RxInt currentMatchIndex = 0.obs;

  OcrResult get data => result.value!;
  bool get hasResult => result.value != null && !result.value!.isEmpty;

  /// Blocks filtered/highlighted by current search query
  List<OcrBlock> get filteredBlocks {
    if (result.value == null) return [];
    return result.value!.blocks;
  }

  @override
  void onReady() {
    super.onReady();
    final imagePath = Get.arguments as String?;
    if (imagePath != null) _run(imagePath);
  }

  Future<void> _run(String imagePath) async {
    isLoading.value = true;
    hasError.value = false;
    result.value = null;

    final steps = AppConstants.ocrProcessingSteps;

    _setStep(steps[0], 0.10);
    await _yield();
    _setStep(steps[1], 0.30);
    await _yield();
    _setStep(steps[2], 0.55);
    await _yield();
    _setStep(steps[3], 0.80);

    final outcome = await _extractText(ExtractTextParams(imagePath: imagePath));

    outcome.fold(
      (failure) {
        hasError.value = true;
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (ocr) {
        _setStep(steps[4], 1.0);
        result.value = ocr;
        isLoading.value = false;
      },
    );
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    currentMatchIndex.value = 0;

    if (query.trim().isEmpty || result.value == null) {
      searchMatches.clear();
      return;
    }

    final lower = query.toLowerCase();
    final words = result.value!.fullText
        .split(RegExp(r'\s+'))
        .where((w) => w.toLowerCase().contains(lower))
        .toList();

    searchMatches.assignAll(words);
  }

  void nextMatch() {
    if (searchMatches.isEmpty) return;
    currentMatchIndex.value =
        (currentMatchIndex.value + 1) % searchMatches.length;
  }

  void previousMatch() {
    if (searchMatches.isEmpty) return;
    currentMatchIndex.value =
        (currentMatchIndex.value - 1 + searchMatches.length) %
        searchMatches.length;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchMatches.clear();
    currentMatchIndex.value = 0;
  }

  Future<void> copyAll() async {
    if (result.value == null) return;
    await Clipboard.setData(ClipboardData(text: result.value!.fullText));
    Get.snackbar(
      'Copied',
      'All text copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> shareText() async {
    if (result.value == null) return;
    await SharePlus.instance.share(
      ShareParams(text: result.value!.fullText, subject: 'Extracted Text'),
    );
  }

  void _setStep(String label, double value) {
    currentStep.value = label;
    progress.value = value;
  }

  Future<void> _yield() => Future.delayed(const Duration(milliseconds: 80));
}
