import 'package:diyetsel/features/recipes/domain/portion_scale.dart';
import 'package:diyetsel/features/recipes/domain/recipe_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the pasted recipe layout and keeps emoji', () {
    const raw = '''
🍽️ Tavuklu Kabak Sandal

Öğün: Ana öğün
Hazırlama süresi: 15 dakika
Pişirme süresi: 25–30 dakika
Servis: 1–2 kişilik

🥗 Malzemeler
1 küçük boy tavuk göğsü
2–3 adet kabak
Tuz
🤍 Sosu için
1 tatlı kaşığı zeytinyağı

🍳 Hazırlanışı
Tavuğu haşlayıp didikleyin.
Kabakları rendeleyip suyunu sıkın.

İpucu
Kabağı çok sıkma.

Dipnot
Aynı gün içinde tüketin.
''';

    final parsed = RecipeTextParser.parse(raw);
    expect(parsed, isNotNull);
    expect(parsed!.title, '🍽️ Tavuklu Kabak Sandal');
    expect(parsed.category, 'Ana öğün');
    expect(parsed.prepMinutes, 15);
    expect(parsed.cookMinutes, 30);
    expect(parsed.servings, 2);
    expect(parsed.ingredients.map((e) => e.amount), ['1 küçük boy', '2–3 adet', '']);
    expect(parsed.ingredients.map((e) => e.name), ['tavuk göğsü', 'kabak', 'Tuz']);
    expect(parsed.sauce.map((e) => e.amount), ['1 tatlı kaşığı']);
    expect(parsed.sauce.map((e) => e.name), ['zeytinyağı']);
    expect(parsed.steps, [
      'Tavuğu haşlayıp didikleyin.',
      'Kabakları rendeleyip suyunu sıkın.',
    ]);
    expect(parsed.tips, ['Kabağı çok sıkma.']);
    expect(parsed.footnote, 'Aynı gün içinde tüketin.');
  });

  test('scales ranges and fractions from the recipe serving', () {
    expect(PortionScale.scale('2–3 adet', 0.5), '1–1 1/2 adet');
    expect(PortionScale.scale('1/4 su bardağı', 2), '1/2 su bardağı');
    expect(PortionScale.scale('1 küçük boy', 1.5), '1 1/2 küçük boy');
    expect(PortionScale.present(
      PortionScale.split('2–3 adet kabak'),
      1.5,
    ).amount, '3–4,5 adet');
  });

  test('rejects text without steps', () {
    expect(RecipeTextParser.parse('Sadece başlık'), isNull);
  });
}
