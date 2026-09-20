import 'package:flutter/material.dart';
import 'theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C241B) : Colors.white;
    final titleColor =
        isDark ? const Color(0xFFEAF1E8) : const Color(0xFF1B3A1E);
    final subtitleColor =
        isDark ? const Color(0xFF9CB098) : const Color(0xFF66766A);
    final shadowColor =
        isDark ? const Color(0x40000000) : const Color(0x1A2E7D32);

    return Scaffold(
      appBar: AppBar(title: const Text('Ρυθμίσεις')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeNotifier,
              builder: (context, mode, _) {
                final isDarkMode =
                    mode == ThemeMode.dark ||
                    (mode == ThemeMode.system &&
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark);
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Σκούρο θέμα',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  subtitle: Text(
                    'Η επιλογή σου αποθηκεύεται στη συσκευή',
                    style: TextStyle(fontSize: 12.5, color: subtitleColor),
                  ),
                  value: isDarkMode,
                  activeColor: const Color(0xFF2E7D32),
                  onChanged:
                      (_) => toggleThemeMode(isCurrentlyDark: isDarkMode),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
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
                  child: const Icon(Icons.eco, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Διατροφή & Άσκηση',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Έκδοση 1.0.0',
                        style: TextStyle(fontSize: 12.5, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
