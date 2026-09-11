import 'package:flutter/material.dart';
import 'meal_entry_screen.dart';
import 'exercise_entry_screen.dart';
import 'goals_entry_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';
import 'meal_list_screen.dart';
import 'exercise_list_screen.dart';
import 'goal_list_screen.dart';
import 'daily_summary_screen.dart';
import 'stats_screen.dart';
import 'export_screen.dart';
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(GoalAdapter());

  await Hive.openBox<Meal>('meals');
  await Hive.openBox<Exercise>('exercise');
  await Hive.openBox<Goal>('goal');

  runApp(const DiatrofiApp());
}

class DiatrofiApp extends StatelessWidget {
  const DiatrofiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Διατροφή & Άσκηση',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        cardTheme: const CardTheme(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          filled: true,
          fillColor: Color(0xFFF7F8FA),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      home: const AppShell(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final mealBox = Hive.box<Meal>('meals');
    print('📦 Meal καταχωρήσεις: ${mealBox.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Διατροφή & Άσκηση')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealEntryScreen(),
                  ),
                );
              },
              child: const Text('Καταχώρηση Διατροφής'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseEntryScreen(),
                  ),
                );
              },
              child: const Text('Καταχώρηση Άσκησης'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GoalsScreen()),
                );
              },
              child: const Text('Στόχοι'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MealListScreen(),
                  ),
                );
              },
              child: const Text('Προβολή Γευμάτων'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExerciseListScreen(),
                  ),
                );
              },
              child: const Text('Προβολή Ασκήσεων'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GoalListScreen(),
                  ),
                );
              },
              child: const Text('Προβολή Στόχων'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailySummaryScreen(),
                  ),
                );
              },
              child: const Text('Ημερήσια Ανασκόπηση'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatsScreen()),
                );
              },
              child: const Text('Στατιστικά Εβδομάδας'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExportScreen()),
                );
              },
              child: const Text('Εξαγωγή Δεδομένων (CSV)'),
            ),
          ],
        ),
      ),
    );
  }
}
