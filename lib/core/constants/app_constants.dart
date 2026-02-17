class AppConstants {
  AppConstants._();

  static const String appName = 'Scanify';
  // Hive box names
  static const String historyBoxName = 'processing_history';

  // File storage directories
  static const String faceResultsDir = 'face_results';
  static const String documentResultsDir = 'document_results';
  static const String ocrResultsDir = 'ocr_results';

  // Processing step labels
  static const List<String> faceProcessingSteps = [
    'Loading image...',
    'Detecting faces...',
    'Cropping face regions...',
    'Applying B&W filter...',
    'Compositing result...',
    'Saving to storage...',
    'Done!',
  ];

  static const List<String> documentProcessingSteps = [
    'Loading image...',
    'Detecting text regions...',
    'Finding document edges...',
    'Applying perspective transform...',
    'Enhancing contrast...',
    'Generating PDF...',
    'Saving to storage...',
    'Done!',
  ];

  // OCR processing steps
  static const List<String> ocrProcessingSteps = [
    'Loading image...',
    'Detecting text regions...',
    'Extracting characters...',
    'Structuring blocks...',
    'Done!',
  ];
}
