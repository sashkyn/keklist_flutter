// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeatureFlagObjectAdapter extends TypeAdapter<FeatureFlagObject> {
  @override
  final int typeId = 0;

  @override
  FeatureFlagObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeatureFlagObject()
      ..flagType = fields[0] as String
      ..value = fields[1] == null ? true : fields[1] as bool;
  }

  @override
  void write(BinaryWriter writer, FeatureFlagObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.flagType)
      ..writeByte(1)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeatureFlagObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
