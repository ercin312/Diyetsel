import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/marketplace.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/recipe_visuals.dart';

class RecipeTonightCard extends ConsumerWidget {
  const RecipeTonightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final pick = tonightPick(store, user.id, recipes);
    if (pick == null) return const SizedBox.shrink();

    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    final modern = context.isModern;
    final brand = context.brandPrimary;
    final r = pick.recipe;
    final radius = cartoon ? 28.0 : (luxury ? 14.0 : 24.0);
    final photo = diyetselFoodImage(imageUrl: r.imageUrl, seed: r.title);

    if (modern) {
      Widget card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/app/recipes'),
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.modernTealCard,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.modernSoftShadow,
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 108, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bugün akşam bunu dene',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.modernFire,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              pick.highlight,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        r.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pick.reason,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.72), height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${r.calories} kcal • ${r.prepMinutes} dk • ${recipeProtein(r)} g protein',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.modernSageSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -8,
                  top: 18,
                  bottom: 18,
                  child: Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: diyetselFoodPhoto(url: photo, width: 108, height: 108),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return card.animate().fadeIn().slideY(begin: 0.05);
    }

    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/app/recipes'),
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cartoon
                  ? const [AppColors.kawaiiCream, AppColors.kawaiiMint]
                  : [AppColors.luxuryCopperDeep, AppColors.luxuryPlate],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: luxury
                ? Border.all(color: brand.withValues(alpha: 0.45), width: 1)
                : null,
            boxShadow: cartoon
                ? const [
                    BoxShadow(
                      color: AppColors.kawaiiShadow,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Bugün akşam bunu dene',
                                  style: TextStyle(
                                    fontWeight: luxury ? FontWeight.w600 : FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: luxury ? 0.2 : null,
                                    color: cartoon ? AppColors.kawaiiInk : Colors.white,
                                  ),
                                ),
                              ),
                              DoodleBadge(label: pick.highlight, emoji: '💪'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            r.title,
                            style: TextStyle(
                              fontWeight: luxury ? FontWeight.w600 : FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: luxury ? 0.15 : null,
                              color: cartoon ? AppColors.kawaiiInk : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            pick.reason,
                            style: TextStyle(
                              color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.78) : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${r.calories} kcal • ${r.prepMinutes} dk • ${recipeProtein(r)} g protein',
                            style: TextStyle(
                              fontWeight: luxury ? FontWeight.w600 : FontWeight.w700,
                              color: cartoon
                                  ? AppColors.kawaiiCoral
                                  : AppColors.luxuryChampagne,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cartoon) ...[
                      const SizedBox(width: 8),
                      diyetselFoodPhoto(
                        url: RecipeVisuals.imageFor(r),
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ],
                ),
          ),
        ),
      ),
    );
    if (cartoon) {
      return card
          .animate()
          .fadeIn(duration: 320.ms)
          .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 420.ms);
    }
    return card.animate().fadeIn().slideY(begin: 0.05);
  }
}

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    final suggestions =
        !widget.admin && user != null ? personalizedRecipes(store, user.id, recipes) : const <RecipeSuggestion>[];
    final cartoon = context.isCartoon;
    final categories = [
      'Tümü',
      ...{for (final r in recipes) r.category},
    ];
    final filtered = _filter == 'Tümü' ? recipes : recipes.where((r) => r.category == _filter).toList();

    if (cartoon) {
      return AppPage(
        title: 'Tarifler',
        padding: EdgeInsets.zero,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _CartoonRecipesHero(count: recipes.length)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Sana özel',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 4),
                Text(
                  'Planındaki proteine göre öneriler',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted.withValues(alpha: 0.95)),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) => _CartoonSuggestionCard(
                      suggestion: suggestions[i],
                      onOpen: () => _openDetail(context, suggestions[i].recipe),
                    )
                        .animate()
                        .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                        .slideX(begin: 0.06, curve: Curves.easeOutCubic),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const Text(
                'Keşfet',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = categories.elementAt(i);
                    final selected = c == _filter;
                    return FilterChip(
                      selected: selected,
                      showCheckmark: false,
                      label: Text(
                        c,
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
              const SizedBox(height: 14),
              for (var i = 0; i < filtered.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartoonRecipeCard(
                    recipe: filtered[i],
                    onOpen: () => _openDetail(context, filtered[i]),
                  )
                      .animate()
                      .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                      .slideY(begin: 0.06, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutBack, duration: 400.ms),
                ),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Bu kategoride tarif yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return AppPage(
      title: 'Tarifler',
      child: ListView(
        children: [
          if (suggestions.isNotEmpty) ...[
            const SectionHeader(title: 'Sana özel', subtitle: 'Planındaki protein ve öğün saatine göre'),
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionCard(
                  suggestion: s,
                  onTap: () => _openDetail(context, s.recipe),
                ),
              ),
            const SizedBox(height: 8),
            const SectionHeader(title: 'Tüm tarifler'),
          ],
          for (final r in recipes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DiyetselCard(
                onTap: () => _openDetail(context, r),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: diyetselFoodPhoto(
                        url: RecipeVisuals.imageFor(r),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            '${r.calories} kcal · ${recipeProtein(r)} g protein · ${r.prepMinutes} dk',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(r.category, style: TextStyle(color: context.brandPrimary, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Recipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RecipeDetailSheet(recipe: recipe),
    );
  }
}

class _CartoonRecipesHero extends StatelessWidget {
  const _CartoonRecipesHero({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E0), AppColors.kawaiiSurfaceCream],
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
                const Text(
                  'Mutfakta ilham',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: AppColors.kawaiiInk, height: 1.15),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count tarif · malzemeler, adımlar ve makro net',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.kawaiiMuted, height: 1.35),
                ),
              ],
            ),
          ),
          Image.asset(
            DiyetselAssets.foodLentilSoup,
            width: 88,
            height: 88,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox(width: 72, height: 72),
          ),
        ],
      ),
    );
  }
}

class _CartoonSuggestionCard extends StatelessWidget {
  const _CartoonSuggestionCard({required this.suggestion, required this.onOpen});
  final RecipeSuggestion suggestion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final r = suggestion.recipe;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Ink(
          width: 240,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
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
                    child: diyetselFoodPhoto(url: RecipeVisuals.imageFor(r), width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.kawaiiLemon.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            suggestion.highlight,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.kawaiiInk),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                suggestion.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted, height: 1.3),
              ),
              const Spacer(),
              Text(
                '${r.calories} kcal · ${recipeProtein(r)} g P · ${r.prepMinutes} dk',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiCoral),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartoonRecipeCard extends StatelessWidget {
  const _CartoonRecipeCard({required this.recipe, required this.onOpen});
  final Recipe recipe;
  final VoidCallback onOpen;

  Color get _headerTint {
    switch (RecipeVisuals.tintFor(recipe)) {
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

  @override
  Widget build(BuildContext context) {
    final tags = RecipeVisuals.displayTags(recipe);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.softLift,
          ),
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
                      Color.lerp(_headerTint, Colors.white, 0.25)!,
                      Color.lerp(_headerTint, AppColors.kawaiiCream, 0.5)!,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusHero - 1)),
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
                                    color: Colors.white.withValues(alpha: 0.88),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.8)),
                                  ),
                                  child: Text(
                                    t,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: AppColors.kawaiiInk),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            recipe.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              height: 1.2,
                              color: AppColors.kawaiiInk,
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
                              color: AppColors.kawaiiInk.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    diyetselFoodPhoto(
                      url: RecipeVisuals.imageFor(recipe),
                      width: 92,
                      height: 92,
                      fit: BoxFit.contain,
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
                        _MacroPill(label: 'kcal', value: '${recipe.calories}', color: AppColors.kawaiiCoral),
                        _MacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.kawaiiLeaf),
                        _MacroPill(
                          label: 'süre',
                          value: '${recipe.totalMinutes > 0 ? recipe.totalMinutes : recipe.prepMinutes} dk',
                          color: AppColors.kawaiiPurple,
                        ),
                        _MacroPill(
                          label: 'malzeme',
                          value: '${recipe.ingredients.length}',
                          color: AppColors.kawaiiSkyBlue,
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
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Tarifi aç',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiLeafDeep, fontSize: 13.5),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.kawaiiLeafDeep),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({required this.label, required this.value, required this.color});
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
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
          ],
        ),
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, this.onTap});
  final RecipeSuggestion suggestion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final r = suggestion.recipe;
    return DiyetselCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: diyetselFoodPhoto(url: RecipeVisuals.imageFor(r), width: 52, height: 52),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                    Text(suggestion.reason, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              DoodleBadge(label: suggestion.highlight, emoji: '✨'),
            ],
          ),
          const SizedBox(height: 10),
          Text(r.description, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RecipeDetailSheet extends StatefulWidget {
  const _RecipeDetailSheet({required this.recipe});
  final Recipe recipe;

  @override
  State<_RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<_RecipeDetailSheet> {
  final Set<int> _checkedIngredients = {};
  final Set<int> _doneSteps = {};
  int _servingsMul = 1;

  Recipe get recipe => widget.recipe;

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
    final cartoon = context.isCartoon;
    final tags = RecipeVisuals.displayTags(recipe);
    final bg = cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface;
    final ink = cartoon ? AppColors.kawaiiInk : Theme.of(context).colorScheme.onSurface;
    final muted = cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant;
    final baseServings = recipe.servings.clamp(1, 20);
    final shownServings = baseServings * _servingsMul;
    final cook = recipe.cookMinutes;
    final prep = recipe.prepMinutes;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.98,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Center(
                child: diyetselFoodPhoto(
                  url: RecipeVisuals.imageFor(recipe),
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
              ).animate().fadeIn(duration: 280.ms).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
              const SizedBox(height: 12),
              Text(
                recipe.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, height: 1.45, color: muted),
              ),
              const SizedBox(height: 14),
              _RecipeMetaRow(
                cartoon: cartoon,
                servings: shownServings,
                prepMinutes: prep,
                cookMinutes: cook,
                calories: recipe.calories,
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in tags)
                    Chip(
                      label: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cartoon ? AppColors.kawaiiInk : null)),
                      backgroundColor: cartoon ? AppColors.kawaiiMint : null,
                      side: cartoon ? const BorderSide(color: AppColors.kawaiiOutline) : null,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MacroPill(label: 'kcal', value: '${recipe.calories}', color: cartoon ? AppColors.kawaiiCoral : context.brandPrimary),
                  _MacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary),
                  if (recipe.carbsGrams > 0)
                    _MacroPill(label: 'karb', value: '${recipe.carbsGrams}g', color: cartoon ? AppColors.kawaiiSalmon : AppColors.carbs),
                  if (recipe.fatGrams > 0)
                    _MacroPill(label: 'yağ', value: '${recipe.fatGrams}g', color: cartoon ? AppColors.kawaiiSkyBlue : AppColors.fat),
                ],
              ),
              const SizedBox(height: 18),
              // Servings scaler
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_rounded, size: 20, color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Porsiyon ayarı',
                        style: TextStyle(fontWeight: FontWeight.w800, color: ink),
                      ),
                    ),
                    _RoundIconBtn(
                      icon: Icons.remove_rounded,
                      enabled: _servingsMul > 1,
                      onTap: () => setState(() => _servingsMul--),
                      cartoon: cartoon,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '×$_servingsMul',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary),
                      ),
                    ),
                    _RoundIconBtn(
                      icon: Icons.add_rounded,
                      enabled: _servingsMul < 4,
                      onTap: () => setState(() => _servingsMul++),
                      cartoon: cartoon,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _DetailSectionTitle(
                title: 'İçindekiler',
                subtitle: '${recipe.ingredients.length} malzeme · $shownServings porsiyon',
                cartoon: cartoon,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
                  boxShadow: cartoon ? AppSpacing.soft : null,
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < recipe.ingredients.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
                      _IngredientRow(
                        name: recipe.ingredients[i].name,
                        amount: _scaleAmount(recipe.ingredients[i].amount),
                        checked: _checkedIngredients.contains(i),
                        cartoon: cartoon,
                        onTap: () => setState(() {
                          if (_checkedIngredients.contains(i)) {
                            _checkedIngredients.remove(i);
                          } else {
                            _checkedIngredients.add(i);
                          }
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              if (recipe.allergens.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cartoon ? AppColors.kawaiiPeach : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 18, color: cartoon ? AppColors.kawaiiCoralDeep : Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alerjen: ${recipe.allergens.join(', ')}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: cartoon ? AppColors.kawaiiCoralDeep : Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _DetailSectionTitle(
                title: 'Nasıl yapılır?',
                subtitle: 'Adım adım anlatım',
                cartoon: cartoon,
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < recipe.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StepCard(
                    index: i + 1,
                    text: recipe.steps[i],
                    done: _doneSteps.contains(i),
                    cartoon: cartoon,
                    onTap: () => setState(() {
                      if (_doneSteps.contains(i)) {
                        _doneSteps.remove(i);
                      } else {
                        _doneSteps.add(i);
                      }
                    }),
                  )
                      .animate()
                      .fadeIn(delay: (45 * i).ms, duration: 280.ms)
                      .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                ),
              if (recipe.tips.isNotEmpty) ...[
                const SizedBox(height: 14),
                _DetailSectionTitle(
                  title: 'Püf noktaları',
                  subtitle: 'Daha iyi sonuç için',
                  cartoon: cartoon,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    color: cartoon ? AppColors.kawaiiMint : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < recipe.tips.length; i++) ...[
                        if (i > 0) const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_rounded, size: 18, color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recipe.tips[i],
                                style: TextStyle(fontWeight: FontWeight.w600, height: 1.4, color: ink),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Text(
                'Makrolar ${shownServings == 1 ? '1 porsiyon' : '$shownServings porsiyon'} için yaklaşık değerlerdir.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecipeMetaRow extends StatelessWidget {
  const _RecipeMetaRow({
    required this.cartoon,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.calories,
  });

  final bool cartoon;
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
                color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  Icon(items[i].$1, size: 18, color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: cartoon ? AppColors.kawaiiInk : null,
                    ),
                  ),
                  Text(
                    items[i].$3,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant,
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

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.title, required this.subtitle, required this.cartoon});

  final String title;
  final String subtitle;
  final bool cartoon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cartoon ? AppColors.kawaiiInk : null),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.name,
    required this.amount,
    required this.checked,
    required this.cartoon,
    required this.onTap,
  });

  final String name;
  final String amount;
  final bool checked;
  final bool cartoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: checked
                    ? (cartoon ? AppColors.kawaiiLeaf : context.brandPrimary)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: checked
                      ? (cartoon ? AppColors.kawaiiLeaf : context.brandPrimary)
                      : (cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
                  width: 1.6,
                ),
              ),
              child: checked ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color: checked
                      ? (cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant)
                      : (cartoon ? AppColors.kawaiiInk : null),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13.5,
                color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.text,
    required this.done,
    required this.cartoon,
    required this.onTap,
  });

  final int index;
  final String text;
  final bool done;
  final bool cartoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: done ? 0.55 : 1,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: done
                    ? (cartoon ? AppColors.kawaiiLeaf : context.brandPrimary)
                    : (cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor),
              ),
              boxShadow: cartoon ? AppSpacing.soft : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: done
                      ? (cartoon ? AppColors.kawaiiLeaf : context.brandPrimary)
                      : (cartoon ? AppColors.kawaiiMint : context.brandPrimary.withValues(alpha: 0.15)),
                  child: done
                      ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                      : Text(
                          '$index',
                          style: TextStyle(
                            color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adım $index',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        text,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                          fontSize: 14.5,
                          decoration: done ? TextDecoration.lineThrough : null,
                          color: cartoon ? AppColors.kawaiiInk : null,
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
    );
  }
}

class _RoundIconBtn extends StatelessWidget {
  const _RoundIconBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.cartoon,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool cartoon;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: cartoon ? AppColors.kawaiiMint : Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(icon, size: 18, color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary),
          ),
        ),
      ),
    );
  }
}
