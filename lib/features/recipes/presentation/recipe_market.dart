import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/app_store.dart';
import '../../../core/l10n/ui_string.dart';
import '../../../core/models/models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../shopping/presentation/widgets/shopping_delivery_sheet.dart';
import '../domain/portion_scale.dart';

Future<void> sendCheckedToMarket({
  required BuildContext context,
  required WidgetRef ref,
  required Recipe recipe,
  required int portion,
  required Set<int> ingredientIndexes,
  required Set<int> sauceIndexes,
  required bool cartoon,
}) async {
  if (ingredientIndexes.isEmpty && sauceIndexes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(('Markete gidecek malzemeleri işaretle.').ui)),
    );
    return;
  }
  final user = ref.read(authControllerProvider).user;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(('Alışveriş listesi için giriş yap.').ui)),
    );
    return;
  }
  final base = recipe.servings < 1 ? 1 : recipe.servings;
  final factor = portion / base;
  final picked = <Ingredient>[
    for (final i in ingredientIndexes)
      if (i >= 0 && i < recipe.ingredients.length) recipe.ingredients[i],
    for (final i in sauceIndexes)
      if (i >= 0 && i < recipe.sauce.length) recipe.sauce[i],
  ];
  if (picked.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(('Markete gidecek malzemeleri işaretle.').ui)),
    );
    return;
  }

  final store = ref.read(appStoreProvider);
  final existing = [...store.shoppingList(user.id)];
  for (final item in picked) {
    final line = PortionScale.present(item, factor);
    final key = line.name.toLowerCase();
    final index = existing.indexWhere((e) => e.name.toLowerCase() == key);
    final next = ShoppingItem(
      id: index >= 0 && existing[index].id.isNotEmpty
          ? existing[index].id
          : 'shop-${DateTime.now().microsecondsSinceEpoch}-$key',
      name: line.name,
      amount: line.amount,
      category: item.category,
      checked: false,
    );
    if (index >= 0) {
      existing[index] = next;
    } else {
      existing.add(next);
    }
  }
  await store.saveShoppingList(user.id, existing);
  if (!context.mounted) return;
  await showShoppingDeliverySheet(context: context, items: existing, cartoon: cartoon);
}
