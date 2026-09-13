import 'package:flutter/material.dart';

/// Eve teslim market platformları — resmi sepet API’si yok;
/// arama deep link / web + pano / paylaşım ile yarı otomatik akış.
enum ShoppingDeliveryPlatform {
  trendyolGo,
  yemeksepeti,
  migros,
  a101,
  getir,
}

extension ShoppingDeliveryPlatformX on ShoppingDeliveryPlatform {
  String get id => name;

  String get label => switch (this) {
        ShoppingDeliveryPlatform.trendyolGo => 'Trendyol Go',
        ShoppingDeliveryPlatform.yemeksepeti => 'Yemeksepeti',
        ShoppingDeliveryPlatform.migros => 'Migros',
        ShoppingDeliveryPlatform.a101 => 'A101',
        ShoppingDeliveryPlatform.getir => 'Getir',
      };

  String get shortHint => switch (this) {
        ShoppingDeliveryPlatform.trendyolGo => 'Market araması açılır',
        ShoppingDeliveryPlatform.yemeksepeti => 'Market / arama',
        ShoppingDeliveryPlatform.migros => 'Sanal Market arama',
        ShoppingDeliveryPlatform.a101 => 'Kapıda arama',
        ShoppingDeliveryPlatform.getir => 'Getir arama',
      };

  IconData get icon => switch (this) {
        ShoppingDeliveryPlatform.trendyolGo => Icons.local_shipping_rounded,
        ShoppingDeliveryPlatform.yemeksepeti => Icons.delivery_dining_rounded,
        ShoppingDeliveryPlatform.migros => Icons.storefront_rounded,
        ShoppingDeliveryPlatform.a101 => Icons.shopping_bag_rounded,
        ShoppingDeliveryPlatform.getir => Icons.pedal_bike_rounded,
      };

  Color get accent => switch (this) {
        ShoppingDeliveryPlatform.trendyolGo => const Color(0xFFF27A1A),
        ShoppingDeliveryPlatform.yemeksepeti => const Color(0xFFFA0050),
        ShoppingDeliveryPlatform.migros => const Color(0xFFFF6D00),
        ShoppingDeliveryPlatform.a101 => const Color(0xFF00A0E2),
        ShoppingDeliveryPlatform.getir => const Color(0xFF5D3EBC),
      };

  /// Web search URL — uygulama yoksa tarayıcıda açılır.
  Uri searchUri(String query) {
    final q = Uri.encodeQueryComponent(query.trim());
    return switch (this) {
      ShoppingDeliveryPlatform.trendyolGo =>
        Uri.parse('https://www.trendyol.com/sr?q=$q'),
      ShoppingDeliveryPlatform.yemeksepeti =>
        Uri.parse('https://www.yemeksepeti.com/city/istanbul/search?q=$q'),
      ShoppingDeliveryPlatform.migros =>
        Uri.parse('https://www.migros.com.tr/arama?q=$q'),
      ShoppingDeliveryPlatform.a101 =>
        Uri.parse('https://www.a101.com.tr/list/?search_text=$q'),
      ShoppingDeliveryPlatform.getir =>
        Uri.parse('https://getir.com/arama/?keyword=$q'),
    };
  }

  static ShoppingDeliveryPlatform? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final p in ShoppingDeliveryPlatform.values) {
      if (p.id == raw || p.name == raw) return p;
    }
    return null;
  }
}
