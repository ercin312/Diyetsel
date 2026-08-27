import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';

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
    final r = pick.recipe;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/app/recipes'),
        borderRadius: BorderRadius.circular(cartoon ? 24 : 18),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cartoon
                  ? [AppColors.peach.withValues(alpha: 0.55), AppColors.accent.withValues(alpha: 0.35)]
                  : [const Color(0xFF292524), const Color(0xFF44403C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(cartoon ? 24 : 18),
            border: Border.all(color: AppColors.primary.withValues(alpha: cartoon ? 0.25 : 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const StyleIcon(icon: Icons.restaurant_menu_rounded, emoji: '🍲', size: 28, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bugün akşam bunu dene',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: cartoon ? AppColors.lightInk : Colors.white,
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
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: cartoon ? AppColors.lightInk : Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  pick.reason,
                  style: TextStyle(color: cartoon ? AppColors.lightInk.withValues(alpha: 0.78) : Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${r.calories} kcal • ${r.prepMinutes} dk • ${recipeProtein(r)} g protein',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cartoon ? AppColors.primary : AppColors.peach,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class RecipesScreen extends ConsumerWidget {
  const RecipesScreen({super.key, this.admin = false});
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    final suggestions = !admin && user != null ? personalizedRecipes(store, user.id, recipes) : const <RecipeSuggestion>[];

    return AppPage(
      title: 'Tarifler',
      child: ListView(
        children: [
          if (suggestions.isNotEmpty) ...[
            const SectionHeader(title: 'Sana özel', subtitle: 'Planındaki protein ve öğün saatine göre'),
            for (final s in suggestions)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionCard(suggestion: s),
              ),
            const SizedBox(height: 8),
            const SectionHeader(title: 'Tüm tarifler'),
          ],
          for (final r in recipes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DiyetselCard(
                child: ExpansionTile(
                  leading: StyleIcon(icon: Icons.menu_book_rounded, emoji: '🍲', size: 24),
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${r.calories} kcal • ${recipeProtein(r)} g protein • ${r.prepMinutes} dk • ${r.category}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(r.description),
                    ),
                    if (r.allergens.isNotEmpty)
                      ListTile(title: Text('Alerjen: ${r.allergens.join(', ')}')),
                    ...r.ingredients.map((i) => ListTile(dense: true, title: Text('${i.name} — ${i.amount}'))),
                    ...r.steps.asMap().entries.map((e) => ListTile(dense: true, title: Text('${e.key + 1}. ${e.value}'))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});
  final RecipeSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final r = suggestion.recipe;
    return DiyetselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                r.category == 'Akşam'
                    ? '🌙'
                    : r.category == 'Kahvaltı'
                        ? '☀️'
                        : '🥗',
                style: const TextStyle(fontSize: 24),
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

class ShoppingScreen extends ConsumerWidget {
  const ShoppingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(shoppingListsProvider);
    var items = store.shoppingList(user.id);
    return AppPage(
      title: 'Alışveriş listesi',
      actions: [
        TextButton(
          onPressed: () async {
            final plan = store.dietPlanForClient(user.id);
            if (plan == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Önce bir diyet planı olmalı')),
                );
              }
              return;
            }
            final generated = <String, ShoppingItem>{};
            for (final day in plan.days) {
              for (final meal in day.meals) {
                for (final ing in meal.ingredients) {
                  generated['${ing.category}-${ing.name}'] = ShoppingItem(
                    name: ing.name,
                    amount: ing.amount,
                    category: ing.category,
                  );
                }
              }
            }
            await store.saveShoppingList(user.id, generated.values.toList());
          },
          child: const Text('Diyetten üret'),
        ),
      ],
      child: ListView(
        children: [
          for (final cat in ['vegetable', 'protein', 'dairy', 'grain', 'other'])
            if (items.any((e) => e.category == cat)) ...[
              SectionHeader(title: _label(cat)),
              ...items.where((e) => e.category == cat).map(
                    (e) => CheckboxListTile(
                      value: e.checked,
                      title: Text(e.name),
                      subtitle: Text(e.amount),
                      onChanged: (v) {
                        final next = [
                          for (final i in items)
                            if (i.name == e.name) i.copyWith(checked: v ?? false) else i,
                        ];
                        store.saveShoppingList(user.id, next);
                      },
                    ),
                  ),
            ],
        ],
      ),
    );
  }

  String _label(String cat) => switch (cat) {
        'vegetable' => 'Sebze & meyve',
        'protein' => 'Protein',
        'dairy' => 'Süt ürünleri',
        'grain' => 'Tahıl',
        _ => 'Diğer',
      };
}

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(documentsProvider);
    final files = user.isAdmin
        ? store.users().where((u) => !u.isAdmin).expand((u) => store.documents(u.id)).toList()
        : store.documents(user.id);
    files.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return AppPage(
      title: 'Belge kasası',
      fab: FloatingActionButton(
        onPressed: () async {
          final picked = await FilePicker.pickFiles();
          if (picked.isEmpty || picked.first.path == null) return;
          final file = picked.first;
          await store.saveDocument(
            VaultFile(
              id: newId(),
              userId: user.id,
              name: file.name,
              path: file.path!,
              mime: file.name.contains('.') ? file.name.split('.').last : 'file',
              uploadedAt: DateTime.now(),
            ),
          );
        },
        child: const Icon(Icons.upload_file),
      ),
      child: files.isEmpty
          ? const EmptyState(icon: Icons.folder, title: 'Belge yok')
          : ListView(
              children: [
                for (final f in files)
                  ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(f.name),
                    subtitle: Text(DateFormat('d MMM y HH:mm', 'tr').format(f.uploadedAt)),
                  ),
              ],
            ),
    );
  }
}
