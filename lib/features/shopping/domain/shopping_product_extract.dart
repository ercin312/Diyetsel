/// Turns diet / Word lines into shoppable grocery product names.
///
/// Diet text often looks like "1 yemek kaşığı yoğurt" or
/// "Porsiyon meyve + 1 adet salatalık" — platforms need "Yoğurt", "Meyve", "Salatalık".
class ShoppingProductExtract {
  ShoppingProductExtract._();

  static final _timeRe = RegExp(r'\d{1,2}\s*:\s*\d{2}');
  static final _qtyPrefixRe = RegExp(
    r'^(?:\d+(?:[.,]\d+)?\s*[x×]\s*)?(?:\d+(?:[.,]\d+)?\s*)?',
    caseSensitive: false,
  );

  /// Leading portion / measure phrases (stripped before the food name).
  static final _portionPrefixRe = RegExp(
    r'^(?:'
    r'(?:ince\s+)?dilim(?:ler)?|'
    r'porsiyon(?:luk)?|'
    r'(?:su|çay)\s*bardağı(?:\s*kadar)?|'
    r'yemek\s*kaşığı(?:\s*kadar)?|'
    r'tatlı\s*kaşığı(?:\s*kadar)?|'
    r'çay\s*kaşığı(?:\s*kadar)?|'
    r'kaşık(?:\s*kadar)?|'
    r'kase(?:cik)?|'
    r'avuç(?:\s*dolusu)?|'
    r'tutam|'
    r'adet|'
    r'gram(?:lık)?|'
    r'ml|'
    r'lt|'
    r'kg'
    r')\s+',
    caseSensitive: false,
  );

  static final _mealOnlyRe = RegExp(
    r'^(?:kahvalt[ıi]|sabah(?:\s*ara)?|ara(?:\s*ö[gğ]ün)?(?:\s*\d+)?|'
    r'ö[gğ]le(?:\s*yeme[gğ]i)?|ikindi|ak[sş]am(?:\s*yeme[gğ]i)?|'
    r'gece(?:\s*ara)?|snack|breakfast|lunch|dinner)\s*$',
    caseSensitive: false,
  );

  /// Extract zero or more shoppable products from an ingredient name + amount.
  static List<ShoppingProduct> fromIngredient({
    required String name,
    String amount = '',
  }) {
    final n = name.trim();
    final a = amount.trim();

    // Docx / amount-regex bug: "meyve + 1 adet salatalık" → name "meyve +", amount "1 adet salatalık"
    final rejoined = _maybeRejoin(n, a);
    final fromText = fromLine(rejoined);

    // If amount is only a pure quantity (50 g, 7× 150 ml), attach to first product.
    if (fromText.isNotEmpty && a.isNotEmpty && !_amountLooksLikeFood(a)) {
      final tip = _cleanAmountTip(a);
      if (tip.isNotEmpty) {
        return [
          ShoppingProduct(name: fromText.first.name, amount: tip),
          ...fromText.skip(1),
        ];
      }
    }
    return fromText;
  }

  /// Extract products from a free-text diet line.
  static List<ShoppingProduct> fromLine(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return const [];
    if (isNonShoppable(text)) return const [];

    // Drop outer decorative wrappers.
    text = text.replaceAll(RegExp(r'^[•\-\*]+\s*'), '');

    final chunks = <String>[];
    final plusParts = text
        .split(RegExp(r'\s*[+&]\s*|\s+ve\s+', caseSensitive: false))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    for (final part in plusParts) {
      if (part.contains(',') && !part.contains('/')) {
        chunks.addAll(
          part
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty && e.length < 48),
        );
      } else {
        chunks.add(part);
      }
    }

    final out = <ShoppingProduct>[];
    final seen = <String>{};
    for (final chunk in chunks) {
      final product = _cleanOne(chunk);
      if (product == null) continue;
      final key = product.name.toLowerCase();
      if (!seen.add(key)) continue;
      out.add(product);
    }
    return out;
  }

  static bool isNonShoppable(String raw) {
    final t = raw.trim();
    if (t.isEmpty || t.length < 2) return true;
    if (_timeRe.hasMatch(t)) return true;
    final bare = t
        .replaceAll(RegExp(r'[\(\)\[\]\{\}]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (_mealOnlyRe.hasMatch(bare)) return true;
    // Pure measure with no food: "1 yemek kaşığı", "2 dilim"
    final stripped = _stripPortions(_stripQty(bare));
    if (stripped.isEmpty || stripped.length < 2) return true;
    return false;
  }

  static String? searchQuery(String name) {
    final products = fromLine(name);
    if (products.isEmpty) return null;
    return products.first.name;
  }

  static String _maybeRejoin(String name, String amount) {
    if (amount.isEmpty) return name;
    if (_amountLooksLikeFood(amount)) {
      final left = name.replaceFirst(RegExp(r'[+\s]+$'), '').trim();
      return left.isEmpty ? amount : '$left + $amount';
    }
    return name;
  }

  static bool _amountLooksLikeFood(String amount) {
    final a = amount.trim();
    if (a.isEmpty) return false;
    // "7× 50 g" / "150 ml" — quantity only
    if (RegExp(
      r'^\d+\s*[x×]\s*\d+(?:[.,]\d+)?\s*(?:g|kg|ml|lt|l)\s*$',
      caseSensitive: false,
    ).hasMatch(a)) {
      return false;
    }
    if (RegExp(
      r'^\d+(?:[.,]\d+)?\s*(?:g|kg|ml|lt|l)\s*$',
      caseSensitive: false,
    ).hasMatch(a)) {
      return false;
    }
    // "1 adet salatalık", "3 adet zeytin", "7× 1 adet salatalık"
    final withoutCount = a.replaceFirst(
      RegExp(r'^\d+\s*[x×]\s*', caseSensitive: false),
      '',
    );
    final afterUnit = withoutCount.replaceFirst(
      RegExp(
        r'^\d+(?:[.,]\d+)?\s*(?:adet|dilim|kaşık|yemek\s*kaşığı|porsiyon)?\s*',
        caseSensitive: false,
      ),
      '',
    ).trim();
    if (afterUnit.length >= 3 && RegExp(r'[a-zöçğıüşâîû]', caseSensitive: false).hasMatch(afterUnit)) {
      return true;
    }
    return false;
  }

  static String _cleanAmountTip(String amount) {
    return amount.replaceAll('×', 'x').trim();
  }

  static ShoppingProduct? _cleanOne(String raw) {
    var t = raw.trim();
    if (t.isEmpty || isNonShoppable(t)) return null;

    // Pull trailing pure amounts into tip when present: "yoğurt 150 g"
    String amount = '';
    final trailing = RegExp(
      r'^(.*?)\s+(\d+(?:[.,]\d+)?\s*(?:g|kg|ml|lt|l))\s*$',
      caseSensitive: false,
    ).firstMatch(t);
    if (trailing != null) {
      t = trailing.group(1)!.trim();
      amount = trailing.group(2)!.trim();
    }

    // Remove prep notes in parentheses — not useful for search.
    t = t.replaceAll(RegExp(r'\([^)]*\)'), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();

    // Lowercase early so Turkish İ/I don't break portion stripping.
    t = t.toLowerCase();

    // Slash alternatives: "tam buğday / kepekli / çavdar ekmeği" → "tam buğday ekmeği"
    t = _resolveSlashAlternatives(t);

    t = _stripQty(t);
    // Strip portion prefixes repeatedly (e.g. "ince dilim" then leftover).
    for (var i = 0; i < 4; i++) {
      final next = _stripPortions(t);
      if (next == t) break;
      t = next;
    }

    t = t.replaceAll(RegExp(r'^[\s,;:/\-]+|[\s,;:/\-]+$'), '').trim();
    t = _normalizeAliases(t);
    if (t.length < 2 || isNonShoppable(t)) return null;

    return ShoppingProduct(name: _capitalize(t), amount: amount);
  }

  static String _stripQty(String t) => t.replaceFirst(_qtyPrefixRe, '').trim();

  static String _stripPortions(String t) {
    var s = t.trim();
    s = s.replaceFirst(_portionPrefixRe, '').trim();
    // Also: "kadar kakao" leftover "kadar "
    s = s.replaceFirst(RegExp(r'^kadar\s+', caseSensitive: false), '').trim();
    return s;
  }

  static String _resolveSlashAlternatives(String t) {
    if (!t.contains('/')) return t;
    final parts = t.split('/').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length < 2) return t;

    // Shared trailing noun: "tam buğday / kepekli / çavdar ekmeği"
    final lastWords = parts.last.split(RegExp(r'\s+'));
    if (lastWords.length >= 2) {
      final noun = lastWords.last;
      final first = parts.first;
      if (!first.toLowerCase().endsWith(noun.toLowerCase())) {
        return '$first $noun';
      }
    }
    // Otherwise take the first option only.
    return parts.first;
  }

  static String _normalizeAliases(String t) {
    var s = t.toLowerCase().trim();
    // Drop filler adjectives that hurt search.
    s = s.replaceFirst(RegExp(r'^bol\s+'), '');
    s = s.replaceFirst(RegExp(r'^az\s+'), '');
    s = s.replaceFirst(RegExp(r'^taze\s+'), '');
    s = s.replaceFirst(RegExp(r'^haşlanmış\s+'), '');
    s = s.replaceFirst(RegExp(r'^ızgara\s+'), '');
    s = s.replaceFirst(RegExp(r'^yağsız\s+'), '');
    s = s.replaceFirst(RegExp(r'^şekersiz\s+'), '');
    s = s.replaceFirst(RegExp(r'^açık\s+'), ''); // açık çay → çay
    s = s.replaceFirst(RegExp(r'^tam\s+ceviz'), 'ceviz');
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  static String _capitalize(String s) {
    final t = s.trim();
    if (t.isEmpty) return t;
    return '${t[0].toUpperCase()}${t.substring(1)}';
  }
}

class ShoppingProduct {
  const ShoppingProduct({required this.name, this.amount = ''});

  final String name;
  final String amount;
}
