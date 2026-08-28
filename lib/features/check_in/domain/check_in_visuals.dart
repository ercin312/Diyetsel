import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/models.dart';

class CheckInVisuals {
  CheckInVisuals._();

  static const moods = <(IconData, String, Color)>[
    (Icons.sentiment_very_dissatisfied_rounded, 'Zor', AppColors.kawaiiCoralDeep),
    (Icons.sentiment_dissatisfied_rounded, 'Eh işte', AppColors.kawaiiSalmon),
    (Icons.sentiment_neutral_rounded, 'Normal', AppColors.kawaiiSkyBlue),
    (Icons.sentiment_satisfied_rounded, 'İyi', AppColors.kawaiiLeaf),
    (Icons.sentiment_very_satisfied_rounded, 'Harika', AppColors.kawaiiLeafDeep),
  ];

  static const energyLabels = ['Çok düşük', 'Düşük', 'Orta', 'İyi', 'Yüksek'];
  static const adherenceLabels = ['Zayıf', 'Kısmen', 'Orta', 'İyi', 'Tam'];

  static const quickTags = [
    'Spor yaptım',
    'Az uyudum',
    'Stresli hafta',
    'Seyahat',
    'Sosyal yemek',
    'Hastalandım',
    'Motivasyon yüksek',
  ];

  static (IconData, String, Color) moodMeta(int mood) {
    final i = (mood - 1).clamp(0, moods.length - 1);
    return moods[i];
  }

  static String tipOfWeek(int daySeed) {
    const tips = [
      'Aynı gün ve saatte tartıl — trend gürültüden daha net görünür.',
      'Bel ölçüsünü göbek hizasından, nefes verdikten sonra al.',
      'Not kısmına zorlandığın öğünü yaz; diyetisyenin oradan revize eder.',
      'Ruh hali düşükse önce uyku ve suyu kontrol et.',
      'Haftalık check-in günlük tartıdan daha güvenilir bir pusuladır.',
    ];
    return tips[daySeed.abs() % tips.length];
  }

  static String summaryLine(WeeklyCheckIn log) {
    final mood = moodMeta(log.mood).$2;
    return [
      if (log.weight != null) '${log.weight!.toStringAsFixed(1)} kg',
      if (log.waist != null) 'bel ${log.waist!.toStringAsFixed(0)} cm',
      mood,
      if (log.sleepHours != null) '${log.sleepHours!.toStringAsFixed(1)} sa uyku',
    ].join(' · ');
  }

  static Color tintForMood(int mood) {
    switch (mood) {
      case 1:
        return AppColors.kawaiiRose;
      case 2:
        return AppColors.kawaiiPeach;
      case 3:
        return AppColors.kawaiiSky;
      case 4:
        return AppColors.kawaiiMint;
      default:
        return AppColors.kawaiiLemon;
    }
  }
}
