import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/shopping_visuals.dart';
import 'widgets/soft_shopping_widgets.dart';

/// Soft premium modern shopping list.
class SoftShoppingScreen extends ConsumerStatefulWidget {
  const SoftShoppingScreen({super.key});

  @override
  ConsumerState<SoftShoppingScreen> createState() => _SoftShoppingScreenState();
}

class _SoftShoppingScreenState extends ConsumerState<SoftShoppingScreen> {
  String _filter = 'Tümü';
  bool _hideChecked = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(shoppingListsProvider);
    final items = store.shoppingList(user.id);

    final done = items.where((e) => e.checked).length;
    final total = items.length;
    final priorityCount = items.where((e) => e.priority && !e.checked).length;
    final catCount = {for (final e in items) e.category}.length;

    final categories = [
      'Tümü',
      ...ShoppingVisuals.categoryOrder.where((c) => items.any((e) => e.category == c)),
    ];

    var shown = _filter == 'Tümü' ? items : items.where((e) => e.category == _filter).toList();
    if (_hideChecked) shown = shown.where((e) => !e.checked).toList();

    final priority = shown.where((e) => e.priority && !e.checked).toList();
    final open = shown.where((e) => !e.checked && !e.priority).toList()
      ..sort((a, b) {
        final ai = ShoppingVisuals.categoryOrder.indexOf(a.category);
        final bi = ShoppingVisuals.categoryOrder.indexOf(b.category);
        return (ai < 0 ? 99 : ai).compareTo(bi < 0 ? 99 : bi);
      });
    final checked = shown.where((e) => e.checked).toList();

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            SoftShoppingHeader(
              onAdd: () => _openAddSheet(context, store, user.id, items),
            )
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftShoppingHero(
              done: done,
              total: total,
              tip: ShoppingVisuals.tipOfDay(DateTime.now().day),
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftShoppingStatsRow(
              total: total,
              done: done,
              priority: priorityCount,
              categories: catCount,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftShoppingActionRow(
              onGenerate: () => _generateFromDiet(context, store, user.id, items),
              onAdd: () => _openAddSheet(context, store, user.id, items),
              onClearChecked: done == 0
                  ? null
                  : () async {
                      final next = items.where((e) => !e.checked).toList();
                      await store.saveShoppingList(user.id, next);
                    },
              hideChecked: _hideChecked,
              onToggleHide: () => setState(() => _hideChecked = !_hideChecked),
            ).animate().fadeIn(delay: 80.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftShoppingCategoryChips(
              categories: categories,
              filter: _filter,
              onChanged: (c) => setState(() => _filter = c),
            ).animate().fadeIn(delay: 95.ms, duration: 280.ms),
            const SizedBox(height: 16),
            if (items.isEmpty)
              SoftShoppingEmpty(
                onGenerate: () => _generateFromDiet(context, store, user.id, items),
                onAdd: () => _openAddSheet(context, store, user.id, items),
              )
                  .animate()
                  .fadeIn(duration: 320.ms)
                  .scale(begin: const Offset(0.96, 0.96))
            else if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  'Bu filtrede ürün yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              )
            else ...[
              if (priority.isNotEmpty) ...[
                const SoftShoppingSectionLabel(
                  title: 'Önce bunları al',
                  icon: Icons.priority_high_rounded,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < priority.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftShopCard(
                      item: priority[i],
                      onToggle: () => _toggle(store, user.id, items, priority[i]),
                      onOpen: () => _openDetail(context, store, user.id, items, priority[i]),
                    )
                        .animate()
                        .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                  ),
                const SizedBox(height: 6),
              ],
              if (open.isNotEmpty) ...[
                SoftShoppingSectionLabel(
                  title: _filter == 'Tümü' ? 'Listen' : ShoppingVisuals.label(_filter),
                  icon: Icons.checklist_rounded,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < open.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftShopCard(
                      item: open[i],
                      onToggle: () => _toggle(store, user.id, items, open[i]),
                      onOpen: () => _openDetail(context, store, user.id, items, open[i]),
                    )
                        .animate()
                        .fadeIn(delay: (35 * i).ms, duration: 280.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                  ),
              ],
              if (checked.isNotEmpty && !_hideChecked) ...[
                const SizedBox(height: 8),
                SoftShoppingSectionLabel(
                  title: 'Sepete gidenler ($done)',
                  icon: Icons.check_circle_rounded,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < checked.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SoftShopCard(
                      item: checked[i],
                      onToggle: () => _toggle(store, user.id, items, checked[i]),
                      onOpen: () => _openDetail(context, store, user.id, items, checked[i]),
                    ).animate().fadeIn(delay: (25 * i).ms, duration: 240.ms),
                  ),
              ],
            ],
            const SizedBox(height: 12),
            const SoftShoppingFooterTip()
                .animate()
                .fadeIn(delay: 160.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(AppStore store, String userId, List<ShoppingItem> items, ShoppingItem item) async {
    final next = [
      for (final i in items)
        if (i.key == item.key) i.copyWith(checked: !i.checked) else i,
    ];
    await store.saveShoppingList(userId, next);
  }

  Future<void> _generateFromDiet(
    BuildContext context,
    AppStore store,
    String userId,
    List<ShoppingItem> current,
  ) async {
    final plan = store.dietPlanForClient(userId);
    if (plan == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önce bir diyet planı olmalı')),
        );
      }
      return;
    }
    final checkedByKey = {for (final i in current) i.key: i.checked};
    final generated = <String, ShoppingItem>{};
    for (final day in plan.days) {
      for (final meal in day.meals) {
        for (final ing in meal.ingredients) {
          final key = '${ing.category}|${ing.name}|${ing.amount}';
          generated[key] = ShoppingItem(
            id: 'diet-$key',
            name: ing.name,
            amount: ing.amount,
            category: ing.category,
            checked: checkedByKey[key] ?? checkedByKey['diet-$key'] ?? false,
            tip: _tipForIngredient(ing),
            aisle: _aisleFor(ing.category),
          );
        }
      }
    }
    await store.saveShoppingList(userId, generated.values.toList());
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${generated.length} ürün diyetten eklendi')),
      );
    }
  }

  String _tipForIngredient(Ingredient ing) {
    switch (ing.category) {
      case 'vegetable':
        return 'Taze ve canlı renkli olanları seç.';
      case 'protein':
        return 'Porsiyonunu haftalık menüye göre ayarla.';
      case 'dairy':
        return 'Son kullanma tarihine dikkat et.';
      case 'grain':
        return 'Tam tahıl / az işlenmiş tercih et.';
      default:
        return 'Listeye göre al, dürtü rafına bakma.';
    }
  }

  String _aisleFor(String cat) => switch (cat) {
        'vegetable' => 'Sebze-meyve',
        'protein' => 'Et / balık / bakliyat',
        'dairy' => 'Süt ürünleri',
        'grain' => 'Tahıl / bakliyat',
        _ => 'Genel',
      };

  void _openDetail(
    BuildContext context,
    AppStore store,
    String userId,
    List<ShoppingItem> items,
    ShoppingItem item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoftShopDetailSheet(
        item: item,
        onToggle: () async {
          await _toggle(store, userId, items, item);
          if (ctx.mounted) Navigator.pop(ctx);
        },
        onDelete: () async {
          final next = items.where((e) => e.key != item.key).toList();
          await store.saveShoppingList(userId, next);
          if (ctx.mounted) Navigator.pop(ctx);
        },
        onTogglePriority: () async {
          final next = [
            for (final i in items)
              if (i.key == item.key) i.copyWith(priority: !i.priority) else i,
          ];
          await store.saveShoppingList(userId, next);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  void _openAddSheet(BuildContext context, AppStore store, String userId, List<ShoppingItem> items) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoftAddShopItemSheet(
        onSave: (item) async {
          await store.saveShoppingList(userId, [...items, item]);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}
