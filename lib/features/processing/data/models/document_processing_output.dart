/// Output of the document pipeline
class DocumentProcessingOutput {
  final String resultPdfPath;
  final int fileSizeBytes;

  const DocumentProcessingOutput({
    required this.resultPdfPath,
    required this.fileSizeBytes,
  });
}
