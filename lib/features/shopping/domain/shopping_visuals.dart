import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/models.dart';

class ShoppingVisuals {
  ShoppingVisuals._();

  static const categoryOrder = ['vegetable', 'protein', 'dairy', 'grain', 'other'];

  static String label(String cat) => switch (cat) {
        'vegetable' => 'Sebze & meyve',
        'protein' => 'Protein',
        'dairy' => 'Süt ürünleri',
        'grain' => 'Tahıl & bakliyat',
        _ => 'Diğer',
      };

  static IconData iconFor(String cat) => switch (cat) {
        'vegetable' => Icons.eco_rounded,
        'protein' => Icons.set_meal_rounded,
        'dairy' => Icons.icecream_rounded,
        'grain' => Icons.grain_rounded,
        _ => Icons.shopping_bag_rounded,
      };

  static Color tintFor(String cat) => switch (cat) {
        'vegetable' => AppColors.kawaiiMint,
        'protein' => AppColors.kawaiiPeach,
        'dairy' => AppColors.kawaiiSky,
        'grain' => AppColors.kawaiiLemon,
        _ => AppColors.kawaiiLilac,
      };

  static Color accentFor(String cat) => switch (cat) {
        'vegetable' => AppColors.kawaiiLeafDeep,
        'protein' => AppColors.kawaiiCoralDeep,
        'dairy' => AppColors.kawaiiSkyBlue,
        'grain' => AppColors.kawaiiSalmon,
        _ => AppColors.kawaiiPurple,
      };

  static String? imageFor(ShoppingItem item) {
    final url = item.imageUrl?.trim();
    if (url != null && url.isNotEmpty) return url;
    final n = item.name.toLowerCase();
    if (n.contains('mercimek') || n.contains('çorba')) return DiyetselAssets.foodLentilSoup;
    if (n.contains('smoothie') || n.contains('brokoli') || n.contains('ıspanak') || n.contains('yeşil')) {
      return DiyetselAssets.foodGreenSmoothie;
    }
    if (n.contains('salata') || n.contains('yulaf') || n.contains('quinoa') || n.contains('kase')) {
      return DiyetselAssets.foodSaladBowl;
    }
    return null;
  }

  static String tipOfDay(int daySeed) {
    const tips = [
      'Listeyi reyon sırasına göre gez — daha az tur, daha az dürtü alışverişi.',
      'Açken markete girme; protein ve sebzeyi önce sepete koy.',
      'Etiket: 100 g’da şeker ve doymuş yağ satırına bak.',
      'Haftalık menüden üret; unutulan malzeme kalmaz.',
      'Dondurulmuş sebze-meyve de taze kadar besleyici olabilir.',
    ];
    return tips[daySeed.abs() % tips.length];
  }
}
