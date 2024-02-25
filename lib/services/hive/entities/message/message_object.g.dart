// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageObjectAdapter extends TypeAdapter<MessageObject> {
  @override
  final int typeId = 3;

  @override
  MessageObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageObject()
      ..id = fields[0] as String
      ..text = fields[1] as String
      ..rootMindId = fields[2] as String
      ..timestamp = fields[3] as DateTime
      ..sender = fields[4] as String?;
  }

  @override
  void write(BinaryWriter writer, MessageObject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.rootMindId)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.sender);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
