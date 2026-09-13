import 'package:flutter_test/flutter_test.dart';

import 'package:diyetsel/core/models/enums.dart';
import 'package:diyetsel/core/models/models.dart';
import 'package:diyetsel/features/shopping/domain/shopping_from_diet.dart';
import 'package:diyetsel/features/shopping/domain/shopping_product_extract.dart';

void main() {
  group('ShoppingProductExtract', () {
    test('strips portions and splits plus compounds', () {
      final a = ShoppingProductExtract.fromLine(
        'Porsiyon meyve + 1 adet salatalık',
      );
      expect(a.map((e) => e.name.toLowerCase()), ['meyve', 'salatalık']);

      final b = ShoppingProductExtract.fromIngredient(
        name: 'Tam ceviz +',
        amount: '7 x 3 adet zeytin',
      );
      expect(b.map((e) => e.name.toLowerCase()), containsAll(['ceviz', 'zeytin']));

      final c = ShoppingProductExtract.fromLine(
        'Su bardağı süt + 1 çay kaşığı kadar kakao',
      );
      expect(c.map((e) => e.name.toLowerCase()), ['süt', 'kakao']);

      final d = ShoppingProductExtract.fromLine('Yemek kaşığı yoğurt');
      expect(d.single.name.toLowerCase(), 'yoğurt');

      final e = ShoppingProductExtract.fromLine('Açık çay ( şekersiz )');
      expect(e.single.name.toLowerCase(), 'çay');

      final f = ShoppingProductExtract.fromLine(
        'İnce dilim tam buğday / kepekli / çavdar ekmeği',
      );
      expect(f.single.name.toLowerCase(), 'tam buğday ekmeği');
    });

    test('skips meal times and schedule labels', () {
      expect(
        ShoppingProductExtract.fromLine('Ara ( 17:00 - 17:30 )'),
        isEmpty,
      );
      expect(ShoppingProductExtract.fromLine('Kahvaltı'), isEmpty);
      expect(ShoppingProductExtract.isNonShoppable('Ara ( 08:00 )'), isTrue);
    });

    test('bol salata yağsız becomes salata', () {
      final p = ShoppingProductExtract.fromLine('Bol salata (Yağsız)');
      expect(p.single.name.toLowerCase(), 'salata');
    });
  });

  group('ShoppingFromDiet', () {
    DietPlan planWithIngredients() {
      final monday = DateTime(2026, 9, 1);
      return DietPlan(
        id: 'p1',
        clientId: 'c1',
        clientName: 'Test',
        dietitianId: 'a1',
        title: 'Test',
        weekStart: monday,
        days: [
          for (var i = 0; i < 7; i++)
            DietDay(
              date: monday.add(Duration(days: i)),
              meals: [
                DietMeal(
                  id: 'b$i',
                  type: MealType.breakfast,
                  name: 'Yulaf',
                  description: 'Yulaf kasesi',
                  calories: 400,
                  protein: 20,
                  carbs: 40,
                  fat: 10,
                  ingredients: const [
                    Ingredient(name: 'Yulaf', amount: '50 g', category: 'grain'),
                    Ingredient(
                      name: 'Süzme yoğurt',
                      amount: '150 g',
                      category: 'dairy',
                    ),
                  ],
                ),
                DietMeal(
                  id: 'l$i',
                  type: MealType.lunch,
                  name: 'Tavuk',
                  description: 'Izgara tavuk',
                  calories: 500,
                  protein: 40,
                  carbs: 30,
                  fat: 15,
                  ingredients: const [
                    Ingredient(
                      name: 'Tavuk göğsü',
                      amount: '150 g',
                      category: 'protein',
                    ),
                  ],
                ),
              ],
            ),
        ],
      );
    }

    test('aggregates identical ingredients across week days', () {
      final result = ShoppingFromDiet.build(plan: planWithIngredients());
      expect(result.isEmpty, isFalse);
      expect(result.dietItemCount, 3);
      final yulaf = result.items.firstWhere((e) => e.name == 'Yulaf');
      expect(yulaf.amount, '7x 50 g');
      expect(yulaf.category, 'grain');
      expect(yulaf.id.startsWith('diet-'), isTrue);
    });

    test('keeps manual items and preserves checked diet items', () {
      final current = [
        const ShoppingItem(
          id: 'manual-1',
          name: 'Zeytinyağı',
          amount: '1 lt',
          category: 'other',
        ),
        ShoppingItem(
          id: 'diet-grain|yulaf',
          name: 'Yulaf',
          amount: '50 g',
          category: 'grain',
          checked: true,
        ),
      ];
      final result = ShoppingFromDiet.build(
        plan: planWithIngredients(),
        current: current,
      );
      expect(result.items.any((e) => e.name == 'Zeytinyağı'), isTrue);
      final yulaf = result.items.firstWhere((e) => e.name == 'Yulaf');
      expect(yulaf.checked, isTrue);
    });

    test('falls back to description / meal title when ingredients empty', () {
      final monday = DateTime(2026, 9, 1);
      final plan = DietPlan(
        id: 'p2',
        clientId: 'c1',
        clientName: 'Test',
        dietitianId: 'a1',
        title: 'Word',
        weekStart: monday,
        days: [
          DietDay(
            date: monday,
            meals: const [
              DietMeal(
                id: 'm1',
                type: MealType.breakfast,
                name: 'Kahvaltı kasesi',
                description: 'Yulaf, yoğurt, chia',
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
              ),
            ],
          ),
        ],
      );
      final result = ShoppingFromDiet.build(plan: plan);
      expect(result.dietItemCount, greaterThanOrEqualTo(3));
      expect(
        result.items.map((e) => e.name.toLowerCase()),
        containsAll(['yulaf', 'yoğurt', 'chia']),
      );
    });

    test('word-style portion lines become grocery products', () {
      final monday = DateTime(2026, 9, 1);
      final plan = DietPlan(
        id: 'p3',
        clientId: 'c1',
        clientName: 'Test',
        dietitianId: 'a1',
        title: 'Word portions',
        weekStart: monday,
        days: [
          DietDay(
            date: monday,
            meals: const [
              DietMeal(
                id: 's1',
                type: MealType.afternoonSnack,
                name: 'Ara ( 17:00 - 17:30 )',
                description: 'Ara',
                calories: 0,
                protein: 0,
                carbs: 0,
                fat: 0,
                ingredients: [
                  Ingredient(name: 'Porsiyon meyve +', amount: '1 adet salatalık'),
                  Ingredient(name: 'Yemek kaşığı yoğurt', amount: ''),
                  Ingredient(name: 'Ara ( 17:00 - 17:30 )', amount: ''),
                  Ingredient(name: 'Açık çay ( şekersiz )', amount: ''),
                  Ingredient(
                    name: 'İnce dilim tam buğday / kepekli / çavdar ekmeği',
                    amount: '',
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final result = ShoppingFromDiet.build(plan: plan);
      final names = result.items.map((e) => e.name.toLowerCase()).toList();
      expect(names, isNot(contains(contains('17:00'))));
      expect(names, containsAll(['meyve', 'salatalık', 'yoğurt', 'çay']));
      expect(names, contains('tam buğday ekmeği'));
      expect(names.any((n) => n.contains('yemek kaşığı')), isFalse);
      expect(names.any((n) => n.startsWith('porsiyon')), isFalse);
    });
  });
}
