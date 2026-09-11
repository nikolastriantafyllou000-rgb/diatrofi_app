import 'package:flutter/material.dart';
import 'meal_entry_screen.dart';
import 'exercise_entry_screen.dart';
import 'goals_entry_screen.dart';
import 'meal_list_screen.dart';
import 'exercise_list_screen.dart';
import 'goal_list_screen.dart';
import 'daily_summary_screen.dart';
import 'stats_screen.dart';
import 'export_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const _HomeTab(),
      const _ListsTab(),
      const StatsScreen(),
      const ExportScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Αρχική',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Λίστες',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Στατιστικά',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Εξαγωγή',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Διατροφή & Άσκηση')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Γρήγορα actions
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ActionCard(
                    icon: Icons.restaurant,
                    title: 'Καταχώρηση Διατροφής',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MealEntryScreen(),
                          ),
                        ),
                  ),
                  _ActionCard(
                    icon: Icons.fitness_center,
                    title: 'Καταχώρηση Άσκησης',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExerciseEntryScreen(),
                          ),
                        ),
                  ),
                  _ActionCard(
                    icon: Icons.flag,
                    title: 'Ορισμός Στόχων',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GoalsScreen(),
                          ),
                        ),
                  ),
                  _ActionCard(
                    icon: Icons.today,
                    title: 'Ημερήσια Ανασκόπηση',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DailySummaryScreen(),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Καλώς ήρθες! Χρησιμοποίησε τις καρτέλες κάτω για γρήγορη πλοήγηση.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListsTab extends StatelessWidget {
  const _ListsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Λίστες')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _ListTileNav(
            icon: Icons.restaurant,
            title: 'Προβολή Γευμάτων',
            subtitle: 'Όλες οι καταχωρήσεις διατροφής (νέες πρώτες)',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MealListScreen()),
                ),
          ),
          _ListTileNav(
            icon: Icons.fitness_center,
            title: 'Προβολή Ασκήσεων',
            subtitle: 'Όλες οι καταχωρήσεις άσκησης (νέες πρώτες)',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExerciseListScreen()),
                ),
          ),
          _ListTileNav(
            icon: Icons.flag,
            title: 'Προβολή Στόχων',
            subtitle: 'Τελευταίοι στόχοι και ιστορικό',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GoalListScreen()),
                ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          _ListTileNav(
            icon: Icons.today,
            title: 'Ημερήσια Ανασκόπηση',
            subtitle: 'Θερμίδες & Άσκηση σε σχέση με τους στόχους',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DailySummaryScreen()),
                ),
          ),
          _ListTileNav(
            icon: Icons.bar_chart,
            title: 'Στατιστικά Εβδομάδας',
            subtitle: 'Γραφήματα θερμίδων & άσκησης',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StatsScreen()),
                ),
          ),
          _ListTileNav(
            icon: Icons.download,
            title: 'Εξαγωγή Δεδομένων (CSV)',
            subtitle: 'Εξαγωγή γευμάτων, ασκήσεων, στόχων',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: kElevationToShadow[1],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListTileNav extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ListTileNav({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
