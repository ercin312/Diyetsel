import '../../../core/models/models.dart';

class PortionScale {
  const PortionScale._();

  static const _units = [
    'parmak boyutunda',
    'tatlı kaşığı',
    'yemek kaşığı',
    'çay kaşığı',
    'su bardağı',
    'çay bardağı',
    'küçük boy',
    'büyük boy',
    'orta boy',
    'adet',
    'dilim',
    'gram',
    'demet',
    'tutam',
    'çimdik',
    'avuç',
    'dal',
    'diş',
    'paket',
    'kutu',
    'bardak',
    'kaşık',
    'boy',
    'ml',
    'kg',
    'g',
  ];

  static final _lead = RegExp(
    r'^[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}\u{20E3}\s]+',
    unicode: true,
  );

  /// Splits a pasted line into a scalable amount and the ingredient name.
  static Ingredient split(String raw, {String category = 'other'}) {
    final line = raw.trim();
    final lead = _lead.firstMatch(line);
    final prefix = lead?.group(0) ?? '';
    final rest = line.substring(prefix.length).trimLeft();
    final qty = _quantity(rest);
    if (qty == null) {
      return Ingredient(name: line, amount: '', category: category);
    }
    final afterQty = rest.substring(qty.end).trimLeft();
    final unit = _unit(afterQty);
    final amount = unit == null ? qty.text : '${qty.text} $unit'.trim();
    final nameRest = unit == null ? afterQty : afterQty.substring(unit.length).trimLeft();
    final name = '${prefix.trim()} $nameRest'.trim();
    if (name.isEmpty) {
      return Ingredient(name: line, amount: '', category: category);
    }
    return Ingredient(name: name, amount: amount, category: category);
  }

  static ({String name, String amount}) present(Ingredient item, double factor) {
    var name = item.name.trim();
    var amount = item.amount.trim();
    if (amount.isEmpty || amount == '—') {
      final parts = split(name, category: item.category);
      if (parts.amount.isNotEmpty) {
        name = parts.name;
        amount = parts.amount;
      }
    }
    return (name: name, amount: scale(amount, factor));
  }

  static String scale(String amount, double factor) {
    final text = amount.trim();
    if (text.isEmpty || (factor - 1).abs() < 0.001) return amount;
    return text.replaceAllMapped(RegExp(r'\d+\s*/\s*\d+|\d+(?:[.,]\d+)?'), (match) {
      final raw = match.group(0)!;
      final slash = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(raw);
      final value = slash != null
          ? int.parse(slash.group(1)!) / int.parse(slash.group(2)!)
          : double.parse(raw.replaceAll(',', '.'));
      return _format(value * factor);
    });
  }

  static ({String text, int end})? _quantity(String text) {
    final match = RegExp(
      r'^(?:\d+\s*/\s*\d+|\d+(?:[.,]\d+)?(?:\s*[–\-]\s*\d+(?:[.,]\d+)?)?)',
    ).firstMatch(text);
    if (match == null) return null;
    return (text: match.group(0)!, end: match.end);
  }

  static String? _unit(String text) {
    final folded = _fold(text);
    for (final unit in _units) {
      final key = _fold(unit);
      if (folded == key || folded.startsWith('$key ')) return text.substring(0, unit.length);
    }
    return null;
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
        .replaceAll('ç', 'c');
  }

  static String _format(double value) {
    final fractions = {
      0.25: '1/4',
      0.5: '1/2',
      0.75: '3/4',
      1.25: '1 1/4',
      1.5: '1 1/2',
      1.75: '1 3/4',
      2.5: '2 1/2',
    };
    for (final entry in fractions.entries) {
      if ((value - entry.key).abs() < 0.02) return entry.value;
    }
    if ((value - value.round()).abs() < 0.05) return '${value.round()}';
    final text = value < 10 ? value.toStringAsFixed(1) : value.round().toString();
    return text.replaceAll('.', ',');
  }
}
