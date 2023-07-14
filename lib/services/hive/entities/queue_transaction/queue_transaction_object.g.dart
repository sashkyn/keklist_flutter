// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_transaction_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueTransactionObjectAdapter
    extends TypeAdapter<QueueTransactionObject> {
  @override
  final int typeId = 2;

  @override
  QueueTransactionObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueueTransactionObject(
      transaction: fields[0] as Future<dynamic>,
      debugName: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QueueTransactionObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.transaction)
      ..writeByte(1)
      ..write(obj.debugName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueTransactionObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
