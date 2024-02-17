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
    return MessageObject();
  }

  @override
  void write(BinaryWriter writer, MessageObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.rootMindId)
      ..writeByte(3)
      ..write(obj.timestamp);
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
