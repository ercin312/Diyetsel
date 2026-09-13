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
import '../../../../core/widgets/marketplace.dart';
import '../../../../core/widgets/nav_back.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/recipe_visuals.dart';

enum SoftRecipeShelf { discover, liked, saved }

enum SoftRecipeQuickFilter { all, quick, highProtein, lowCal }

class SoftSectionTitle extends StatelessWidget {
  const SoftSectionTitle({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.primaryDeep,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftRecipesHeader extends StatelessWidget {
  const SoftRecipesHeader({
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
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin ? 'Tarif yönetimi' : 'Tarifler',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                admin
                    ? 'Danışanlara özel tarifler oluştur ve yayınla'
                    : likedCount + savedCount > 0
                        ? '$likedCount beğeni · $savedCount kayıtlı · mutfakta yanındayız'
                        : 'Beğen, kaydet, sonra pişir · sıcak lezzet',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
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
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 28,
            fallback: Icons.menu_book_rounded,
            fallbackColor: AppColors.primary,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.04, 1.04),
              duration: 1800.ms,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

class SoftRecipesHero extends StatelessWidget {
  const SoftRecipesHero({
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
          colors: [Color(0xFFFFF0E8), Color(0xFFFFF6E9), Color(0xFFE8F5F0)],
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
                  child: const Text(
                    'Mutfakta ilham',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(duration: 2400.ms, color: Colors.white24),
                const SizedBox(height: 12),
                const Text(
                  'Protein odaklı mutfak',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count tarif · $categories kategori · adım adım & makro net',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
                if (likedCount + savedCount > 0) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (likedCount > 0)
                        SoftRecipeMetaChip(
                          icon: Icons.favorite_rounded,
                          label: '$likedCount beğeni',
                          color: const Color(0xFFE07A5F),
                        ),
                      if (savedCount > 0)
                        SoftRecipeMetaChip(
                          icon: Icons.bookmark_rounded,
                          label: '$savedCount kayıt',
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernCardDetox,
            size: 78,
            fallback: Icons.soup_kitchen_rounded,
            fallbackColor: AppColors.primary,
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -5, duration: 1600.ms, curve: Curves.easeInOut),
        ],
      ),
    );
  }
}

class SoftRecipeMetaChip extends StatelessWidget {
  const SoftRecipeMetaChip({
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
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: color),
          ),
        ],
      ),
    );
  }
}

class SoftRecipeShelfTabs extends StatelessWidget {
  const SoftRecipeShelfTabs({
    super.key,
    required this.shelf,
    required this.likedCount,
    required this.savedCount,
    required this.onChanged,
  });

  final SoftRecipeShelf shelf;
  final int likedCount;
  final int savedCount;
  final ValueChanged<SoftRecipeShelf> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (SoftRecipeShelf.discover, 'Keşfet', Icons.explore_rounded, null),
      (SoftRecipeShelf.liked, 'Beğenilen', Icons.favorite_rounded, likedCount),
      (SoftRecipeShelf.saved, 'Kayıtlı', Icons.bookmark_rounded, savedCount),
    ];
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
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
                    color: shelf == item.$1 ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: shelf == item.$1
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.28),
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
                            : AppColors.primary.withValues(alpha: 0.55),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$4 == null ? item.$2 : '${item.$2} (${item.$4})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: shelf == item.$1
                              ? Colors.white
                              : AppColors.primaryDeep.withValues(alpha: 0.7),
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

class SoftRecipeQuickFilters extends StatelessWidget {
  const SoftRecipeQuickFilters({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SoftRecipeQuickFilter selected;
  final ValueChanged<SoftRecipeQuickFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (SoftRecipeQuickFilter.all, 'Hepsi', Icons.apps_rounded),
      (SoftRecipeQuickFilter.quick, '≤15 dk', Icons.bolt_rounded),
      (SoftRecipeQuickFilter.highProtein, 'Yüksek P', Icons.fitness_center_rounded),
      (SoftRecipeQuickFilter.lowCal, 'Hafif', Icons.eco_rounded),
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
                color: on ? const Color(0xFFFFF0E8) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: on ? const Color(0xFFE07A5F).withValues(alpha: 0.45) : AppColors.modernLine,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item.$3,
                    size: 15,
                    color: on ? const Color(0xFFE07A5F) : AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: on ? const Color(0xFFE07A5F) : AppColors.primaryDeep.withValues(alpha: 0.7),
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

class SoftRecipesStatsRow extends StatelessWidget {
  const SoftRecipesStatsRow({
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
      ('Tarif', '$recipes', DiyetselAssets.modernIconPlan, Icons.menu_book_rounded, AppColors.primary),
      ('Ort. kcal', '$avgKcal', DiyetselAssets.modernIconCheck, Icons.local_fire_department_rounded, const Color(0xFFE07A5F)),
      ('Hızlı', '$quick', DiyetselAssets.modernIconCalendar, Icons.timer_outlined, const Color(0xFF5BA3C9)),
      if (liked + saved > 0)
        ('Koleksiyon', '${liked + saved}', DiyetselAssets.modernIconCheck, Icons.favorite_rounded, const Color(0xFFD4A017)),
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
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    items[i].$3,
                    size: 22,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    items[i].$2,
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

class SoftRecipeCollectionStrip extends StatelessWidget {
  const SoftRecipeCollectionStrip({
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
              child: SoftSectionTitle(
                title: 'Senin koleksiyonun',
                subtitle: 'Beğendiğin ve kaydettiğin tarifler',
              ),
            ),
            SoftTap(
              onTap: onShowSaved,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  'Tümü →',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.85),
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
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_rounded, color: const Color(0xFFE07A5F).withValues(alpha: 0.85)),
                        const SizedBox(height: 6),
                        Text(
                          'Beğeniler',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: AppColors.primaryDeep.withValues(alpha: 0.75),
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
                    border: Border.all(color: AppColors.modernLine),
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
                                  const Icon(Icons.favorite_rounded, size: 14, color: Color(0xFFE07A5F)),
                                if (isSaved(r.id)) ...[
                                  const SizedBox(width: 2),
                                  const Icon(Icons.bookmark_rounded, size: 14, color: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          height: 1.2,
                          color: AppColors.primaryDeep,
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

class SoftRecipeReactionButton extends StatelessWidget {
  const SoftRecipeReactionButton({
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
          color: active ? color.withValues(alpha: 0.16) : Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? color.withValues(alpha: 0.35) : AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Icon(active ? activeIcon : idleIcon, size: iconSize, color: color),
      ),
    )
        .animate(target: active ? 1 : 0)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.08, 1.08),
          duration: 180.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class SoftRecipeCategoryChip extends StatelessWidget {
  const SoftRecipeCategoryChip({
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
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.modernLine),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: selected ? Colors.white : AppColors.primaryDeep.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class SoftRecipeSuggestionCard extends StatelessWidget {
  const SoftRecipeSuggestionCard({
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
    final accent = RecipeVisuals.softAccentFor(r);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 258,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
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
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          suggestion.highlight,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 10.5,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    SoftRecipeReactionButton(
                      active: liked,
                      activeIcon: Icons.favorite_rounded,
                      idleIcon: Icons.favorite_border_rounded,
                      color: const Color(0xFFE07A5F),
                      onTap: onToggleLike,
                      compact: true,
                    ),
                    const SizedBox(height: 6),
                    SoftRecipeReactionButton(
                      active: saved,
                      activeIcon: Icons.bookmark_rounded,
                      idleIcon: Icons.bookmark_border_rounded,
                      color: AppColors.primary,
                      onTap: onToggleSave,
                      compact: true,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              suggestion.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.primary.withValues(alpha: 0.55),
                height: 1.3,
              ),
            ),
            const Spacer(),
            Text(
              '${r.calories} kcal · ${recipeProtein(r)} g P · ${r.prepMinutes} dk',
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

class SoftRecipeFeaturedCard extends StatelessWidget {
  const SoftRecipeFeaturedCard({
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
    final tint = RecipeVisuals.softTintFor(recipe);
    final accent = RecipeVisuals.softAccentFor(recipe);
    final tags = RecipeVisuals.displayTags(recipe);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
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
                    Color.lerp(tint, Colors.white, 0.1)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.35)!,
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
                              child: Text(
                                'Öne çıkan',
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
                                child: Text(
                                  t,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                    color: AppColors.primaryDeep,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.primary.withValues(alpha: 0.6),
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
                          SoftRecipeReactionButton(
                            active: liked,
                            activeIcon: Icons.favorite_rounded,
                            idleIcon: Icons.favorite_border_rounded,
                            color: const Color(0xFFE07A5F),
                            onTap: onToggleLike,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          SoftRecipeReactionButton(
                            active: saved,
                            activeIcon: Icons.bookmark_rounded,
                            idleIcon: Icons.bookmark_border_rounded,
                            color: AppColors.primary,
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
                  SoftRecipeMacroPill(label: 'kcal', value: '${recipe.calories}', color: const Color(0xFFE07A5F)),
                  const SizedBox(width: 6),
                  SoftRecipeMacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.primary),
                  const SizedBox(width: 6),
                  SoftRecipeMacroPill(
                    label: 'süre',
                    value: '${recipe.prepMinutes} dk',
                    color: const Color(0xFF5BA3C9),
                  ),
                  const Spacer(),
                  Text(
                    'Tarifi aç',
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

class SoftRecipeCard extends StatelessWidget {
  const SoftRecipeCard({
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
    final tint = RecipeVisuals.softTintFor(recipe);
    final accent = RecipeVisuals.softAccentFor(recipe);
    final tags = RecipeVisuals.displayTags(recipe);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
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
                    Color.lerp(tint, Colors.white, 0.15)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.4)!,
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
                                ),
                                child: Text(
                                  t,
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
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.primaryDeep.withValues(alpha: 0.7),
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
                          SoftRecipeReactionButton(
                            active: liked,
                            activeIcon: Icons.favorite_rounded,
                            idleIcon: Icons.favorite_border_rounded,
                            color: const Color(0xFFE07A5F),
                            onTap: onToggleLike,
                            compact: true,
                          ),
                          const SizedBox(width: 6),
                          SoftRecipeReactionButton(
                            active: saved,
                            activeIcon: Icons.bookmark_rounded,
                            idleIcon: Icons.bookmark_border_rounded,
                            color: AppColors.primary,
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
                      SoftRecipeMacroPill(label: 'kcal', value: '${recipe.calories}', color: const Color(0xFFE07A5F)),
                      SoftRecipeMacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.primary),
                      SoftRecipeMacroPill(
                        label: 'süre',
                        value: '${recipe.totalMinutes > 0 ? recipe.totalMinutes : recipe.prepMinutes} dk',
                        color: const Color(0xFF5BA3C9),
                      ),
                      SoftRecipeMacroPill(
                        label: 'malzeme',
                        value: '${recipe.ingredients.length}',
                        color: const Color(0xFFD4A017),
                      ),
                      if (recipe.likes > 0)
                        SoftRecipeMacroPill(
                          label: 'beğeni',
                          value: '${recipe.likes}',
                          color: const Color(0xFFE07A5F),
                        ),
                    ],
                  ),
                  if (recipe.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      recipe.ingredients
                              .take(3)
                              .map((e) => e.amount.isEmpty ? e.name : '${e.name} (${e.amount})')
                              .join(' · ') +
                          (recipe.ingredients.length > 3 ? '…' : ''),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Tarifi aç',
                        style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13.5),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                      const Spacer(),
                      if (liked)
                        const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFE07A5F)),
                      if (saved) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.bookmark_rounded, size: 16, color: AppColors.primary),
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

class SoftRecipeMacroPill extends StatelessWidget {
  const SoftRecipeMacroPill({
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
        color: Color.lerp(color, Colors.white, 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$value ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftRecipesEmpty extends StatelessWidget {
  const SoftRecipesEmpty({
    super.key,
    this.admin = false,
    this.shelf = SoftRecipeShelf.discover,
    this.onAdd,
    this.onExplore,
  });

  final bool admin;
  final SoftRecipeShelf shelf;
  final VoidCallback? onAdd;
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final title = admin
        ? 'Henüz tarif yok'
        : switch (shelf) {
            SoftRecipeShelf.liked => 'Beğenilen tarif yok',
            SoftRecipeShelf.saved => 'Kayıtlı tarif yok',
            SoftRecipeShelf.discover => 'Bu filtrede tarif yok',
          };
    final body = admin
        ? 'Danışanlara göstereceğin ilk tarifi ekle.'
        : switch (shelf) {
            SoftRecipeShelf.liked => 'Bir tarifi kalp ile işaretle; burada seni bekler.',
            SoftRecipeShelf.saved => 'Sonra pişirmek istediğin tarifleri kaydet.',
            SoftRecipeShelf.discover => 'Başka bir kategori veya filtre dene.',
          };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconSearch,
            size: 48,
            fallback: Icons.restaurant_outlined,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 1200.ms),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          if (admin && onAdd != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Yeni tarif ekle'),
            ),
          ],
          if (onExplore != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onExplore,
              icon: const Icon(Icons.explore_rounded),
              label: const Text('Tarifleri keşfet'),
            ),
          ],
        ],
      ),
    );
  }
}

class SoftRecipesFab extends StatelessWidget {
  const SoftRecipesFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'Yeni tarif',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SoftRecipeDetailSheet extends ConsumerStatefulWidget {
  const SoftRecipeDetailSheet({
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
  ConsumerState<SoftRecipeDetailSheet> createState() => _SoftRecipeDetailSheetState();
}

class _SoftRecipeDetailSheetState extends ConsumerState<SoftRecipeDetailSheet> {
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
    final accent = RecipeVisuals.softAccentFor(current);
    final tint = RecipeVisuals.softTintFor(current);
    final tags = RecipeVisuals.displayTags(current);
    final baseServings = current.servings.clamp(1, 20);
    final shownServings = baseServings * _servingsMul;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.98,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
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
                    color: AppColors.modernLine,
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
                      const Color(0xFFFFF6E9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.modernLine),
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
                    Text(
                      current.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        color: AppColors.primaryDeep,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      current.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                    if (!widget.admin && user != null) ...[
                      const SizedBox(height: 14),
                      SoftRecipeActionBar(
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
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text('Düzenle'),
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
                              label: const Text('Sil'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                        border: Border.all(color: AppColors.modernLine),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.75),
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
                  SoftRecipeMacroPill(label: 'kcal', value: '${current.calories}', color: const Color(0xFFE07A5F)),
                  SoftRecipeMacroPill(label: 'protein', value: '${recipeProtein(current)}g', color: AppColors.primary),
                  if (current.carbsGrams > 0)
                    SoftRecipeMacroPill(label: 'karb', value: '${current.carbsGrams}g', color: const Color(0xFF5BA3C9)),
                  if (current.fatGrams > 0)
                    SoftRecipeMacroPill(label: 'yağ', value: '${current.fatGrams}g', color: const Color(0xFFD4A017)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 20, color: accent),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Porsiyon ayarı',
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDeep),
                      ),
                    ),
                    SoftTap(
                      onTap: _servingsMul > 1 ? () => setState(() => _servingsMul--) : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.modernWash,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          color: _servingsMul > 1
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '×$_servingsMul',
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
                          color: AppColors.modernWash,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: _servingsMul < 4
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'İçindekiler',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${current.ingredients.length} malzeme · $shownServings porsiyon',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < current.ingredients.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: AppColors.modernLine),
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
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _checkedIngredients.contains(i)
                                      ? Icons.check_circle_rounded
                                      : Icons.circle_outlined,
                                  key: ValueKey(_checkedIngredients.contains(i)),
                                  size: 22,
                                  color: _checkedIngredients.contains(i)
                                      ? accent
                                      : AppColors.primary.withValues(alpha: 0.35),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  current.ingredients[i].name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    decoration: _checkedIngredients.contains(i)
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: AppColors.primaryDeep.withValues(
                                      alpha: _checkedIngredients.contains(i) ? 0.45 : 1,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                _scaleAmount(current.ingredients[i].amount),
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
                    color: const Color(0xFFFFF0E8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE07A5F).withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFE07A5F)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alerjen: ${current.allergens.join(', ')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: Color(0xFFE07A5F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Nasıl yapılır?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Adım adım anlatım',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: AppColors.primary.withValues(alpha: 0.5),
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
                              ? accent.withValues(alpha: 0.4)
                              : AppColors.modernLine,
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
                              color: _doneSteps.contains(i) ? accent : accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: _doneSteps.contains(i) ? Colors.white : accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              current.steps[i],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                decoration: _doneSteps.contains(i)
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: AppColors.primaryDeep.withValues(
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
                const Text(
                  'İpuçları',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 10),
                for (final tip in current.tips)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              color: AppColors.primary.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SoftRecipeActionBar extends StatelessWidget {
  const SoftRecipeActionBar({
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
        border: Border.all(color: AppColors.modernLine),
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
                  color: liked ? const Color(0xFFFFF0E8) : AppColors.modernWash,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: const Color(0xFFE07A5F),
                      size: 20,
                    )
                        .animate(target: liked ? 1 : 0)
                        .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 180.ms),
                    const SizedBox(width: 6),
                    Text(
                      liked ? 'Beğenildi${likes > 0 ? ' · $likes' : ''}' : 'Beğen${likes > 0 ? ' · $likes' : ''}',
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
          Expanded(
            child: SoftTap(
              onTap: onSave,
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: saved ? AppColors.modernMint : AppColors.modernWash,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      saved ? 'Kayıtlı' : 'Kaydet',
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
        ],
      ),
    );
  }
}
