import '../../../core/models/models.dart';
import '../../diet_plan/domain/meal_display.dart';
import 'shopping_product_extract.dart';

/// Builds a shopping list from a [DietPlan], merging with any existing manual items.
class ShoppingFromDiet {
  ShoppingFromDiet._();

  static const dietIdPrefix = 'diet-';

  /// Result of a generate-from-diet run.
  static ShoppingFromDietResult build({
    required DietPlan plan,
    List<ShoppingItem> current = const [],
  }) {
    final checkedByKey = {for (final i in current) i.key: i.checked};
    final priorityByName = {
      for (final i in current)
        if (i.priority) _norm(i.name): true,
    };
    final noteByName = {
      for (final i in current)
        if (i.note.trim().isNotEmpty) _norm(i.name): i.note,
    };

    // Aggregate by normalized shoppable name + category.
    final buckets = <String, _Agg>{};
    var mealCount = 0;
    var ingredientHits = 0;

    for (final day in plan.days) {
      for (final meal in day.meals) {
        mealCount++;
        final ings = MealDisplay.resolvedIngredients(meal);
        final products = <ShoppingProduct>[];

        if (ings.isNotEmpty) {
          for (final ing in ings) {
            products.addAll(
              ShoppingProductExtract.fromIngredient(
                name: ing.name,
                amount: ing.amount,
              ),
            );
          }
        } else {
          // Prefer description tokens, then meal title — never schedule labels.
          products.addAll(ShoppingProductExtract.fromLine(meal.description));
          if (products.isEmpty) {
            products.addAll(ShoppingProductExtract.fromLine(meal.name));
          }
        }

        for (final p in products) {
          final name = p.name.trim();
          if (name.isEmpty) continue;
          if (ShoppingProductExtract.isNonShoppable(name)) continue;
          final cat = guessCategory(name);
          final key = '$cat|${_norm(name)}';
          final bucket = buckets.putIfAbsent(
            key,
            () => _Agg(name: name, category: cat),
          );
          bucket.addAmount(p.amount);
          ingredientHits++;
        }
      }
    }

    final generated = <ShoppingItem>[
      for (final entry in buckets.entries)
        ShoppingItem(
          id: '$dietIdPrefix${entry.key}',
          name: entry.value.name,
          amount: entry.value.amountLabel(),
          category: entry.value.category,
          checked: checkedByKey['$dietIdPrefix${entry.key}'] ??
              checkedByKey[entry.key] ??
              false,
          tip: tipForCategory(entry.value.category),
          aisle: aisleFor(entry.value.category),
          note: noteByName[_norm(entry.value.name)] ?? '',
          priority: priorityByName[_norm(entry.value.name)] ?? false,
        ),
    ]..sort((a, b) {
        final ai = _catRank(a.category);
        final bi = _catRank(b.category);
        if (ai != bi) return ai.compareTo(bi);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    // Keep manually added items (not from diet generate).
    final manual = current
        .where((i) => !i.id.startsWith(dietIdPrefix))
        .where(
          (i) => !generated.any(
            (g) => _norm(g.name) == _norm(i.name) && g.category == i.category,
          ),
        )
        .toList();

    return ShoppingFromDietResult(
      items: [...generated, ...manual],
      dietItemCount: generated.length,
      mealCount: mealCount,
      ingredientHits: ingredientHits,
      dayCount: plan.days.length,
    );
  }

  /// Cleans an existing list (portion phrases → products). Keeps manual ids.
  static List<ShoppingItem> normalizeItems(List<ShoppingItem> current) {
    final buckets = <String, _Agg>{};
    final checkedByKey = {for (final i in current) i.key: i.checked};
    final priorityByName = {
      for (final i in current)
        if (i.priority) _norm(i.name): true,
    };
    final noteByName = {
      for (final i in current)
        if (i.note.trim().isNotEmpty) _norm(i.name): i.note,
    };
    final manualExtras = <ShoppingItem>[];

    for (final item in current) {
      final products = ShoppingProductExtract.fromIngredient(
        name: item.name,
        amount: item.amount,
      );
      if (products.isEmpty) {
        // Drop non-shoppable diet junk; keep opaque manual rows as-is if unknown.
        if (!item.id.startsWith(dietIdPrefix)) {
          manualExtras.add(item);
        }
        continue;
      }
      for (final p in products) {
        final cat = item.category == 'other' || item.category.isEmpty
            ? guessCategory(p.name)
            : item.category;
        final key = '$cat|${_norm(p.name)}';
        final bucket = buckets.putIfAbsent(
          key,
          () => _Agg(name: p.name, category: cat),
        );
        bucket.addAmount(p.amount.isNotEmpty ? p.amount : item.amount);
      }
    }

    final cleaned = <ShoppingItem>[
      for (final entry in buckets.entries)
        ShoppingItem(
          id: '$dietIdPrefix${entry.key}',
          name: entry.value.name,
          amount: entry.value.amountLabel(),
          category: entry.value.category,
          checked: checkedByKey['$dietIdPrefix${entry.key}'] ?? false,
          tip: tipForCategory(entry.value.category),
          aisle: aisleFor(entry.value.category),
          note: noteByName[_norm(entry.value.name)] ?? '',
          priority: priorityByName[_norm(entry.value.name)] ?? false,
        ),
      ...manualExtras.where(
        (m) => !buckets.values.any((b) => _norm(b.name) == _norm(m.name)),
      ),
    ]..sort((a, b) {
        final ai = _catRank(a.category);
        final bi = _catRank(b.category);
        if (ai != bi) return ai.compareTo(bi);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return cleaned;
  }

  static bool needsNormalize(List<ShoppingItem> items) {
    for (final i in items) {
      if (ShoppingProductExtract.isNonShoppable(i.name)) return true;
      final products = ShoppingProductExtract.fromIngredient(
        name: i.name,
        amount: i.amount,
      );
      if (products.length > 1) return true;
      if (products.length == 1 &&
          _norm(products.first.name) != _norm(i.name)) {
        return true;
      }
    }
    return false;
  }

  static String tipForCategory(String cat) => switch (cat) {
        'vegetable' => 'Taze ve canlı renkli olanları seç.',
        'protein' => 'Porsiyonunu haftalık menüye göre ayarla.',
        'dairy' => 'Son kullanma tarihine dikkat et.',
        'grain' => 'Tam tahıl / az işlenmiş tercih et.',
        _ => 'Listeye göre al, dürtü rafına bakma.',
      };

  static String aisleFor(String cat) => switch (cat) {
        'vegetable' => 'Sebze-meyve',
        'protein' => 'Et / balık / bakliyat',
        'dairy' => 'Süt ürünleri',
        'grain' => 'Tahıl / bakliyat',
        _ => 'Genel',
      };

  static String guessCategory(String name) {
    final n = _norm(name);
    const veg = [
      'salata', 'roka', 'marul', 'domates', 'salatalık', 'biber', 'brokoli', 'havuç',
      'patates', 'soğan', 'sarımsak', 'ıspanak', 'kabak', 'patlıcan', 'meyve',
      'elma', 'muz', 'armut', 'çilek', 'mersin', 'üzüm', 'portakal', 'limon',
      'avokado', 'zeytin', 'sebze',
    ];
    const protein = [
      'tavuk', 'hindi', 'et', 'kıyma', 'köfte', 'balık', 'somon', 'ton', 'yumurta',
      'tofu', 'nohut', 'mercimek', 'fasulye', 'badem', 'ceviz', 'fındık', 'protein',
    ];
    const dairy = [
      'süt', 'yoğurt', 'süzme', 'kefir', 'ayran', 'peynir', 'lor', 'kaşar', 'labne',
    ];
    const grain = [
      'yulaf', 'ekmek', 'pirinç', 'bulgur', 'quinoa', 'makarna', 'chia', 'kinoa',
      'tahıl', 'un', 'galeta', 'granola', 'müsli',
    ];
    const otherFood = ['çay', 'kahve', 'kakao', 'bal', 'reçel', 'zeytinyağı'];
    if (dairy.any(n.contains)) return 'dairy';
    if (veg.any(n.contains)) return 'vegetable';
    if (grain.any(n.contains)) return 'grain';
    if (protein.any(n.contains)) return 'protein';
    if (otherFood.any(n.contains)) return 'other';
    return 'other';
  }

  static int _catRank(String cat) {
    const order = ['vegetable', 'protein', 'dairy', 'grain', 'other'];
    final i = order.indexOf(cat);
    return i < 0 ? 99 : i;
  }

  static String _norm(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

class ShoppingFromDietResult {
  const ShoppingFromDietResult({
    required this.items,
    required this.dietItemCount,
    required this.mealCount,
    required this.ingredientHits,
    required this.dayCount,
  });

  final List<ShoppingItem> items;
  final int dietItemCount;
  final int mealCount;
  final int ingredientHits;
  final int dayCount;

  bool get isEmpty => dietItemCount == 0;
}

class _Agg {
  _Agg({required this.name, required this.category});

  final String name;
  final String category;
  final List<String> _amounts = [];

  void addAmount(String raw) {
    final a = raw.trim();
    if (a.isEmpty) return;
    // Never store food-like leftovers as amounts.
    if (ShoppingProductExtract.fromLine(a).length == 1 &&
        !RegExp(r'\d').hasMatch(a)) {
      return;
    }
    if (RegExp(r'[a-zöçğıüş]{4,}', caseSensitive: false).hasMatch(a) &&
        !RegExp(r'\d').hasMatch(a)) {
      return;
    }
    _amounts.add(a);
  }

  String amountLabel() {
    if (_amounts.isEmpty) return '';
    final unique = _amounts.toSet();
    if (unique.length == 1) {
      final one = unique.first;
      if (_amounts.length > 1) return '${_amounts.length}x $one';
      return one;
    }
    if (unique.length <= 3) return unique.join(' · ');
    return '${_amounts.length} porsiyon';
  }
}
