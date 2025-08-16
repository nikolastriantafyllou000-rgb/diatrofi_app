import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  int calorieGoal;

  @HiveField(1)
  int exerciseGoalMinutes;

  Goal({required this.calorieGoal, required this.exerciseGoalMinutes});
}
