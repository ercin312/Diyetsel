import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/widgets/kawaii_doodle.dart';

class StoryTemplate {
  const StoryTemplate({
    required this.id,
    required this.chip,
    required this.icon,
    required this.kind,
    required this.colors,
    required this.title,
    required this.subtitle,
    required this.foot,
    required this.caption,
    this.statLabel,
    this.statValue,
  });

  final String id;
  final String chip;
  final IconData icon;
  final KawaiiKind kind;
  final List<Color> colors;
  final String title;
  final String subtitle;
  final String foot;
  final String caption;
  final String? statLabel;
  final String? statValue;
}

class StoryVisuals {
  StoryVisuals._();

  static List<String> captionIdeas(StoryTemplate t) => [
        t.caption,
        'Diyetsel ile küçük adımlar, büyük fark 🌿',
        'Bugün kendime söz tuttum.',
        'Haftalık ritim > mükemmel gün.',
        '${t.chip} hedefimdeyim — sen de?',
      ];

  static List<StoryTemplate> buildTemplates({
    required AppStore store,
    required UserProfile user,
    required bool cartoon,
    required bool luxury,
  }) {
    final streak = store.streak(user.id);
    final water = store.waterLog(user.id, DateTime.now());
    final measures = store.measurements(user.id);
    final delta = measures.length >= 2 && measures.last.weight != null && measures[measures.length - 2].weight != null
        ? measures.last.weight! - measures[measures.length - 2].weight!
        : null;
    final dietitian = store.users().where((u) => u.isAdmin).firstOrNull?.displayName ?? 'Diyetisyen';
    final checkIns = store.checkIns(userId: user.id);
    final lastCheck = checkIns.isEmpty ? null : checkIns.first;
    final weekly = buildPeriodReport(store: store, user: user, period: ReportPeriod.weekly);
    final progress = store.userProgress(user.id);
    final badgeCount = progress.earnedBadgeIds.length;

    return [
      StoryTemplate(
        id: 'streak',
        chip: 'Seri',
        icon: Icons.local_fire_department_rounded,
        kind: KawaiiKind.fire,
        colors: cartoon
            ? const [AppColors.kawaiiRose, AppColors.kawaiiLemon]
            : luxury
                ? const [AppColors.luxuryCopperDeep, Color(0xFF3D2314)]
                : const [AppColors.modernFire, AppColors.modernFireBright],
        title: '${streak.current} günlük seri',
        subtitle: 'En iyi ${streak.best} gün',
        foot: streak.freezeUsed ? 'Bu ay dondurma kullanıldı' : 'Planına sadık gün',
        caption: '${streak.current} gündür Diyetsel ritmimdeyim 🔥',
        statLabel: 'Seri',
        statValue: '${streak.current}',
      ),
      StoryTemplate(
        id: 'water',
        chip: 'Su',
        icon: Icons.water_drop_rounded,
        kind: KawaiiKind.water,
        colors: cartoon
            ? const [AppColors.kawaiiSky, AppColors.kawaiiMint]
            : luxury
                ? const [AppColors.luxuryBronze, AppColors.luxuryCopper]
                : const [AppColors.primaryBright, AppColors.accent],
        title: 'Su %${(water.progress * 100).round()}',
        subtitle: '${water.amountMl} / ${water.goalMl} ml',
        foot: water.progress >= 1 ? 'Hedef doldu 💧' : 'Bir bardak daha',
        caption: 'Bugün ${(water.amountMl / 1000).toStringAsFixed(1)} L su — hidrasyon check ✓',
        statLabel: 'Su',
        statValue: '%${(water.progress * 100).round()}',
      ),
      StoryTemplate(
        id: 'progress',
        chip: 'İlerleme',
        icon: Icons.favorite_rounded,
        kind: KawaiiKind.heart,
        colors: cartoon
            ? const [AppColors.kawaiiLilac, AppColors.kawaiiMint]
            : luxury
                ? const [Color(0xFF2A1F18), AppColors.luxuryCopperDeep]
                : const [AppColors.primaryDeep, AppColors.modernSageDeep],
        title: delta == null
            ? 'İlerleme kartı'
            : (delta <= 0 ? '${delta.abs().toStringAsFixed(1)} kg düşüş' : '+${delta.toStringAsFixed(1)} kg'),
        subtitle: 'Diyetisyen: $dietitian',
        foot: 'Diyetsel ile devam',
        caption: delta == null
            ? 'Diyetsel ile yolculuğum devam ediyor 💚'
            : (delta <= 0
                ? 'Son ölçüme göre ${delta.abs().toStringAsFixed(1)} kg — sabır işe yarıyor'
                : 'Ölçüm dalgalandı; trend önemli, panik yok'),
        statLabel: 'Δ kg',
        statValue: delta == null ? '—' : '${delta <= 0 ? '' : '+'}${delta.toStringAsFixed(1)}',
      ),
      StoryTemplate(
        id: 'mood',
        chip: 'Ruh hali',
        icon: Icons.sentiment_satisfied_alt_rounded,
        kind: KawaiiKind.sparkle,
        colors: cartoon
            ? const [AppColors.kawaiiPeach, AppColors.kawaiiLilac]
            : luxury
                ? const [AppColors.luxuryCopper, Color(0xFF4A2C1A)]
                : const [Color(0xFF2F8A74), AppColors.accent],
        title: lastCheck == null ? 'Haftalık check-in' : _moodTitle(lastCheck.mood),
        subtitle: lastCheck == null
            ? 'İlk check-in’ini gönder'
            : (lastCheck.note.isEmpty ? 'Son check-in kaydı' : lastCheck.note),
        foot: lastCheck == null ? 'Kendine dürüst ol' : 'Enerji ${lastCheck.energy}/5 · Uyum ${lastCheck.adherence}/5',
        caption: lastCheck == null
            ? 'Bu hafta kendimi dinliyorum — Diyetsel check-in'
            : 'Bu hafta ruh halim: ${_moodTitle(lastCheck.mood)}',
        statLabel: 'Mood',
        statValue: lastCheck == null ? '—' : '${lastCheck.mood}/5',
      ),
      StoryTemplate(
        id: 'diet',
        chip: 'Diyet',
        icon: Icons.restaurant_rounded,
        kind: KawaiiKind.plate,
        colors: cartoon
            ? const [AppColors.kawaiiMint, AppColors.kawaiiLemon]
            : luxury
                ? const [Color(0xFF1F1612), AppColors.luxuryBronze]
                : const [AppColors.modernSageDeep, AppColors.primaryBright],
        title: weekly.dietMealsTotal == 0
            ? 'Plan takipte'
            : 'Uyumu %${(weekly.dietCompliance * 100).round()}',
        subtitle: weekly.dietMealsTotal == 0
            ? 'Öğünlerini işaretlemeye başla'
            : '${weekly.dietMealsConsumed}/${weekly.dietMealsTotal} öğün bu hafta',
        foot: weekly.scoreLabel,
        caption: weekly.dietMealsTotal == 0
            ? 'Diyetsel planımla ilerliyorum'
            : 'Bu hafta diyet uyumum %${(weekly.dietCompliance * 100).round()} 🥗',
        statLabel: 'Uyumu',
        statValue: weekly.dietMealsTotal == 0 ? '—' : '%${(weekly.dietCompliance * 100).round()}',
      ),
      StoryTemplate(
        id: 'badges',
        chip: 'Rozet',
        icon: Icons.emoji_events_rounded,
        kind: KawaiiKind.gift,
        colors: cartoon
            ? const [AppColors.kawaiiLemon, AppColors.kawaiiPeach]
            : luxury
                ? const [AppColors.luxuryGold, AppColors.luxuryCopperDeep]
                : const [AppColors.modernFireBright, AppColors.peachDeep],
        title: badgeCount == 0 ? 'İlk rozet yolda' : '$badgeCount rozet',
        subtitle: badgeCount == 0 ? 'Küçük alışkanlıklar birikir' : 'Koleksiyon büyüyor',
        foot: 'Diyetsel başarıları',
        caption: badgeCount == 0
            ? 'Diyetsel yolculuğum başladı ✨'
            : 'Diyetsel’de $badgeCount rozet kazandım 🏆',
        statLabel: 'Rozet',
        statValue: '$badgeCount',
      ),
    ];
  }

  static String _moodTitle(int mood) => switch (mood) {
        1 => 'Zor bir hafta',
        2 => 'Eh işte',
        3 => 'Dengede',
        4 => 'İyi hissediyorum',
        _ => 'Harika bir hafta',
      };

  static String howItWorks(int step) => switch (step) {
        1 => 'Seri, su, ilerleme, ruh hali, diyet veya rozet şablonunu seç.',
        2 => 'Rakamlar senin verinden gelir; başlığı ve alt yazıyı önizle.',
        3 => 'Paylaşım metnini seç, PNG olarak hikâyene veya sohbete gönder.',
        _ => '',
      };
}
