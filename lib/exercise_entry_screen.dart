import 'package:flutter/material.dart';
import 'models/exercise.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ExerciseEntryScreen extends StatefulWidget {
  const ExerciseEntryScreen({super.key});

  @override
  State<ExerciseEntryScreen> createState() => _ExerciseEntryScreenState();
}

class _ExerciseEntryScreenState extends State<ExerciseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseController = TextEditingController();
  final _durationController = TextEditingController();
  String _intensity = 'Μέτρια';
  DateTime _selectedDate = DateTime.now();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final exercise = Exercise(
        name: _exerciseController.text,
        duration: int.parse(_durationController.text),
        intensity: _intensity,
        date: _selectedDate,
      );

      final box = Hive.box<Exercise>('exercise');
      await box.add(exercise);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Η άσκηση αποθηκεύτηκε με επιτυχία')),
      );

      Navigator.pop(context); // επιστροφή στην αρχική οθόνη
    }
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Καταχώρηση Άσκησης')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _exerciseController,
                decoration: const InputDecoration(labelText: 'Όνομα Άσκησης'),
                validator: (value) => value!.isEmpty ? 'Εισάγετε άσκηση' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Διάρκεια (λεπτά)',
                ),
                keyboardType: TextInputType.number,
                validator:
                    (value) => value!.isEmpty ? 'Εισάγετε διάρκεια' : null,
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
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Επιλογή Ημερομηνίας'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _intensity,
                decoration: const InputDecoration(labelText: 'Ένταση'),
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
                  setState(() {
                    _intensity = value!;
                  });
                },
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
