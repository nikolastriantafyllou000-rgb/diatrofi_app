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
            return const _EmptyState(
              title: 'Δεν υπάρχουν στόχοι',
              subtitle: 'Καταχώρησε έναν στόχο από την αρχική οθόνη.',
              icon: Icons.flag,
            );
          }

          // Νεότεροι πρώτοι (τελευταίοι καταχωρημένοι)
          final goals = box.values.toList().reversed.toList();

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: goals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final goal = goals[index];
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
                  return await _confirmDelete(context, box, actualKey);
                },
                onDismissed: (_) async {
                  await box.delete(actualKey);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ο στόχος διαγράφηκε.')),
                    );
                  }
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.flag),
                    ),
                    title: Text(
                      'Θερμίδες/ημέρα: ${goal.calorieGoal}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Άσκηση/ημέρα: ${goal.exerciseGoalMinutes} λεπτά',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Επεξεργασία',
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed:
                              () => _showEditDialog(
                                context,
                                box,
                                actualKey,
                                goal,
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
                            );
                            if (ok) {
                              await box.delete(actualKey);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ο στόχος διαγράφηκε.'),
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

  Future<bool> _confirmDelete(
    BuildContext context,
    Box<Goal> box,
    dynamic key,
  ) async {
    final result =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Διαγραφή Στόχου'),
                content: const Text(
                  'Είσαι σίγουρος ότι θέλεις να διαγράψεις τον στόχο;',
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

  void _showEditDialog(
    BuildContext context,
    Box<Goal> box,
    dynamic key,
    Goal goal,
  ) {
    final formKey = GlobalKey<FormState>();
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
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Στόχος θερμίδων/ημέρα',
                      hintText: 'π.χ. 2000',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Απαιτείται τιμή';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n <= 0) return 'Μη έγκυρος αριθμός';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: exerciseController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Στόχος άσκησης/ημέρα (λεπτά)',
                      hintText: 'π.χ. 30',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Απαιτείται τιμή';
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

                  final updated = Goal(
                    calorieGoal: int.parse(calorieController.text.trim()),
                    exerciseGoalMinutes: int.parse(
                      exerciseController.text.trim(),
                    ),
                  );
                  await box.put(key, updated);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ο στόχος ενημερώθηκε.')),
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

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 54, color: Colors.grey.shade500),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
