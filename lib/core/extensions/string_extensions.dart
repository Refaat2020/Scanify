extension StringExtensions on String {
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns the file extension without the dot, lowercase.
  /// e.g. '/path/to/file.PDF' → 'pdf'
  String get fileExtension {
    final dot = lastIndexOf('.');
    return dot == -1 ? '' : substring(dot + 1).toLowerCase();
  }

  bool get isPdf => fileExtension == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'webp'].contains(fileExtension);
}
