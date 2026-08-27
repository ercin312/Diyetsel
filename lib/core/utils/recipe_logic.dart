import '../data/app_store.dart';
import '../models/models.dart';

class RecipeSuggestion {
  const RecipeSuggestion({
    required this.recipe,
    required this.reason,
    required this.highlight,
    required this.proteinGap,
  });

  final Recipe recipe;
  final String reason;
  final String highlight;
  final int proteinGap;
}

int recipeProtein(Recipe recipe) {
  if (recipe.proteinGrams > 0) return recipe.proteinGrams;
  return recipe.ingredients.where((i) => i.category == 'protein').length * 18;
}

(int consumed, int target) todayProtein(AppStore store, String userId) {
  final plan = store.dietPlanForClient(userId);
  if (plan == null) return (0, 110);
  final today = plan.days.where((d) => _sameDay(d.date, DateTime.now())).expand((d) => d.meals);
  var consumed = 0;
  var target = plan.proteinTarget;
  for (final m in today) {
    if (m.consumed) consumed += m.protein;
    target = plan.proteinTarget;
  }
  if (target <= 0) target = 110;
  return (consumed, target);
}

bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

String _mealSlotLabel() {
  final h = DateTime.now().hour;
  if (h < 11) return 'kahvaltı';
  if (h < 16) return 'öğle';
  return 'akşam';
}

String _categoryForSlot() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Kahvaltı';
  if (h < 16) return 'Öğle';
  return 'Akşam';
}

List<RecipeSuggestion> personalizedRecipes(AppStore store, String userId, List<Recipe> recipes) {
  if (recipes.isEmpty) return const [];
  final (consumed, target) = todayProtein(store, userId);
  final gap = (target - consumed).clamp(0, 999);
  final slot = _categoryForSlot();
  final slotLabel = _mealSlotLabel();

  final scored = recipes.map((r) {
    final protein = recipeProtein(r);
    var score = protein;
    if (r.category == slot) score += 40;
    if (gap > 0 && protein >= gap * 0.4) score += 30;
    if (gap <= 0 && protein <= 25) score += 20;
    return MapEntry(r, score);
  }).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return scored.take(3).map((e) {
    final r = e.key;
    final protein = recipeProtein(r);
    final reason = gap > 15
        ? 'Bugün ~$gap g protein eksik — $slotLabel için ideal'
        : 'Planına uygun, dengeli bir $slotLabel önerisi';
    final highlight = gap > 15 ? '+$protein g protein' : '${r.calories} kcal • $protein g protein';
    return RecipeSuggestion(recipe: r, reason: reason, highlight: highlight, proteinGap: gap);
  }).toList();
}

RecipeSuggestion? tonightPick(AppStore store, String userId, List<Recipe> recipes) {
  final list = personalizedRecipes(store, userId, recipes);
  if (list.isEmpty) return null;
  final evening = list.where((s) => s.recipe.category == 'Akşam').toList();
  return evening.isNotEmpty ? evening.first : list.first;
}
