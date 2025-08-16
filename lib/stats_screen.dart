import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/meal.dart';
import 'models/exercise.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealsBox = Hive.box<Meal>('meals');
    final exerciseBox = Hive.box<Exercise>('exercise');

    return ValueListenableBuilder(
      // 1ος: meals
      valueListenable: mealsBox.listenable(),
      builder: (context, _, __) {
        return ValueListenableBuilder(
          // 2ος: exercise
          valueListenable: exerciseBox.listenable(),
          builder: (context, __, ___) {
            final now = DateTime.now();
            final monday = _weekStart(now);
            final sunday = monday.add(const Duration(days: 6));

            final caloriesPerDay = List<double>.filled(7, 0);
            final minutesPerDay = List<double>.filled(7, 0);

            for (final m in mealsBox.values) {
              if (_isSameWeek(m.date, monday)) {
                final idx = m.date.weekday - 1;
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

            return Scaffold(
              appBar: AppBar(
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
                              _SectionHeader(
                                title: 'Θερμίδες ανά ημέρα',
                                trailing:
                                    'Σύνολο: ${totalCal.toStringAsFixed(0)} kcal',
                              ),
                              const SizedBox(height: 8),
                              _BarChartBlock(
                                values: caloriesPerDay,
                                maxY: _niceCeil(caloriesPerDay),
                                unitSuffix: 'kcal',
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
                                maxY: _niceCeil(minutesPerDay),
                                unitSuffix: 'λεπτά',
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

  // Helpers
  static DateTime _weekStart(DateTime d) {
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
  final List<double> values; // Δευ..Κυρ
  final double maxY;
  final String unitSuffix;

  const _BarChartBlock({
    required this.values,
    required this.maxY,
    required this.unitSuffix,
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
          ),
        ],
      );
    });

    return Container(
      height: 240,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: kElevationToShadow[1],
      ),
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: 0,
          gridData: FlGridData(show: true, horizontalInterval: maxY / 4),
          borderData: FlBorderData(show: false),
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
