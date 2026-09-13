import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/soft_ui_kit.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/diet_interaction.dart';
import '../../domain/meal_display.dart';

Color softMealAccent(MealType type) => switch (type) {
      MealType.breakfast => const Color(0xFFE8B86D),
      MealType.morningSnack => const Color(0xFFE07A5F),
      MealType.lunch => AppColors.primary,
      MealType.afternoonSnack => const Color(0xFF5BA3C9),
      MealType.dinner => AppColors.primaryDeep,
    };

Color softMealWash(MealType type) => switch (type) {
      MealType.breakfast => const Color(0xFFFFF3E0),
      MealType.morningSnack => const Color(0xFFFFE8DF),
      MealType.lunch => const Color(0xFFE8F5F0),
      MealType.afternoonSnack => const Color(0xFFE3F2F8),
      MealType.dinner => const Color(0xFFE6EEEC),
    };

class SoftDietHero extends StatelessWidget {
  const SoftDietHero({
    super.key,
    required this.planTitle,
    required this.done,
    required this.total,
    required this.dayLabel,
    this.streak = 0,
  });

  final String planTitle;
  final int done;
  final int total;
  final String dayLabel;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final ratio = total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    final allDone = total > 0 && done >= total;

    Widget ring = SoftProgressRing(
      progress: ratio,
      size: 102,
      stroke: 8.5,
      color: allDone ? AppColors.accent : AppColors.primary,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          allDone ? DiyetselAssets.foodGreenSmoothie : DiyetselAssets.foodSaladBowl,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => SoftModernIcon(
            DiyetselAssets.modernIconDietScale,
            size: 40,
            fallback: Icons.restaurant_menu_rounded,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(begin: 0, end: -5, duration: 1800.ms, curve: Curves.easeInOut),
    );

    if (allDone) {
      ring = ring
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1400.ms,
            curve: Curves.easeInOut,
          );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: allDone
              ? const [Color(0xFFD8F0E4), Color(0xFFFFF6E9)]
              : const [Color(0xFFE8F5F0), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: allDone ? 0.16 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    allDone ? 'Gün tamam' : 'Bugünkü plan',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2400.ms, color: Colors.white38),
                const SizedBox(height: 10),
                Text(
                  planTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.primaryDeep,
                    height: 1.2,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: AppColors.primary.withValues(alpha: 0.58),
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      SoftModernIcon(
                        DiyetselAssets.modernIconStreak,
                        size: 20,
                        fallback: Icons.local_fire_department_rounded,
                        fallbackColor: const Color(0xFFE07A5F),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$streak gün seri',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: Color(0xFFC45A3C),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  allDone ? 'Gün tamam — harika iş!' : '$done / $total öğün tamam',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: allDone ? AppColors.primary : AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ratio),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.7),
                      color: allDone ? AppColors.accent : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ring,
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 340.ms)
        .slideY(begin: -0.05, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutCubic, duration: 420.ms);
  }
}

class SoftDietActionStrip extends StatelessWidget {
  const SoftDietActionStrip({
    super.key,
    required this.water,
    required this.onWater,
    required this.onShopping,
    this.remainingKcal,
  });

  final WaterLog water;
  final int? remainingKcal;
  final VoidCallback onWater;
  final VoidCallback onShopping;

  @override
  Widget build(BuildContext context) {
    final waterRatio = water.progress.clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SoftTap(
            onTap: onWater,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2F8), Colors.white],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFB8DCEC)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5BA3C9).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SoftModernIcon(
                      DiyetselAssets.modernIconWaterDrop,
                      size: 28,
                      fallback: Icons.water_drop_rounded,
                      fallbackColor: const Color(0xFF5BA3C9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${water.amountMl} / ${water.goalMl} ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${AppConstants.waterSipMl} ml ekle',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 7),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: waterRatio),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 5,
                              backgroundColor: const Color(0xFF5BA3C9).withValues(alpha: 0.12),
                              color: const Color(0xFF5BA3C9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (remainingKcal != null) ...[
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalan',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    '$remainingKcal',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: AppColors.primary,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(width: 8),
        SoftTap(
          onTap: onShopping,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF0D6), Colors.white],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8D4A8)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8B86D).withValues(alpha: 0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                SoftModernIcon(
                  DiyetselAssets.modernIconPlan,
                  size: 26,
                  fallback: Icons.shopping_bag_rounded,
                  fallbackColor: AppColors.primary,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Liste',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, curve: Curves.easeOutCubic);
  }
}

class SoftNextMealCard extends StatelessWidget {
  const SoftNextMealCard({
    super.key,
    required this.next,
    required this.onEat,
    required this.onJump,
  });

  final DietNextMeal next;
  final VoidCallback onEat;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    final meal = next.meal;
    final countdown = DietInteraction.countdownLabel(next);
    final overdue = next.isOverdue;

    Widget card = SoftTap(
      onTap: onJump,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.modernTealCard,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: overdue ? 0.38 : 0.28),
              blurRadius: overdue ? 26 : 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
              padding: const EdgeInsets.all(6),
              child: Image.asset(
                MealDisplay.foodAsset(meal.type),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Text(
                  meal.type.emoji,
                  style: const TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -4, duration: 1400.ms, curve: Curves.easeInOut)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.04, 1.04),
                    duration: 1400.ms,
                    curve: Curves.easeInOut,
                  ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overdue ? 'Şimdi ye' : 'Sıradaki öğün',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: overdue
                          ? const Color(0xFFFFC4A8)
                          : Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    MealDisplay.headline(meal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.type.tr} · ${meal.effectiveReminderTime} · $countdown',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            SoftTap(
              onTap: onEat,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Yedim',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (overdue) {
      card = card
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1800.ms, color: Colors.white24)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.015, 1.015),
            duration: 900.ms,
            curve: Curves.easeInOut,
          );
    }

    return card.animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, curve: Curves.easeOutCubic);
  }
}

class SoftDayChip extends StatelessWidget {
  const SoftDayChip({
    super.key,
    required this.label,
    required this.dayNum,
    required this.selected,
    required this.progress,
    required this.isToday,
    required this.onTap,
  });

  final String label;
  final String dayNum;
  final bool selected;
  final double progress;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = progress >= 1;

    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        width: 62,
        height: 78,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : isToday
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : complete
                        ? AppColors.accent.withValues(alpha: 0.45)
                        : AppColors.modernLine,
            width: selected || isToday || complete ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: selected
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayNum,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: selected ? Colors.white : AppColors.primaryDeep,
                  ),
                ),
                if (complete) ...[
                  const SizedBox(width: 2),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12,
                    color: selected ? Colors.white : AppColors.accent,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 28,
              height: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : AppColors.primary.withValues(alpha: 0.1),
                  color: selected
                      ? Colors.white
                      : complete
                          ? AppColors.accent
                          : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftMacroOverview extends StatelessWidget {
  const SoftMacroOverview({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.softLift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Makro özeti',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SoftMacroRing(
                  label: 'kcal',
                  value: calories,
                  target: calorieTarget,
                  color: AppColors.calorie,
                ),
              ),
              Expanded(
                child: _SoftMacroRing(
                  label: 'Protein',
                  value: protein,
                  target: proteinTarget,
                  color: AppColors.protein,
                ),
              ),
              Expanded(
                child: _SoftMacroRing(
                  label: 'Karb',
                  value: carbs,
                  target: carbsTarget,
                  color: AppColors.carbs,
                ),
              ),
              Expanded(
                child: _SoftMacroRing(
                  label: 'Yağ',
                  value: fat,
                  target: fatTarget,
                  color: AppColors.fat,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftMacroRing extends StatelessWidget {
  const _SoftMacroRing({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final int value;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: p,
                  strokeWidth: 7,
                  backgroundColor: color.withValues(alpha: 0.12),
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${(p * 100).round()}%',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: AppColors.primary.withValues(alpha: 0.55),
          ),
        ),
        Text(
          '$value/$target',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: AppColors.primaryDeep,
          ),
        ),
      ],
    );
  }
}

class SoftRemainingMacros extends StatelessWidget {
  const SoftRemainingMacros({
    super.key,
    required this.kcalLeft,
    required this.proteinLeft,
    required this.carbsLeft,
  });

  final int kcalLeft;
  final int proteinLeft;
  final int carbsLeft;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String value, Color accent) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Color.lerp(accent, Colors.white, 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('kcal kaldı', '$kcalLeft', AppColors.calorie),
        const SizedBox(width: 8),
        chip('protein', '${proteinLeft}g', AppColors.protein),
        const SizedBox(width: 8),
        chip('karb', '${carbsLeft}g', AppColors.carbs),
      ],
    );
  }
}

class SoftFilterPill extends StatelessWidget {
  const SoftFilterPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.modernLine,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: selected ? Colors.white : AppColors.primaryDeep,
          ),
        ),
      ),
    );
  }
}

/// Soft timeline rail wrapping a list of [SoftMealCard] children.
class SoftMealTimeline extends StatelessWidget {
  const SoftMealTimeline({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? AppColors.primary : AppColors.modernMint,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      if (i < children.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.28),
                                  AppColors.primary.withValues(alpha: 0.08),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: children[i]),
              ],
            ),
          ),
          if (i < children.length - 1) const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class SoftMealCard extends StatefulWidget {
  const SoftMealCard({
    super.key,
    required this.meal,
    required this.index,
    required this.onToggle,
    required this.onPickReminder,
    this.isNext = false,
  });

  final DietMeal meal;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onPickReminder;
  final bool isNext;

  @override
  State<SoftMealCard> createState() => _SoftMealCardState();
}

class _SoftMealCardState extends State<SoftMealCard> {
  bool _ingredientsOpen = false;
  final Set<int> _checkedIngredients = {};

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final accent = softMealAccent(meal.type);
    final wash = softMealWash(meal.type);
    final ingredients = MealDisplay.resolvedIngredients(meal);
    final headline = MealDisplay.headline(meal);
    final hook = MealDisplay.hook(meal);
    final detail = MealDisplay.detailNote(meal);

    Widget nextBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Sırada',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
          color: Colors.white,
        ),
      ),
    );
    if (widget.isNext) {
      nextBadge = nextBadge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(duration: 1600.ms, color: Colors.white38)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1200.ms,
            curve: Curves.easeInOut,
          );
    }

    Widget toggleBtn = SoftTap(
      onTap: widget.onToggle,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: meal.consumed ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          border: meal.consumed
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              meal.consumed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              size: 18,
              color: meal.consumed ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              meal.consumed ? 'Yenildi — geri al' : 'Yenildi olarak işaretle',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13.5,
                color: meal.consumed ? AppColors.primary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (meal.consumed) {
      toggleBtn = toggleBtn
          .animate()
          .fadeIn(duration: 280.ms)
          .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutCubic, duration: 320.ms);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: meal.consumed
              ? [const Color(0xFFE8F5F0), Colors.white]
              : widget.isNext
                  ? [wash, Colors.white]
                  : [Colors.white, wash.withValues(alpha: 0.45)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.isNext
              ? accent.withValues(alpha: 0.55)
              : meal.consumed
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.modernLine,
          width: widget.isNext ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.isNext ? accent : AppColors.primary).withValues(alpha: widget.isNext ? 0.16 : 0.08),
            blurRadius: widget.isNext ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: accent.withValues(alpha: 0.25), width: 2),
                  boxShadow: AppSpacing.soft,
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  MealDisplay.foodAsset(meal.type),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(meal.type.icon, color: accent, size: 28),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            MealDisplay.accentLabel(meal.type),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 10.5,
                              color: accent,
                            ),
                          ),
                        ),
                        if (widget.isNext) ...[
                          const SizedBox(width: 6),
                          nextBadge,
                        ],
                        const Spacer(),
                        SoftTap(
                          onTap: widget.onPickReminder,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.modernLine),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded, size: 14, color: accent),
                                const SizedBox(width: 4),
                                Text(
                                  meal.effectiveReminderTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      headline,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.primaryDeep,
                        decoration: meal.consumed ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.type.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hook,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
              color: AppColors.primary.withValues(alpha: 0.72),
            ),
          ),
          if (detail != null && detail != hook) ...[
            const SizedBox(height: 6),
            Text(
              detail,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
          ],
          if (ingredients.isNotEmpty) ...[
            const SizedBox(height: 10),
            SoftTap(
              onTap: () => setState(() => _ingredientsOpen = !_ingredientsOpen),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.kitchen_rounded, size: 16, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Malzemeler (${ingredients.length})'
                        '${_checkedIngredients.isNotEmpty ? ' · ${_checkedIngredients.length} hazır' : ''}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _ingredientsOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i < ingredients.length; i++)
                      SoftTap(
                        onTap: () => setState(() {
                          if (_checkedIngredients.contains(i)) {
                            _checkedIngredients.remove(i);
                          } else {
                            _checkedIngredients.add(i);
                          }
                        }),
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _checkedIngredients.contains(i)
                                ? accent.withValues(alpha: 0.14)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _checkedIngredients.contains(i)
                                  ? accent.withValues(alpha: 0.45)
                                  : accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _checkedIngredients.contains(i)
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 14,
                                color: accent,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                ingredients[i].amount.isEmpty
                                    ? ingredients[i].name
                                    : '${ingredients[i].name} · ${ingredients[i].amount}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11.5,
                                  color: AppColors.primaryDeep,
                                  decoration: _checkedIngredients.contains(i)
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: accent.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              crossFadeState:
                  _ingredientsOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
            ),
          ],
          if (meal.calories > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _macroPill('🔥', '${meal.calories}', accent),
                const SizedBox(width: 6),
                _macroPill('P', '${meal.protein}g', AppColors.protein),
                const SizedBox(width: 6),
                _macroPill('K', '${meal.carbs}g', AppColors.carbs),
                const SizedBox(width: 6),
                _macroPill('Y', '${meal.fat}g', AppColors.fat),
              ],
            ),
          ],
          const SizedBox(height: 12),
          toggleBtn,
        ],
      ),
    )
        .animate(delay: (50 * widget.index).ms)
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.06, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
  }

  Widget _macroPill(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$label $value',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: color,
          ),
        ),
      ),
    );
  }
}

class SoftDietCompletionBanner extends StatelessWidget {
  const SoftDietCompletionBanner({
    super.key,
    this.onShopping,
    this.onRecipes,
  });

  final VoidCallback? onShopping;
  final VoidCallback? onRecipes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8F0E4), Color(0xFFFFF6E9), Color(0xFFE8F5F0)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.celebration_rounded, color: AppColors.accent, size: 24),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 1100.ms,
                    curve: Curves.easeInOut,
                  ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gün tamam!',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primaryDeep,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tüm öğünler işaretlendi — yarın için hazırlan.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onShopping != null || onRecipes != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (onShopping != null)
                  Expanded(
                    child: SoftTap(
                      onTap: onShopping!,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: const Text(
                          'Alışveriş listesi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (onShopping != null && onRecipes != null) const SizedBox(width: 8),
                if (onRecipes != null)
                  Expanded(
                    child: SoftTap(
                      onTap: onRecipes!,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Tariflere bak',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 360.ms)
        .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 480.ms)
        .shimmer(delay: 200.ms, duration: 1600.ms, color: Colors.white38);
  }
}

class SoftWeekOverview extends StatelessWidget {
  const SoftWeekOverview({
    super.key,
    required this.plan,
    required this.selected,
    required this.onSelect,
  });

  final DietPlan plan;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık ilerleme',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < plan.days.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: SoftTap(
                    onTap: () => onSelect(i),
                    child: Column(
                      children: [
                        Text(
                          ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'][plan.days[i].date.weekday - 1],
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            color: i == selected
                                ? AppColors.primary
                                : AppColors.primary.withValues(alpha: 0.45),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (_) {
                            final d = plan.days[i];
                            final done = d.meals.where((m) => m.consumed).length;
                            final total = d.meals.length;
                            final ratio = total == 0 ? 0.0 : done / total;
                            return Container(
                              height: 36,
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 280),
                                width: double.infinity,
                                height: 8 + ratio * 28,
                                decoration: BoxDecoration(
                                  color: i == selected
                                      ? AppColors.primary
                                      : Color.lerp(
                                          AppColors.primary.withValues(alpha: 0.15),
                                          AppColors.primary,
                                          ratio,
                                        ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class SoftDietTipCard extends StatelessWidget {
  const SoftDietTipCard({super.key, required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF3E0), Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8D4A8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: SoftModernIcon(
              DiyetselAssets.modernIconStory,
              size: 24,
              fallback: Icons.lightbulb_rounded,
              fallbackColor: const Color(0xFFE8B86D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Küçük ipucu',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 320.ms)
        .slideY(begin: 0.04, curve: Curves.easeOutCubic)
        .shimmer(delay: 180.ms, duration: 2200.ms, color: Colors.white24);
  }
}

class SoftDietEmptyMeals extends StatelessWidget {
  const SoftDietEmptyMeals({super.key, required this.filterDone});

  final bool filterDone;

  @override
  Widget build(BuildContext context) {
    return SoftEmptyRich(
      title: filterDone ? 'Henüz yenilen öğün yok' : 'Kalan öğün yok',
      body: filterDone
          ? 'Öğünleri yedikçe burada görünecek. İlk adımı at!'
          : 'Günü tamamladın — harika tempo. Su hedefini de unutma.',
      icon: filterDone ? Icons.restaurant_outlined : Icons.check_circle_outline_rounded,
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutCubic);
  }
}
