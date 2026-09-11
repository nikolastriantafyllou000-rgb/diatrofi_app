import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'utils/date_format.dart';
import 'widgets/empty_state.dart';

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
            return const EmptyState(
              title: 'Δεν υπάρχουν γεύματα',
              subtitle: 'Πρόσθεσε το πρώτο σου γεύμα από την αρχική οθόνη.',
              icon: Icons.restaurant,
            );
          }

          // Νεότερες εγγραφές πρώτες
          final meals = box.values.toList().reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: meals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final meal = meals[index];
              // Mapping από "αντεστραμμένο index" στο πραγματικό key του Hive
              final actualKey = box.keyAt(box.length - 1 - index);

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
                  return await _confirmDelete(context, box, actualKey, meal);
                },
                onDismissed: (_) async {
                  await box.delete(actualKey);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Διαγράφηκε το «${meal.name}».')),
                    );
                  }
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.restaurant_menu),
                    ),
                    title: Text(
                      meal.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Θερμίδες: ${meal.calories} • ${formatDateTime(meal.date)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Επεξεργασία',
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () => _editMeal(context, box, actualKey, meal),
                        ),
                        IconButton(
                          tooltip: 'Διαγραφή',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final ok = await _confirmDelete(
                              context,
                              box,
                              actualKey,
                              meal,
                            );
                            if (ok) {
                              await box.delete(actualKey);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Διαγράφηκε το «${meal.name}».',
                                    ),
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

  /// Dialog επιβεβαίωσης διαγραφής. Επιστρέφει true/false.
  Future<bool> _confirmDelete(
    BuildContext context,
    Box<Meal> box,
    dynamic key,
    Meal meal,
  ) async {
    final result =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Διαγραφή Γεύματος'),
                content: Text(
                  'Θέλεις σίγουρα να διαγράψεις το «${meal.name}»;',
                ),
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

  /// Dialog επεξεργασίας γεύματος με έλεγχο τιμών
  void _editMeal(BuildContext context, Box<Meal> box, dynamic key, Meal meal) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: meal.name);
    final caloriesController = TextEditingController(
      text: meal.calories.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Επεξεργασία Γεύματος'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Όνομα γεύματος',
                      hintText: 'π.χ. Κοτόπουλο με ρύζι',
                    ),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Απαιτείται όνομα'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: caloriesController,
                    decoration: const InputDecoration(
                      labelText: 'Θερμίδες',
                      hintText: 'π.χ. 520',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Απαιτούνται θερμίδες';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n < 0) return 'Μη έγκυρος αριθμός';
                      return null;
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

                  final updatedMeal = Meal(
                    name: nameController.text.trim(),
                    calories: int.parse(caloriesController.text.trim()),
                    date:
                        meal.date, // κρατάμε την αρχική ημερομηνία καταχώρησης
                  );

                  await box.put(key, updatedMeal);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Το γεύμα ενημερώθηκε.')),
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
