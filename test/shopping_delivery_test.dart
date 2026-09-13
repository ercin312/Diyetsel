import 'package:flutter_test/flutter_test.dart';

import 'package:diyetsel/core/models/models.dart';
import 'package:diyetsel/features/shopping/domain/shopping_delivery.dart';
import 'package:diyetsel/features/shopping/domain/shopping_platforms.dart';

void main() {
  ShoppingItem item({
    required String name,
    String amount = '',
    bool checked = false,
  }) =>
      ShoppingItem(
        id: name,
        name: name,
        amount: amount,
        category: 'other',
        checked: checked,
      );

  test('neededItems excludes checked', () {
    final all = [
      item(name: 'Yulaf', amount: '500g'),
      item(name: 'Süt', checked: true),
      item(name: 'Yoğurt'),
    ];
    final needed = ShoppingDelivery.neededItems(all);
    expect(needed.map((e) => e.name), ['Yulaf', 'Yoğurt']);
  });

  test('formatList includes platform and lines', () {
    final text = ShoppingDelivery.formatList(
      [item(name: 'Yulaf', amount: '500g'), item(name: 'Süt')],
      platform: ShoppingDeliveryPlatform.migros,
    );
    expect(text, contains('Migros'));
    expect(text, contains('1. Yulaf (500g)'));
    expect(text, contains('2. Süt'));
  });

  test('searchUri encodes query', () {
    final uri = ShoppingDeliveryPlatform.a101.searchUri('tam buğday');
    expect(uri.toString(), contains('search_text='));
    expect(uri.toString(), contains('tam'));
  });
}
