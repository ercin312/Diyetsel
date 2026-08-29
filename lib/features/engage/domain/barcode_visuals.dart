import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class BarcodeVisuals {
  BarcodeVisuals._();

  static Color stampAccent(String? stamp) => switch (stamp) {
        'fazla' => const Color(0xFFE07A5F),
        'eksik' => const Color(0xFFD4A017),
        'uygun' => AppColors.primary,
        _ => const Color(0xFF5BA3C9),
      };

  static Color stampTint(String? stamp) => switch (stamp) {
        'fazla' => const Color(0xFFFFF0E8),
        'eksik' => const Color(0xFFFFF8E8),
        'uygun' => const Color(0xFFE8F5F0),
        _ => const Color(0xFFE3F2F8),
      };

  static String stampLabel(String? stamp) => switch (stamp) {
        'fazla' => 'Fazla',
        'eksik' => 'Eksik',
        'uygun' => 'Uygun',
        _ => 'Bekleniyor',
      };

  static String stampMessage(String? stamp) => switch (stamp) {
        'uygun' => 'Bu porsiyon kalan planına sığıyor. Dilediğin gibi ekleyebilirsin.',
        'fazla' => 'Kalori bütçesini aşıyor. Daha küçük porsiyon, paylaşım veya başka öğün dene.',
        'eksik' => 'Kalori düşük — planına ekleyebilirsin.',
        _ => 'Barkod tara veya kodu yaz; 100 g kalorisi bütçenle kıyaslanır.',
      };

  static IconData stampIcon(String? stamp) => switch (stamp) {
        'uygun' => Icons.check_circle_rounded,
        'fazla' => Icons.warning_amber_rounded,
        'eksik' => Icons.info_outline_rounded,
        _ => Icons.qr_code_scanner_rounded,
      };

  static String howItWorks(int step) => switch (step) {
        1 => 'Kamerayı barkoda tut veya kodu manuel yaz.',
        2 => '100 g kalorisi bugünkü kalan bütçenle karşılaştırılır.',
        3 => 'Uygun / fazla damgasına göre porsiyonu ayarla.',
        _ => '',
      };

  static String tipOfDay(int daySeed) {
    const tips = [
      'Open Food Facts çoğu ürünü 100 g olarak verir — paket gramajına böl.',
      'Ara öğün tavanı, kalan günlük kalorinden düşük olabilir.',
      'Damga yeşilse bile porsiyonu paylaşmak her zaman iyi fikir.',
      'Barkod bulunamazsa kodu elle yaz; 8–13 hane yeterli.',
      'Etiketteki şeker satırına da göz at — kalori tek başına yetmez.',
    ];
    return tips[daySeed.abs() % tips.length];
  }
}
