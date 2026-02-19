/// Output of the face pipeline
class FaceProcessingOutput {
  final String resultImagePath;
  final int fileSizeBytes;
  final int facesDetected;

  const FaceProcessingOutput({
    required this.resultImagePath,
    required this.fileSizeBytes,
    required this.facesDetected,
  });
}
