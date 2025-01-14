// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ServiceModelAdapter extends TypeAdapter<ServiceModel> {
  @override
  final int typeId = 1;

  @override
  ServiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ServiceModel(
      origin: fields[0] as String,
      destination: fields[1] as String,
      cargoType: fields[2] as String,
      cargoWeight: fields[3] as String,
      shippingCost: fields[4] as String,
      totalCost: fields[5] as String,
      receiverName: fields[6] as String,
      receiverPhone: fields[7] as String,
      driverSalary: fields[8] as String,
      tollCost: fields[9] as String,
      fuelCost: fields[10] as String,
      disinfectionCost: fields[11] as String,
      billCost: fields[12] as String,
      highwayTollCost: fields[13] as String,
      loadingTipCost: fields[14] as String,
      unloadingTipCost: fields[15] as String,
      loadingScaleCost: fields[16] as String,
      unloadingScaleCost: fields[17] as String,
      otherCost: fields[18] as String,
      tripDuration: fields[19] as String,
      selectedDate1: fields[20] as String,
      selectedTime1: fields[21] as String,
      selectedDate2: fields[22] as String,
      selectedTime2: fields[23] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ServiceModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.origin)
      ..writeByte(1)
      ..write(obj.destination)
      ..writeByte(2)
      ..write(obj.cargoType)
      ..writeByte(3)
      ..write(obj.cargoWeight)
      ..writeByte(4)
      ..write(obj.shippingCost)
      ..writeByte(5)
      ..write(obj.totalCost)
      ..writeByte(6)
      ..write(obj.receiverName)
      ..writeByte(7)
      ..write(obj.receiverPhone)
      ..writeByte(8)
      ..write(obj.driverSalary)
      ..writeByte(9)
      ..write(obj.tollCost)
      ..writeByte(10)
      ..write(obj.fuelCost)
      ..writeByte(11)
      ..write(obj.disinfectionCost)
      ..writeByte(12)
      ..write(obj.billCost)
      ..writeByte(13)
      ..write(obj.highwayTollCost)
      ..writeByte(14)
      ..write(obj.loadingTipCost)
      ..writeByte(15)
      ..write(obj.unloadingTipCost)
      ..writeByte(16)
      ..write(obj.loadingScaleCost)
      ..writeByte(17)
      ..write(obj.unloadingScaleCost)
      ..writeByte(18)
      ..write(obj.otherCost)
      ..writeByte(19)
      ..write(obj.tripDuration)
      ..writeByte(20)
      ..write(obj.selectedDate1)
      ..writeByte(21)
      ..write(obj.selectedTime1)
      ..writeByte(22)
      ..write(obj.selectedDate2)
      ..writeByte(23)
      ..write(obj.selectedTime2);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
