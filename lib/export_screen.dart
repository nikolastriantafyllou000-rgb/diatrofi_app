import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';
import 'export_stub.dart'
    if (dart.library.io) 'export_io.dart'
    if (dart.library.html) 'export_web.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _busy = false;
  String? _lastSavedPath;

  static String get _sep => ';';

  @override
  Widget build(BuildContext context) {
    final mealsBox = Hive.box<Meal>('meals');
    final exerciseBox = Hive.box<Exercise>('exercise');
    final goalBox = Hive.box<Goal>('goal');

    return Scaffold(
      appBar: AppBar(title: const Text('Εξαγωγή Δεδομένων (CSV)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Γεύματα: ${mealsBox.length} εγγραφές'),
            Text('Ασκήσεις: ${exerciseBox.length} εγγραφές'),
            Text('Στόχοι: ${goalBox.length} εγγραφές'),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _busy ? null : _exportAll,
              icon: const Icon(Icons.download),
              label:
                  _busy
                      ? const Text('Γίνεται εξαγωγή...')
                      : const Text('Εξαγωγή όλων (Γεύματα, Ασκήσεις, Στόχοι)'),
            ),

            const SizedBox(height: 16),
            if (_lastSavedPath != null)
              Text(
                'Αποθήκευση στο:\n$_lastSavedPath',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAll() async {
    setState(() => _busy = true);
    try {
      final mealsBox = Hive.box<Meal>('meals');
      final exerciseBox = Hive.box<Exercise>('exercise');
      final goalBox = Hive.box<Goal>('goal');

      final timestamp = _ts();

      final mealsCsv = _buildMealsCsv(mealsBox.values.toList());
      final exercisesCsv = _buildExercisesCsv(exerciseBox.values.toList());
      final goalsCsv = _buildGoalsCsv(goalBox.values.toList());

      final savedTo = await saveExportFiles({
        'meals_$timestamp.csv': mealsCsv,
        'exercises_$timestamp.csv': exercisesCsv,
        'goals_$timestamp.csv': goalsCsv,
      });

      setState(() {
        _lastSavedPath = savedTo;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Η εξαγωγή ολοκληρώθηκε! \nΦάκελος: $savedTo'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Σφάλμα στην εξαγωγή: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _buildMealsCsv(List<Meal> items) {
    final b = StringBuffer();
    b.writeln(['name', 'calories', 'date'].join(_sep));
    for (final m in items) {
      b.writeln(
        [
          _csv(m.name),
          m.calories.toString(),
          m.date.toIso8601String(),
        ].join(_sep),
      );
    }
    return b.toString();
  }

  String _buildExercisesCsv(List<Exercise> items) {
    final b = StringBuffer();
    b.writeln(['name', 'duration', 'intensity', 'date'].join(_sep));
    for (final e in items) {
      b.writeln(
        [
          _csv(e.name),
          e.duration.toString(),
          _csv(e.intensity),
          e.date.toIso8601String(),
        ].join(_sep),
      );
    }
    return b.toString();
  }

  String _buildGoalsCsv(List<Goal> items) {
    final b = StringBuffer();
    b.writeln(['calorieGoal', 'exerciseGoalMinutes'].join(_sep));
    for (final g in items) {
      b.writeln(
        [g.calorieGoal.toString(), g.exerciseGoalMinutes.toString()].join(_sep),
      );
    }
    return b.toString();
  }

  // Quoting για CSV: αν περιέχει ;, " ή newline, το τυλίγουμε σε "
  // και διπλασιάζουμε τα εσωτερικά " -> ""
  String _csv(String input) {
    final needsQuoting =
        input.contains(_sep) || input.contains('"') || input.contains('\n');
    if (!needsQuoting) return input;
    final escaped = input.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _ts() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$y$m${d}_$hh$mm';
  }
}
