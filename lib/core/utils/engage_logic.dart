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
    this.category = 'Restoran',
    this.blurb = '',
    this.orderLine = '',
    this.swaps = const [],
    this.proteinG = 0,
    this.tags = const [],
  });

  final String title;
  final String place;
  final int kcal;
  final String tip;
  final String emoji;
  final IconData icon;
  final String category;
  final String blurb;
  final String orderLine;
  final List<String> swaps;
  final int proteinG;
  final List<String> tags;
}

const eatOutMenu = <EatOutIdea>[
  EatOutIdea(
    title: 'Izgara tavuk salata',
    place: 'Salad / Grill',
    category: 'Salata',
    kcal: 420,
    proteinG: 38,
    tip: 'Sos ayrı, kruton yok',
    blurb: 'Protein dolu, tok tutan klasik. Yanında limon ve zeytinyağı iste; kremalı soslardan uzak dur.',
    orderLine: 'Izgara tavuk salata, sos ayrı, kruton ve mısır olmadan lütfen.',
    swaps: ['Kruton → ekstra yeşillik', 'Ranch → limon + zeytinyağı', 'Peynir yarıya'],
    tags: ['Yüksek protein', 'Hafif', 'Hızlı'],
    emoji: '🥗',
    icon: Icons.restaurant_rounded,
  ),
  EatOutIdea(
    title: 'Mercimek çorbası + ayran',
    place: 'Lokanta',
    category: 'Lokanta',
    kcal: 280,
    proteinG: 16,
    tip: 'Ekmek yerine salata',
    blurb: 'Demir ve lif deposu. Ekmek sepetini geri çevirip yanına çoban salata iste.',
    orderLine: 'Mercimek çorbası, yanında ayran; ekmek getirmeyin, salata olur mu?',
    swaps: ['Ekmek → salata', 'Yağlı sos yok', 'Limon sık'],
    tags: ['Hafif', 'Sıcak', 'Ekonomik'],
    emoji: '🍲',
    icon: Icons.soup_kitchen_rounded,
  ),
  EatOutIdea(
    title: 'Balık ızgara + yeşillik',
    place: 'Balıkçı',
    category: 'Balık',
    kcal: 450,
    proteinG: 36,
    tip: 'Kızartma ve pilavı çıkar',
    blurb: 'Omega-3 için güvenli liman. Kızartma tabağı yerine ızgara + bol limon.',
    orderLine: 'Izgara balık, yanına pilav yerine yeşillik ve limon lütfen.',
    swaps: ['Kızartma → ızgara', 'Pilav → salata', 'Tereyağı sosu yok'],
    tags: ['Omega-3', 'Protein', 'Akşam'],
    emoji: '🐟',
    icon: Icons.set_meal_rounded,
  ),
  EatOutIdea(
    title: 'Köfte (2 adet) + bol salata',
    place: 'Köfteci',
    category: 'Izgara',
    kcal: 480,
    proteinG: 32,
    tip: 'Pide yerine cacık',
    blurb: 'Porsiyonu kontrol et: 2 köfte yeterli. Pide yerine cacık veya ezme.',
    orderLine: '2 adet ızgara köfte, pide yerine cacık ve bol salata.',
    swaps: ['Pide → cacık', '3. köfteyi bırak', 'Kola → ayran'],
    tags: ['Doyurucu', 'Izgara'],
    emoji: '🍖',
    icon: Icons.kebab_dining_rounded,
  ),
  EatOutIdea(
    title: 'Tavuk dürüm, lavaş yarım',
    place: 'Dürüm / wrap',
    category: 'Sokak',
    kcal: 390,
    proteinG: 28,
    tip: 'Mayonez yok, bol yeşillik',
    blurb: 'Lavaşın yarısını açık bırak; mayonez yerine yoğurt veya hardal.',
    orderLine: 'Tavuk dürüm, mayonez yok, bol yeşillik, lavaş yarım olsun.',
    swaps: ['Mayonez → yoğurt', 'Lavaş yarıya', 'Patates yok'],
    tags: ['Sokak lezzeti', 'Pratik'],
    emoji: '🌯',
    icon: Icons.lunch_dining_rounded,
  ),
  EatOutIdea(
    title: 'Menemen, az yağ, pidesiz',
    place: 'Kahvaltıcı',
    category: 'Kahvaltı',
    kcal: 320,
    proteinG: 18,
    tip: 'Peynir ve sucuğu azalt',
    blurb: 'Sabah dışarıdaysan: az yağlı menemen, pide yerine salatalık-domates.',
    orderLine: 'Az yağlı menemen, pidesiz; sucuk ve kaşar olmasın.',
    swaps: ['Pide → salata', 'Sucuk çıkar', 'Zeytinyağı az'],
    tags: ['Kahvaltı', 'Hafif'],
    emoji: '🍳',
    icon: Icons.egg_alt_rounded,
  ),
  EatOutIdea(
    title: 'Çoban salata + ızgara hindi',
    place: 'Restoran',
    category: 'Salata',
    kcal: 360,
    proteinG: 34,
    tip: 'Yağlı sos yerine limon',
    blurb: 'Hindi dilimleriyle protein takviyeli çoban. Sos yerine limon-zeytinyağı.',
    orderLine: 'Çoban salata, üzerine ızgara hindi; sos yerine limon lütfen.',
    swaps: ['Sos → limon', 'Peynir az', 'Zeytin ölçülü'],
    tags: ['Protein', 'Hafif', 'Öğle'],
    emoji: '🥬',
    icon: Icons.eco_rounded,
  ),
  EatOutIdea(
    title: 'Sade Türk kahvesi + 3 ceviz',
    place: 'Kafe',
    category: 'Kafe',
    kcal: 90,
    proteinG: 2,
    tip: 'Tatlı yerine avuç içi kadar kuruyemiş',
    blurb: 'Kalori bütçesi daraldığında en zarif kaçış. Şekerli tatlıyı ertele.',
    orderLine: 'Sade Türk kahvesi; tatlı yerine 3 ceviz olur mu?',
    swaps: ['Şekerli kahve → sade', 'Cheesecake → ceviz', 'Sütlü latte → sade'],
    tags: ['Mini', 'Kafe', 'Acil'],
    emoji: '☕',
    icon: Icons.coffee_rounded,
  ),
  EatOutIdea(
    title: 'Izgara somon + buharlı sebze',
    place: 'Balıkçı / grill',
    category: 'Balık',
    kcal: 430,
    proteinG: 34,
    tip: 'Tereyağı sosunu istemeden söyle',
    blurb: 'Premium ama sade: somon + buharlı sebze. Tereyağlı sos ekstra kalori demek.',
    orderLine: 'Izgara somon, buharlı sebze; tereyağı sosu olmadan.',
    swaps: ['Tereyağı → limon', 'Patates → sebze', 'Ekmek yok'],
    tags: ['Omega-3', 'Premium'],
    emoji: '🐟',
    icon: Icons.set_meal_rounded,
  ),
  EatOutIdea(
    title: 'Tavuk şiş + cacık',
    place: 'Ocakbaşı',
    category: 'Izgara',
    kcal: 410,
    proteinG: 40,
    tip: 'Pilav yerine salata',
    blurb: 'Ocakbaşı klasikleri içinde en temiz seçim. Pilavı pas geç.',
    orderLine: 'Tavuk şiş, pilav yerine cacık ve salata lütfen.',
    swaps: ['Pilav → cacık', 'Ekmek az', 'Ayran tercih et'],
    tags: ['Yüksek protein', 'Izgara'],
    emoji: '🍖',
    icon: Icons.outdoor_grill_rounded,
  ),
  EatOutIdea(
    title: 'Yoğurtlu kumpir, az tereyağı',
    place: 'Kumpirci',
    category: 'Sokak',
    kcal: 380,
    proteinG: 14,
    tip: 'Mısır ve sosları yarıya indir',
    blurb: 'Kumpir tuzağı: sos ve tereyağı. Yoğurt ağırlıklı, az tereyağlı iste.',
    orderLine: 'Kumpir az tereyağlı, bol yoğurtlu; mısır ve soslar yarıya.',
    swaps: ['Tereyağı az', 'Ketçap yok', 'Yoğurt bol'],
    tags: ['Sokak', 'Doyurucu'],
    emoji: '🥔',
    icon: Icons.rice_bowl_rounded,
  ),
  EatOutIdea(
    title: 'Çiğ köfte porsiyon + ayran',
    place: 'Çiğköfteci',
    category: 'Sokak',
    kcal: 340,
    proteinG: 12,
    tip: 'Lavaşın yarısını bırak',
    blurb: 'Acılı ama hafif kalabilir. Lavaş yığını yerine porsiyon + ayran.',
    orderLine: 'Çiğ köfte porsiyon, az lavaş, yanında ayran.',
    swaps: ['Lavaş yarıya', 'Nar ekşisi ölçülü', 'Ayran ekle'],
    tags: ['Hafif', 'Sokak', 'Vejetaryen'],
    emoji: '🌯',
    icon: Icons.tapas_rounded,
  ),
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
