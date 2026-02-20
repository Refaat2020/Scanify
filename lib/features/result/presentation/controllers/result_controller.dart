import 'dart:io';

import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../processing/domain/entities/processing_result.dart';

class ResultController extends GetxController {
  final Rx<ProcessingResult?> result = Rx<ProcessingResult?>(null);

  // Face view: 0 = original, 1 = result (for PageView)
  final RxInt currentPage = 0.obs;

  // Slider comparison value 0.0 → 1.0
  final RxDouble sliderValue = 0.5.obs;

  // Whether the image slider compare mode is active
  final RxBool isSliderMode = true.obs;

  ProcessingResult get data => result.value!;
  bool get isFace => result.value?.isFace ?? false;
  bool get isDocument => result.value?.isDocument ?? false;

  String get formattedFileSize =>
      FileSizeFormatter.format(result.value?.fileSizeBytes ?? 0);

  String get resultLabel => isFace ? 'Face Processed' : 'Document Scanned';

  bool get originalFileExists =>
      File(result.value?.originalImagePath ?? '').existsSync();

  bool get resultFileExists =>
      File(result.value?.resultPath ?? '').existsSync();

  @override
  void onReady() {
    super.onReady();
    // ProcessingController passes ProcessingResult via Get.arguments
    final args = Get.arguments;
    if (args is ProcessingResult) {
      result.value = args;
    }
  }

  /// Called when user taps Done — clears stack back to home.
  /// HomeController.onReady fires again and reloads history automatically.
  void onDone() => Get.offAllNamed(AppRoutes.home);

  /// Share the result file (image or PDF) via system share sheet
  Future<void> onShare() async {
    final path = result.value?.resultPath;
    if (path == null || !File(path).existsSync()) return;
    await Share.shareXFiles([XFile(path)], subject: resultLabel);
  }
}
