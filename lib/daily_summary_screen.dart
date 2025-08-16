import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';

class DailySummaryScreen extends StatelessWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealBox = Hive.box<Meal>('meals');
    final exerciseBox = Hive.box<Exercise>('exercise');
    final goalBox = Hive.box<Goal>('goal');

    final today = DateTime.now();

    final todayMeals =
        mealBox.values
            .where(
              (meal) =>
                  meal.date.year == today.year &&
                  meal.date.month == today.month &&
                  meal.date.day == today.day,
            )
            .toList();

    final todayExercises =
        exerciseBox.values
            .where(
              (exercise) =>
                  exercise.date.year == today.year &&
                  exercise.date.month == today.month &&
                  exercise.date.day == today.day,
            )
            .toList();

    final int totalCalories = todayMeals.fold(0, (sum, m) => sum + m.calories);
    final int totalExercise = todayExercises.fold(
      0,
      (sum, e) => sum + e.duration,
    );

    final latestGoal = goalBox.isEmpty ? null : goalBox.values.last;

    // Υπολογισμός ποσοστών με ασφάλεια
    final double calorieProgress =
        (latestGoal != null && latestGoal.calorieGoal > 0)
            ? totalCalories / latestGoal.calorieGoal
            : 0;

    final double exerciseProgress =
        (latestGoal != null && latestGoal.exerciseGoalMinutes > 0)
            ? totalExercise / latestGoal.exerciseGoalMinutes
            : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Ημερήσια Ανασκόπηση')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ημερομηνία: ${today.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Θερμίδες
            Text(
              'Σύνολο Θερμίδων: $totalCalories kcal',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (latestGoal != null && latestGoal.calorieGoal > 0) ...[
              Text(
                'Πρόοδος Θερμίδων: ${(calorieProgress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
              ),
              LinearProgressIndicator(
                value: calorieProgress.clamp(0.0, 1.0),
                color:
                    totalCalories <= latestGoal.calorieGoal
                        ? Colors.green
                        : Colors.red,
                backgroundColor: Colors.grey[300],
              ),
            ],

            const SizedBox(height: 20),

            // Άσκηση
            Text(
              'Σύνολο Άσκησης: $totalExercise λεπτά',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            if (latestGoal != null && latestGoal.exerciseGoalMinutes > 0) ...[
              Text(
                'Πρόοδος Άσκησης: ${(exerciseProgress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
              ),
              LinearProgressIndicator(
                value: exerciseProgress.clamp(0.0, 1.0),
                color:
                    totalExercise >= latestGoal.exerciseGoalMinutes
                        ? Colors.green
                        : Colors.red,
                backgroundColor: Colors.grey[300],
              ),
            ],

            const SizedBox(height: 20),

            // Έξτρα επιβεβαίωση στόχων
            if (latestGoal != null) ...[
              Text(
                totalCalories <= latestGoal.calorieGoal
                    ? '✅ Εντός στόχου θερμίδων'
                    : '❌ Πάνω από τον στόχο θερμίδων',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      totalCalories <= latestGoal.calorieGoal
                          ? Colors.green
                          : Colors.red,
                ),
              ),
              Text(
                totalExercise >= latestGoal.exerciseGoalMinutes
                    ? '✅ Επιτεύχθηκε ο στόχος άσκησης'
                    : '❌ Δεν επιτεύχθηκε ο στόχος άσκησης',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      totalExercise >= latestGoal.exerciseGoalMinutes
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ] else
              const Text(
                'Δεν έχει καταχωρηθεί στόχος.',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
