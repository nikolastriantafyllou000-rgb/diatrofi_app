import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/exercise.dart';

class ExerciseListScreen extends StatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  @override
  Widget build(BuildContext context) {
    final exerciseBox = Hive.box<Exercise>('exercise');

    return Scaffold(
      appBar: AppBar(title: const Text('Αποθηκευμένες Ασκήσεις')),
      body: ValueListenableBuilder(
        valueListenable: exerciseBox.listenable(),
        builder: (context, Box<Exercise> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Δεν υπάρχουν καταχωρημένες ασκήσεις.'),
            );
          }

          final exercises = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final key = box.keyAt(box.length - 1 - index);

              return ListTile(
                title: Text(exercise.name),
                subtitle: Text(
                  'Διάρκεια: ${exercise.duration} λεπτά - Ένταση: ${exercise.intensity} - Ημερομηνία: ${exercise.date.toLocal().toString().substring(0, 16)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed:
                          () => _editExercise(context, box, key, exercise),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, box, key),
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

  void _confirmDelete(BuildContext context, Box<Exercise> box, dynamic key) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Επιβεβαίωση διαγραφής'),
            content: const Text(
              'Θέλεις σίγουρα να διαγράψεις αυτή την άσκηση;',
            ),
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

  void _editExercise(
    BuildContext context,
    Box<Exercise> box,
    dynamic key,
    Exercise exercise,
  ) {
    final nameController = TextEditingController(text: exercise.name);
    final durationController = TextEditingController(
      text: exercise.duration.toString(),
    );
    String intensity = exercise.intensity;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Επεξεργασία Άσκησης'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Όνομα Άσκησης'),
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: 'Διάρκεια (λεπτά)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: intensity,
                  items:
                      ['Χαμηλή', 'Μέτρια', 'Υψηλή']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) intensity = value;
                  },
                  decoration: const InputDecoration(labelText: 'Ένταση'),
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
                  final updatedExercise = Exercise(
                    name: nameController.text,
                    duration: int.tryParse(durationController.text) ?? 0,
                    intensity: intensity,
                    date: exercise.date,
                  );
                  box.put(key, updatedExercise);
                  Navigator.of(context).pop();
                },
                child: const Text('Αποθήκευση'),
              ),
            ],
          ),
    );
  }
}
