import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/recipe_logic.dart';
import '../../../../core/widgets/marketplace.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/recipe_visuals.dart';

class SoftRecipesHeader extends StatelessWidget {
  const SoftRecipesHeader({super.key, required this.admin});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoftTap(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
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
                admin ? 'Danışanlara özel tarifler' : 'Ölçülü, adım adım yemekler',
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
        ),
      ],
    );
  }
}

class SoftRecipesHero extends StatelessWidget {
  const SoftRecipesHero({super.key, required this.count, required this.categories});

  final int count;
  final int categories;

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
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ölçülü tarifler',
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
                  '$count tarif · $categories kategori · makro net',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernCardDetox,
            size: 78,
            fallback: Icons.soup_kitchen_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
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
  });

  final int recipes;
  final int avgKcal;
  final int quick;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Tarif', '$recipes', DiyetselAssets.modernIconPlan, Icons.menu_book_rounded, AppColors.primary),
      ('Ort. kcal', '$avgKcal', DiyetselAssets.modernIconCheck, Icons.local_fire_department_rounded, const Color(0xFFE07A5F)),
      ('Hızlı', '$quick', DiyetselAssets.modernIconCalendar, Icons.timer_outlined, const Color(0xFF5BA3C9)),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                    size: 24,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    items[i].$2,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$5,
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
  });

  final RecipeSuggestion suggestion;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final r = suggestion.recipe;
    final accent = RecipeVisuals.softAccentFor(r);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 248,
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
  });

  final Recipe recipe;
  final VoidCallback onOpen;

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
                            ),
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
                  diyetselFoodPhoto(
                    url: RecipeVisuals.imageFor(recipe),
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
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
  });

  final Recipe recipe;
  final VoidCallback onOpen;
  final int index;

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
                  diyetselFoodPhoto(
                    url: RecipeVisuals.imageFor(recipe),
                    width: 88,
                    height: 88,
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(
          begin: 0.04,
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
  const SoftRecipesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
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
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu kategoride tarif yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Başka bir kategori seç veya tümünü görüntüle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftRecipeDetailSheet extends StatefulWidget {
  const SoftRecipeDetailSheet({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<SoftRecipeDetailSheet> createState() => _SoftRecipeDetailSheetState();
}

class _SoftRecipeDetailSheetState extends State<SoftRecipeDetailSheet> {
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
    final accent = RecipeVisuals.softAccentFor(recipe);
    final tint = RecipeVisuals.softTintFor(recipe);
    final tags = RecipeVisuals.displayTags(recipe);
    final baseServings = recipe.servings.clamp(1, 20);
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
                      url: RecipeVisuals.imageFor(recipe),
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ).animate().fadeIn(duration: 280.ms).scale(
                          begin: const Offset(0.9, 0.9),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 12),
                    Text(
                      recipe.title,
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
                      recipe.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
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
                  SoftRecipeMacroPill(label: 'kcal', value: '${recipe.calories}', color: const Color(0xFFE07A5F)),
                  SoftRecipeMacroPill(label: 'protein', value: '${recipeProtein(recipe)}g', color: AppColors.primary),
                  if (recipe.carbsGrams > 0)
                    SoftRecipeMacroPill(label: 'karb', value: '${recipe.carbsGrams}g', color: const Color(0xFF5BA3C9)),
                  if (recipe.fatGrams > 0)
                    SoftRecipeMacroPill(label: 'yağ', value: '${recipe.fatGrams}g', color: const Color(0xFFD4A017)),
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
              Text(
                'İçindekiler',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${recipe.ingredients.length} malzeme · $shownServings porsiyon',
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
                    for (var i = 0; i < recipe.ingredients.length; i++) ...[
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
                              Icon(
                                _checkedIngredients.contains(i)
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 22,
                                color: _checkedIngredients.contains(i)
                                    ? accent
                                    : AppColors.primary.withValues(alpha: 0.35),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  recipe.ingredients[i].name,
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
                                _scaleAmount(recipe.ingredients[i].amount),
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
              if (recipe.allergens.isNotEmpty) ...[
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
                          'Alerjen: ${recipe.allergens.join(', ')}',
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
              for (var i = 0; i < recipe.steps.length; i++)
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
                    child: Container(
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
                          Container(
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
                              recipe.steps[i],
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
                  ).animate().fadeIn(delay: (45 * i).ms, duration: 280.ms),
                ),
              if (recipe.tips.isNotEmpty) ...[
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
                for (final tip in recipe.tips)
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
