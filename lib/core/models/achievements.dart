import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class BadgeDef {
  const BadgeDef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.target,
    required this.tint,
    this.lessonSeriesId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final int target;
  final Color tint;
  final String? lessonSeriesId;
}

class BadgeCatalog {
  BadgeCatalog._();

  static const all = [
    BadgeDef(
      id: 'water_week',
      title: 'Su ustası',
      subtitle: '7 gün üst üste su hedefini tut',
      emoji: '💧',
      target: 7,
      tint: AppColors.accent,
    ),
    BadgeDef(
      id: 'checkin_4',
      title: 'Check-in yıldızı',
      subtitle: '4 haftalık check-in tamamla',
      emoji: '❤️',
      target: 4,
      tint: AppColors.danger,
    ),
    BadgeDef(
      id: 'meal_photos_10',
      title: 'Tabak sanatçısı',
      subtitle: '10 öğün fotoğrafı paylaş',
      emoji: '📷',
      target: 10,
      tint: AppColors.peachDeep,
    ),
    BadgeDef(
      id: 'streak_7',
      title: 'Ateş serisi',
      subtitle: '7 günlük aktiflik serisi yakala',
      emoji: '🔥',
      target: 7,
      tint: AppColors.primary,
    ),
    BadgeDef(
      id: 'lesson_labels',
      title: 'Etiket dedektifi',
      subtitle: '7 günlük etiket okuma serisini bitir',
      emoji: '🔍',
      target: 7,
      tint: AppColors.primaryDeep,
      lessonSeriesId: 'label_reading',
    ),
    BadgeDef(
      id: 'lesson_portions',
      title: 'Porsiyon ustası',
      subtitle: '7 günlük porsiyon serisini bitir',
      emoji: '🥄',
      target: 7,
      tint: AppColors.success,
      lessonSeriesId: 'portion_art',
    ),
  ];

  static BadgeDef? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}
