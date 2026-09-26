import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import 'recipe_editor_screen.dart';
import 'widgets/soft_recipe_widgets.dart';
import '../../../core/l10n/ui_string.dart';

/// Soft premium modern recipes hub.
class SoftRecipesScreen extends ConsumerStatefulWidget {
  const SoftRecipesScreen({super.key, this.admin = false});

  final bool admin;

  @override
  ConsumerState<SoftRecipesScreen> createState() => _SoftRecipesScreenState();
}

class _SoftRecipesScreenState extends ConsumerState<SoftRecipesScreen> {
  String _filter = 'Tümü';
  SoftRecipeShelf _shelf = SoftRecipeShelf.discover;
  SoftRecipeQuickFilter _quick = SoftRecipeQuickFilter.all;

  Future<void> _openEditor({Recipe? existing}) async {
    await Navigator.push<Recipe>(
      context,
      MaterialPageRoute<Recipe>(
        builder: (_) => RecipeEditorScreen(existing: existing),
      ),
    );
  }

  List<Recipe> _applyQuick(List<Recipe> list) {
    switch (_quick) {
      case SoftRecipeQuickFilter.all:
        return list;
      case SoftRecipeQuickFilter.quick:
        return list.where((r) => r.prepMinutes <= 15).toList();
      case SoftRecipeQuickFilter.highProtein:
        return list.where((r) => recipeProtein(r) >= 20).toList();
      case SoftRecipeQuickFilter.lowCal:
        return list.where((r) => r.calories > 0 && r.calories <= 350).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(recipeInteractionsProvider);
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    final suggestions =
        !widget.admin && user != null ? personalizedRecipes(store, user.id, recipes) : const <RecipeSuggestion>[];

    final liked = user == null ? const <Recipe>[] : store.likedRecipes(user.id);
    final saved = user == null ? const <Recipe>[] : store.savedRecipes(user.id);

    final categories = [
      'Tümü',
      ...{for (final r in recipes) r.category},
    ];

    List<Recipe> base;
    if (widget.admin || _shelf == SoftRecipeShelf.discover) {
      base = _filter == 'Tümü' ? recipes : recipes.where((r) => r.category == _filter).toList();
    } else if (_shelf == SoftRecipeShelf.liked) {
      base = liked;
    } else {
      base = saved;
    }
    final filtered = _applyQuick(base);

    final catCount = {for (final r in recipes) r.category}.length;
    final avgKcal = recipes.isEmpty
        ? 0
        : (recipes.fold<int>(0, (s, r) => s + r.calories) / recipes.length).round();
    final quickCount = recipes.where((r) => r.prepMinutes <= 15).length;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: widget.admin
          ? SoftRecipesFab(onPressed: () => _openEditor())
          : null,
      body: SoftWashBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(18, 12, 18, widget.admin ? 100 : 28),
            children: [
              SoftRecipesHeader(
                admin: widget.admin,
                likedCount: liked.length,
                savedCount: saved.length,
              )
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftRecipesHero(
                count: recipes.length,
                categories: catCount,
                likedCount: liked.length,
                savedCount: saved.length,
              )
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 320.ms)
                  .scale(
                    begin: const Offset(0.96, 0.96),
                    curve: Curves.easeOutCubic,
                    duration: 420.ms,
                  ),
              if (!widget.admin) ...[
                const SizedBox(height: 14),
                SoftRecipeShelfTabs(
                  shelf: _shelf,
                  likedCount: liked.length,
                  savedCount: saved.length,
                  onChanged: (s) => setState(() {
                    _shelf = s;
                    if (s != SoftRecipeShelf.discover) {
                      _filter = 'Tümü';
                    }
                  }),
                ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
              ],
              if (!widget.admin && _shelf == SoftRecipeShelf.discover) ...[
                const SizedBox(height: 12),
                SoftTipCard(
                  title: 'Akşam için pratik',
                  body: '15 dk altı tarifleri filtreleyerek yoğun günlerde bile plandan sapmadan kal.',
                  icon: Icons.timer_outlined,
                  accent: AppColors.primary,
                  tint: AppColors.modernMint,
                  onTap: () => setState(() {
                    _quick = SoftRecipeQuickFilter.quick;
                    _shelf = SoftRecipeShelf.discover;
                  }),
                  actionLabel: 'Hızlı tarifleri göster →',
                ),
              ],
              const SizedBox(height: 14),
              SoftRecipesStatsRow(
                recipes: recipes.length,
                avgKcal: avgKcal,
                quick: quickCount,
                liked: liked.length,
                saved: saved.length,
              ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
              if (!widget.admin &&
                  _shelf == SoftRecipeShelf.discover &&
                  (liked.isNotEmpty || saved.isNotEmpty)) ...[
                const SizedBox(height: 18),
                SoftRecipeCollectionStrip(
                  liked: liked,
                  saved: saved,
                  isLiked: (id) => user != null && store.isRecipeLiked(user.id, id),
                  isSaved: (id) => user != null && store.isRecipeSaved(user.id, id),
                  onOpen: (r) => _openDetail(context, r),
                  onShowLiked: () => setState(() => _shelf = SoftRecipeShelf.liked),
                  onShowSaved: () => setState(() => _shelf = SoftRecipeShelf.saved),
                ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
              ],
              if (suggestions.isNotEmpty && _shelf == SoftRecipeShelf.discover) ...[
                const SizedBox(height: 18),
                const SoftSectionTitle(
                  title: 'Sana özel',
                  subtitle: 'Planındaki proteine göre öneriler',
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final r = suggestions[i].recipe;
                      return SoftRecipeSuggestionCard(
                        suggestion: suggestions[i],
                        liked: user != null && store.isRecipeLiked(user.id, r.id),
                        saved: user != null && store.isRecipeSaved(user.id, r.id),
                        onOpen: () => _openDetail(context, r),
                        onToggleLike: user == null
                            ? null
                            : () => store.toggleRecipeLike(user.id, r),
                        onToggleSave: user == null
                            ? null
                            : () => store.toggleRecipeSave(user.id, r.id),
                      )
                          .animate()
                          .fadeIn(delay: (60 * i).ms, duration: 300.ms)
                          .slideX(begin: 0.08, curve: Curves.easeOutCubic);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 18),
              SoftSectionTitle(
                title: _shelfTitle,
                subtitle: _shelfSubtitle(filtered.length),
              ),
              if (_shelf == SoftRecipeShelf.discover) ...[
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
              ],
              const SizedBox(height: 10),
              SoftRecipeQuickFilters(
                selected: _quick,
                onChanged: (q) => setState(() => _quick = q),
              ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
              const SizedBox(height: 14),
              if (filtered.isEmpty)
                SoftRecipesEmpty(
                  admin: widget.admin,
                  shelf: widget.admin ? SoftRecipeShelf.discover : _shelf,
                  onAdd: widget.admin ? () => _openEditor() : null,
                  onExplore: !widget.admin && _shelf != SoftRecipeShelf.discover
                      ? () => setState(() => _shelf = SoftRecipeShelf.discover)
                      : null,
                )
              else ...[
                if (_shelf == SoftRecipeShelf.discover) ...[
                  SoftRecipeFeaturedCard(
                    recipe: filtered.first,
                    liked: user != null && store.isRecipeLiked(user.id, filtered.first.id),
                    saved: user != null && store.isRecipeSaved(user.id, filtered.first.id),
                    onOpen: () => _openDetail(context, filtered.first),
                    onToggleLike: user == null
                        ? null
                        : () => store.toggleRecipeLike(user.id, filtered.first),
                    onToggleSave: user == null
                        ? null
                        : () => store.toggleRecipeSave(user.id, filtered.first.id),
                  )
                      .animate()
                      .fadeIn(delay: 110.ms, duration: 340.ms)
                      .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                  if (filtered.length > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(('Tüm tarifler').ui,
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
                          child: Text(('${filtered.length - 1}').ui,
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
                          liked: user != null && store.isRecipeLiked(user.id, filtered[i].id),
                          saved: user != null && store.isRecipeSaved(user.id, filtered[i].id),
                          onOpen: () => _openDetail(context, filtered[i]),
                          onToggleLike: user == null
                              ? null
                              : () => store.toggleRecipeLike(user.id, filtered[i]),
                          onToggleSave: user == null
                              ? null
                              : () => store.toggleRecipeSave(user.id, filtered[i].id),
                        ),
                      ),
                  ],
                ] else
                  for (var i = 0; i < filtered.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SoftRecipeCard(
                        recipe: filtered[i],
                        index: i,
                        liked: user != null && store.isRecipeLiked(user.id, filtered[i].id),
                        saved: user != null && store.isRecipeSaved(user.id, filtered[i].id),
                        onOpen: () => _openDetail(context, filtered[i]),
                        onToggleLike: user == null
                            ? null
                            : () => store.toggleRecipeLike(user.id, filtered[i]),
                        onToggleSave: user == null
                            ? null
                            : () => store.toggleRecipeSave(user.id, filtered[i].id),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String get _shelfTitle {
    if (widget.admin) return 'Keşfet';
    switch (_shelf) {
      case SoftRecipeShelf.discover:
        return 'Keşfet';
      case SoftRecipeShelf.liked:
        return 'Beğendiklerin';
      case SoftRecipeShelf.saved:
        return 'Kaydettiklerin';
    }
  }

  String _shelfSubtitle(int count) {
    if (widget.admin) return '$count tarif listeleniyor';
    switch (_shelf) {
      case SoftRecipeShelf.discover:
        return 'Kategori ve filtreyle gez · $count tarif';
      case SoftRecipeShelf.liked:
        return count == 0 ? 'Henüz beğeni yok' : '$count tarif kalbinde';
      case SoftRecipeShelf.saved:
        return count == 0 ? 'Henüz kayıt yok' : '$count tarif mutfak defterinde';
    }
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
                    title: Text(('Tarifi sil').ui),
                    content: Text(('“${recipe.title}” silinsin mi?').ui),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(('Vazgeç').ui)),
                      FilledButton(onPressed: () => Navigator.pop(dCtx, true), child: Text(('Sil').ui)),
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
