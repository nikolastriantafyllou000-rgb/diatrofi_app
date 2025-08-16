import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';

class MealListScreen extends StatefulWidget {
  const MealListScreen({super.key});

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  @override
  Widget build(BuildContext context) {
    final mealBox = Hive.box<Meal>('meals');

    return Scaffold(
      appBar: AppBar(title: const Text('Αποθηκευμένα Γεύματα')),
      body: ValueListenableBuilder(
        valueListenable: mealBox.listenable(),
        builder: (context, Box<Meal> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('Δεν υπάρχουν καταχωρημένα γεύματα.'),
            );
          }

          final meals = box.values.toList().reversed.toList();

          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              final actualKey = box.keyAt(box.length - 1 - index);

              return ListTile(
                title: Text(meal.name),
                subtitle: Text(
                  'Θερμίδες: ${meal.calories} - Ημερομηνία: ${meal.date.toLocal().toString().substring(0, 16)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editMeal(context, box, actualKey, meal),
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

  void _confirmDelete(BuildContext context, Box<Meal> box, dynamic key) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Διαγραφή Γεύματος'),
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

  void _editMeal(BuildContext context, Box<Meal> box, dynamic key, Meal meal) {
    final nameController = TextEditingController(text: meal.name);
    final caloriesController = TextEditingController(
      text: meal.calories.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Επεξεργασία Γεύματος'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Όνομα γεύματος',
                  ),
                ),
                TextField(
                  controller: caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Θερμίδες'),
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
                  final updatedMeal = Meal(
                    name: nameController.text,
                    calories: int.tryParse(caloriesController.text) ?? 0,
                    date: meal.date, // δεν αλλάζουμε ημερομηνία
                  );

                  box.put(key, updatedMeal);
                  Navigator.of(context).pop();
                },
                child: const Text('Αποθήκευση'),
              ),
            ],
          ),
    );
  }
}
