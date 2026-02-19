import 'package:flutter/material.dart';
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

  // ── Reactive state ─────────────────────────────────────────────────────────
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

  // ── Orchestration ──────────────────────────────────────────────────────────
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
      _UnknownContentDialog(),
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

  // ── Document pipeline ──────────────────────────────────────────────────────
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

  // ── Save + navigate ────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// Unknown content dialog — shown when neither faces nor text are detected
// ─────────────────────────────────────────────────────────────────────────────

class _UnknownContentDialog extends StatelessWidget {
  const _UnknownContentDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF22222E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF9B59FF).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤔', style: TextStyle(fontSize: 30)),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Content not recognised',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'No faces or document text were detected. Choose how you\'d like to process this image:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFA0A0A8),
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            // Face option
            _ChoiceButton(
              emoji: '👤',
              label: 'Process as Face',
              subtitle: 'Apply B&W filter to detected regions',
              color: const Color(0xFF9B59FF),
              onTap: () => Get.back(result: ProcessingType.face),
            ),

            const SizedBox(height: 10),

            // Document option
            _ChoiceButton(
              emoji: '📄',
              label: 'Process as Document',
              subtitle: 'Enhance and export as PDF',
              color: const Color(0xFF00C9A7),
              onTap: () => Get.back(result: ProcessingType.document),
            ),

            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: () => Get.back(result: null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF6B6B75), fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF6B6B75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
