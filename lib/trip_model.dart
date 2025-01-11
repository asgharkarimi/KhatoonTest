import 'package:hive/hive.dart';

part 'trip_model.g.dart'; // Generated file

@HiveType(typeId: 0) // Unique typeId for Hive
class TripModel {
  @HiveField(0)
  final String button1Title;

  @HiveField(1)
  final String button2Title;

  @HiveField(2)
  final String tripDuration;

  @HiveField(3)
  final String initialDate;

  @HiveField(4)
  final String firstDate;

  @HiveField(5)
  final String lastDate;

  TripModel({
    required this.button1Title,
    required this.button2Title,
    required this.tripDuration,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });
}