import '../../../core/models/models.dart';
import 'portion_scale.dart';

class ParsedRecipeText {
  const ParsedRecipeText({
    required this.title,
    required this.category,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.servings,
    required this.ingredients,
    required this.sauce,
    required this.steps,
    required this.tips,
    required this.footnote,
  });

  final String title;
  final String category;
  final int prepMinutes;
  final int cookMinutes;
  final int servings;
  final List<Ingredient> ingredients;
  final List<Ingredient> sauce;
  final List<String> steps;
  final List<String> tips;
  final String footnote;
}

class RecipeTextParser {
  const RecipeTextParser._();

  static final _symbol = RegExp(
    r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}\u{20E3}]',
    unicode: true,
  );

  static ParsedRecipeText? parse(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    final title = lines.first;
    var category = 'Diğer';
    var prep = 0;
    var cook = 0;
    var servings = 1;
    final ingredients = <Ingredient>[];
    final sauce = <Ingredient>[];
    final steps = <String>[];
    final tips = <String>[];
    final notes = <String>[];
    var mode = _Mode.meta;

    for (final line in lines.skip(1)) {
      final key = _key(line);
      if (key.startsWith('ogun:')) {
        category = _valueAfterColon(line);
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
      if (_isSauceHeader(key)) {
        mode = _Mode.sauce;
        continue;
      }
      if (key == 'hazirlanisi' || key.startsWith('hazirlanisi:')) {
        mode = _Mode.steps;
        continue;
      }
      if (key == 'ipucu' || key == 'ipuclari' || key.startsWith('ipucu:') || key.startsWith('ipuclari:')) {
        mode = _Mode.tips;
        final inline = _valueAfterColon(line);
        if (inline.isNotEmpty && key.contains(':')) tips.add(inline);
        continue;
      }
      if (key == 'dipnot' || key.startsWith('dipnot:')) {
        mode = _Mode.footnote;
        final inline = _valueAfterColon(line);
        if (inline.isNotEmpty && key.contains(':')) notes.add(inline);
        continue;
      }
      switch (mode) {
        case _Mode.ingredients:
          ingredients.add(PortionScale.split(line));
          break;
        case _Mode.sauce:
          sauce.add(PortionScale.split(line));
          break;
        case _Mode.steps:
          steps.add(line);
          break;
        case _Mode.tips:
          tips.add(line);
          break;
        case _Mode.footnote:
          notes.add(line);
          break;
        case _Mode.meta:
          break;
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
      sauce: sauce,
      steps: steps,
      tips: tips,
      footnote: notes.join('\n'),
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
      buffer.writeln(_line(item));
    }
    if (recipe.sauce.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Sosu için');
      for (final item in recipe.sauce) {
        buffer.writeln(_line(item));
      }
    }
    buffer
      ..writeln()
      ..writeln('Hazırlanışı');
    for (final step in recipe.steps) {
      buffer.writeln(step);
    }
    if (recipe.tips.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('İpucu');
      for (final tip in recipe.tips) {
        buffer.writeln(tip);
      }
    }
    if (recipe.footnote.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Dipnot')
        ..writeln(recipe.footnote.trim());
    }
    return buffer.toString().trimRight();
  }

  static String _line(Ingredient item) {
    final amount = item.amount.trim();
    if (amount.isEmpty || amount == '—') return item.name;
    return '$amount ${item.name}'.trim();
  }

  static bool _isSauceHeader(String key) {
    return key == 'sosu icin' ||
        key == 'sos icin' ||
        key == 'sosu' ||
        key == 'sos' ||
        key.startsWith('sosu icin ') ||
        key.startsWith('sos icin ');
  }

  static String _key(String line) {
    final plain = line.replaceAll(_symbol, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    return plain
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

  static String _valueAfterColon(String line) {
    final index = line.indexOf(':');
    if (index < 0) return '';
    return line.substring(index + 1).trim();
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

enum _Mode { meta, ingredients, sauce, steps, tips, footnote }
