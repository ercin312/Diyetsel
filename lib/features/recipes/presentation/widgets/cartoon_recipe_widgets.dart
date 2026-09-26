import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/data/app_store.dart';
import '../../../../core/data/providers.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/recipe_logic.dart';
import '../../../../core/widgets/cartoon_asset_icon.dart';
import '../../../../core/widgets/marketplace.dart';
import '../../../../core/widgets/nav_back.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../domain/recipe_visuals.dart';
import '../../../../core/l10n/ui_string.dart';

enum CartoonRecipeShelf { discover, liked, saved }

enum CartoonRecipeQuickFilter { all, quick, highProtein, lowCal }

Color cartoonTintFor(Recipe r) {
  switch (RecipeVisuals.tintFor(r)) {
    case ColorTint.lemon:
      return AppColors.kawaiiLemon;
    case ColorTint.mint:
      return AppColors.kawaiiMint;
    case ColorTint.lilac:
      return AppColors.kawaiiLilac;
    case ColorTint.peach:
      return AppColors.kawaiiPeach;
    case ColorTint.sky:
      return AppColors.kawaiiSky;
  }
}

Color cartoonAccentFor(Recipe r) {
  switch (RecipeVisuals.tintFor(r)) {
    case ColorTint.lemon:
      return AppColors.kawaiiSalmon;
    case ColorTint.mint:
      return AppColors.kawaiiLeaf;
    case ColorTint.lilac:
      return AppColors.kawaiiPurple;
    case ColorTint.peach:
      return AppColors.kawaiiCoral;
    case ColorTint.sky:
      return AppColors.kawaiiSkyBlue;
  }
}

class CartoonWashBackground extends StatelessWidget {
  const CartoonWashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.kawaiiSurfaceCream,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -28,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kawaiiMint.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            top: 160,
            left: -50,
            child: IgnorePointer(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kawaiiLemon.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: -36,
            child: IgnorePointer(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kawaiiPeach.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class CartoonNavBackButton extends StatelessWidget {
  const CartoonNavBackButton({super.key, this.showLabelOnDesktop = true});

  final bool showLabelOnDesktop;

  @override
  Widget build(BuildContext context) {
    final canBack = canNavigateBack(context);
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final label = canBack ? 'Geri' : 'Ana sayfa';
    final icon = canBack ? Icons.arrow_back_rounded : Icons.home_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateBackOrHome(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.soft,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: desktop && showLabelOnDesktop ? 12 : 0,
            ),
            child: SizedBox(
              height: 44,
              width: desktop && showLabelOnDesktop ? null : 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.kawaiiLeafDeep, size: 22),
                  if (desktop && showLabelOnDesktop) ...[
                    const SizedBox(width: 8),
                    Text((label).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CartoonSectionTitle extends StatelessWidget {
  const CartoonSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((title).ui,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.kawaiiInk,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text((subtitle!).ui,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.kawaiiMuted.withValues(alpha: 0.95),
            ),
          ),
        ],
      ],
    );
  }
}

class CartoonRecipesHeader extends StatelessWidget {
  const CartoonRecipesHeader({
    super.key,
    required this.admin,
    this.likedCount = 0,
    this.savedCount = 0,
  });

  final bool admin;
  final int likedCount;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CartoonNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((admin ? 'Tarif yönetimi' : 'Tarifler').ui,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.kawaiiInk,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text((admin
                    ? 'Danışanlara özel tarifler oluştur ve yayınla'
                    : likedCount + savedCount > 0
                        ? '$likedCount beğeni · $savedCount kayıtlı · mutfakta yanındayız'
                        : 'Beğen, kaydet, sonra pişir · sıcak lezzet').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.kawaiiInk.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: const CartoonAssetIcon(
            DiyetselAssets.iconPlan,
            size: 28,
            fallback: Icons.menu_book_rounded,
            fallbackColor: AppColors.kawaiiLeaf,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 1600.ms,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

class CartoonRecipesHero extends StatelessWidget {
  const CartoonRecipesHero({
    super.key,
    required this.count,
    required this.categories,
    this.likedCount = 0,
    this.savedCount = 0,
  });

  final int count;
  final int categories;
  final int likedCount;
  final int savedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E0), AppColors.kawaiiSurfaceCream, AppColors.kawaiiMint],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiLeaf.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(('Mutfakta ilham').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.kawaiiLeafDeep,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2400.ms, color: Colors.white24),
                const SizedBox(height: 12),
                Text(('Protein odaklı mutfak').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.kawaiiInk,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(('$count tarif · $categories kategori · adım adım & makro net').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.kawaiiInk.withValues(alpha: 0.65),
                  ),
                ),
                if (likedCount + savedCount > 0) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (likedCount > 0)
                        CartoonRecipeMetaChip(
                          icon: Icons.favorite_rounded,
                          label: '$likedCount beğeni',
                          color: AppColors.kawaiiCoral,
                        ),
                      if (savedCount > 0)
                        CartoonRecipeMetaChip(
                          icon: Icons.bookmark_rounded,
                          label: '$savedCount kayıt',
                          color: AppColors.kawaiiLeaf,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Image.asset(
            DiyetselAssets.foodLentilSoup,
            width: 78,
            height: 78,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const CartoonAssetIcon(
              DiyetselAssets.mascotCarrot,
              size: 72,
              fallback: Icons.soup_kitchen_rounded,
              fallbackColor: AppColors.kawaiiLeaf,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -5, duration: 1600.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class CartoonRecipeMetaChip extends StatelessWidget {
  const CartoonRecipeMetaChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text((label).ui,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: color),
          ),
        ],
      ),
    );
  }
}

class CartoonRecipeShelfTabs extends StatelessWidget {
  const CartoonRecipeShelfTabs({
    super.key,
    required this.shelf,
    required this.likedCount,
    required this.savedCount,
    required this.onChanged,
  });

  final CartoonRecipeShelf shelf;
  final int likedCount;
  final int savedCount;
  final ValueChanged<CartoonRecipeShelf> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (CartoonRecipeShelf.discover, 'Keşfet', Icons.explore_rounded, null),
      (CartoonRecipeShelf.liked, 'Beğenilen', Icons.favorite_rounded, likedCount),
      (CartoonRecipeShelf.saved, 'Kayıtlı', Icons.bookmark_rounded, savedCount),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: SoftTap(
                onTap: () => onChanged(item.$1),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: shelf == item.$1 ? AppColors.kawaiiLeaf : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: shelf == item.$1
                        ? [
                            BoxShadow(
                              color: AppColors.kawaiiLeaf.withValues(alpha: 0.32),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        item.$3,
                        size: 18,
                        color: shelf == item.$1
                            ? Colors.white
                            : AppColors.kawaiiLeaf.withValues(alpha: 0.55),
                      ),
                      const SizedBox(height: 4),
                      Text((item.$4 == null ? item.$2 : '${item.$2} (${item.$4})').ui,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: shelf == item.$1
                              ? Colors.white
                              : AppColors.kawaiiInk.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CartoonRecipeQuickFilters extends StatelessWidget {
  const CartoonRecipeQuickFilters({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final CartoonRecipeQuickFilter selected;
  final ValueChanged<CartoonRecipeQuickFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (CartoonRecipeQuickFilter.all, 'Hepsi', Icons.apps_rounded),
      (CartoonRecipeQuickFilter.quick, '≤15 dk', Icons.bolt_rounded),
      (CartoonRecipeQuickFilter.highProtein, 'Yüksek P', Icons.fitness_center_rounded),
      (CartoonRecipeQuickFilter.lowCal, 'Hafif', Icons.eco_rounded),
    ];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final item = items[i];
          final on = selected == item.$1;
          return SoftTap(
            onTap: () => onChanged(item.$1),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: on ? AppColors.kawaiiPeach : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: on ? AppColors.kawaiiCoral.withValues(alpha: 0.45) : AppColors.kawaiiOutline,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.$3,
                    size: 15,
                    color: on ? AppColors.kawaiiCoralDeep : AppColors.kawaiiLeaf.withValues(alpha: 0.55),
                  ),
                  const SizedBox(width: 6),
                  Text((item.$2).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: on ? AppColors.kawaiiCoralDeep : AppColors.kawaiiInk.withValues(alpha: 0.7),
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

class CartoonRecipesStatsRow extends StatelessWidget {
  const CartoonRecipesStatsRow({
    super.key,
    required this.recipes,
    required this.avgKcal,
    required this.quick,
    this.liked = 0,
    this.saved = 0,
  });

  final int recipes;
  final int avgKcal;
  final int quick;
  final int liked;
  final int saved;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tarif', '$recipes', DiyetselAssets.iconPlan, Icons.menu_book_rounded, AppColors.kawaiiLeaf),
      ('Ort. kcal', '$avgKcal', DiyetselAssets.iconCheck, Icons.local_fire_department_rounded, AppColors.kawaiiCoral),
      ('Hızlı', '$quick', DiyetselAssets.iconCalendar, Icons.timer_outlined, AppColors.kawaiiSkyBlue),
      if (liked + saved > 0)
        ('Koleksiyon', '${liked + saved}', DiyetselAssets.iconStreak, Icons.favorite_rounded, AppColors.kawaiiSalmon),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.kawaiiOutline),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CartoonAssetIcon(
                    items[i].$3,
                    size: 22,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text((items[i].$1).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.kawaiiMuted.withValues(alpha: 0.9),
                    ),
                  ),
                  Text((items[i].$2).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: items[i].$5,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: (40 * i).ms, duration: 260.ms)
                .slideY(begin: 0.08, curve: Curves.easeOutCubic),
          ),
        ],
      ],
    );
  }
}

class CartoonTipCard extends StatelessWidget {
  const CartoonTipCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.timer_outlined,
    this.accent = AppColors.kawaiiCoral,
    this.tint = AppColors.kawaiiPeach,
    this.onTap,
    this.actionLabel,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Color tint;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((title).ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.kawaiiInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text((body).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      height: 1.4,
                      color: AppColors.kawaiiInk.withValues(alpha: 0.65),
                    ),
                  ),
                  if (actionLabel != null) ...[
                    const SizedBox(height: 8),
                    Text((actionLabel!).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonRecipeCollectionStrip extends StatelessWidget {
  const CartoonRecipeCollectionStrip({
    super.key,
    required this.liked,
    required this.saved,
    required this.isLiked,
    required this.isSaved,
    required this.onOpen,
    required this.onShowLiked,
    required this.onShowSaved,
  });

  final List<Recipe> liked;
  final List<Recipe> saved;
  final bool Function(String id) isLiked;
  final bool Function(String id) isSaved;
  final ValueChanged<Recipe> onOpen;
  final VoidCallback onShowLiked;
  final VoidCallback onShowSaved;

  @override
  Widget build(BuildContext context) {
    final preview = <Recipe>[
      ...saved.take(6),
      ...liked.where((r) => !saved.any((s) => s.id == r.id)).take(6),
    ].take(8).toList();
    if (preview.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: CartoonSectionTitle(
                title: 'Senin koleksiyonun',
                subtitle: 'Beğendiğin ve kaydettiğin tarifler',
              ),
            ),
            SoftTap(
              onTap: onShowSaved,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(('Tümü →').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.kawaiiLeafDeep,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              if (i == preview.length) {
                return SoftTap(
                  onTap: onShowLiked,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.kawaiiOutline),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded, color: AppColors.kawaiiCoral),
                        SizedBox(height: 6),
                        Text(('Beğeniler').ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.kawaiiInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final r = preview[i];
              return SoftTap(
                onTap: () => onOpen(r),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.kawaiiOutline),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: diyetselFoodPhoto(
                              url: RecipeVisuals.imageFor(r),
                              width: 92,
                              height: 62,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                if (isLiked(r.id))
                                  const Icon(Icons.favorite_rounded, size: 14, color: AppColors.kawaiiCoral),
                                if (isSaved(r.id)) ...[
                                  const SizedBox(width: 2),
                                  const Icon(Icons.bookmark_rounded, size: 14, color: AppColors.kawaiiLeaf),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text((r.title).ui,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          height: 1.2,
                          color: AppColors.kawaiiInk,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                  .slideX(begin: 0.08, curve: Curves.easeOutCubic);
            },
          ),
        ),
      ],
    );
  }
}

class CartoonRecipeReactionButton extends StatelessWidget {
  const CartoonRecipeReactionButton({
    super.key,
    required this.active,
    required this.activeIcon,
    required this.idleIcon,
    required this.color,
    required this.onTap,
    this.compact = false,
  });

  final bool active;
  final IconData activeIcon;
  final IconData idleIcon;
  final Color color;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 34.0 : 40.0;
    final iconSize = compact ? 17.0 : 20.0;
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? color.withValues(alpha: 0.4) : AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Icon(active ? activeIcon : idleIcon, size: iconSize, color: color),
      ),
    )
        .animate(target: active ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 180.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class CartoonRecipeCategoryChip extends StatelessWidget {
  const CartoonRecipeCategoryChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.kawaiiLeaf : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.kawaiiLeaf.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Text((label).ui,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: selected ? Colors.white : AppColors.kawaiiInk.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

class CartoonRecipeSuggestionCard extends StatelessWidget {
  const CartoonRecipeSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onOpen,
    this.liked = false,
    this.saved = false,
    this.onToggleLike,
    this.onToggleSave,
  });

  final RecipeSuggestion suggestion;
  final VoidCallback onOpen;
  final bool liked;
  final bool saved;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final r = suggestion.recipe;
    final accent = cartoonAccentFor(r);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 258,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: diyetselFoodPhoto(
                    url: RecipeVisuals.imageFor(r),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text((suggestion.highlight).ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text((r.title).ui,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.kawaiiInk,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    CartoonRecipeReactionButton(
                      active: liked,
                      activeIcon: Icons.favorite_rounded,
                      idleIcon: Icons.favorite_border_rounded,
                      color: AppColors.kawaiiCoral,
                      onTap: onToggleLike,
                      compact: true,
                    ),
                    const SizedBox(height: 6),
                    CartoonRecipeReactionButton(
                      active: saved,
                      activeIcon: Icons.bookmark_rounded,
                      idleIcon: Icons.bookmark_border_rounded,
                      color: AppColors.kawaiiLeaf,
                      onTap: onToggleSave,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text((suggestion.reason).ui,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.kawaiiMuted.withValues(alpha: 0.95),
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(('${r.calories} kcal · ${recipeProtein(r)} g P · ${r.prepMinutes} dk').ui,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonRecipeFeaturedCard extends StatelessWidget {
  const CartoonRecipeFeaturedCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    this.liked = false,
    this.saved = false,
    this.onToggleLike,
    this.onToggleSave,
  });

  final Recipe recipe;
  final VoidCallback onOpen;
  final bool liked;
  final bool saved;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final tint = cartoonTintFor(recipe);
    final accent = cartoonAccentFor(recipe);
    final tags = RecipeVisuals.displayTags(recipe);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.15)!,
                    Color.lerp(tint, AppColors.kawaiiCream, 0.4)!,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(('Öne çıkan').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: accent,
                                ),
                              ),
                            )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .shimmer(duration: 2200.ms, color: Colors.white38),
                            for (final t in tags.take(2))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text((t).ui,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    color: AppColors.kawaiiInk,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text((recipe.title).ui,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.2,
                            color: AppColors.kawaiiInk,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text((recipe.description).ui,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.kawaiiInk.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      diyetselFoodPhoto(
                        url: RecipeVisuals.imageFor(recipe),
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .moveY(begin: 0, end: -4, duration: 1400.ms, curve: Curves.easeInOut),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CartoonRecipeReactionButton(
                            active: liked,
                            activeIcon: Icons.favorite_rounded,
                            idleIcon: Icons.favorite_border_rounded,
                            color: AppColors.kawaiiCoral,
                            onTap: onToggleLike,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          CartoonRecipeReactionButton(
                            active: saved,
                            activeIcon: Icons.bookmark_rounded,
                            idleIcon: Icons.bookmark_border_rounded,
                            color: AppColors.kawaiiLeaf,
                            onTap: onToggleSave,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  CartoonRecipeMacroPill(label: 'kcal', value: '${recipe.calories}', color: AppColors.kawaiiCoral),
                  const SizedBox(width: 6),
                  CartoonRecipeMacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.kawaiiLeaf),
                  const SizedBox(width: 6),
                  CartoonRecipeMacroPill(
                    label: 'süre',
                    value: '${recipe.prepMinutes} dk',
                    color: AppColors.kawaiiPurple,
                  ),
                  const Spacer(),
                  Text(('Tarifi aç').ui,
                    style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13.5),
                  ),
                  Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonRecipeCard extends StatelessWidget {
  const CartoonRecipeCard({
    super.key,
    required this.recipe,
    required this.onOpen,
    this.index = 0,
    this.liked = false,
    this.saved = false,
    this.onToggleLike,
    this.onToggleSave,
  });

  final Recipe recipe;
  final VoidCallback onOpen;
  final int index;
  final bool liked;
  final bool saved;
  final VoidCallback? onToggleLike;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    final tint = cartoonTintFor(recipe);
    final accent = cartoonAccentFor(recipe);
    final tags = RecipeVisuals.displayTags(recipe);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.softLift,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.2)!,
                    Color.lerp(tint, AppColors.kawaiiCream, 0.45)!,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final t in tags.take(3))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.8)),
                                ),
                                child: Text((t).ui,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    color: accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text((recipe.title).ui,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.2,
                            color: AppColors.kawaiiInk,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text((recipe.description).ui,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.kawaiiInk.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Column(
                    children: [
                      diyetselFoodPhoto(
                        url: RecipeVisuals.imageFor(recipe),
                        width: 88,
                        height: 88,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CartoonRecipeReactionButton(
                            active: liked,
                            activeIcon: Icons.favorite_rounded,
                            idleIcon: Icons.favorite_border_rounded,
                            color: AppColors.kawaiiCoral,
                            onTap: onToggleLike,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          CartoonRecipeReactionButton(
                            active: saved,
                            activeIcon: Icons.bookmark_rounded,
                            idleIcon: Icons.bookmark_border_rounded,
                            color: AppColors.kawaiiLeaf,
                            onTap: onToggleSave,
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      CartoonRecipeMacroPill(label: 'kcal', value: '${recipe.calories}', color: AppColors.kawaiiCoral),
                      CartoonRecipeMacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.kawaiiLeaf),
                      CartoonRecipeMacroPill(
                        label: 'süre',
                        value: '${recipe.totalMinutes > 0 ? recipe.totalMinutes : recipe.prepMinutes} dk',
                        color: AppColors.kawaiiPurple,
                      ),
                      CartoonRecipeMacroPill(
                        label: 'malzeme',
                        value: '${recipe.ingredients.length}',
                        color: AppColors.kawaiiSkyBlue,
                      ),
                      if (recipe.likes > 0)
                        CartoonRecipeMacroPill(
                          label: 'beğeni',
                          value: '${recipe.likes}',
                          color: AppColors.kawaiiCoral,
                        ),
                    ],
                  ),
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text((recipe.ingredients
                              .take(3)
                              .map((e) => e.amount.isEmpty ? e.name : '${e.name} (${e.amount})')
                              .join(' · ') +
                          (recipe.ingredients.length > 3 ? '…' : '')).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: AppColors.kawaiiMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(('Tarifi aç').ui,
                        style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13.5),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                      const Spacer(),
                      if (liked)
                        const Icon(Icons.favorite_rounded, size: 16, color: AppColors.kawaiiCoral),
                      if (saved) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.kawaiiLeaf),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(
          begin: 0.05,
          curve: Curves.easeOutCubic,
        );
  }
}

class CartoonRecipeMacroPill extends StatelessWidget {
  const CartoonRecipeMacroPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$value ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
            const TextSpan(
              text: '',
            ),
            TextSpan(
              text: label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.kawaiiMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartoonRecipesEmpty extends StatelessWidget {
  const CartoonRecipesEmpty({
    super.key,
    this.admin = false,
    this.shelf = CartoonRecipeShelf.discover,
    this.onAdd,
    this.onExplore,
  });

  final bool admin;
  final CartoonRecipeShelf shelf;
  final VoidCallback? onAdd;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final title = admin
        ? 'Henüz tarif yok'
        : switch (shelf) {
            CartoonRecipeShelf.liked => 'Beğenilen tarif yok',
            CartoonRecipeShelf.saved => 'Kayıtlı tarif yok',
            CartoonRecipeShelf.discover => 'Bu filtrede tarif yok',
          };
    final body = admin
        ? 'Danışanlara göstereceğin ilk tarifi ekle.'
        : switch (shelf) {
            CartoonRecipeShelf.liked => 'Bir tarifi kalp ile işaretle; burada seni bekler.',
            CartoonRecipeShelf.saved => 'Sonra pişirmek istediğin tarifleri kaydet.',
            CartoonRecipeShelf.discover => 'Başka bir kategori veya filtre dene.',
          };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.kawaiiOutline),
      ),
      child: Column(
        children: [
          const CartoonAssetIcon(
            DiyetselAssets.iconSearch,
            size: 48,
            fallback: Icons.restaurant_outlined,
            fallbackColor: AppColors.kawaiiMuted,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1200.ms),
          const SizedBox(height: 12),
          Text((title).ui,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.kawaiiInk,
            ),
          ),
          const SizedBox(height: 6),
          Text((body).ui,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.kawaiiMuted,
            ),
          ),
          if (admin && onAdd != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.kawaiiLeaf,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(('Yeni tarif ekle').ui),
            ),
          ],
          if (onExplore != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onExplore,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.kawaiiLeafDeep,
                side: const BorderSide(color: AppColors.kawaiiLeaf),
              ),
              icon: const Icon(Icons.explore_rounded),
              label: Text(('Tarifleri keşfet').ui),
            ),
          ],
        ],
      ),
    );
  }
}

class CartoonRecipesFab extends StatelessWidget {
  const CartoonRecipesFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.kawaiiLeaf,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.add_rounded),
      label: Text(('Yeni tarif').ui,
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class CartoonRecipeActionBar extends StatelessWidget {
  const CartoonRecipeActionBar({
    super.key,
    required this.likes,
    required this.liked,
    required this.saved,
    required this.onLike,
    required this.onSave,
  });

  final int likes;
  final bool liked;
  final bool saved;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: SoftTap(
              onTap: onLike,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: liked ? AppColors.kawaiiPeach : AppColors.kawaiiCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: AppColors.kawaiiCoral,
                      size: 20,
                    )
                        .animate(target: liked ? 1 : 0)
                        .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 180.ms),
                    const SizedBox(width: 6),
                    Text((liked ? 'Beğenildi${likes > 0 ? ' · $likes' : ''}' : 'Beğen${likes > 0 ? ' · $likes' : ''}').ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: onSave,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: saved ? AppColors.kawaiiMint : AppColors.kawaiiCream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: AppColors.kawaiiLeaf,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text((saved ? 'Kayıtlı' : 'Kaydet').ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartoonRecipeDetailSheet extends ConsumerStatefulWidget {
  const CartoonRecipeDetailSheet({
    super.key,
    required this.recipe,
    this.admin = false,
    this.onEdit,
    this.onDelete,
  });

  final Recipe recipe;
  final bool admin;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  ConsumerState<CartoonRecipeDetailSheet> createState() => _CartoonRecipeDetailSheetState();
}

class _CartoonRecipeDetailSheetState extends ConsumerState<CartoonRecipeDetailSheet> {
  final Set<int> _checkedIngredients = {};
  final Set<int> _doneSteps = {};
  int _servingsMul = 1;

  Recipe get recipe {
    final list = ref.watch(recipesProvider).valueOrNull ?? const <Recipe>[];
    for (final r in list) {
      if (r.id == widget.recipe.id) return r;
    }
    return widget.recipe;
  }

  String _scaleAmount(String amount) {
    if (_servingsMul == 1) return amount;
    final match = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$').firstMatch(amount.trim());
    if (match == null) return amount;
    final n = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (n == null) return amount;
    final scaled = n * _servingsMul;
    final numStr = scaled == scaled.roundToDouble()
        ? '${scaled.round()}'
        : scaled.toStringAsFixed(scaled < 10 ? 1 : 0);
    final unit = match.group(2) ?? '';
    return unit.isEmpty ? numStr : '$numStr $unit';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(recipeInteractionsProvider);
    final user = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    final current = recipe;
    final liked = user != null && store.isRecipeLiked(user.id, current.id);
    final saved = user != null && store.isRecipeSaved(user.id, current.id);
    final accent = cartoonAccentFor(current);
    final tint = cartoonTintFor(current);
    final tags = RecipeVisuals.displayTags(current);
    final baseServings = current.servings.clamp(1, 20);
    final shownServings = baseServings * _servingsMul;
    final cook = current.cookMinutes;
    final prep = current.prepMinutes;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.98,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.kawaiiCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiOutline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(tint, Colors.white, 0.12)!,
                      AppColors.kawaiiSurfaceCream,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: Column(
                  children: [
                    diyetselFoodPhoto(
                      url: RecipeVisuals.imageFor(current),
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: 280.ms)
                        .scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutBack)
                        .then()
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(begin: 0, end: -5, duration: 1500.ms, curve: Curves.easeInOut),
                    const SizedBox(height: 12),
                    Text((current.title).ui,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.kawaiiInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text((current.description).ui,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.kawaiiInk.withValues(alpha: 0.65),
                      ),
                    ),
                    if (!widget.admin && user != null) ...[
                      const SizedBox(height: 14),
                      CartoonRecipeActionBar(
                        likes: current.likes,
                        liked: liked,
                        saved: saved,
                        onLike: () => store.toggleRecipeLike(user.id, current),
                        onSave: () => store.toggleRecipeSave(user.id, current.id),
                      ).animate().fadeIn(delay: 80.ms, duration: 280.ms).slideY(begin: 0.1),
                    ],
                    if (widget.admin) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onEdit,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.kawaiiLeafDeep,
                                side: const BorderSide(color: AppColors.kawaiiLeaf),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: Text(('Düzenle').ui),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onDelete,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.danger,
                                side: BorderSide(
                                  color: AppColors.danger.withValues(alpha: 0.45),
                                ),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded, size: 18),
                              label: Text(('Sil').ui),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _CartoonMetaRow(
                servings: shownServings,
                prepMinutes: prep,
                cookMinutes: cook,
                calories: current.calories,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.kawaiiOutline),
                      ),
                      child: Text((t).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.kawaiiInk.withValues(alpha: 0.78),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  CartoonRecipeMacroPill(label: 'kcal', value: '${current.calories}', color: AppColors.kawaiiCoral),
                  CartoonRecipeMacroPill(label: 'protein', value: '${recipeProtein(current)}g', color: AppColors.kawaiiLeaf),
                  if (current.carbsGrams > 0)
                    CartoonRecipeMacroPill(label: 'karb', value: '${current.carbsGrams}g', color: AppColors.kawaiiSalmon),
                  if (current.fatGrams > 0)
                    CartoonRecipeMacroPill(label: 'yağ', value: '${current.fatGrams}g', color: AppColors.kawaiiSkyBlue),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 20, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(('Porsiyon ayarı').ui,
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiInk),
                      ),
                    ),
                    SoftTap(
                      onTap: _servingsMul > 1 ? () => setState(() => _servingsMul--) : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.kawaiiMint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.kawaiiOutline),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: _servingsMul > 1
                              ? AppColors.kawaiiLeafDeep
                              : AppColors.kawaiiLeaf.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(('×$_servingsMul').ui,
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: accent),
                      ),
                    ),
                    SoftTap(
                      onTap: _servingsMul < 4 ? () => setState(() => _servingsMul++) : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.kawaiiMint,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.kawaiiOutline),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: _servingsMul < 4
                              ? AppColors.kawaiiLeafDeep
                              : AppColors.kawaiiLeaf.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(('İçindekiler').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.kawaiiInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(('${current.ingredients.length} malzeme · $shownServings porsiyon').ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: AppColors.kawaiiMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.kawaiiOutline),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < current.ingredients.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: AppColors.kawaiiOutline),
                      SoftTap(
                        onTap: () => setState(() {
                          if (_checkedIngredients.contains(i)) {
                            _checkedIngredients.remove(i);
                          } else {
                            _checkedIngredients.add(i);
                          }
                        }),
                        borderRadius: BorderRadius.circular(0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _checkedIngredients.contains(i)
                                      ? AppColors.kawaiiLeaf
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _checkedIngredients.contains(i)
                                        ? AppColors.kawaiiLeaf
                                        : AppColors.kawaiiOutline,
                                    width: 1.6,
                                  ),
                                ),
                                child: _checkedIngredients.contains(i)
                                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text((current.ingredients[i].name).ui,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: _checkedIngredients.contains(i)
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: AppColors.kawaiiInk.withValues(
                                      alpha: _checkedIngredients.contains(i) ? 0.45 : 1,
                                    ),
                                  ),
                                ),
                              ),
                              Text((_scaleAmount(current.ingredients[i].amount)).ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (current.allergens.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiPeach,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.kawaiiCoral.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.kawaiiCoralDeep),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(('Alerjen: ${current.allergens.join(', ')}').ui,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: AppColors.kawaiiCoralDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(('Nasıl yapılır?').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.kawaiiInk,
                ),
              ),
              const SizedBox(height: 4),
              Text(('Adım adım anlatım').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: AppColors.kawaiiMuted,
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < current.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftTap(
                    onTap: () => setState(() {
                      if (_doneSteps.contains(i)) {
                        _doneSteps.remove(i);
                      } else {
                        _doneSteps.add(i);
                      }
                    }),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _doneSteps.contains(i)
                              ? accent.withValues(alpha: 0.45)
                              : AppColors.kawaiiOutline,
                        ),
                        boxShadow: AppSpacing.soft,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _doneSteps.contains(i) ? accent : accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(('${i + 1}').ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: _doneSteps.contains(i) ? Colors.white : accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text((current.steps[i]).ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                decoration: _doneSteps.contains(i)
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: AppColors.kawaiiInk.withValues(
                                  alpha: _doneSteps.contains(i) ? 0.45 : 0.9,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: (45 * i).ms, duration: 280.ms).slideX(begin: 0.04),
                ),
              if (current.tips.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(('Püf noktaları').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.kawaiiInk,
                  ),
                ),
                const SizedBox(height: 10),
                for (final tip in current.tips)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.kawaiiMint,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.kawaiiOutline),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text((tip).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: AppColors.kawaiiInk.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              Text(('Makrolar ${shownServings == 1 ? '1 porsiyon' : '$shownServings porsiyon'} için yaklaşık değerlerdir.').ui,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kawaiiMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartoonMetaRow extends StatelessWidget {
  const _CartoonMetaRow({
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.calories,
  });

  final int servings;
  final int prepMinutes;
  final int cookMinutes;
  final int calories;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.people_alt_rounded, '$servings', 'porsiyon'),
      (Icons.timer_outlined, '$prepMinutes dk', 'hazırlık'),
      if (cookMinutes > 0) (Icons.local_fire_department_rounded, '$cookMinutes dk', 'pişirme'),
      (Icons.local_dining_rounded, '$calories', 'kcal'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.kawaiiOutline),
              ),
              child: Column(
                children: [
                  Icon(items[i].$1, size: 18, color: AppColors.kawaiiLeafDeep),
                  const SizedBox(height: 4),
                  Text((items[i].$2).ui,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: AppColors.kawaiiInk,
                    ),
                  ),
                  Text((items[i].$3).ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: AppColors.kawaiiMuted,
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
