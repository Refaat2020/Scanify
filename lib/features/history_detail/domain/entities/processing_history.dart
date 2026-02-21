import 'package:equatable/equatable.dart';

enum ProcessingType { face, document }

class ProcessingHistory extends Equatable {
  final String id;
  final String filePath;
  final ProcessingType type;
  final DateTime createdAt;
  final int fileSize;

  const ProcessingHistory({
    required this.id,
    required this.filePath,
    required this.type,
    required this.createdAt,
    required this.fileSize,
  });

  @override
  List<Object?> get props => [id, filePath, type, createdAt, fileSize];
}
