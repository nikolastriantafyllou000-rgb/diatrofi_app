import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';
import 'models/goal.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late DateTime _weekStart; // Δευτέρα τρέχουσας εβδομάδας

  @override
  void initState() {
    super.initState();
    _weekStart = _weekStartOf(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final mealsBox = Hive.box<Meal>('meals');
    final exerciseBox = Hive.box<Exercise>('exercise');
    final goalBox = Hive.box<Goal>('goal');

    return ValueListenableBuilder(
      // 1ος: meals
      valueListenable: mealsBox.listenable(),
      builder: (context, _, __) {
        return ValueListenableBuilder(
          // 2ος: exercise
          valueListenable: exerciseBox.listenable(),
          builder: (context, __, ___) {
            final monday = _weekStart;
            final sunday = monday.add(const Duration(days: 6));

            // Υπολογισμοί για την επιλεγμένη εβδομάδα
            final caloriesPerDay = List<double>.filled(7, 0);
            final minutesPerDay = List<double>.filled(7, 0);

            for (final m in mealsBox.values) {
              if (_isSameWeek(m.date, monday)) {
                final idx = m.date.weekday - 1; // 0..6 (Δε..Κυ)
                caloriesPerDay[idx] += m.calories.toDouble();
              }
            }
            for (final e in exerciseBox.values) {
              if (_isSameWeek(e.date, monday)) {
                final idx = e.date.weekday - 1;
                minutesPerDay[idx] += e.duration.toDouble();
              }
            }

            final totalCal = caloriesPerDay.fold<double>(0, (a, b) => a + b);
            final totalMin = minutesPerDay.fold<double>(0, (a, b) => a + b);
            final noData = totalCal == 0 && totalMin == 0;

            final latestGoal = goalBox.isEmpty ? null : goalBox.values.last;
            final daysWithinCalorieGoal =
                (latestGoal != null && latestGoal.calorieGoal > 0)
                    ? caloriesPerDay
                        .where((c) => c > 0 && c <= latestGoal.calorieGoal)
                        .length
                    : 0;
            final activeExerciseDays = minutesPerDay.where((m) => m > 0).length;

            return Scaffold(
              appBar: AppBar(
                // δεν ορίζουμε leading -> έτσι εμφανίζεται το default back
                automaticallyImplyLeading: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Στατιστικά εβδομάδας'),
                    Text(
                      '${_fmt(monday)} – ${_fmt(sunday)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Προηγούμενη εβδομάδα',
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _weekStart = _weekStart.subtract(
                          const Duration(days: 7),
                        );
                      });
                    },
                  ),
                  IconButton(
                    tooltip: 'Σήμερα (τρέχουσα εβδομάδα)',
                    icon: const Icon(Icons.today),
                    onPressed: () {
                      setState(() {
                        _weekStart = _weekStartOf(DateTime.now());
                      });
                    },
                  ),
                  IconButton(
                    tooltip: 'Επόμενη εβδομάδα',
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _weekStart = _weekStart.add(const Duration(days: 7));
                      });
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    noData
                        ? const Center(
                          child: Text(
                            'Δεν υπάρχουν δεδομένα για αυτή την εβδομάδα.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _StatChip(
                                    icon: Icons.local_fire_department,
                                    value:
                                        '${(totalCal / 7).toStringAsFixed(0)} kcal',
                                    label: 'Μ.Ο. θερμίδων/ημέρα',
                                  ),
                                  if (latestGoal != null &&
                                      latestGoal.calorieGoal > 0)
                                    _StatChip(
                                      icon: Icons.check_circle_outline,
                                      value: '$daysWithinCalorieGoal/7',
                                      label: 'Ημέρες εντός στόχου',
                                    ),
                                  _StatChip(
                                    icon: Icons.directions_run,
                                    value:
                                        '${(totalMin / 7).toStringAsFixed(0)} λεπτά',
                                    label: 'Μ.Ο. άσκησης/ημέρα',
                                  ),
                                  _StatChip(
                                    icon: Icons.event_available,
                                    value: '$activeExerciseDays/7',
                                    label: 'Ενεργές ημέρες',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              _SectionHeader(
                                title: 'Θερμίδες ανά ημέρα',
                                trailing:
                                    'Σύνολο: ${totalCal.toStringAsFixed(0)} kcal',
                              ),
                              const SizedBox(height: 8),
                              _BarChartBlock(
                                values: caloriesPerDay,
                                maxY: _niceCeil([
                                  ...caloriesPerDay,
                                  if (latestGoal != null)
                                    latestGoal.calorieGoal.toDouble(),
                                ]),
                                unitSuffix: 'kcal',
                                goalLine:
                                    (latestGoal != null &&
                                            latestGoal.calorieGoal > 0)
                                        ? latestGoal.calorieGoal.toDouble()
                                        : null,
                              ),
                              const SizedBox(height: 24),

                              _SectionHeader(
                                title: 'Άσκηση (λεπτά) ανά ημέρα',
                                trailing:
                                    'Σύνολο: ${totalMin.toStringAsFixed(0)} λεπτά',
                              ),
                              const SizedBox(height: 8),
                              _BarChartBlock(
                                values: minutesPerDay,
                                maxY: _niceCeil([
                                  ...minutesPerDay,
                                  if (latestGoal != null)
                                    latestGoal.exerciseGoalMinutes.toDouble(),
                                ]),
                                unitSuffix: 'λεπτά',
                                goalLine:
                                    (latestGoal != null &&
                                            latestGoal.exerciseGoalMinutes > 0)
                                        ? latestGoal.exerciseGoalMinutes
                                            .toDouble()
                                        : null,
                              ),
                            ],
                          ),
                        ),
              ),
            );
          },
        );
      },
    );
  }

  static DateTime _weekStartOf(DateTime d) {
    final date = DateTime(d.year, d.month, d.day);
    return date.subtract(Duration(days: date.weekday - 1)); // Δευτέρα
  }

  static bool _isSameWeek(DateTime date, DateTime monday) {
    final onlyDate = DateTime(date.year, date.month, date.day);
    final start = monday;
    final end = monday.add(const Duration(days: 7)); // exclusive
    return (onlyDate.isAtSameMomentAs(start)) ||
        (onlyDate.isAfter(start) && onlyDate.isBefore(end));
  }

  static String _fmt(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }

  static double _niceCeil(List<double> vals) {
    final maxVal = vals.isEmpty ? 0 : vals.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return 10;
    final order = (maxVal / 10).ceil();
    return (order * 10).toDouble();
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C241B) : Colors.white;
    final valueColor =
        isDark ? const Color(0xFFEAF1E8) : const Color(0xFF1B3A1E);
    final labelColor =
        isDark ? const Color(0xFF9CB098) : const Color(0xFF66766A);
    final shadowColor =
        isDark ? const Color(0x40000000) : const Color(0x1A2E7D32);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: valueColor,
                ),
              ),
              Text(label, style: TextStyle(fontSize: 11, color: labelColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing!, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _BarChartBlock extends StatelessWidget {
  final List<double> values;
  final double maxY;
  final String unitSuffix;
  final double? goalLine;

  const _BarChartBlock({
    required this.values,
    required this.maxY,
    required this.unitSuffix,
    this.goalLine,
  });

  static const _days = ['Δε', 'Τρ', 'Τε', 'Πε', 'Πα', 'Σα', 'Κυ'];

  @override
  Widget build(BuildContext context) {
    final barGroups = List.generate(7, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: values[i],
            width: 14,
            borderRadius: BorderRadius.circular(4),
            color: const Color(0xFF2E7D32),
          ),
        ],
      );
    });

    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A2E7D32),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(show: true, horizontalInterval: maxY / 4),
          borderData: FlBorderData(show: false),
          extraLinesData:
              goalLine == null
                  ? const ExtraLinesData()
                  : ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: goalLine!,
                        color: const Color(0xFFEF6C00),
                        strokeWidth: 2,
                        dashArray: const [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFEF6C00),
                            fontWeight: FontWeight.w600,
                          ),
                          labelResolver: (_) => 'Στόχος',
                        ),
                      ),
                    ],
                  ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: maxY / 4,
                getTitlesWidget: (v, _) => Text(v.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx > 6) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_days[idx]),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          barGroups: barGroups,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, __) {
                final day = _days[group.x.toInt()];
                final v = rod.toY.toStringAsFixed(0);
                return BarTooltipItem(
                  '$day: $v $unitSuffix',
                  const TextStyle(fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
