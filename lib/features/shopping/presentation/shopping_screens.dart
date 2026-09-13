import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/marketplace.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import '../domain/shopping_from_diet.dart';
import '../domain/shopping_platforms.dart';
import '../domain/shopping_visuals.dart';
import 'soft_shopping_screen.dart';
import 'widgets/shopping_delivery_sheet.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  String _filter = 'Tümü';
  bool _hideChecked = false;
  bool _didNormalize = false;

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return const SoftShoppingScreen();
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(shoppingListsProvider);
    final items = store.shoppingList(user.id);

    if (!_didNormalize && items.isNotEmpty && ShoppingFromDiet.needsNormalize(items)) {
      _didNormalize = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final cleaned = ShoppingFromDiet.normalizeItems(items);
        await store.saveShoppingList(user.id, cleaned);
      });
    } else if (!_didNormalize) {
      _didNormalize = true;
    }

    final done = items.where((e) => e.checked).length;
    final total = items.length;
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

    return AppPage(
      title: 'Alışveriş',
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: 'Ürün ekle',
          onPressed: () => _openAddSheet(context, store, user.id, items),
          icon: const Icon(Icons.add_rounded, color: AppColors.kawaiiLeafDeep, size: 26),
        ),
      ],
      child: ColoredBox(
        color: AppColors.kawaiiSurfaceCream,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _ShoppingHero(
              done: done,
              total: total,
              tip: ShoppingVisuals.tipOfDay(DateTime.now().day),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            _ActionRow(
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
              onSendToPlatform: items.isEmpty
                  ? null
                  : () => showShoppingDeliverySheet(
                        context: context,
                        items: items,
                        cartoon: true,
                        initialPlatform: ShoppingDeliveryPlatformX.tryParse(
                          store.preferredShoppingPlatform(user.id),
                        ),
                        onPlatformSelected: (p) {
                          store.savePreferredShoppingPlatform(user.id, p.id);
                        },
                      ),
            ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final selected = c == _filter;
                  final label = c == 'Tümü' ? 'Tümü' : ShoppingVisuals.label(c);
                  return FilterChip(
                    selected: selected,
                    showCheckmark: false,
                    avatar: c == 'Tümü'
                        ? null
                        : Icon(
                            ShoppingVisuals.iconFor(c),
                            size: 16,
                            color: selected ? Colors.white : ShoppingVisuals.accentFor(c),
                          ),
                    label: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: selected ? Colors.white : AppColors.kawaiiInk,
                      ),
                    ),
                    selectedColor: AppColors.kawaiiLeaf,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
                    onSelected: (_) => setState(() => _filter = c),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              _EmptyShopping(
                onGenerate: () => _generateFromDiet(context, store, user.id, items),
                onAdd: () => _openAddSheet(context, store, user.id, items),
              ).animate().fadeIn(duration: 320.ms).scale(begin: const Offset(0.96, 0.96))
            else if (shown.isEmpty)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Text(
                  'Bu filtrede ürün yok.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                ),
              )
            else ...[
              if (priority.isNotEmpty) ...[
                const _SectionLabel(title: 'Önce bunları al', emojiIcon: Icons.priority_high_rounded),
                const SizedBox(height: 8),
                for (var i = 0; i < priority.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CartoonShopCard(
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
                _SectionLabel(
                  title: _filter == 'Tümü' ? 'Listen' : ShoppingVisuals.label(_filter),
                  emojiIcon: Icons.checklist_rounded,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < open.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CartoonShopCard(
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
                _SectionLabel(
                  title: 'Sepete gidenler ($done)',
                  emojiIcon: Icons.check_circle_rounded,
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < checked.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CartoonShopCard(
                      item: checked[i],
                      onToggle: () => _toggle(store, user.id, items, checked[i]),
                      onOpen: () => _openDetail(context, store, user.id, items, checked[i]),
                    ).animate().fadeIn(delay: (25 * i).ms, duration: 240.ms),
                  ),
              ],
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.kawaiiOutline),
                boxShadow: AppSpacing.soft,
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppColors.kawaiiLeafDeep),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Diyetten üret, reyon etiketlerine bak, tamamlananları temizle — listen her hafta taze kalsın.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.kawaiiMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 300.ms),
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
          const SnackBar(
            content: Text('Önce bir diyet planın olmalı. Diyetisyeninden plan iste.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final result = ShoppingFromDiet.build(plan: plan, current: current);
    if (result.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Planda alışverişe çevrilecek malzeme bulunamadı. Öğünlere malzeme eklenmiş olmalı.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    await store.saveShoppingList(userId, result.items);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.dietItemCount} ürün diyetten eklendi'
            '${result.items.length > result.dietItemCount ? ' · elle eklenenler korundu' : ''}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
      builder: (ctx) => _ShopDetailSheet(
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
      builder: (ctx) => _AddShopItemSheet(
        onSave: (item) async {
          await store.saveShoppingList(userId, [...items, item]);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _ShoppingHero extends StatelessWidget {
  const _ShoppingHero({required this.done, required this.total, required this.tip});

  final int done;
  final int total;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream, AppColors.kawaiiLemon],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Haftalık market',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  total == 0 ? 'Listen seni bekliyor' : '$done / $total alındı',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.kawaiiInk,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.kawaiiMuted,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    color: AppColors.kawaiiLeaf,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(DiyetselAssets.mascotCarrot, height: 88, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.onGenerate,
    required this.onAdd,
    required this.onClearChecked,
    required this.hideChecked,
    required this.onToggleHide,
    this.onSendToPlatform,
  });

  final VoidCallback onGenerate;
  final VoidCallback onAdd;
  final VoidCallback? onClearChecked;
  final bool hideChecked;
  final VoidCallback onToggleHide;
  final VoidCallback? onSendToPlatform;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SoftTap(
                onTap: onGenerate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiLeaf,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Diyetten üret',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SoftTap(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.kawaiiLeafDeep, size: 22),
              ),
            ),
            const SizedBox(width: 8),
            SoftTap(
              onTap: onToggleHide,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hideChecked ? AppColors.kawaiiMint : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: Icon(
                  hideChecked ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.kawaiiLeafDeep,
                  size: 22,
                ),
              ),
            ),
            if (onClearChecked != null) ...[
              const SizedBox(width: 8),
              SoftTap(
                onTap: onClearChecked,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.kawaiiOutline),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: AppColors.kawaiiCoralDeep, size: 22),
                ),
              ),
            ],
          ],
        ),
        if (onSendToPlatform != null) ...[
          const SizedBox(height: 8),
          SoftTap(
            onTap: onSendToPlatform,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.kawaiiOutline),
                boxShadow: AppSpacing.soft,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_rounded, color: AppColors.kawaiiLeafDeep, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Platforma gönder',
                    style: TextStyle(
                      color: AppColors.kawaiiLeafDeep,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.emojiIcon});

  final String title;
  final IconData emojiIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(emojiIcon, size: 18, color: AppColors.kawaiiLeafDeep),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk),
        ),
      ],
    );
  }
}

class _CartoonShopCard extends StatelessWidget {
  const _CartoonShopCard({
    required this.item,
    required this.onToggle,
    required this.onOpen,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tint = ShoppingVisuals.tintFor(item.category);
    final accent = ShoppingVisuals.accentFor(item.category);
    final photo = ShoppingVisuals.imageFor(item);
    final dimmed = item.checked;

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.62 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: item.priority && !item.checked ? AppColors.kawaiiLeaf.withValues(alpha: 0.55) : AppColors.kawaiiOutline,
              width: item.priority && !item.checked ? 1.6 : 1,
            ),
            boxShadow: AppSpacing.soft,
          ),
          child: Row(
            children: [
              SoftTap(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.checked ? AppColors.kawaiiLeaf : tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.checked ? Icons.check_rounded : ShoppingVisuals.iconFor(item.category),
                    color: item.checked ? Colors.white : accent,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              color: AppColors.kawaiiInk,
                              decoration: item.checked ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.kawaiiMuted,
                            ),
                          ),
                        ),
                        if (item.priority && !item.checked)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.bolt_rounded, size: 18, color: AppColors.kawaiiCoral),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.amount,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.kawaiiLeafDeep),
                    ),
                    if (item.tip.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.tip,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, height: 1.3, color: AppColors.kawaiiMuted),
                      ),
                    ],
                    if (item.aisle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item.aisle,
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: accent),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (photo != null) ...[
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: diyetselFoodPhoto(url: photo, width: 56, height: 56, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyShopping extends StatelessWidget {
  const _EmptyShopping({required this.onGenerate, required this.onAdd});

  final VoidCallback onGenerate;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          Image.asset(DiyetselAssets.mascotAvocado, height: 96),
          const SizedBox(height: 12),
          const Text(
            'Sepetin henüz boş',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 6),
          const Text(
            'Diyet planından otomatik liste üret veya tek tek ekle — reyon ipuçlarıyla market turu kısalır.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.4, color: AppColors.kawaiiMuted),
          ),
          const SizedBox(height: 16),
          SoftTap(
            onTap: onGenerate,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.kawaiiLeaf,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Diyetten üret',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SoftTap(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.kawaiiMint,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.kawaiiOutline),
              ),
              child: const Text(
                'Manuel ürün ekle',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.kawaiiLeafDeep, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopDetailSheet extends StatelessWidget {
  const _ShopDetailSheet({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    required this.onTogglePriority,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTogglePriority;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final tint = ShoppingVisuals.tintFor(item.category);
    final accent = ShoppingVisuals.accentFor(item.category);
    final photo = ShoppingVisuals.imageFor(item);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiOutline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: photo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: diyetselFoodPhoto(url: photo, width: 64, height: 64, fit: BoxFit.cover),
                          )
                        : Icon(ShoppingVisuals.iconFor(item.category), color: accent, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: cartoon ? AppColors.kawaiiInk : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.amount,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _MiniTag(label: ShoppingVisuals.label(item.category), color: tint, ink: accent),
                            if (item.aisle.isNotEmpty) _MiniTag(label: item.aisle, color: AppColors.kawaiiSky, ink: AppColors.kawaiiLeafDeep),
                            if (item.priority) const _MiniTag(label: 'Öncelikli', color: AppColors.kawaiiPeach, ink: AppColors.kawaiiCoralDeep),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.tip.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Alışveriş ipucu',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: cartoon ? AppColors.kawaiiInk : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.tip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: cartoon ? AppColors.kawaiiMuted : null,
                  ),
                ),
              ],
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Not',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: cartoon ? AppColors.kawaiiInk : null,
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.note, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
              ],
              const SizedBox(height: 22),
              SoftTap(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    item.checked ? 'Tekrar listeye al' : 'Aldım — işaretle',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTogglePriority,
                      icon: Icon(item.priority ? Icons.bolt_outlined : Icons.bolt_rounded),
                      label: Text(item.priority ? 'Önceliği kaldır' : 'Öncelikli yap'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label, required this.color, required this.ink});

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: ink)),
    );
  }
}

class _AddShopItemSheet extends StatefulWidget {
  const _AddShopItemSheet({required this.onSave});

  final Future<void> Function(ShoppingItem item) onSave;

  @override
  State<_AddShopItemSheet> createState() => _AddShopItemSheetState();
}

class _AddShopItemSheetState extends State<_AddShopItemSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _tip = TextEditingController();
  String _category = 'vegetable';
  bool _priority = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _tip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppColors.kawaiiOutline, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              Text(
                'Ürün ekle',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: cartoon ? AppColors.kawaiiInk : null,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Ürün adı', hintText: 'Örn. Roka'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _amount,
                decoration: const InputDecoration(labelText: 'Miktar', hintText: 'Örn. 1 demet'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tip,
                decoration: const InputDecoration(labelText: 'İpucu (opsiyonel)'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ShoppingVisuals.categoryOrder)
                    ChoiceChip(
                      selected: _category == c,
                      label: Text(ShoppingVisuals.label(c)),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Öncelikli ürün', style: TextStyle(fontWeight: FontWeight.w700)),
                value: _priority,
                onChanged: (v) => setState(() => _priority = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        final name = _name.text.trim();
                        if (name.isEmpty) return;
                        setState(() => _saving = true);
                        await widget.onSave(
                          ShoppingItem(
                            id: newId(),
                            name: name,
                            amount: _amount.text.trim().isEmpty ? '1 adet' : _amount.text.trim(),
                            category: _category,
                            tip: _tip.text.trim(),
                            aisle: switch (_category) {
                              'vegetable' => 'Sebze-meyve',
                              'protein' => 'Et / balık / bakliyat',
                              'dairy' => 'Süt ürünleri',
                              'grain' => 'Tahıl / bakliyat',
                              _ => 'Genel',
                            },
                            priority: _priority,
                          ),
                        );
                      },
                child: Text(_saving ? 'Kaydediliyor…' : 'Listeye ekle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
