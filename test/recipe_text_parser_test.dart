import 'package:diyetsel/features/recipes/domain/recipe_text_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the pasted recipe layout', () {
    const raw = '''
🍽️ Tavuklu Kabak Sandal

Öğün: Ana öğün
Hazırlama süresi: 15 dakika
Pişirme süresi: 25–30 dakika
Servis: 1–2 kişilik

🥗 Malzemeler
1 küçük boy tavuk göğsü
2–3 adet kabak
🤍 Sosu için
1 tatlı kaşığı zeytinyağı

🍳 Hazırlanışı
Tavuğu haşlayıp didikleyin.
Kabakları rendeleyip suyunu sıkın.
''';

    final parsed = RecipeTextParser.parse(raw);
    expect(parsed, isNotNull);
    expect(parsed!.title, 'Tavuklu Kabak Sandal');
    expect(parsed.category, 'Ana öğün');
    expect(parsed.prepMinutes, 15);
    expect(parsed.cookMinutes, 30);
    expect(parsed.servings, 2);
    expect(parsed.ingredients.map((e) => e.name), [
      '1 küçük boy tavuk göğsü',
      '2–3 adet kabak',
      'Sosu için',
      '1 tatlı kaşığı zeytinyağı',
    ]);
    expect(parsed.steps, [
      'Tavuğu haşlayıp didikleyin.',
      'Kabakları rendeleyip suyunu sıkın.',
    ]);
  });

  test('rejects text without steps', () {
    expect(RecipeTextParser.parse('Sadece başlık'), isNull);
  });
}
