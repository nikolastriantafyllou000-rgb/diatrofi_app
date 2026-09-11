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

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF98A398),
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w600
                    : FontWeight.w400,
            color:
                states.contains(WidgetState.selected)
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF98A398),
          ),
        ),
      ),
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFEDEFEC), width: 1),
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE8F5E9),
            elevation: 0,
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
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 4 : 2;

    final actions = [
      _ActionCard(
        icon: Icons.restaurant,
        title: 'Καταχώρηση Διατροφής',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MealEntryScreen()),
            ),
      ),
      _ActionCard(
        icon: Icons.fitness_center,
        title: 'Καταχώρηση Άσκησης',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExerciseEntryScreen()),
            ),
      ),
      _ActionCard(
        icon: Icons.flag,
        title: 'Ορισμός Στόχων',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GoalsScreen()),
            ),
      ),
      _ActionCard(
        icon: Icons.today,
        title: 'Ημερήσια Ανασκόπηση',
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailySummaryScreen()),
            ),
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < actions.length; i += crossAxisCount) {
      final rowItems = actions.skip(i).take(crossAxisCount).toList();
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 14));
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < rowItems.length; j++) ...[
              if (j > 0) const SizedBox(width: 14),
              Expanded(child: rowItems[j]),
            ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HomeHeader(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(children: rows),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x261B3A1E),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.eco, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Διατροφή & Άσκηση',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Κάθε υγιεινή επιλογή σε φέρνει πιο κοντά στον στόχο σου.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A2E7D32),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: Color(0xFF1B3A1E),
              ),
            ),
          ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A2E7D32),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 22, color: const Color(0xFF2E7D32)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1B3A1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF66766A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Color(0xFF98A398)),
            ],
          ),
        ),
      ),
    );
  }
}
