import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'models/goal.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _calorieController = TextEditingController();
  final _exerciseController = TextEditingController();

  @override
  void dispose() {
    _calorieController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final goal = Goal(
        calorieGoal: int.parse(_calorieController.text),
        exerciseGoalMinutes: int.parse(_exerciseController.text),
      );

      final box = Hive.box<Goal>('goal');
      box.add(goal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ο στόχος αποθηκεύτηκε με επιτυχία')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Καταχώρηση Στόχων')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _calorieController,
                decoration: const InputDecoration(
                  labelText: 'Ημερήσιος Στόχος Θερμίδων',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Εισάγετε στόχο θερμίδων' : null,
              ),
              TextFormField(
                controller: _exerciseController,
                decoration: const InputDecoration(
                  labelText: 'Ημερήσιος Στόχος Άσκησης (λεπτά)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Εισάγετε στόχο άσκησης' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Αποθήκευση Στόχων'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
