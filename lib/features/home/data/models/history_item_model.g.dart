// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemModelAdapter extends TypeAdapter<HistoryItemModel> {
  @override
  final typeId = 0;

  @override
  HistoryItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItemModel(
      id: fields[0] as String,
      processingTypeIndex: (fields[1] as num).toInt(),
      originalImagePath: fields[2] as String,
      resultPath: fields[3] as String,
      createdAt: fields[4] as DateTime,
      fileSizeBytes: (fields[5] as num).toInt(),
      facesDetected: (fields[6] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.processingTypeIndex)
      ..writeByte(2)
      ..write(obj.originalImagePath)
      ..writeByte(3)
      ..write(obj.resultPath)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.fileSizeBytes)
      ..writeByte(6)
      ..write(obj.facesDetected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
