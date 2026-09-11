import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _busy = false;
  String? _lastSavedPath;

  static String get _sep => ';';
  static String get _bom => '\uFEFF';

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
                      : const Text('Εξαγωγή όλων (3 CSV)'),
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

      // 1) Προσπαθούμε Downloads (Windows/desktop).
      Directory? baseDir;
      try {
        baseDir = await getDownloadsDirectory();
      } catch (_) {
        baseDir = null;
      }
      // 2) Fallback σε Documents αν δεν υπάρχει Downloads.
      baseDir ??= await getApplicationDocumentsDirectory();

      final exportDir = Directory(p.join(baseDir.path, 'diatrofi_exports'));
      await exportDir.create(recursive: true);

      final timestamp = _ts();

      // --- Meals CSV ---
      final mealsCsv = _buildMealsCsv(mealsBox.values.toList());
      final mealsPath = p.join(exportDir.path, 'meals_$timestamp.csv');
      await File(mealsPath).writeAsString(_bom + mealsCsv);

      // --- Exercises CSV ---
      final exercisesCsv = _buildExercisesCsv(exerciseBox.values.toList());
      final exercisesPath = p.join(exportDir.path, 'exercises_$timestamp.csv');
      await File(exercisesPath).writeAsString(_bom + exercisesCsv);

      // --- Goals CSV ---
      final goalsCsv = _buildGoalsCsv(goalBox.values.toList());
      final goalsPath = p.join(exportDir.path, 'goals_$timestamp.csv');
      await File(goalsPath).writeAsString(_bom + goalsCsv);

      setState(() {
        _lastSavedPath = exportDir.path;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Η εξαγωγή ολοκληρώθηκε! \nΦάκελος: ${exportDir.path}',
            ),
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
