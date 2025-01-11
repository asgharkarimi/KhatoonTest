// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 0;

  @override
  TripModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TripModel(
      button1Title: fields[0] as String,
      button2Title: fields[1] as String,
      tripDuration: fields[2] as String,
      initialDate: fields[3] as String,
      firstDate: fields[4] as String,
      lastDate: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.button1Title)
      ..writeByte(1)
      ..write(obj.button2Title)
      ..writeByte(2)
      ..write(obj.tripDuration)
      ..writeByte(3)
      ..write(obj.initialDate)
      ..writeByte(4)
      ..write(obj.firstDate)
      ..writeByte(5)
      ..write(obj.lastDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
