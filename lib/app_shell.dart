import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'meal_entry_screen.dart';
import 'exercise_entry_screen.dart';
import 'goals_entry_screen.dart';
import 'meal_list_screen.dart';
import 'exercise_list_screen.dart';
import 'goal_list_screen.dart';
import 'daily_summary_screen.dart';
import 'stats_screen.dart';
import 'export_screen.dart';
import 'theme_controller.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor =
        isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
    final unselectedColor =
        isDark ? const Color(0xFF6E8169) : const Color(0xFF98A398);

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
                    ? selectedColor
                    : unselectedColor,
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
                    ? selectedColor
                    : unselectedColor,
          ),
        ),
      ),
      child: Scaffold(
        body: pages[_index],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF29332A) : const Color(0xFFEDEFEC),
                width: 1,
              ),
            ),
          ),
          child: NavigationBar(
            backgroundColor: isDark ? const Color(0xFF161C15) : Colors.white,
            indicatorColor:
                isDark ? const Color(0xFF223821) : const Color(0xFFE8F5E9),
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

class _HomeHeader extends StatefulWidget {
  const _HomeHeader();

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  late final VideoPlayerController _controller;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset('assets/videos/home_hero.mp4')
          ..setLooping(true)
          ..setVolume(0)
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() => _videoReady = true);
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _cornerRadius = BorderRadius.only(
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: _cornerRadius,
        boxShadow: [
          BoxShadow(
            color: Color(0x261B3A1E),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: _cornerRadius,
        child: Stack(
          children: [
            // Βίντεο φόντο (loop, χωρίς ήχο) — fallback στο πράσινο gradient όσο φορτώνει.
            Positioned.fill(
              child:
                  _videoReady
                      ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      )
                      : const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                          ),
                        ),
                      ),
            ),
            // Σκούρο πράσινο scrim πάνω από το βίντεο για ευανάγνωστο κείμενο.
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xCC1B5E20), Color(0xB32E7D32)],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
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
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Διατροφή & Άσκηση',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const _ThemeToggleButton(),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return IconButton(
          tooltip:
              isDark
                  ? 'Ενεργοποίηση φωτεινού θέματος'
                  : 'Ενεργοποίηση σκοτεινού θέματος',
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: Colors.white,
          ),
          onPressed: () => toggleThemeMode(isCurrentlyDark: isDark),
        );
      },
    );
  }
}

class _ListsTab extends StatelessWidget {
  const _ListsTab();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final introColor =
        isDark ? const Color(0xFF9CB098) : const Color(0xFF66766A);

    return Scaffold(
      appBar: AppBar(title: const Text('Λίστες')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Text(
              'Το ιστορικό όλων των καταχωρήσεών σου.',
              style: TextStyle(fontSize: 13, color: introColor),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C241B) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFEAF1E8) : const Color(0xFF1B3A1E);
    final shadowColor =
        isDark ? const Color(0x40000000) : const Color(0x1A2E7D32);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
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
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: titleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C241B) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFEAF1E8) : const Color(0xFF1B3A1E);
    final subtitleColor =
        isDark ? const Color(0xFF9CB098) : const Color(0xFF66766A);
    final chevronColor =
        isDark ? const Color(0xFF6E8169) : const Color(0xFF98A398);
    final shadowColor =
        isDark ? const Color(0x40000000) : const Color(0x1A2E7D32);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardColor,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 20,
                offset: const Offset(0, 8),
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.5, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: chevronColor),
            ],
          ),
        ),
      ),
    );
  }
}
