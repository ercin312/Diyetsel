import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';

class SettingsVisuals {
  SettingsVisuals._();

  static const blue = Color(0xFF5BA3C9);
  static const blueDeep = Color(0xFF2A6B8A);
  static const coral = Color(0xFFE07A5F);
  static const mint = Color(0xFFE8F5F0);
  static const sky = Color(0xFFE3F2F8);
  static const peach = Color(0xFFFFF0E8);

  static String visualStyleLabel(VisualStyle style) => switch (style) {
        VisualStyle.modern => 'Modern',
        VisualStyle.cartoon => 'Karikatür',
      };

  static int activeReminderCount(NotificationPrefs prefs) {
    var count = 0;
    if (prefs.smartReminders) count++;
    if (prefs.appointmentReminders) count++;
    if (prefs.feedbackAlerts) count++;
    if (prefs.inactivityAlerts) count++;
    if (prefs.waterShortcut) count++;
    return count;
  }

  static String tipOfDay(int daySeed) {
    const tips = [
      'Akıllı hatırlatıcılar su, öğün ve randevuna göre kişiselleşir.',
      'Akıllı hatırlatıcılar su, öğün ve randevuna göre kişiselleşir.',
      'Su kısayolu bildirimi Android’de tek dokunuşla +250 ml ekler.',
      'Diyetisyen geri bildirimi açıkken öğün fotoğraflarından haberdar olursun.',
      'Klinik modüllerini kapatırsan ilgili bölüm tüm danışanlarda gizlenir.',
      'Su periyodunu günlük rutinine göre 2–3 saat aralığında tut.',
    ];
    return tips[daySeed.abs() % tips.length];
  }
}
