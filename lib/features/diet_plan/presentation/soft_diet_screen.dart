import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/diet_interaction.dart';
import 'widgets/soft_diet_widgets.dart';

/// Soft premium modern diet experience — cream / teal wellness language.
/// Cartoon theme keeps [DietPlanScreen]'s cartoon branch untouched.
class SoftDietScreen extends ConsumerStatefulWidget {
  const SoftDietScreen({super.key, required this.plan});

  final DietPlan plan;

  @override
  ConsumerState<SoftDietScreen> createState() => _SoftDietScreenState();
}

class _SoftDietScreenState extends ConsumerState<SoftDietScreen> {
  int? _dayIndex;
  int _mealFilter = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(dietPlansProvider);
    ref.watch(waterLogsProvider);
    ref.watch(streaksProvider);

    final plan = store.dietPlanForClient(user.id) ?? widget.plan;
    final todayIndex = plan.days.indexWhere((d) => DateUtils.isSameDay(d.date, DateTime.now()));
    final selected = (_dayIndex ?? (todayIndex >= 0 ? todayIndex : 0)).clamp(0, plan.days.length - 1);
    final day = plan.days[selected];
    final consumed = day.meals.where((m) => m.consumed);
    final cal = consumed.fold(0, (s, m) => s + m.calories);
    final p = consumed.fold(0, (s, m) => s + m.protein);
    final c = consumed.fold(0, (s, m) => s + m.carbs);
    final f = consumed.fold(0, (s, m) => s + m.fat);
    final showMacros = plan.calorieTarget > 0 && day.meals.any((m) => m.calories > 0);
    final doneCount = day.meals.where((m) => m.consumed).length;
    final totalMeals = day.meals.length;
    final next = DietInteraction.nextMeal(day.meals);
    final water = store.waterLog(user.id, DateTime.now());
    final streak = store.streak(user.id);
    final remaining = showMacros ? DietInteraction.remainingKcal(plan: plan, day: day) : null;
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());

    final visibleMeals = day.meals.asMap().entries.where((e) {
      if (_mealFilter == 1) return !e.value.consumed;
      if (_mealFilter == 2) return e.value.consumed;
      return true;
    }).toList();

    return AppPage(
      title: 'Diyetim',
      padding: EdgeInsets.zero,
      child: ColoredBox(
        color: AppColors.modernWash,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            SoftDietHero(
              planTitle: plan.title,
              done: doneCount,
              total: totalMeals,
              dayLabel: DateFormat('d MMMM EEEE', 'tr').format(day.date),
              streak: streak.current,
            ),
            const SizedBox(height: 12),
            SoftDietActionStrip(
              water: water,
              remainingKcal: remaining,
              onWater: () async {
                await store.addWaterSip(user.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('+${AppConstants.waterSipMl} ml su eklendi')),
                  );
                }
              },
              onShopping: () => context.push('/app/shopping'),
            ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
            if (next != null && isToday) ...[
              const SizedBox(height: 12),
              SoftNextMealCard(
                next: next,
                onEat: () => _toggleMeal(context, store, plan, selected, day.meals[next.index], doneCount, totalMeals),
                onJump: () => setState(() => _mealFilter = 1),
              ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            ],
            const SizedBox(height: 16),
            Text(
              'Günü seç',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plan.days.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final d = plan.days[i];
                  final dayDone = d.meals.where((m) => m.consumed).length;
                  return SoftDayChip(
                    label: DateFormat('EEE', 'tr').format(d.date),
                    dayNum: DateFormat('d', 'tr').format(d.date),
                    selected: i == selected,
                    progress: d.meals.isEmpty ? 0 : dayDone / d.meals.length,
                    isToday: DateUtils.isSameDay(d.date, DateTime.now()),
                    onTap: () => setState(() {
                      _dayIndex = i;
                      _mealFilter = 0;
                    }),
                  );
                },
              ),
            ),
            if (showMacros) ...[
              const SizedBox(height: 14),
              SoftMacroOverview(
                calories: cal,
                calorieTarget: plan.calorieTarget,
                protein: p,
                proteinTarget: plan.proteinTarget,
                carbs: c,
                carbsTarget: plan.carbsTarget,
                fat: f,
                fatTarget: plan.fatTarget,
              ).animate().fadeIn(duration: 360.ms),
              const SizedBox(height: 10),
              SoftRemainingMacros(
                kcalLeft: remaining ?? 0,
                proteinLeft: (plan.proteinTarget - p).clamp(0, plan.proteinTarget),
                carbsLeft: (plan.carbsTarget - c).clamp(0, plan.carbsTarget),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Öğünler',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.primaryDeep,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                SoftFilterPill(label: 'Tümü', selected: _mealFilter == 0, onTap: () => setState(() => _mealFilter = 0)),
                const SizedBox(width: 6),
                SoftFilterPill(label: 'Kalan', selected: _mealFilter == 1, onTap: () => setState(() => _mealFilter = 1)),
                const SizedBox(width: 6),
                SoftFilterPill(label: 'Yenildi', selected: _mealFilter == 2, onTap: () => setState(() => _mealFilter = 2)),
              ],
            ),
            const SizedBox(height: 12),
            if (visibleMeals.isEmpty)
              SoftDietEmptyMeals(filterDone: _mealFilter == 2)
            else
              for (final entry in visibleMeals) ...[
                SoftMealCard(
                  meal: entry.value,
                  index: entry.key,
                  isNext: next != null && next.index == entry.key && isToday,
                  onToggle: () => _toggleMeal(
                    context,
                    store,
                    plan,
                    selected,
                    entry.value,
                    doneCount,
                    totalMeals,
                  ),
                  onPickReminder: () => _pickReminder(context, plan, entry.value),
                ),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 8),
            SoftWeekOverview(
              plan: plan,
              selected: selected,
              onSelect: (i) => setState(() {
                _dayIndex = i;
                _mealFilter = 0;
              }),
            ),
            const SizedBox(height: 12),
            SoftDietTipCard(
              body: DietInteraction.tipOfDay(DateTime.now().day + selected),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMeal(
    BuildContext context,
    AppStore store,
    DietPlan plan,
    int dayIndex,
    DietMeal meal,
    int doneBefore,
    int total,
  ) async {
    final wasConsumed = meal.consumed;
    await store.toggleMealConsumed(plan, dayIndex, meal.id);
    if (!context.mounted) return;
    if (!wasConsumed) {
      final willComplete = doneBefore + 1 >= total && total > 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(willComplete ? 'Günün tüm öğünleri tamam — harika iş!' : 'Afiyet olsun! Öğün işaretlendi.'),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _pickReminder(BuildContext context, DietPlan plan, DietMeal meal) async {
    final parts = meal.effectiveReminderTime.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    final store = ref.read(appStoreProvider);
    await store.updateMealReminder(plan.id, meal.type, '$hh:$mm');
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      await SmartNotificationService.instance.sync(store, user);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${meal.type.tr} hatırlatıcısı $hh:$mm olarak ayarlandı')),
      );
    }
    setState(() {});
  }
}

/// Empty state for modern diet when no plan is assigned.
class SoftDietEmptyScreen extends StatelessWidget {
  const SoftDietEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Diyetim',
      child: ColoredBox(
        color: AppColors.modernWash,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.softLift,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(
                    'assets/images/food_salad_bowl.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.restaurant_menu_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Henüz plan yok',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Diyetisyeniniz Word belgesiyle plan yüklediğinde burada görünecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
