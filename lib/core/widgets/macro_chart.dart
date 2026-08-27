import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class MacroRings extends StatelessWidget {
  const MacroRings({
    super.key,
    required this.calories,
    required this.calorieTarget,
    required this.protein,
    required this.proteinTarget,
    required this.carbs,
    required this.carbsTarget,
    required this.fat,
    required this.fatTarget,
  });

  final int calories;
  final int calorieTarget;
  final int protein;
  final int proteinTarget;
  final int carbs;
  final int carbsTarget;
  final int fat;
  final int fatTarget;

  @override
  Widget build(BuildContext context) {
    Widget ring(String label, int value, int target, Color color) {
      final p = target == 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
      return Column(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 0,
                    centerSpaceRadius: 24,
                    sections: [
                      PieChartSectionData(value: p, color: color, radius: 10, showTitle: false),
                      PieChartSectionData(
                        value: 1 - p,
                        color: color.withValues(alpha: 0.12),
                        radius: 10,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Text('${(p * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text('$value / $target', style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ring('kcal', calories, calorieTarget, AppColors.calorie),
        ring('P', protein, proteinTarget, AppColors.protein),
        ring('K', carbs, carbsTarget, AppColors.carbs),
        ring('Y', fat, fatTarget, AppColors.fat),
      ],
    );
  }
}
