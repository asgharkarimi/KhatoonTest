// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cargo_type_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CargoTypeModelAdapter extends TypeAdapter<CargoTypeModel> {
  @override
  final int typeId = 0;

  @override
  CargoTypeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CargoTypeModel(
      fields[0] as String,
      selectionCount: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CargoTypeModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.selectionCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CargoTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
