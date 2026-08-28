import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';

/// Presentation helpers — clearer titles, hooks, and ingredient rows for diet UI.
class MealDisplay {
  MealDisplay._();

  /// Prefer a punchy title; fall back to meal type when name is empty.
  static String headline(DietMeal meal) {
    final n = meal.name.trim();
    if (n.isEmpty) return meal.type.tr;
    return n;
  }

  /// Short, friendly why-this-meal line under the title.
  static String hook(DietMeal meal) {
    final desc = meal.description.trim();
    final ingredients = resolvedIngredients(meal);
    final names = ingredients.map((e) => e.name).where((e) => e.isNotEmpty).toList();

    // If description is just a comma list matching ingredients, invent a hook.
    final looksLikeList = desc.contains(',') && !desc.contains('.');
    if (desc.isEmpty || looksLikeList || (names.isNotEmpty && desc.toLowerCase() == names.join(', ').toLowerCase())) {
      return switch (meal.type) {
        MealType.breakfast => _breakfastHook(names),
        MealType.morningSnack => _snackHook(names, morning: true),
        MealType.lunch => _lunchHook(names),
        MealType.afternoonSnack => _snackHook(names, morning: false),
        MealType.dinner => _dinnerHook(names),
      };
    }
    return desc;
  }

  /// Body note when description adds detail beyond the ingredient list.
  static String? detailNote(DietMeal meal) {
    final desc = meal.description.trim();
    if (desc.isEmpty) return null;
    final looksLikeList = desc.contains(',') && !desc.contains('.');
    if (looksLikeList) return null;
    final hookText = hook(meal);
    if (desc == hookText) return null;
    if (desc.toLowerCase() == meal.name.trim().toLowerCase()) return null;
    return desc;
  }

  static List<Ingredient> resolvedIngredients(DietMeal meal) {
    if (meal.ingredients.isNotEmpty) return meal.ingredients;
    return parseIngredientHints(meal.description);
  }

  /// Split "Yulaf, yoğurt, chia" style free text into chips.
  static List<Ingredient> parseIngredientHints(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return const [];
    if (!text.contains(',') && text.length > 48) return const [];
    final parts = text
        .split(RegExp(r'[,;/•·|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e.length < 40)
        .toList();
    if (parts.length < 2) return const [];
    return [
      for (final p in parts)
        Ingredient(name: _capitalize(p), amount: '', category: 'other'),
    ];
  }

  static String foodAsset(MealType type) => switch (type) {
        MealType.breakfast => DiyetselAssets.foodSaladBowl,
        MealType.morningSnack => DiyetselAssets.mascotCarrot,
        MealType.lunch => DiyetselAssets.foodSaladBowl,
        MealType.afternoonSnack => DiyetselAssets.foodGreenSmoothie,
        MealType.dinner => DiyetselAssets.foodLentilSoup,
      };

  static String accentLabel(MealType type) => switch (type) {
        MealType.breakfast => 'Sabah başlangıcı',
        MealType.morningSnack => 'Ara enerji',
        MealType.lunch => 'Öğle tabağı',
        MealType.afternoonSnack => 'İkindi molası',
        MealType.dinner => 'Akşam dengesi',
      };

  static String _breakfastHook(List<String> names) {
    if (names.isEmpty) return 'Güne tok ve hafif başlamak için.';
    return '${names.take(2).join(' + ')} ile tok tutan sabah kaseni.';
  }

  static String _lunchHook(List<String> names) {
    if (names.isEmpty) return 'Öğlen enerjini dengede tutan protein tabağı.';
    return '${names.first} odaklı, doyurucu öğle önerisi.';
  }

  static String _dinnerHook(List<String> names) {
    if (names.isEmpty) return 'Akşam için hafif ama doyurucu bir tabak.';
    return '${names.take(2).join(' & ')} ile sakin bir akşam.';
  }

  static String _snackHook(List<String> names, {required bool morning}) {
    if (names.isEmpty) {
      return morning ? 'Küçük ama akıllı bir ara öğün.' : 'İkindiyi yumuşak geçiren atıştırmalık.';
    }
    final item = names.first;
    return morning ? 'Pratik ${item.toLowerCase()} molası — tok tutar.' : '$item ile hafif bir ara.';
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }
}
