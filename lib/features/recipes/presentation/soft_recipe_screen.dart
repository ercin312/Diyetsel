import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../auth/presentation/auth_controller.dart';
import 'recipe_editor_screen.dart';
import 'widgets/soft_recipe_widgets.dart';
import '../../../core/widgets/soft_ui_kit.dart';

/// Soft premium modern recipes hub.
class SoftRecipesScreen extends ConsumerStatefulWidget {
  const SoftRecipesScreen({super.key, this.admin = false});

  final bool admin;

  @override
  ConsumerState<SoftRecipesScreen> createState() => _SoftRecipesScreenState();
}

class _SoftRecipesScreenState extends ConsumerState<SoftRecipesScreen> {
  String _filter = 'Tümü';

  Future<void> _openEditor({Recipe? existing}) async {
    await Navigator.push<Recipe>(
      context,
      MaterialPageRoute<Recipe>(
        builder: (_) => RecipeEditorScreen(existing: existing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    final suggestions =
        !widget.admin && user != null ? personalizedRecipes(store, user.id, recipes) : const <RecipeSuggestion>[];
    final categories = [
      'Tümü',
      ...{for (final r in recipes) r.category},
    ];
    final filtered = _filter == 'Tümü' ? recipes : recipes.where((r) => r.category == _filter).toList();
    final catCount = {for (final r in recipes) r.category}.length;
    final avgKcal = recipes.isEmpty
        ? 0
        : (recipes.fold<int>(0, (s, r) => s + r.calories) / recipes.length).round();
    final quick = recipes.where((r) => r.prepMinutes <= 15).length;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: widget.admin
          ? SoftRecipesFab(onPressed: () => _openEditor())
          : null,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(18, 12, 18, widget.admin ? 100 : 28),
          children: [
            SoftRecipesHeader(admin: widget.admin)
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftRecipesHero(count: recipes.length, categories: catCount)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            if (!widget.admin) ...[
              const SizedBox(height: 12),
              SoftTipCard(
                title: 'Akşam için pratik',
                body: '15 dk altı tarifleri filtreleyerek yoğun günlerde bile plandan sapmadan kal.',
                icon: Icons.timer_outlined,
                accent: AppColors.primary,
                tint: AppColors.modernMint,
                onTap: () => setState(() => _filter = 'Tümü'),
                actionLabel: 'Tüm tarifleri gör →',
              ),
            ],
            const SizedBox(height: 14),
            SoftRecipesStatsRow(
              recipes: recipes.length,
              avgKcal: avgKcal,
              quick: quick,
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Sana özel',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Planındaki proteine göre öneriler',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 168,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: suggestions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) => SoftRecipeSuggestionCard(
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
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.primaryDeep,
              ),
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
                  return SoftRecipeCategoryChip(
                    label: c,
                    selected: c == _filter,
                    onTap: () => setState(() => _filter = c),
                  );
                },
              ),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              SoftRecipesEmpty(
                admin: widget.admin,
                onAdd: widget.admin ? () => _openEditor() : null,
              )
            else ...[
              SoftRecipeFeaturedCard(
                recipe: filtered.first,
                onOpen: () => _openDetail(context, filtered.first),
              )
                  .animate()
                  .fadeIn(delay: 110.ms, duration: 320.ms)
                  .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
              if (filtered.length > 1) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Tüm tarifler',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${filtered.length - 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 1; i < filtered.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftRecipeCard(
                      recipe: filtered[i],
                      index: i,
                      onOpen: () => _openDetail(context, filtered[i]),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Recipe recipe) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoftRecipeDetailSheet(
        recipe: recipe,
        admin: widget.admin,
        onEdit: widget.admin
            ? () async {
                Navigator.pop(ctx);
                await _openEditor(existing: recipe);
              }
            : null,
        onDelete: widget.admin
            ? () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('Tarifi sil'),
                    content: Text('“${recipe.title}” silinsin mi?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('Vazgeç')),
                      FilledButton(onPressed: () => Navigator.pop(dCtx, true), child: const Text('Sil')),
                    ],
                  ),
                );
                if (ok != true || !context.mounted) return;
                await ref.read(appStoreProvider).deleteRecipe(recipe.id);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            : null,
      ),
    );
  }
}
