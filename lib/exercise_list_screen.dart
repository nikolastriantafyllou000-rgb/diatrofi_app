import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/exercise.dart';
import 'utils/date_format.dart';
import 'widgets/empty_state.dart';

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
            return const EmptyState(
              title: 'Δεν υπάρχουν ασκήσεις',
              subtitle: 'Πρόσθεσε την πρώτη σου άσκηση από την αρχική οθόνη.',
              icon: Icons.fitness_center,
            );
          }

          // Νεότερες πρώτες
          final exercises = box.values.toList().reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final actualKey = box.keyAt(box.length - 1 - index);

              final intensityColor = _intensityColor(exercise.intensity);

              return Dismissible(
                key: ValueKey(actualKey),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                confirmDismiss: (_) async {
                  return await _confirmDelete(
                    context,
                    box,
                    actualKey,
                    exercise,
                  );
                },
                onDismissed: (_) async {
                  await box.delete(actualKey);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Διαγράφηκε η άσκηση «${exercise.name}».',
                        ),
                      ),
                    );
                  }
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFE8F5E9),
                      child: const Icon(
                        Icons.directions_run,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Διάρκεια: ${exercise.duration} λεπτά • ${formatDateTime(exercise.date)}',
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: intensityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: intensityColor,
                              width: 0.6,
                            ),
                          ),
                          child: Text(
                            exercise.intensity,
                            style: TextStyle(
                              color: intensityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Επεξεργασία',
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () => _editExercise(
                                context,
                                box,
                                actualKey,
                                exercise,
                              ),
                        ),
                        IconButton(
                          tooltip: 'Διαγραφή',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await _confirmDelete(
                              context,
                              box,
                              actualKey,
                              exercise,
                            );
                            if (ok) {
                              await box.delete(actualKey);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Η άσκηση διαγράφηκε.'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _intensityColor(String intensity) {
    switch (intensity.trim()) {
      case 'Χαμηλή':
        return Colors.green;
      case 'Μέτρια':
        return Colors.orange;
      case 'Υψηλή':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    Box<Exercise> box,
    dynamic key,
    Exercise exercise,
  ) async {
    final result =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Διαγραφή Άσκησης'),
                content: Text('Να διαγραφεί η άσκηση «${exercise.name}»;'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Ακύρωση'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Διαγραφή'),
                  ),
                ],
              ),
        ) ??
        false;

    return result;
  }

  void _editExercise(
    BuildContext context,
    Box<Exercise> box,
    dynamic key,
    Exercise exercise,
  ) {
    final formKey = GlobalKey<FormState>();
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
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Όνομα άσκησης',
                      hintText: 'π.χ. Τρέξιμο',
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Απαιτείται όνομα'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Διάρκεια (λεπτά)',
                      hintText: 'π.χ. 30',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Απαιτείται διάρκεια';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Μη έγκυρος αριθμός';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: intensity,
                    decoration: const InputDecoration(labelText: 'Ένταση'),
                    items: const [
                      DropdownMenuItem(value: 'Χαμηλή', child: Text('Χαμηλή')),
                      DropdownMenuItem(value: 'Μέτρια', child: Text('Μέτρια')),
                      DropdownMenuItem(value: 'Υψηλή', child: Text('Υψηλή')),
                    ],
                    onChanged: (v) {
                      if (v != null) intensity = v;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ακύρωση'),
              ),
              TextButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final updated = Exercise(
                    name: nameController.text.trim(),
                    duration: int.parse(durationController.text.trim()),
                    intensity: intensity,
                    date: exercise.date, // κρατάμε την αρχική ημερομηνία
                  );
                  await box.put(key, updated);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Η άσκηση ενημερώθηκε.')),
                    );
                  }
                },
                child: const Text('Αποθήκευση'),
              ),
            ],
          ),
    );
  }
}

