import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import 'shopping_platforms.dart';
import 'shopping_product_extract.dart';

/// Alınacaklar (tiklenmemiş) listesini platform aramasına / panoya / paylaşıma taşır.
class ShoppingDelivery {
  ShoppingDelivery._();

  static List<ShoppingItem> neededItems(List<ShoppingItem> all) =>
      all.where((e) => !e.checked).toList();

  /// Unchecked items expanded into clean shoppable product rows (for platform UI).
  static List<ShoppingItem> neededProducts(List<ShoppingItem> all) {
    final out = <ShoppingItem>[];
    final seen = <String>{};
    for (final item in neededItems(all)) {
      final products = ShoppingProductExtract.fromIngredient(
        name: item.name,
        amount: item.amount,
      );
      if (products.isEmpty) continue;
      for (final p in products) {
        final key = p.name.toLowerCase();
        if (!seen.add(key)) continue;
        out.add(
          item.copyWith(
            name: p.name,
            amount: p.amount.isNotEmpty ? p.amount : '',
          ),
        );
      }
    }
    return out;
  }

  static String lineFor(ShoppingItem item) {
    final amount = item.amount.trim();
    return amount.isEmpty ? item.name.trim() : '${item.name.trim()} ($amount)';
  }

  static String searchQueryFor(ShoppingItem item) {
    final cleaned = ShoppingProductExtract.searchQuery(item.name);
    if (cleaned != null && cleaned.isNotEmpty) return cleaned;
    final fallback = item.name.trim();
    return fallback;
  }

  static String formatList(
    List<ShoppingItem> needed, {
    ShoppingDeliveryPlatform? platform,
  }) {
    if (needed.isEmpty) return '';
    final buf = StringBuffer();
    buf.writeln('Alışveriş listesi — e-Diyet');
    if (platform != null) buf.writeln('Platform: ${platform.label}');
    buf.writeln('');
    for (var i = 0; i < needed.length; i++) {
      buf.writeln('${i + 1}. ${lineFor(needed[i])}');
    }
    buf.writeln('');
    buf.writeln('Not: Ürünleri uygulamada tek tek arayıp sepete ekleyebilirsin.');
    return buf.toString().trim();
  }

  static Future<void> copyList(
    List<ShoppingItem> needed, {
    ShoppingDeliveryPlatform? platform,
  }) async {
    final text = formatList(needed, platform: platform);
    await Clipboard.setData(ClipboardData(text: text));
  }

  static Future<void> shareList(
    List<ShoppingItem> needed, {
    ShoppingDeliveryPlatform? platform,
  }) async {
    final text = formatList(needed, platform: platform);
    if (text.isEmpty) return;
    await SharePlus.instance.share(ShareParams(text: text, subject: 'Alışveriş listesi'));
  }

  static Future<bool> openSearch(
    ShoppingDeliveryPlatform platform,
    ShoppingItem item,
  ) async {
    final q = searchQueryFor(item);
    if (q.isEmpty) return false;
    final uri = platform.searchUri(q);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openPlatformHome(ShoppingDeliveryPlatform platform) async {
    final home = switch (platform) {
      ShoppingDeliveryPlatform.trendyolGo => Uri.parse('https://www.trendyol.com/'),
      ShoppingDeliveryPlatform.yemeksepeti => Uri.parse('https://www.yemeksepeti.com/'),
      ShoppingDeliveryPlatform.migros => Uri.parse('https://www.migros.com.tr/'),
      ShoppingDeliveryPlatform.a101 => Uri.parse('https://www.a101.com.tr/'),
      ShoppingDeliveryPlatform.getir => Uri.parse('https://getir.com/'),
    };
    return launchUrl(home, mode: LaunchMode.externalApplication);
  }
}
