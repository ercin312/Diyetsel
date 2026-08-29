import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

typedef FastingPhaseInfo = ({String title, String body});

class FastingVisuals {
  FastingVisuals._();

  static const phases = [
    (0, '0–4 sa', 'Sindirim', Icons.restaurant_rounded),
    (4, '4–12 sa', 'Yağ yakımı', Icons.local_fire_department_rounded),
    (12, '12–16 sa', 'Pencere', Icons.nightlight_round),
  ];

  static FastingPhaseInfo phaseForHours(int hours) {
    if (hours < 4) {
      return (
        title: 'Sindirim',
        body: 'Son öğün hâlâ işleniyor. Su iç, kafein istersen sade tut.',
      );
    }
    if (hours < 12) {
      return (
        title: 'Yağ yakımı',
        body: 'Glikojen azalıyor. Açlık dalgaları geçer; yürüyüş yardımcı olur.',
      );
    }
    return (
      title: 'Pencere',
      body: '16:8\'in asıl dilimi. Elektrolit ve suyu ihmal etme.',
    );
  }

  static int phaseIndex(int hours) {
    if (hours < 4) return 0;
    if (hours < 12) return 1;
    return 2;
  }

  static Color phaseAccent(int index) => switch (index) {
        0 => const Color(0xFF5BA3C9),
        1 => const Color(0xFFE07A5F),
        _ => AppColors.primary,
      };

  static Color phaseTint(int index) => switch (index) {
        0 => const Color(0xFFE3F2F8),
        1 => const Color(0xFFFFF0E8),
        _ => const Color(0xFFE8F5F0),
      };

  static String tipOfDay(int daySeed) {
    const tips = [
      '16:8 — 16 saat oruç, 8 saat yeme. Diyet planın yeme penceresine sığmalı.',
      'Oruçta su, sade çay ve şekersiz kahve serbest; sütlü kahve pencereyi bozar.',
      'Kahvaltıyı geç, akşamı erken bitir — pencereyi hayatına göre kaydır.',
      'Açlık dalgası geçicidir; su ve kısa yürüyüş yardımcı olur.',
      'Planın yeme penceresine sığmıyorsa diyetisyeninle konuş.',
    ];
    return tips[daySeed.abs() % tips.length];
  }
}
