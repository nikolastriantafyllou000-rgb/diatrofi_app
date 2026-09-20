import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _settingsBoxName = 'settings';
const _themeModeKey = 'themeMode';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
  ThemeMode.system,
);

Future<void> loadThemeMode() async {
  final box = await Hive.openBox(_settingsBoxName);
  themeModeNotifier.value = _parseThemeMode(box.get(_themeModeKey));
}

void toggleThemeMode({required bool isCurrentlyDark}) {
  final next = isCurrentlyDark ? ThemeMode.light : ThemeMode.dark;
  themeModeNotifier.value = next;
  Hive.box(
    _settingsBoxName,
  ).put(_themeModeKey, next == ThemeMode.dark ? 'dark' : 'light');
}

ThemeMode _parseThemeMode(Object? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}
