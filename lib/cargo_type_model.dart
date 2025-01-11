import 'package:hive/hive.dart';

part 'cargo_type_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class CargoTypeModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  int selectionCount; // Track selection count

  CargoTypeModel(this.name, {this.selectionCount = 0});
}