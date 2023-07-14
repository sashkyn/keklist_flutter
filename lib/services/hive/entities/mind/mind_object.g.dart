// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mind_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MindObjectAdapter extends TypeAdapter<MindObject> {
  @override
  final int typeId = 1;

  @override
  MindObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MindObject()
      ..id = fields[0] as String
      ..emoji = fields[1] as String
      ..note = fields[2] as String
      ..dayIndex = fields[3] as int
      ..creationDate = fields[4] as DateTime
      ..sortIndex = fields[5] as int
      ..isUploadedToServer = fields[6] == null ? false : fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, MindObject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.emoji)
      ..writeByte(2)
      ..write(obj.note)
      ..writeByte(3)
      ..write(obj.dayIndex)
      ..writeByte(4)
      ..write(obj.creationDate)
      ..writeByte(5)
      ..write(obj.sortIndex)
      ..writeByte(6)
      ..write(obj.isUploadedToServer);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MindObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
