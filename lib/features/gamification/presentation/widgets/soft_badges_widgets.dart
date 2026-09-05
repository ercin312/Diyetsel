import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/achievements.dart';
import '../../../../core/utils/achievement_logic.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/badge_visuals.dart';
import '../../../../core/widgets/nav_back.dart';


class SoftBadgesHeader extends StatelessWidget {
  const SoftBadgesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rozetler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Hedefler & başarılar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconStory,
            size: 28,
            fallback: Icons.emoji_events_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftBadgesHero extends StatelessWidget {
  const SoftBadgesHero({
    super.key,
    required this.earned,
    required this.total,
    required this.tip,
  });

  final int earned;
  final int total;
  final String tip;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : earned / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E8), Color(0xFFFFF6E9), Color(0xFFE8F5F0)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    color: const Color(0xFFD4A017),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$earned',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: AppColors.primaryDeep,
                        height: 1,
                      ),
                    ),
                    Text(
                      '/ $total',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Koleksiyon',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: Color(0xFFD4A017),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  earned == 0
                      ? 'İlk rozetin seni bekliyor'
                      : earned == total
                          ? 'Tüm rozetler senin!'
                          : '$earned rozet kazandın',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SoftBadgesStatsRow extends StatelessWidget {
  const SoftBadgesStatsRow({
    super.key,
    required this.earned,
    required this.inProgress,
    required this.remaining,
    required this.bestPct,
  });

  final int earned;
  final int inProgress;
  final int remaining;
  final int bestPct;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.emoji_events_rounded, DiyetselAssets.modernIconStory, const Color(0xFFD4A017), 'Kazanılan', '$earned'),
      (Icons.trending_up_rounded, DiyetselAssets.modernIconStreak, const Color(0xFFE07A5F), 'Devam', '$inProgress'),
      (Icons.lock_outline_rounded, DiyetselAssets.modernIconPlan, const Color(0xFF5BA3C9), 'Kalan', '$remaining'),
      (Icons.speed_rounded, DiyetselAssets.modernIconCheck, AppColors.primary, 'En yakın', '%$bestPct'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                children: [
                  SoftModernIcon(
                    items[i].$2,
                    size: 22,
                    fallback: items[i].$1,
                    fallbackColor: items[i].$3,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$5,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: items[i].$3,
                    ),
                  ),
                  Text(
                    items[i].$4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftBadgesFilterChips extends StatelessWidget {
  const SoftBadgesFilterChips({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  final String filter;
  final ValueChanged<String> onChanged;

  static const options = ['Tümü', 'Kazanılan', 'Devam eden'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: () => onChanged(options[i]),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: filter == options[i] ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: filter == options[i]
                        ? AppColors.primary
                        : AppColors.modernLine,
                  ),
                  boxShadow: filter == options[i]
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.28),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : AppSpacing.soft,
                ),
                child: Text(
                  options[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: filter == options[i] ? Colors.white : AppColors.primaryDeep,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftNextBadgeCard extends StatelessWidget {
  const SoftNextBadgeCard({
    super.key,
    required this.item,
    required this.onOpen,
  });

  final BadgeProgress item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final b = item.badge;
    final accent = BadgeVisuals.softAccentFor(b);
    final tint = BadgeVisuals.softTintFor(b);
    final left = (b.target - item.current).clamp(0, b.target);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tint, Colors.white],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Sıradaki hedef',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: accent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '%${(item.ratio * 100).round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                SoftBadgeIcon(badge: b, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.subtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.35,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        left == 0 ? 'Tamamlanmaya hazır!' : '$left adım kaldı · ${item.current}/${b.target}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: item.ratio,
                minHeight: 10,
                backgroundColor: Colors.white.withValues(alpha: 0.85),
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftBadgeIcon extends StatelessWidget {
  const SoftBadgeIcon({
    super.key,
    required this.badge,
    this.size = 48,
    this.earned = false,
  });

  final BadgeDef badge;
  final double size;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final accent = BadgeVisuals.softAccentFor(badge);
    final tint = BadgeVisuals.softTintFor(badge);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: earned ? accent.withValues(alpha: 0.18) : tint,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: earned ? accent.withValues(alpha: 0.45) : AppColors.modernLine,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: SoftModernIcon(
        BadgeVisuals.softAssetFor(badge),
        size: size * 0.52,
        fallback: BadgeVisuals.softIconFor(badge),
        fallbackColor: accent,
      ),
    );
  }
}

class SoftEarnedStrip extends StatelessWidget {
  const SoftEarnedStrip({
    super.key,
    required this.items,
    required this.onOpen,
  });

  final List<BadgeProgress> items;
  final ValueChanged<BadgeProgress> onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Koleksiyonun',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kazandığın rozetler',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = items[i];
              final accent = BadgeVisuals.softAccentFor(item.badge);
              return SoftTap(
                onTap: () => onOpen(item),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 96,
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Column(
                    children: [
                      SoftBadgeIcon(badge: item.badge, size: 44, earned: true),
                      const SizedBox(height: 8),
                      Text(
                        item.badge.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          height: 1.2,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class SoftBadgeCard extends StatelessWidget {
  const SoftBadgeCard({
    super.key,
    required this.item,
    required this.onOpen,
  });

  final BadgeProgress item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final b = item.badge;
    final accent = BadgeVisuals.softAccentFor(b);
    final tint = BadgeVisuals.softTintFor(b);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.earned ? accent.withValues(alpha: 0.4) : AppColors.modernLine,
            width: item.earned ? 1.4 : 1,
          ),
          boxShadow: AppSpacing.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SoftBadgeIcon(badge: b, size: 52, earned: item.earned),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.primaryDeep,
                              ),
                            ),
                          ),
                          if (item.earned)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Kazanıldı',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: accent,
                                ),
                              ),
                            )
                          else
                            Text(
                              '${item.current}/${b.target}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: accent,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.subtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    BadgeVisuals.categoryFor(b),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: accent,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '%${(item.ratio * 100).round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: item.ratio,
                minHeight: 8,
                backgroundColor: tint,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftBadgeDetailSheet extends StatelessWidget {
  const SoftBadgeDetailSheet({super.key, required this.item});

  final BadgeProgress item;

  @override
  Widget build(BuildContext context) {
    final b = item.badge;
    final accent = BadgeVisuals.softAccentFor(b);
    final tint = BadgeVisuals.softTintFor(b);
    final left = (b.target - item.current).clamp(0, b.target);

    return DraggableScrollableSheet(
      initialChildSize: 0.52,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Center(child: SoftBadgeIcon(badge: b, size: 88, earned: item.earned)),
              const SizedBox(height: 16),
              Text(
                b.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                b.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SoftMiniChip(label: BadgeVisuals.categoryFor(b), color: tint, ink: accent),
                  const SizedBox(width: 8),
                  SoftMiniChip(
                    label: item.earned ? 'Kazanıldı' : '${item.current}/${b.target}',
                    color: accent.withValues(alpha: 0.14),
                    ink: accent,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.earned ? 'Hedef tamam' : 'İlerleme',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '%${(item.ratio * 100).round()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: item.ratio,
                        minHeight: 10,
                        backgroundColor: tint,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.earned
                          ? 'Bu rozeti kazandın — koleksiyonuna eklendi.'
                          : left == 0
                              ? 'Hedefe ulaştın; kutlama yakında görünebilir.'
                              : 'Rozeti açmak için $left adım daha.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SoftMiniChip extends StatelessWidget {
  const SoftMiniChip({
    super.key,
    required this.label,
    required this.color,
    required this.ink,
  });

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: ink)),
    );
  }
}

class SoftBadgesFooterTip extends StatelessWidget {
  const SoftBadgesFooterTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.lightbulb_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Su, check-in, öğün fotoğrafı ve mini dersler rozetleri açar. Günlük küçük adımlar yeter.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftBadgesEmptyFilter extends StatelessWidget {
  const SoftBadgesEmptyFilter({super.key, required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Text(
        filter == 'Kazanılan'
            ? 'Henüz rozet kazanmadın — sıradaki hedefe bak.'
            : 'Bu filtrede rozet yok.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class SoftBadgeCelebrationCard extends StatelessWidget {
  const SoftBadgeCelebrationCard({
    super.key,
    required this.badge,
    required this.onClose,
  });

  final BadgeDef badge;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final accent = BadgeVisuals.softAccentFor(badge);
    final tint = BadgeVisuals.softTintFor(badge);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Colors.white, const Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Yeni rozet!',
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SoftBadgeIcon(badge: badge, size: 96, earned: true),
          const SizedBox(height: 16),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primaryDeep,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SoftTap(
            onTap: onClose,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Text(
                'Harika!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}
