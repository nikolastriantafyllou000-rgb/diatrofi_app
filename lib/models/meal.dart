import 'package:hive/hive.dart';

part 'meal.g.dart';

@HiveType(typeId: 0)
class Meal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int calories;

  @HiveField(2)
  DateTime date;

  Meal({required this.name, required this.calories, required this.date});
}
