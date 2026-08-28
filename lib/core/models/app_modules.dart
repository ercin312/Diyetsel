import 'package:flutter/material.dart';

class AppModule {
  static const diet = 'diet';
  static const water = 'water';
  static const appointments = 'appointments';
  static const barcode = 'barcode';
  static const checkIn = 'check_in';
  static const eatOut = 'eat_out';
  static const story = 'story';
  static const fasting = 'fasting';
  static const recipes = 'recipes';
  static const blog = 'blog';
  static const shopping = 'shopping';
  static const chat = 'chat';
  static const services = 'services';
  static const documents = 'documents';

  static const all = [
    diet,
    water,
    appointments,
    barcode,
    checkIn,
    eatOut,
    story,
    fasting,
    recipes,
    blog,
    shopping,
    chat,
    services,
    documents,
  ];

  static String label(String id) => switch (id) {
        diet => 'Diyet planı',
        water => 'Su takibi',
        appointments => 'Randevu',
        barcode => 'Barkod',
        checkIn => 'Haftalık check-in',
        eatOut => 'Dışarıda ne yesem',
        story => 'Hikaye kartı',
        fasting => 'Aralıklı oruç',
        recipes => 'Tarifler',
        blog => 'Blog',
        shopping => 'Alışveriş listesi',
        chat => 'Sohbet',
        services => 'Hizmetler',
        documents => 'Belge kasası',
        _ => id,
      };

  static String subtitle(String id) => switch (id) {
        diet => 'Günlük öğün listesi ve işaretleme',
        water => 'Bardak, seri ve su hedefi',
        appointments => 'Seans talep ve takvim',
        barcode => 'Ürün tarayıp plana uygunluk',
        checkIn => 'Haftalık kilo, ruh hali ve diyet uyumu',
        eatOut => 'Kalan kaloriye göre restoran önerisi',
        story => 'Instagram’a hazır ilerleme kartı',
        fasting => '16:8 pencere takibi',
        recipes => 'Sana özel tarifler',
        blog => 'Yazılar ve hikayeler',
        shopping => 'Alışveriş listesi',
        chat => 'Diyetisyen mesajları',
        services => 'Paket ve kampanyalar',
        documents => 'Lab, plan ve formlarını güvenle sakla',
        _ => '',
      };

  static String emoji(String id) => switch (id) {
        diet => '🥗',
        water => '💧',
        appointments => '📅',
        barcode => '📷',
        checkIn => '❤️',
        eatOut => '🍽️',
        story => '✨',
        fasting => '⏳',
        recipes => '🍲',
        blog => '📰',
        shopping => '🛒',
        chat => '💬',
        services => '🎁',
        documents => '📁',
        _ => '✨',
      };

  static IconData icon(String id) => switch (id) {
        diet => Icons.restaurant_rounded,
        water => Icons.water_drop_rounded,
        appointments => Icons.event_available_rounded,
        barcode => Icons.qr_code_scanner_rounded,
        checkIn => Icons.favorite_rounded,
        eatOut => Icons.restaurant_menu_rounded,
        story => Icons.auto_awesome_rounded,
        fasting => Icons.hourglass_bottom_rounded,
        recipes => Icons.menu_book_rounded,
        blog => Icons.article_rounded,
        chat => Icons.chat_rounded,
        shopping => Icons.shopping_cart_rounded,
        services => Icons.storefront_rounded,
        documents => Icons.folder_rounded,
        _ => Icons.grid_view_rounded,
      };

  static String? fromRoute(String route) {
    if (route.startsWith('/app/diet')) return diet;
    if (route.startsWith('/app/track')) return water;
    if (route.startsWith('/app/appointments')) return appointments;
    if (route.startsWith('/app/barcode')) return barcode;
    if (route.startsWith('/app/check-in')) return checkIn;
    if (route.startsWith('/app/eat-out')) return eatOut;
    if (route.startsWith('/app/story')) return story;
    if (route.startsWith('/app/fasting')) return fasting;
    if (route.startsWith('/app/recipes')) return recipes;
    if (route.startsWith('/app/blog')) return blog;
    if (route.startsWith('/app/shopping')) return shopping;
    if (route.startsWith('/app/chat')) return chat;
    if (route.startsWith('/app/services')) return services;
    if (route.startsWith('/app/documents')) return documents;
    return null;
  }
}
