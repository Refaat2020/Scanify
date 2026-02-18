enum ProcessingType {
  face,
  document;

  String get label {
    switch (this) {
      case ProcessingType.face:
        return 'Face Processed';
      case ProcessingType.document:
        return 'Document Scan';
    }
  }

  String get icon {
    switch (this) {
      case ProcessingType.face:
        return '👤';
      case ProcessingType.document:
        return '📄';
    }
  }
}
