import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Local data source failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// File system failures
class FileSystemFailure extends Failure {
  const FileSystemFailure([super.message = 'File system error occurred']);
}

// Image processing failures
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure([super.message = 'Image processing failed']);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

// No faces/document detected
class DetectionFailure extends Failure {
  const DetectionFailure([super.message = 'No content detected in the image']);
}

// Invalid input
class InvalidInputFailure extends Failure {
  const InvalidInputFailure([super.message = 'Invalid input provided']);
}
