import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/data/app_store.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/marketplace.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/shopping_visuals.dart';
import '../../../../core/widgets/nav_back.dart';
import '../../../../core/l10n/ui_string.dart';


class SoftShoppingHeader extends StatelessWidget {
  const SoftShoppingHeader({super.key, required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(('Alışveriş').ui,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(('Haftalık market listesi').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        SoftTap(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ],
    );
  }
}

class SoftShoppingHero extends StatelessWidget {
  const SoftShoppingHero({
    super.key,
    required this.done,
    required this.total,
    required this.tip,
  });

  final int done;
  final int total;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFFFF0E8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(('Haftalık market').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text((total == 0 ? 'Listen seni bekliyor' : '$done / $total alındı').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text((tip).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.75),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 64,
            fallback: Icons.shopping_bag_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftShoppingStatsRow extends StatelessWidget {
  const SoftShoppingStatsRow({
    super.key,
    required this.total,
    required this.done,
    required this.priority,
    required this.categories,
  });

  final int total;
  final int done;
  final int priority;
  final int categories;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.shopping_cart_rounded, DiyetselAssets.modernIconPlan, AppColors.primary, 'Ürün', '$total'),
      (Icons.check_circle_rounded, DiyetselAssets.modernIconCheck, const Color(0xFF5BA3C9), 'Alındı', '$done'),
      (Icons.bolt_rounded, DiyetselAssets.modernIconStreak, const Color(0xFFE07A5F), 'Öncelik', '$priority'),
      (Icons.category_rounded, DiyetselAssets.modernIconAppsAll, const Color(0xFFD4A017), 'Reyon', '$categories'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                children: [
                  SoftModernIcon(
                    items[i].$2,
                    size: 22,
                    fallback: items[i].$1,
                    fallbackColor: items[i].$3,
                  ),
                  const SizedBox(height: 6),
                  Text((items[i].$5).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$3,
                    ),
                  ),
                  Text((items[i].$4).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
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

class SoftShoppingActionRow extends StatelessWidget {
  const SoftShoppingActionRow({
    super.key,
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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(('Diyetten üret').ui,
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
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Icon(Icons.add_rounded, color: AppColors.primary.withValues(alpha: 0.85), size: 22),
              ),
            ),
            const SizedBox(width: 8),
            SoftTap(
              onTap: onToggleHide,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: hideChecked ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: hideChecked ? AppColors.primary.withValues(alpha: 0.3) : AppColors.modernLine,
                  ),
                  boxShadow: AppSpacing.soft,
                ),
                child: Icon(
                  hideChecked ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.primary.withValues(alpha: 0.85),
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
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFE07A5F), size: 22),
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
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_rounded, color: AppColors.primary.withValues(alpha: 0.9), size: 20),
                  const SizedBox(width: 8),
                  Text(('Platforma gönder').ui,
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.95),
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

class SoftShoppingCategoryChips extends StatelessWidget {
  const SoftShoppingCategoryChips({
    super.key,
    required this.categories,
    required this.filter,
    required this.onChanged,
  });

  final List<String> categories;
  final String filter;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final selected = c == filter;
          final label = c == 'Tümü' ? 'Tümü' : ShoppingVisuals.label(c);
          final accent = c == 'Tümü' ? AppColors.primary : ShoppingVisuals.softAccentFor(c);
          return SoftTap(
            onTap: () => onChanged(c),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? accent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? accent : AppColors.modernLine),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : AppSpacing.soft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (c != 'Tümü') ...[
                    Icon(
                      ShoppingVisuals.iconFor(c),
                      size: 16,
                      color: selected ? Colors.white : accent,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text((label).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: selected ? Colors.white : AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoftShoppingSectionLabel extends StatelessWidget {
  const SoftShoppingSectionLabel({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary.withValues(alpha: 0.85)),
        const SizedBox(width: 6),
        Text((title).ui,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.primaryDeep,
          ),
        ),
      ],
    );
  }
}

class SoftShopCard extends StatelessWidget {
  const SoftShopCard({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onOpen,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tint = ShoppingVisuals.softTintFor(item.category);
    final accent = ShoppingVisuals.softAccentFor(item.category);
    final photo = ShoppingVisuals.imageFor(item);
    final dimmed = item.checked;

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.62 : 1,
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.priority && !item.checked
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.modernLine,
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
                    color: item.checked ? AppColors.primary : tint,
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
                          child: Text((item.name).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.5,
                              color: AppColors.primaryDeep,
                              decoration: item.checked ? TextDecoration.lineThrough : null,
                              decorationColor: AppColors.primary.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                        if (item.priority && !item.checked)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFE07A5F)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text((item.amount).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: accent,
                      ),
                    ),
                    if (item.tip.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text((item.tip).ui,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.3,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
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
                        child: Text((item.aisle).ui,
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

class SoftShoppingEmpty extends StatelessWidget {
  const SoftShoppingEmpty({
    super.key,
    required this.onGenerate,
    required this.onAdd,
  });

  final VoidCallback onGenerate;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 72,
            fallback: Icons.shopping_cart_outlined,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(height: 14),
          Text(('Sepetin henüz boş').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(('Diyet planından otomatik liste üret veya tek tek ekle — reyon ipuçlarıyla market turu kısalır.').ui,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),
          SoftTap(
            onTap: onGenerate,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(('Diyetten üret').ui,
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.modernLine),
              ),
              child: Text(('Manuel ürün ekle').ui,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftShoppingFooterTip extends StatelessWidget {
  const SoftShoppingFooterTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.lightbulb_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(('Diyetten üret, reyon etiketlerine bak, tamamlananları temizle — listen her hafta taze kalsın.').ui,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftShopDetailSheet extends StatelessWidget {
  const SoftShopDetailSheet({
    super.key,
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
    final tint = ShoppingVisuals.softTintFor(item.category);
    final accent = ShoppingVisuals.softAccentFor(item.category);
    final photo = ShoppingVisuals.imageFor(item);

    return DraggableScrollableSheet(
      initialChildSize: 0.58,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: photo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: diyetselFoodPhoto(url: photo, width: 68, height: 68, fit: BoxFit.cover),
                          )
                        : Icon(ShoppingVisuals.iconFor(item.category), color: accent, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((item.name).ui,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text((item.amount).ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            SoftMiniTag(
                              label: ShoppingVisuals.label(item.category),
                              color: tint,
                              ink: accent,
                            ),
                            if (item.aisle.isNotEmpty)
                              SoftMiniTag(
                                label: item.aisle,
                                color: const Color(0xFFE3F2F8),
                                ink: const Color(0xFF5BA3C9),
                              ),
                            if (item.priority)
                              const SoftMiniTag(
                                label: 'Öncelikli',
                                color: Color(0xFFFFF0E8),
                                ink: Color(0xFFE07A5F),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (item.tip.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(('Alışveriş ipucu').ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text((item.tip).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: AppColors.primary.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (item.note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(('Not').ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text((item.note).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: AppColors.primary.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SoftTap(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text((item.checked ? 'Tekrar listeye al' : 'Aldım — işaretle').ui,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SoftTap(
                      onTap: onTogglePriority,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.priority ? Icons.bolt_outlined : Icons.bolt_rounded,
                              size: 18,
                              color: const Color(0xFFE07A5F),
                            ),
                            const SizedBox(width: 6),
                            Text((item.priority ? 'Önceliği kaldır' : 'Öncelikli yap').ui,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SoftTap(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.modernLine),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE07A5F)),
                    ),
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

class SoftMiniTag extends StatelessWidget {
  const SoftMiniTag({
    super.key,
    required this.label,
    required this.color,
    required this.ink,
  });

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text((label).ui, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: ink)),
    );
  }
}

class SoftAddShopItemSheet extends StatefulWidget {
  const SoftAddShopItemSheet({super.key, required this.onSave});

  final Future<void> Function(ShoppingItem item) onSave;

  @override
  State<SoftAddShopItemSheet> createState() => _SoftAddShopItemSheetState();
}

class _SoftAddShopItemSheetState extends State<SoftAddShopItemSheet> {
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
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.modernWash,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  decoration: BoxDecoration(
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(('Ürün ekle').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 14),
              SoftShopField(controller: _name, label: 'Ürün adı', hint: 'Örn. Roka'),
              const SizedBox(height: 10),
              SoftShopField(controller: _amount, label: 'Miktar', hint: 'Örn. 1 demet'),
              const SizedBox(height: 10),
              SoftShopField(controller: _tip, label: 'İpucu (opsiyonel)'),
              const SizedBox(height: 14),
              Text(('Kategori').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ShoppingVisuals.categoryOrder)
                    SoftTap(
                      onTap: () => setState(() => _category = c),
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _category == c
                              ? ShoppingVisuals.softAccentFor(c)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _category == c
                                ? ShoppingVisuals.softAccentFor(c)
                                : AppColors.modernLine,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              ShoppingVisuals.iconFor(c),
                              size: 15,
                              color: _category == c
                                  ? Colors.white
                                  : ShoppingVisuals.softAccentFor(c),
                            ),
                            const SizedBox(width: 5),
                            Text((ShoppingVisuals.label(c)).ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: _category == c ? Colors.white : AppColors.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SoftTap(
                onTap: () => setState(() => _priority = !_priority),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.modernLine),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _priority ? Icons.bolt_rounded : Icons.bolt_outlined,
                        color: const Color(0xFFE07A5F),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(('Öncelikli ürün').ui,
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDeep),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 44,
                        height: 26,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _priority ? AppColors.primary : AppColors.modernLine,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        alignment: _priority ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SoftTap(
                onTap: _saving
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
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _saving ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text((_saving ? 'Kaydediliyor…' : 'Listeye ekle').ui,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoftShopField extends StatelessWidget {
  const SoftShopField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDeep),
      decoration: InputDecoration(
        labelText: (label).ui,
        hintText: hint?.ui,
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primary.withValues(alpha: 0.55),
        ),
        hintStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.35)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.modernLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.modernLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
