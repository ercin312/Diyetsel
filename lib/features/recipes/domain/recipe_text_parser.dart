import '../../../core/models/models.dart';

class ParsedRecipeText {
  const ParsedRecipeText({
    required this.title,
    required this.category,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.steps,
  });

  final String title;
  final String category;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final List<Ingredient> ingredients;
  final List<String> steps;
}

class RecipeTextParser {
  const RecipeTextParser._();

  static final _symbol = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}\u{20E3}]',
    unicode: true,
  );

  static String stripSymbols(String line) {
    return line.replaceAll(_symbol, '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static ParsedRecipeText? parse(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map(stripSymbols)
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    final title = lines.first;
    var category = 'Diğer';
    var prep = 0;
    var cook = 0;
    var servings = 1;
    final ingredients = <Ingredient>[];
    final steps = <String>[];
    var mode = _Mode.meta;

    for (final line in lines.skip(1)) {
      final key = _fold(line);
      if (key.startsWith('ogun:')) {
        category = line.split(':').skip(1).join(':').trim();
        if (category.isEmpty) category = 'Diğer';
        continue;
      }
      if (key.startsWith('hazirlama suresi:')) {
        prep = _firstNumber(line);
        continue;
      }
      if (key.startsWith('pisirme suresi:')) {
        cook = _lastNumber(line);
        continue;
      }
      if (key.startsWith('servis:')) {
        final n = _lastNumber(line);
        servings = n == 0 ? 1 : n;
        continue;
      }
      if (key == 'malzemeler' || key.startsWith('malzemeler:')) {
        mode = _Mode.ingredients;
        continue;
      }
      if (key == 'hazirlanisi' || key.startsWith('hazirlanisi:')) {
        mode = _Mode.steps;
        continue;
      }
      if (_isSauceHeader(key)) {
        mode = _Mode.ingredients;
        ingredients.add(Ingredient(name: line, amount: ''));
        continue;
      }
      if (mode == _Mode.ingredients) {
        ingredients.add(Ingredient(name: line, amount: ''));
      } else if (mode == _Mode.steps) {
        steps.add(line);
      }
    }

    if (title.isEmpty || steps.isEmpty) return null;
    return ParsedRecipeText(
      title: title,
      category: category,
      prepMinutes: prep,
      cookMinutes: cook,
      servings: servings,
      ingredients: ingredients,
      steps: steps,
    );
  }

  static String format(Recipe recipe) {
    final buffer = StringBuffer()
      ..writeln(recipe.title)
      ..writeln('Öğün: ${recipe.category}')
      ..writeln('Hazırlama süresi: ${recipe.prepMinutes} dakika')
      ..writeln('Pişirme süresi: ${recipe.cookMinutes} dakika')
      ..writeln('Servis: ${recipe.servings} kişilik')
      ..writeln()
      ..writeln('Malzemeler');
    for (final item in recipe.ingredients) {
      final amount = item.amount.trim();
      if (amount.isEmpty || amount == '—') {
        buffer.writeln(item.name);
      } else {
        buffer.writeln('$amount ${item.name}'.trim());
      }
    }
    buffer
      ..writeln()
      ..writeln('Hazırlanışı');
    for (final step in recipe.steps) {
      buffer.writeln(step);
    }
    return buffer.toString().trimRight();
  }

  static bool _isSauceHeader(String key) {
    return key == 'sosu icin' ||
        key == 'sos icin' ||
        key.startsWith('sosu icin ') ||
        key.startsWith('sos icin ');
  }

  static String _fold(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('i̇', 'i')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('â', 'a');
  }

  static int _firstNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    return match == null ? 0 : int.parse(match.group(0)!);
  }

  static int _lastNumber(String text) {
    final matches = RegExp(r'\d+').allMatches(text).toList();
    if (matches.isEmpty) return 0;
    return int.parse(matches.last.group(0)!);
  }
}

enum _Mode { meta, ingredients, steps }
