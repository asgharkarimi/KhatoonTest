import 'package:hive/hive.dart';

part 'trip_model.g.dart'; // Generated file
@HiveType(typeId: 0) // نوع ID برای مدل
class ServiceModel {
  @HiveField(0)
  final String origin;

  @HiveField(1)
  final String destination;

  @HiveField(2)
  final String cargoType;

  @HiveField(3)
  final String cargoWeight;

  @HiveField(4)
  final String shippingCost;

  @HiveField(5)
  final String totalCost;

  @HiveField(6)
  final String receiverName;

  @HiveField(7)
  final String receiverPhone;

  @HiveField(8)
  final String driverSalary;

  @HiveField(9)
  final String tollCost;

  @HiveField(10)
  final String fuelCost;

  @HiveField(11)
  final String disinfectionCost;

  @HiveField(12)
  final String billCost;

  @HiveField(13)
  final String highwayTollCost;

  @HiveField(14)
  final String loadingTipCost;

  @HiveField(15)
  final String unloadingTipCost;

  @HiveField(16)
  final String loadingScaleCost;

  @HiveField(17)
  final String unloadingScaleCost;

  @HiveField(18)
  final String otherCost;

  @HiveField(19)
  final String tripDuration;

  @HiveField(20)
  final String selectedDate1;

  @HiveField(21)
  final String selectedTime1;

  @HiveField(22)
  final String selectedDate2;

  @HiveField(23)
  final String selectedTime2;

  ServiceModel({
    required this.origin,
    required this.destination,
    required this.cargoType,
    required this.cargoWeight,
    required this.shippingCost,
    required this.totalCost,
    required this.receiverName,
    required this.receiverPhone,
    required this.driverSalary,
    required this.tollCost,
    required this.fuelCost,
    required this.disinfectionCost,
    required this.billCost,
    required this.highwayTollCost,
    required this.loadingTipCost,
    required this.unloadingTipCost,
    required this.loadingScaleCost,
    required this.unloadingScaleCost,
    required this.otherCost,
    required this.tripDuration,
    required this.selectedDate1,
    required this.selectedTime1,
    required this.selectedDate2,
    required this.selectedTime2,
  });
}
