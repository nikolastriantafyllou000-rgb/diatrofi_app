import 'package:flutter/material.dart';
import 'models/meal.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MealEntryScreen extends StatefulWidget {
  const MealEntryScreen({super.key});

  @override
  State<MealEntryScreen> createState() => _MealEntryScreenState();
}

class _MealEntryScreenState extends State<MealEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mealController = TextEditingController();
  final _caloriesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final meal = Meal(
        name: _mealController.text,
        calories: int.tryParse(_caloriesController.text) ?? 0,
        date: _selectedDate,
      );

      final box = Hive.box<Meal>('meals');
      box.add(meal);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Το γεύμα αποθηκεύτηκε με επιτυχία')),
      );

      Navigator.pop(context);

      _mealController.clear();
      _caloriesController.clear();
    }
  }

  @override
  void dispose() {
    _mealController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Καταχώρηση Διατροφής')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _mealController,
                decoration: const InputDecoration(labelText: 'Όνομα Γεύματος'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Παρακαλώ εισάγετε ένα γεύμα' : null,
              ),
              TextFormField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Θερμίδες'),
                keyboardType: TextInputType.number,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Παρακαλώ εισάγετε θερμίδες' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Ημερομηνία: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (!mounted || picked == null) return;
                      setState(() => _selectedDate = picked);
                    },
                    child: const Text('Επιλογή Ημερομηνίας'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Αποθήκευση'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
