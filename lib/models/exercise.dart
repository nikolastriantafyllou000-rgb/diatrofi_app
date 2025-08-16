import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int duration;

  @HiveField(2)
  String intensity;

  @HiveField(3)
  DateTime date;

  Exercise({
    required this.name,
    required this.duration,
    required this.intensity,
    required this.date,
  });
}
