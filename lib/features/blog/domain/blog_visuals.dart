import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/models.dart';

/// Display helpers for Premium Cartoon blog UI.
class BlogVisuals {
  BlogVisuals._();

  static String coverFor(BlogPost post) {
    if (post.coverUrl != null && post.coverUrl!.trim().isNotEmpty) {
      return post.coverUrl!.trim();
    }
    switch (post.id) {
      case 'blog-keto':
        return DiyetselAssets.foodGreenSmoothie;
      case 'blog-if':
        return DiyetselAssets.mascotAvocado;
      case 'blog-med':
        return DiyetselAssets.foodSaladBowl;
      case 'blog-detox':
        return DiyetselAssets.foodLentilSoup;
      case 'blog-sport':
        return DiyetselAssets.characterActiveBoy;
      default:
        break;
    }
    final c = post.category.toLowerCase();
    if (c.contains('keto') || c.contains('vegan')) return DiyetselAssets.foodGreenSmoothie;
    if (c.contains('detoks')) return DiyetselAssets.foodLentilSoup;
    if (c.contains('spor')) return DiyetselAssets.characterActiveBoy;
    if (c.contains('akdeniz')) return DiyetselAssets.foodSaladBowl;
    return DiyetselAssets.foodSaladBowl;
  }

  static Color tintFor(BlogPost post) {
    switch (post.category) {
      case 'Keto':
        return AppColors.kawaiiLilac;
      case 'Aralıklı Oruç':
        return AppColors.kawaiiSky;
      case 'Vegan':
        return AppColors.kawaiiMint;
      case 'Akdeniz':
        return AppColors.kawaiiLemon;
      case 'Detoks':
        return AppColors.kawaiiPeach;
      case 'Spor':
        return const Color(0xFFFFE0D4);
      default:
        return AppColors.kawaiiSurfaceCream;
    }
  }

  static IconData iconFor(BlogPost post) {
    switch (post.category) {
      case 'Keto':
        return Icons.local_fire_department_rounded;
      case 'Aralıklı Oruç':
        return Icons.schedule_rounded;
      case 'Vegan':
        return Icons.eco_rounded;
      case 'Akdeniz':
        return Icons.wb_sunny_rounded;
      case 'Detoks':
        return Icons.water_drop_rounded;
      case 'Spor':
        return Icons.fitness_center_rounded;
      default:
        return Icons.article_rounded;
    }
  }

  static int readMinutes(BlogPost post) {
    final chars = post.body.fold<int>(0, (s, b) => s + b.text.length);
    final mins = (chars / 450).ceil();
    return mins.clamp(1, 25);
  }
}
