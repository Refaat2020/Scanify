class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache operation failed']);
}

class FileSystemException implements Exception {
  final String message;
  const FileSystemException([this.message = 'File system operation failed']);
}

class ImageProcessingException implements Exception {
  final String message;
  const ImageProcessingException([this.message = 'Image processing failed']);
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission was denied']);
}

class DetectionException implements Exception {
  final String message;
  const DetectionException([this.message = 'No content was detected']);
}
