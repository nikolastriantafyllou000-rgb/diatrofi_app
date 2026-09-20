import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';
import 'app_shell.dart';
import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(GoalAdapter());

  await Hive.openBox<Meal>('meals');
  await Hive.openBox<Exercise>('exercise');
  await Hive.openBox<Goal>('goal');
  await loadThemeMode();

  runApp(const DiatrofiApp());
}

class DiatrofiApp extends StatelessWidget {
  const DiatrofiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Διατροφή & Άσκηση',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            scaffoldBackgroundColor: const Color(0xFFF7F9F6),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
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
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.green,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF10140F),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            ),
            cardTheme: const CardTheme(
              color: Color(0xFF1C241B),
              elevation: 0,
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
              fillColor: Color(0xFF1C241B),
            ),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
          ),
          themeMode: mode,
          home: const AppShell(),
        );
      },
    );
  }
}
