import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/enums/processing_type.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../home/domain/entities/history_item.dart';
import '../../../home/domain/usecases/save_history_item.dart';
import '../../domain/entities/processing_result.dart';
import '../../domain/usecases/detect_content_type.dart';
import '../../domain/usecases/process_document_image.dart';
import '../../domain/usecases/process_face_image.dart';
import '../widgets/unknown_content_dialog.dart';

class ProcessingController extends GetxController {
  final ImagePicker _picker;
  final DetectContentType _detectContentType;
  final ProcessFaceImage _processFaceImage;
  final ProcessDocumentImage _processDocumentImage;
  final SaveHistoryItem _saveHistoryItem;

  ProcessingController({
    required ImagePicker picker,
    required DetectContentType detectContentType,
    required ProcessFaceImage processFaceImage,
    required ProcessDocumentImage processDocumentImage,
    required SaveHistoryItem saveHistoryItem,
  }) : _picker = picker,
       _detectContentType = detectContentType,
       _processFaceImage = processFaceImage,
       _processDocumentImage = processDocumentImage,
       _saveHistoryItem = saveHistoryItem;

  final RxString currentStep = ''.obs;
  final RxDouble progress = 0.0.obs;
  final RxBool isProcessing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<ProcessingType?> detectedType = Rx<ProcessingType?>(null);
  final RxString originalImagePath = ''.obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments as Map<String, dynamic>?;
    final source = args?['source'] as String? ?? 'gallery';
    _run(source);
  }

  Future<void> _run(String source) async {
    isProcessing.value = true;
    hasError.value = false;

    // Step 1 — pick image
    _setStep('Selecting image...', 0.05);
    final imagePath = await _pickImage(source);
    if (imagePath == null) {
      Get.back();
      return;
    }
    originalImagePath.value = imagePath;

    // Step 2 — detect content type
    _setStep('Analysing image content...', 0.15);
    final typeResult = await _detectContentType(
      DetectContentTypeParams(imagePath: imagePath),
    );

    await typeResult.fold((failure) async => _setError(failure.message), (
      type,
    ) async {
      if (type == null) {
        // ── Unknown content — ask user what to do ─────────────────────────
        await _handleUnknownContent(imagePath);
      } else {
        detectedType.value = type;
        if (type == ProcessingType.face) {
          await _runFacePipeline(imagePath);
        } else {
          await _runDocumentPipeline(imagePath);
        }
      }
    });
  }

  // ── Unknown content dialog ─────────────────────────────────────────────────
  Future<void> _handleUnknownContent(String imagePath) async {
    // Pause the progress bar — we're waiting for user input
    isProcessing.value = false;
    _setStep('', 0.15);

    final choice = await Get.dialog<ProcessingType>(
      UnknownContentDialog(),
      barrierDismissible: false,
    );

    if (choice == null) {
      // User cancelled — go back to home
      Get.back();
      return;
    }

    // Resume with chosen pipeline
    isProcessing.value = true;
    detectedType.value = choice;

    if (choice == ProcessingType.face) {
      await _runFacePipeline(imagePath);
    } else {
      await _runDocumentPipeline(imagePath);
    }
  }

  // ── Face pipeline ──────────────────────────────────────────────────────────
  Future<void> _runFacePipeline(String imagePath) async {
    final steps = AppConstants.faceProcessingSteps;

    _setStep(steps[1], 0.25);
    await _yield();
    _setStep(steps[2], 0.45);
    await _yield();
    _setStep(steps[3], 0.60);
    await _yield();
    _setStep(steps[4], 0.75);

    final result = await _processFaceImage(
      ProcessFaceImageParams(imagePath: imagePath),
    );

    await result.fold((failure) async => _setError(failure.message), (
      output,
    ) async {
      _setStep(steps[5], 0.90);
      await _saveAndNavigate(output);
    });
  }

  Future<void> _runDocumentPipeline(String imagePath) async {
    final steps = AppConstants.documentProcessingSteps;

    _setStep(steps[1], 0.20);
    await _yield();
    _setStep(steps[2], 0.35);
    await _yield();
    _setStep(steps[3], 0.52);
    await _yield();
    _setStep(steps[4], 0.68);
    await _yield();
    _setStep(steps[5], 0.82);

    final result = await _processDocumentImage(
      ProcessDocumentImageParams(imagePath: imagePath),
    );

    await result.fold((failure) async => _setError(failure.message), (
      output,
    ) async {
      _setStep(steps[6], 0.93);
      await _saveAndNavigate(output);
    });
  }

  Future<void> _saveAndNavigate(ProcessingResult output) async {
    final item = HistoryItem(
      id: const Uuid().v4(),
      processingType: output.type,
      originalImagePath: output.originalImagePath,
      resultPath: output.resultPath,
      createdAt: DateTime.now(),
      fileSizeBytes: output.fileSizeBytes,
      facesDetected: output.facesDetected,
    );

    await _saveHistoryItem(SaveHistoryItemParams(item: item));

    _setStep('Done!', 1.0);
    await Future.delayed(const Duration(milliseconds: 300));
    Get.offNamed(AppRoutes.result, arguments: output);
  }

  // ── Image picker ───────────────────────────────────────────────────────────
  Future<String?> _pickImage(String source) async {
    try {
      final XFile? file = source == 'camera'
          ? await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 90,
              maxWidth: 2048,
              maxHeight: 2048,
            )
          : await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: 90,
              maxWidth: 2048,
              maxHeight: 2048,
            );
      return file?.path;
    } catch (e) {
      _setError(
        'Could not access ${source == 'camera' ? 'camera' : 'gallery'}: $e',
      );
      return null;
    }
  }

  // ── Retry ──────────────────────────────────────────────────────────────────
  void retry() {
    final args = Get.arguments as Map<String, dynamic>?;
    final source = args?['source'] as String? ?? 'gallery';
    _run(source);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  void _setStep(String label, double progressValue) {
    currentStep.value = label;
    progress.value = progressValue;
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    isProcessing.value = false;
  }

  Future<void> _yield() => Future.delayed(const Duration(milliseconds: 80));
}
