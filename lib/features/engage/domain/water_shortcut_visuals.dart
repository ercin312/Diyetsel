import 'package:flutter/material.dart';

class WaterShortcutVisuals {
  WaterShortcutVisuals._();

  static const blue = Color(0xFF5BA3C9);
  static const blueDeep = Color(0xFF2A6B8A);
  static const sky = Color(0xFFE3F2F8);
  static const mint = Color(0xFFE8F5F0);

  static const steps = [
    (Icons.notifications_active_rounded, 'Bildirimi aç', 'Kalıcı su kısayolu Android’de her zaman görünür.'),
    (Icons.touch_app_rounded, '+250 ml dokun', 'Bildirimdeki veya buradaki butona bas — anında kaydedilir.'),
    (Icons.flag_rounded, 'Hedefe yakla', 'Günlük ml hedefin otomatik güncellenir; takipte grafiği gör.'),
  ];

  static String tipOfDay(int daySeed) {
    const tips = [
      'Her öğünde 1 bardak su — küçük ritüeller büyük fark yaratır.',
      'Sabah kalkınca 1 bardak su sindirimi ve enerjiyi destekler.',
      'Kalıcı bildirim, unuttuğun günlerde tek dokunuşla seni yakalar.',
      'Açlık mı susuzluk mu? Önce bir yudum su dene — çoğu zaman yeter.',
      '250 ml’lik yudumlar hedefe ulaşmayı oyunlaştırır.',
      'Egzersiz öncesi ve sonrası ekstra 1–2 bardak unutma.',
      'Telefon kilidinden +250 ml — uygulamayı açmana gerek yok.',
    ];
    return tips[daySeed.abs() % tips.length];
  }

  static String platformMessage({required bool supportsNative, required bool enabled}) {
    if (!enabled) {
      return 'Kısayolu açınca Android’de kalıcı bildirim gelir. Windows ve web’de buradan +250 ml ekleyebilirsin.';
    }
    if (supportsNative) {
      return 'Kalıcı bildirim aktif — kilit ekranından veya bildirim çekmecesinden +250 ml ekle.';
    }
    return 'Bu cihazda kalıcı bildirim yok. Hızlı ekle butonları ve su takibi burada çalışır.';
  }

  static String statusLabel({required bool enabled, required bool supportsNative}) {
    if (!enabled) return 'Kapalı';
    if (supportsNative) return 'Bildirim açık';
    return 'Manuel mod';
  }

  static Color statusAccent({required bool enabled}) =>
      enabled ? blue : const Color(0xFF9E9E9E);
}
