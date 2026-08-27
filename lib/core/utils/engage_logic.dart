import 'package:flutter/material.dart';

class OffProduct {
  const OffProduct({
    required this.barcode,
    required this.name,
    required this.kcal,
    this.per = '100 g',
    this.brand,
  });

  final String barcode;
  final String name;
  final int kcal;
  final String per;
  final String? brand;
}

class EatOutIdea {
  const EatOutIdea({
    required this.title,
    required this.place,
    required this.kcal,
    required this.tip,
    required this.emoji,
    required this.icon,
  });

  final String title;
  final String place;
  final int kcal;
  final String tip;
  final String emoji;
  final IconData icon;
}

const eatOutMenu = <EatOutIdea>[
  EatOutIdea(title: 'Izgara tavuk salata', place: 'Salad / Grill', kcal: 420, tip: 'Sos ayrı, kruton yok', emoji: '🥗', icon: Icons.restaurant_rounded),
  EatOutIdea(title: 'Mercimek çorbası + ayran', place: 'Lokanta', kcal: 280, tip: 'Ekmek yerine salata', emoji: '🍲', icon: Icons.soup_kitchen_rounded),
  EatOutIdea(title: 'Balık ızgara + yeşillik', place: 'Balıkçı', kcal: 450, tip: 'Kızartma ve pilavı çıkar', emoji: '🐟', icon: Icons.set_meal_rounded),
  EatOutIdea(title: 'Köfte (2 adet) + bol salata', place: 'Köfteci', kcal: 480, tip: 'Pide yerine cacık', emoji: '🍖', icon: Icons.kebab_dining_rounded),
  EatOutIdea(title: 'Tavuk dürüm, lavaş yarım', place: 'Dürüm / wrap', kcal: 390, tip: 'Mayonez yok, bol yeşillik', emoji: '🌯', icon: Icons.lunch_dining_rounded),
  EatOutIdea(title: 'Menemen, az yağ, pidesiz', place: 'Kahvaltıcı', kcal: 320, tip: 'Peynir ve sucuğu azalt', emoji: '🍳', icon: Icons.egg_alt_rounded),
  EatOutIdea(title: 'Çoban salata + ızgara hindi', place: 'Restoran', kcal: 360, tip: 'Yağlı sos yerine limon', emoji: '🥬', icon: Icons.eco_rounded),
  EatOutIdea(title: 'Sade Türk kahvesi + 3 ceviz', place: 'Kafe', kcal: 90, tip: 'Tatlı yerine avuç içi kadar kuruyemiş', emoji: '☕', icon: Icons.coffee_rounded),
  EatOutIdea(title: 'Izgara somon + buharlı sebze', place: 'Balıkçı / grill', kcal: 430, tip: 'Tereyağı sosunu iste', emoji: '🐟', icon: Icons.set_meal_rounded),
  EatOutIdea(title: 'Tavuk şiş + cacık', place: 'Ocakbaşı', kcal: 410, tip: 'Pilav yerine salata', emoji: '🍖', icon: Icons.outdoor_grill_rounded),
  EatOutIdea(title: 'Yoğurtlu kumpir, az tereyağı', place: 'Kumpirci', kcal: 380, tip: 'Mısır ve sosları yarıya indir', emoji: '🥔', icon: Icons.rice_bowl_rounded),
  EatOutIdea(title: 'Çiğ köfte porsiyon + ayran', place: 'Çiğköfteci', kcal: 340, tip: 'Lavaşın yarısını bırak', emoji: '🌯', icon: Icons.tapas_rounded),
];

String plateStamp({required int estimated, required int planned}) {
  if (planned <= 0) return estimated <= 450 ? 'uygun' : 'fazla';
  final ratio = estimated / planned;
  if (ratio > 1.18) return 'fazla';
  if (ratio < 0.82) return 'eksik';
  return 'uygun';
}

String barcodeStamp({required int productKcal, required int remaining}) {
  if (remaining <= 0) return 'fazla';
  if (productKcal <= remaining + 40) return 'uygun';
  return 'fazla';
}
