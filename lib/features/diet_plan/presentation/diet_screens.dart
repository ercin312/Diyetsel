import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/macro_chart.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/models/app_modules.dart';
import '../../auth/presentation/auth_controller.dart';

class DietPlanScreen extends ConsumerWidget {
  const DietPlanScreen({super.key, this.admin = false});
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    if (!admin) {
      final locked = lockedIfOff(ref, module: AppModule.diet, title: 'Diyet listesi');
      if (locked != null) return locked;
    }
    ref.watch(dietPlansProvider);
    final plan = admin ? (store.dietPlans().isEmpty ? null : store.dietPlans().first) : store.dietPlanForClient(user.id);
    if (plan == null) {
      return AppPage(
        title: 'Diyet listesi',
        fab: admin
            ? FloatingActionButton(
                onPressed: () => _createPlan(ref),
                child: const Icon(Icons.add),
              )
            : null,
        child: const EmptyState(icon: Icons.restaurant, title: 'Henüz plan yok', subtitle: 'Diyetisyeniniz haftalık listenizi atadığında burada görünecek.'),
      );
    }
    final todayIndex = plan.days.indexWhere((d) => DateUtils.isSameDay(d.date, DateTime.now()));
    final day = plan.days[todayIndex >= 0 ? todayIndex : 0];
    final consumed = day.meals.where((m) => m.consumed);
    final cal = consumed.fold(0, (s, m) => s + m.calories);
    final p = consumed.fold(0, (s, m) => s + m.protein);
    final c = consumed.fold(0, (s, m) => s + m.carbs);
    final f = consumed.fold(0, (s, m) => s + m.fat);

    return AppPage(
      title: plan.title,
      fab: admin
          ? FloatingActionButton.extended(
              onPressed: () => _createPlan(ref),
              label: const Text('Yeni plan'),
            )
          : null,
      child: ListView(
        children: [
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
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: plan.days.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = DateUtils.isSameDay(plan.days[i].date, day.date);
                return ChoiceChip(
                  selected: selected,
                  label: Text(DateFormat('EEE d', 'tr').format(plan.days[i].date)),
                  onSelected: (_) {
                    // rebuild via local? keep simple: show only today in this view, other days via dialog
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (ctx) => _DayMeals(
                        plan: plan,
                        dayIndex: i,
                        store: store,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _DayMeals(plan: plan, dayIndex: todayIndex >= 0 ? todayIndex : 0, store: store),
        ],
      ),
    );
  }

  Future<void> _createPlan(WidgetRef ref) async {
    final store = ref.read(appStoreProvider);
    final clients = store.users().where((u) => u.role == UserRole.client).toList();
    if (clients.isEmpty) return;
    final existing = store.dietPlanForClient(clients.first.id);
    var monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    monday = DateTime(monday.year, monday.month, monday.day);
    if (existing != null) {
      monday = existing.weekStart.add(const Duration(days: 7));
    }
    await store.saveDietPlan(
      DietPlan(
        id: newId(),
        clientId: clients.first.id,
        clientName: clients.first.displayName,
        dietitianId: SeedData.adminId,
        title: 'Yeni haftalık plan',
        weekStart: monday,
        days: [
          for (var i = 0; i < 7; i++)
            DietDay(
              date: monday.add(Duration(days: i)),
              meals: [
                DietMeal(
                  id: newId(),
                  type: MealType.breakfast,
                  name: 'Kahvaltı',
                  description: 'Düzenleyin',
                  calories: 400,
                  protein: 25,
                  carbs: 40,
                  fat: 12,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DayMeals extends ConsumerWidget {
  const _DayMeals({required this.plan, required this.dayIndex, required this.store});
  final DietPlan plan;
  final int dayIndex;
  final AppStore store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dietPlansProvider);
    final latest = store.dietPlans().where((p) => p.id == plan.id).firstOrNull ?? plan;
    final day = latest.days[dayIndex];
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      children: [
        for (final meal in day.meals)
          CheckboxListTile(
            value: meal.consumed,
            onChanged: (_) => store.toggleMealConsumed(latest, dayIndex, meal.id),
            title: Text(meal.name),
            subtitle: Text('${meal.type.tr} • ${meal.calories} kcal • P${meal.protein} K${meal.carbs} Y${meal.fat}\n${meal.description}'),
            isThreeLine: true,
          ),
      ],
    );
  }
}
