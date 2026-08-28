import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/docx_diet_parser.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/macro_chart.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import '../domain/diet_interaction.dart';
import '../domain/meal_display.dart';
import 'widgets/meal_section_card.dart';

class DietPlanScreen extends ConsumerStatefulWidget {
  const DietPlanScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<DietPlanScreen> createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends ConsumerState<DietPlanScreen> {
  int? _dayIndex;
  /// 0 all, 1 remaining, 2 done
  int _mealFilter = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    if (!widget.admin) {
      final locked = lockedIfOff(ref, module: AppModule.diet, title: 'Diyet listesi');
      if (locked != null) return locked;
    }
    ref.watch(dietPlansProvider);
    ref.watch(waterLogsProvider);
    ref.watch(streaksProvider);

    if (widget.admin) {
      return _AdminDietHub(
        onOpenUpload: () => _openUploadSheet(context),
      );
    }

    final plan = store.dietPlanForClient(user.id);
    if (plan == null) {
      return AppPage(
        title: 'Diyet listesi',
        child: EmptyState(
          icon: Icons.restaurant_menu_rounded,
          emoji: '🥗',
          title: 'Henüz plan yok',
          subtitle: 'Diyetisyeniniz Word belgesiyle plan yüklediğinde burada görünecek.',
        ).animate().fadeIn().scale(begin: const Offset(0.96, 0.96)),
      );
    }

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
    final cartoon = context.isCartoon;
    final next = DietInteraction.nextMeal(day.meals);
    final water = store.waterLog(user.id, DateTime.now());
    final streak = store.streak(user.id);
    final remaining = showMacros
        ? DietInteraction.remainingKcal(plan: plan, day: day)
        : null;
    final isToday = DateUtils.isSameDay(day.date, DateTime.now());

    final visibleMeals = day.meals.asMap().entries.where((e) {
      if (_mealFilter == 1) return !e.value.consumed;
      if (_mealFilter == 2) return e.value.consumed;
      return true;
    }).toList();

    if (cartoon) {
      return AppPage(
        title: 'Diyetim',
        padding: EdgeInsets.zero,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _CartoonDietHero(
                planTitle: plan.title,
                done: doneCount,
                total: totalMeals,
                dayLabel: DateFormat('d MMMM EEEE', 'tr').format(day.date),
                streak: streak.current,
              ),
              const SizedBox(height: 12),
              _ActionStrip(
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
                _NextMealCard(
                  next: next,
                  onEat: () => _toggleMeal(context, store, plan, selected, day.meals[next.index], doneCount, totalMeals),
                  onJump: () => setState(() => _mealFilter = 1),
                ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
              ],
              const SizedBox(height: 14),
              Text(
                'Günü seç',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.kawaiiInk,
                      fontSize: 14,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plan.days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selectedDay = i == selected;
                    final d = plan.days[i];
                    final dayDone = d.meals.where((m) => m.consumed).length;
                    return _CartoonDayChip(
                      label: DateFormat('EEE', 'tr').format(d.date),
                      dayNum: DateFormat('d', 'tr').format(d.date),
                      selected: selectedDay,
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
                DiyetselCard(
                  child: MacroRings(
                    calories: cal,
                    calorieTarget: plan.calorieTarget,
                    protein: p,
                    proteinTarget: plan.proteinTarget,
                    carbs: c,
                    carbsTarget: plan.carbsTarget,
                    fat: f,
                    fatTarget: plan.fatTarget,
                  ),
                ).animate().fadeIn(duration: 360.ms),
                const SizedBox(height: 10),
                _RemainingMacrosRow(
                  kcalLeft: remaining ?? 0,
                  proteinLeft: (plan.proteinTarget - p).clamp(0, plan.proteinTarget),
                  carbsLeft: (plan.carbsTarget - c).clamp(0, plan.carbsTarget),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Öğünler',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
                    ),
                  ),
                  _FilterPill(label: 'Tümü', selected: _mealFilter == 0, onTap: () => setState(() => _mealFilter = 0)),
                  const SizedBox(width: 6),
                  _FilterPill(label: 'Kalan', selected: _mealFilter == 1, onTap: () => setState(() => _mealFilter = 1)),
                  const SizedBox(width: 6),
                  _FilterPill(label: 'Yenildi', selected: _mealFilter == 2, onTap: () => setState(() => _mealFilter = 2)),
                ],
              ),
              const SizedBox(height: 10),
              if (visibleMeals.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.kawaiiOutline),
                  ),
                  child: Text(
                    _mealFilter == 2 ? 'Henüz yenilen öğün yok.' : 'Kalan öğün yok — günü tamamladın!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                )
              else
                for (final entry in visibleMeals) ...[
                  MealSectionCard(
                    meal: entry.value,
                    index: entry.key,
                    isNext: next != null && next.index == entry.key && isToday,
                    onToggleConsumed: () => _toggleMeal(
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
              _WeekOverview(plan: plan, selected: selected, onSelect: (i) => setState(() => _dayIndex = i)),
              const SizedBox(height: 12),
              TipCard(
                title: 'Küçük ipucu',
                body: DietInteraction.tipOfDay(DateTime.now().day + selected),
                icon: Icons.lightbulb_rounded,
                emoji: '💡',
                color: AppColors.kawaiiLeaf,
              ),
            ],
          ),
        ),
      );
    }

    return AppPage(
      title: plan.title,
      child: ListView(
        children: [
          if (showMacros) ...[
            DiyetselCard(
              child: MacroRings(
                calories: cal,
                calorieTarget: plan.calorieTarget,
                protein: p,
                proteinTarget: plan.proteinTarget,
                carbs: c,
                carbsTarget: plan.carbsTarget,
                fat: f,
                fatTarget: plan.fatTarget,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
          ],
          Text(
            context.isLuxury ? 'HAFTA' : 'Haftanın günü',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  letterSpacing: context.isLuxury ? 1.2 : 0,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: plan.days.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selectedDay = i == selected;
                final d = plan.days[i];
                return ChoiceChip(
                  selected: selectedDay,
                  label: Text(DateFormat('EEE d', 'tr').format(d.date)),
                  onSelected: (_) => setState(() => _dayIndex = i),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < day.meals.length; i++) ...[
            MealSectionCard(
              meal: day.meals[i],
              index: i,
              onToggleConsumed: () => store.toggleMealConsumed(plan, selected, day.meals[i].id),
              onPickReminder: () => _pickReminder(context, plan, day.meals[i]),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          TipCard(
            title: 'Hatırlatıcı',
            body: 'Her öğünün saatine dokunarak bildirim zamanını ayarla. Saat geldiğinde telefonuna hatırlatma gider.',
            icon: Icons.notifications_active_rounded,
            emoji: '⏰',
            color: context.brandPrimary,
          ),
        ],
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

  Future<void> _openUploadSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => const FractionallySizedBox(
        heightFactor: 0.92,
        child: _AdminDietUploadSheet(),
      ),
    );
    setState(() {});
  }
}

class _CartoonDietHero extends StatelessWidget {
  const _CartoonDietHero({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            allDone ? AppColors.kawaiiMint : AppColors.kawaiiSurfaceCream,
            AppColors.kawaiiCream,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.softLift,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.kawaiiInk,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.kawaiiMuted,
                  ),
                ),
                if (streak > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.kawaiiPeach.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      '🔥 $streak gün seri',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  allDone ? 'Bugün tamam 🎉' : '$done / $total öğün tamam',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                    color: allDone ? AppColors.kawaiiLeafDeep : AppColors.kawaiiInk,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppColors.kawaiiOutline.withValues(alpha: 0.55),
                    color: AppColors.kawaiiLeaf,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            allDone ? DiyetselAssets.mascotAvocado : DiyetselAssets.foodSaladBowl,
            width: 88,
            height: 88,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox(width: 72, height: 72),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.04, curve: Curves.easeOut);
  }
}

class _ActionStrip extends StatelessWidget {
  const _ActionStrip({
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
    return Row(
      children: [
        Expanded(
          child: SoftTap(
            onTap: onWater,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kawaiiSky.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.kawaiiOutline),
              ),
              child: Row(
                children: [
                  const Icon(Icons.water_drop_rounded, color: AppColors.kawaiiSkyBlue, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${water.amountMl} / ${water.goalMl} ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppColors.kawaiiInk,
                          ),
                        ),
                        Text(
                          '+${AppConstants.waterSipMl} ml ekle',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: AppColors.kawaiiMuted,
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
        const SizedBox(width: 8),
        if (remainingKcal != null)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.kawaiiOutline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kalan kcal',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted),
                  ),
                  Text(
                    '$remainingKcal',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiLeafDeep),
                  ),
                ],
              ),
            ),
          ),
        if (remainingKcal != null) const SizedBox(width: 8),
        SoftTap(
          onTap: onShopping,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.kawaiiLemon.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: AppColors.kawaiiOutline),
            ),
            child: const Column(
              children: [
                Icon(Icons.shopping_bag_rounded, color: AppColors.kawaiiInk, size: 22),
                SizedBox(height: 2),
                Text(
                  'Liste',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.kawaiiInk),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NextMealCard extends StatelessWidget {
  const _NextMealCard({
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
    return SoftTap(
      onTap: onJump,
      borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.kawaiiLeaf.withValues(alpha: 0.45)),
          boxShadow: AppSpacing.softLift,
        ),
        child: Row(
          children: [
            Image.asset(
              MealDisplay.foodAsset(meal.type),
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Text(meal.type.emoji, style: const TextStyle(fontSize: 36)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    next.isOverdue ? 'Şimdi ye' : 'Sıradaki öğün',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: next.isOverdue ? const Color(0xFFC45C2A) : AppColors.kawaiiLeafDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    MealDisplay.headline(meal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: AppColors.kawaiiInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.effectiveReminderTime} · $countdown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.kawaiiMuted,
                    ),
                  ),
                ],
              ),
            ),
            SoftTap(
              onTap: onEat,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.kawaiiLeaf,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppSpacing.soft,
                ),
                child: const Text(
                  'Yedim',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingMacrosRow extends StatelessWidget {
  const _RemainingMacrosRow({
    required this.kcalLeft,
    required this.proteinLeft,
    required this.carbsLeft,
  });

  final int kcalLeft;
  final int proteinLeft;
  final int carbsLeft;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value, Color bg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.7)),
          ),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        cell('kcal kaldı', '$kcalLeft', AppColors.kawaiiMint.withValues(alpha: 0.55)),
        const SizedBox(width: 8),
        cell('P kaldı', '${proteinLeft}g', AppColors.kawaiiPeach.withValues(alpha: 0.55)),
        const SizedBox(width: 8),
        cell('K kaldı', '${carbsLeft}g', AppColors.kawaiiSky.withValues(alpha: 0.55)),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.kawaiiLeaf : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11.5,
            color: selected ? Colors.white : AppColors.kawaiiMuted,
          ),
        ),
      ),
    );
  }
}

class _WeekOverview extends StatelessWidget {
  const _WeekOverview({
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haftalık özet',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < plan.days.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: SoftTap(
                    onTap: () => onSelect(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Builder(
                      builder: (context) {
                        final d = plan.days[i];
                        final done = d.meals.where((m) => m.consumed).length;
                        final total = d.meals.length;
                        final ratio = total == 0 ? 0.0 : done / total;
                        final isSel = i == selected;
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.kawaiiMint.withValues(alpha: 0.5) : AppColors.kawaiiSurfaceCream,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSel ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('E', 'tr').format(d.date).substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: isSel ? AppColors.kawaiiLeafDeep : AppColors.kawaiiMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 28,
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 10,
                                    height: (8 + ratio * 20).clamp(8.0, 28.0),
                                    decoration: BoxDecoration(
                                      color: ratio >= 1
                                          ? AppColors.kawaiiLeaf
                                          : AppColors.kawaiiLeaf.withValues(alpha: 0.35 + ratio * 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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

class _CartoonDayChip extends StatelessWidget {
  const _CartoonDayChip({
    required this.label,
    required this.dayNum,
    required this.selected,
    required this.progress,
    required this.onTap,
    this.isToday = false,
  });

  final String label;
  final String dayNum;
  final bool selected;
  final double progress;
  final VoidCallback onTap;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.kawaiiLeaf : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.kawaiiLeaf
                : (isToday ? AppColors.kawaiiLeaf.withValues(alpha: 0.55) : AppColors.kawaiiOutline),
            width: isToday && !selected ? 1.5 : 1,
          ),
          boxShadow: selected ? AppSpacing.soft : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white.withValues(alpha: 0.9) : AppColors.kawaiiMuted,
              ),
            ),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.kawaiiInk,
              ),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: 28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: selected
                      ? Colors.white.withValues(alpha: 0.35)
                      : AppColors.kawaiiOutline,
                  color: selected ? Colors.white : AppColors.kawaiiLeaf,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminDietHub extends ConsumerWidget {
  const _AdminDietHub({required this.onOpenUpload});
  final VoidCallback onOpenUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dietPlansProvider);
    final store = ref.watch(appStoreProvider);
    final plans = [...store.dietPlans()]
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));

    return AppPage(
      title: 'Diyet planları',
      fab: FloatingActionButton.extended(
        onPressed: onOpenUpload,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Word yükle'),
      ),
      child: ListView(
        children: [
          DiyetselCard(
            onTap: onOpenUpload,
            child: Row(
              children: [
                StyleIcon(icon: Icons.description_rounded, emoji: '📄', size: 28, selected: true),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Word (.docx) ile plan ata',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dosya seç veya sürükle-bırak. Kahvaltı, ara öğün, öğle… başlıklarıyla yazılmış olmalı.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: context.brandPrimary),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.06, end: 0),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Atanmış planlar', subtitle: 'Danışanlara yüklenen haftalık listeler'),
          if (plans.isEmpty)
            const EmptyState(
              icon: Icons.folder_open_rounded,
              title: 'Plan yok',
              subtitle: 'İlk Word belgenizi yükleyerek başlayın.',
            )
          else
            for (final plan in plans) ...[
              DiyetselCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: StyleIcon(icon: Icons.person_rounded, emoji: '👤', size: 22),
                  title: Text(plan.clientName, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${plan.title}\n${DateFormat('d MMM y', 'tr').format(plan.weekStart)} · ${plan.days.first.meals.length} öğün'),
                  isThreeLine: true,
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _AdminDietUploadSheet extends ConsumerStatefulWidget {
  const _AdminDietUploadSheet();

  @override
  ConsumerState<_AdminDietUploadSheet> createState() => _AdminDietUploadSheetState();
}

class _AdminDietUploadSheetState extends ConsumerState<_AdminDietUploadSheet> {
  UserProfile? _client;
  List<DietMeal> _meals = [];
  String? _fileName;
  String? _error;
  bool _dragging = false;
  bool _saving = false;
  final _title = TextEditingController(text: 'Haftalık diyet planı');

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['docx'],
    );
    if (files.isEmpty) return;
    final file = files.first;
    final path = file.path;
    if (path == null) {
      setState(() => _error = 'Dosya yolu alınamadı.');
      return;
    }
    try {
      final bytes = await File(path).readAsBytes();
      await _ingest(file.name, bytes);
    } catch (_) {
      setState(() => _error = 'Dosya okunamadı. Masaüstünde sürükle-bırak deneyin.');
    }
  }

  Future<void> _ingest(String name, Uint8List bytes) async {
    try {
      final meals = DocxDietParser.parseBytes(bytes);
      setState(() {
        _fileName = name;
        _meals = meals;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Bad state: ', '');
        _meals = [];
        _fileName = name;
      });
    }
  }

  Future<void> _save() async {
    final client = _client;
    if (client == null) {
      setState(() => _error = 'Önce danışan seçin.');
      return;
    }
    if (_meals.isEmpty) {
      setState(() => _error = 'Önce geçerli bir Word dosyası yükleyin.');
      return;
    }
    setState(() => _saving = true);
    final store = ref.read(appStoreProvider);
    final admin = ref.read(authControllerProvider).user!;
    await store.assignDietFromMeals(
      client: client,
      dietitianId: admin.id,
      title: _title.text.trim().isEmpty ? 'Haftalık diyet planı' : _title.text.trim(),
      templateMeals: _meals,
    );
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${client.displayName} için plan kaydedildi')),
      );
    }
  }

  Future<void> _editMeal(int index) async {
    final meal = _meals[index];
    final name = TextEditingController(text: meal.name);
    final desc = TextEditingController(text: meal.description);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(meal.type.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Başlık')),
            const SizedBox(height: 8),
            TextField(
              controller: desc,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'İçerik'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Kaydet')),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        _meals[index] = meal.copyWith(name: name.text.trim(), description: desc.text.trim());
      });
    }
    name.dispose();
    desc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(appStoreProvider);
    final clients = store.users().where((u) => u.role == UserRole.client).toList();
    final canDrop = !kIsWeb;

    final cartoon = context.isCartoon;
    Widget dropZone = AnimatedContainer(
      duration: 200.ms,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          cartoon ? 28 : (context.isLuxury ? 14 : 22),
        ),
        border: Border.all(
          color: cartoon
              ? (_dragging ? AppColors.kawaiiCoral : AppColors.kawaiiOutline.withValues(alpha: 0.4))
              : (_dragging ? context.brandPrimary : Theme.of(context).colorScheme.outline),
          width: cartoon ? (_dragging ? 1.6 : 1) : (_dragging ? 2 : 1.2),
        ),
        color: cartoon
            ? (_dragging
                ? AppColors.kawaiiMint.withValues(alpha: 0.85)
                : AppColors.kawaiiCream.withValues(alpha: 0.75))
            : (_dragging
                ? context.brandPrimary.withValues(alpha: 0.08)
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
        boxShadow: cartoon
            ? const [
                BoxShadow(
                  color: AppColors.kawaiiGlow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.kawaiiShadow,
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ]
            : context.isModern
                ? const [
                    BoxShadow(
                      color: AppColors.modernSoftShadow,
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
      ),
      child: Column(
        children: [
          StyleIcon(icon: Icons.upload_file_rounded, emoji: '📄', size: 32, selected: _dragging),
          const SizedBox(height: 12),
          Text(
            _fileName ?? 'Word (.docx) sürükle-bırak veya seç',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Başlıklar: Kahvaltı, Ara Öğün, Öğle, İkindi, Akşam',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 14),
          DiyetselButton(label: 'Dosya seç', onPressed: _pickFile, expanded: false),
        ],
      ),
    );

    if (canDrop) {
      dropZone = DropTarget(
        onDragEntered: (_) => setState(() => _dragging = true),
        onDragExited: (_) => setState(() => _dragging = false),
        onDragDone: (detail) async {
          setState(() => _dragging = false);
          final x = detail.files.where((f) => f.name.toLowerCase().endsWith('.docx')).firstOrNull;
          if (x == null) {
            setState(() => _error = 'Sadece .docx dosyası kabul edilir.');
            return;
          }
          final bytes = await x.readAsBytes();
          await _ingest(x.name, bytes);
        },
        child: dropZone,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word plan yükle'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Ata'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            // ignore: deprecated_member_use
            value: _client?.id,
            decoration: const InputDecoration(labelText: 'Danışan'),
            items: [
              for (final c in clients)
                DropdownMenuItem(value: c.id, child: Text(c.displayName)),
            ],
            onChanged: (id) {
              setState(() => _client = clients.where((c) => c.id == id).firstOrNull);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Plan başlığı'),
          ),
          const SizedBox(height: 16),
          dropZone.animate().fadeIn(),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ],
          if (_meals.isNotEmpty) ...[
            const SizedBox(height: 18),
            const SectionHeader(title: 'Önizleme', subtitle: 'Kaydetmeden önce düzenleyebilirsin'),
            for (var i = 0; i < _meals.length; i++) ...[
              MealSectionCard(
                meal: _meals[i],
                index: i,
                adminPreview: true,
                onToggleConsumed: () {},
                onPickReminder: () async {
                  final parts = _meals[i].effectiveReminderTime.split(':');
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.tryParse(parts[0]) ?? 8,
                      minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
                    ),
                  );
                  if (picked == null) return;
                  final hh = picked.hour.toString().padLeft(2, '0');
                  final mm = picked.minute.toString().padLeft(2, '0');
                  setState(() {
                    _meals[i] = _meals[i].copyWith(reminderTime: '$hh:$mm');
                  });
                },
                onEditDescription: () => _editMeal(i),
              ),
              const SizedBox(height: 10),
            ],
            DiyetselButton(label: 'Danışana ata', onPressed: _saving ? null : _save),
          ],
        ],
      ),
    );
  }
}
