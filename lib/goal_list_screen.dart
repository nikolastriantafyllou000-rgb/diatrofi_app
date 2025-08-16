import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/goal.dart';

class GoalListScreen extends StatefulWidget {
  const GoalListScreen({super.key});

  @override
  State<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends State<GoalListScreen> {
  @override
  Widget build(BuildContext context) {
    final goalBox = Hive.box<Goal>('goal');

    return Scaffold(
      appBar: AppBar(title: const Text('Αποθηκευμένοι Στόχοι')),
      body: ValueListenableBuilder(
        valueListenable: goalBox.listenable(),
        builder: (context, Box<Goal> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Δεν υπάρχουν καταχωρημένοι στόχοι.'),
            );
          }

          final goals = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final actualKey = box.keyAt(box.length - 1 - index);

              return ListTile(
                title: Text('Θερμίδες: ${goal.calorieGoal}'),
                subtitle: Text('Άσκηση: ${goal.exerciseGoalMinutes} λεπτά'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _showEditDialog(context, box, actualKey, goal),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, box, actualKey),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Box<Goal> box, dynamic key) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Διαγραφή Στόχου'),
            content: const Text('Είσαι σίγουρος ότι θέλεις να το διαγράψεις;'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ακύρωση'),
              ),
              TextButton(
                onPressed: () {
                  box.delete(key);
                  Navigator.of(context).pop();
                },
                child: const Text('Διαγραφή'),
              ),
            ],
          ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Box<Goal> box,
    dynamic key,
    Goal goal,
  ) {
    final calorieController = TextEditingController(
      text: goal.calorieGoal.toString(),
    );
    final exerciseController = TextEditingController(
      text: goal.exerciseGoalMinutes.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Επεξεργασία Στόχου'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: calorieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Θερμίδες'),
                ),
                TextField(
                  controller: exerciseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Άσκηση (λεπτά)',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ακύρωση'),
              ),
              TextButton(
                onPressed: () {
                  final updatedGoal = Goal(
                    calorieGoal:
                        int.tryParse(calorieController.text) ??
                        goal.calorieGoal,
                    exerciseGoalMinutes:
                        int.tryParse(exerciseController.text) ??
                        goal.exerciseGoalMinutes,
                  );
                  box.put(key, updatedGoal);
                  Navigator.of(context).pop();
                },
                child: const Text('Αποθήκευση'),
              ),
            ],
          ),
    );
  }
}
