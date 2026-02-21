import 'dart:io';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class FileHelper {
  FileHelper._();

  static Future<Directory> getStorageDir(String subDir) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, subDir));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<Directory> getFaceResultsDir() =>
      getStorageDir(AppConstants.faceResultsDir);

  static Future<Directory> getDocumentResultsDir() =>
      getStorageDir(AppConstants.documentResultsDir);

  static Future<String> buildResultPath({
    required String subDir,
    required String extension, // e.g. 'jpg', 'pdf'
  }) async {
    final dir = await getStorageDir(subDir);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return p.join(dir.path, '${timestamp}_result.$extension');
  }

  static int fileSizeBytes(String path) {
    final file = File(path);
    return file.existsSync() ? file.lengthSync() : 0;
  }

  /// Deletes a file silently — never throws.
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {
      // Best-effort; caller should not depend on this succeeding
    }
  }
}
