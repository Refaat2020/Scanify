import 'dart:io';

import 'package:flutter/foundation.dart'; // compute()
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:scanify/features/processing/data/processors/face_processor_impl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/file_helper.dart';
import '../models/document_processing_output.dart';
import '../models/face_processing_output.dart';
import '../models/face_rect.dart';
import '../processors/document_processor_impl.dart';
import 'image_processing_datasource.dart';

/// Runs in a separate isolate.
/// Takes processed JPEG bytes → generates A4 PDF → returns PDF bytes.
Future<Uint8List> _runPdfGenerationInIsolate(Uint8List jpgBytes) async {
  final pdf = pw.Document();
  final pdfImage = pw.MemoryImage(jpgBytes);

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) =>
          pw.Center(child: pw.Image(pdfImage, fit: pw.BoxFit.contain)),
    ),
  );

  return pdf.save();
}

class ImageProcessingDataSourceImpl implements ImageProcessingDataSource {
  FaceDetector? _faceDetector;
  TextRecognizer? _textRecognizer;
  FaceProcessorImpl faceProcessor;
  DocumentProcessorImpl documentProcessor;

  ImageProcessingDataSourceImpl(this.faceProcessor, this.documentProcessor);

  FaceDetector get faceDetector {
    _faceDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: false,
        enableLandmarks: false,
        enableContours: false,
        enableTracking: false,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    return _faceDetector!;
  }

  TextRecognizer get textRecognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  // ── hasFaces ───────────────────────────────────────────────────────────────
  // ML Kit already runs on a native thread — no compute() needed.

  @override
  Future<bool> hasFaces(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await faceDetector.processImage(inputImage);
      return faces.isNotEmpty;
    } catch (e) {
      throw DetectionException('Face detection failed: $e');
    }
  }

  // ── hasText ────────────────────────────────────────────────────────────────

  @override
  Future<bool> hasText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognised = await textRecognizer.processImage(inputImage);
      // Require at least 20 characters to avoid false positives on
      // watermarks, logos, or single words in a photo.
      return recognised.text.trim().length >= 20;
    } catch (e) {
      throw DetectionException('Text detection failed: $e');
    }
  }

  // ── Face pipeline ──────────────────────────────────────────────────────────

  @override
  Future<FaceProcessingOutput> processFaceImage(String imagePath) async {
    try {
      // 1. Read bytes — async I/O, stays on main isolate
      final imageBytes = await File(imagePath).readAsBytes();

      // 2. ML Kit face detection — runs on native thread, no compute needed
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw const ImageProcessingException('No faces found in image');
      }

      // 3. Build serializable face rects (Rect is not isolate-safe).
      //    Decode once here on the main isolate just to read dimensions —
      //    the heavy pixel work still happens inside compute() below.
      final imageForSize = img.decodeImage(imageBytes)!;
      final faceRects = faces.map((face) {
        final rect = face.boundingBox;
        final x = rect.left.clamp(0, imageForSize.width - 1).toInt();
        final y = rect.top.clamp(0, imageForSize.height - 1).toInt();
        final w = rect.width.clamp(1, imageForSize.width - x).toInt();
        final h = rect.height.clamp(1, imageForSize.height - y).toInt();
        return FaceRect(x: x, y: y, w: w, h: h);
      }).toList();
      //  4. ✅ COMPUTE — all heavy image work runs in a background isolate
      final resultJpgBytes = await faceProcessor.compositeFaces(
        imageBytes: imageBytes,
        rects: faceRects,
      );

      // 5. Write result — async I/O
      final resultPath = await FileHelper.buildResultPath(
        subDir: AppConstants.faceResultsDir,
        extension: 'jpg',
      );
      await File(resultPath).writeAsBytes(resultJpgBytes);

      return FaceProcessingOutput(
        resultImagePath: resultPath,
        fileSizeBytes: FileHelper.fileSizeBytes(resultPath),
        facesDetected: faces.length,
      );
    } on ImageProcessingException {
      rethrow;
    } catch (e) {
      throw ImageProcessingException('Face processing failed: $e');
    }
  }

  // ── Document pipeline ──────────────────────────────────────────────────────

  @override
  Future<DocumentProcessingOutput> processDocumentImage(
    String imagePath,
  ) async {
    try {
      // 1. Validate and read bytes
      final file = File(imagePath);
      if (!await file.exists()) {
        throw ImageProcessingException('Image file does not exist: $imagePath');
      }

      final imageBytes = await file.readAsBytes();
      if (imageBytes.isEmpty) {
        throw ImageProcessingException('Image file is empty: $imagePath');
      }

      // 2. ML Kit text recognition (validates it's a document)
      // This is optional validation - don't fail if text recognition fails
      try {
        final inputImage = InputImage.fromFilePath(imagePath);
        await textRecognizer.processImage(inputImage);
      } catch (e) {
        debugPrint(
          '⚠️  Text recognition validation failed (continuing anyway): $e',
        );
      }

      // 3. ✅ Single call to processor
      final processedJpgBytes = await documentProcessor.compositeDocument(
        imageBytes: imageBytes,
      );

      if (processedJpgBytes.isEmpty) {
        throw ImageProcessingException(
          'Document processing returned empty result',
        );
      }

      // 4. Generate PDF
      final pdfBytes = await compute(_pdfFromJpgBytes, processedJpgBytes);

      if (pdfBytes.isEmpty) {
        throw ImageProcessingException('PDF generation returned empty result');
      }

      // 5. Save PDF
      final pdfPath = await FileHelper.buildResultPath(
        subDir: AppConstants.documentResultsDir,
        extension: 'pdf',
      );
      await File(pdfPath).writeAsBytes(pdfBytes);

      return DocumentProcessingOutput(
        resultPdfPath: pdfPath,
        fileSizeBytes: FileHelper.fileSizeBytes(pdfPath),
      );
    } on ImageProcessingException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrint('Document processing error: $e');
      debugPrint('Stack trace: $stackTrace');
      throw ImageProcessingException('Document processing failed: $e');
    }
  }
  // ── Cleanup ────────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    await _faceDetector?.close();
    await _textRecognizer?.close();
  }
}

// Top-level wrapper for compute() — pdf.save() returns a Future so we
// need an async top-level fn. compute() supports async top-level functions.
Future<Uint8List> _pdfFromJpgBytes(Uint8List jpgBytes) =>
    _runPdfGenerationInIsolate(jpgBytes);
