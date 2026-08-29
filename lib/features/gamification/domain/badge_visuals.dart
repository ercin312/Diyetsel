import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/achievements.dart';

class BadgeVisuals {
  BadgeVisuals._();

  static String softAssetFor(BadgeDef b) => switch (b.id) {
        'water_week' => DiyetselAssets.modernIconWaterDrop,
        'checkin_4' => DiyetselAssets.modernIconCheck,
        'meal_photos_10' => DiyetselAssets.modernIconPlan,
        'streak_7' => DiyetselAssets.modernIconStreak,
        'lesson_labels' => DiyetselAssets.modernIconSearch,
        'lesson_portions' => DiyetselAssets.modernIconDietScale,
        _ => DiyetselAssets.modernIconStory,
      };

  static IconData softIconFor(BadgeDef b) => switch (b.id) {
        'water_week' => Icons.water_drop_rounded,
        'checkin_4' => Icons.favorite_rounded,
        'meal_photos_10' => Icons.photo_camera_rounded,
        'streak_7' => Icons.local_fire_department_rounded,
        'lesson_labels' => Icons.search_rounded,
        'lesson_portions' => Icons.restaurant_rounded,
        _ => Icons.emoji_events_rounded,
      };

  static Color softTintFor(BadgeDef b) => switch (b.id) {
        'water_week' => const Color(0xFFE3F2F8),
        'checkin_4' => const Color(0xFFFFF0E8),
        'meal_photos_10' => const Color(0xFFE8F5F0),
        'streak_7' => const Color(0xFFFFF0E8),
        'lesson_labels' => const Color(0xFFF0EEF8),
        'lesson_portions' => const Color(0xFFFFF8E8),
        _ => const Color(0xFFE8F5F0),
      };

  static Color softAccentFor(BadgeDef b) => switch (b.id) {
        'water_week' => const Color(0xFF5BA3C9),
        'checkin_4' => const Color(0xFFE07A5F),
        'meal_photos_10' => AppColors.primary,
        'streak_7' => const Color(0xFFE07A5F),
        'lesson_labels' => const Color(0xFF7B6BB0),
        'lesson_portions' => const Color(0xFFD4A017),
        _ => AppColors.primary,
      };

  static String categoryFor(BadgeDef b) => switch (b.id) {
        'water_week' => 'Su',
        'checkin_4' => 'Check-in',
        'meal_photos_10' => 'Öğün',
        'streak_7' => 'Seri',
        'lesson_labels' || 'lesson_portions' => 'Ders',
        _ => 'Genel',
      };

  static String tipOfDay(int daySeed) {
    const tips = [
      'Küçük günlük alışkanlıklar büyük rozetleri açar — suyu unutma.',
      'Check-in’i haftalık ritüel yap; yıldız rozeti yaklaşıyor.',
      'Öğün fotoğrafı hem diyetisyene hem tabak sanatçısı rozetine yarar.',
      'Seriyi kırdığında yeniden başla — ateş tekrar yanar.',
      'Mini dersleri bitirmek rozetleri hızlandırır.',
    ];
    return tips[daySeed.abs() % tips.length];
  }
}
