import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;

class SoftMoreItem {
  const SoftMoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.section,
    this.asset,
    this.tint = const Color(0xFFE8F5F0),
    this.accent = AppColors.primary,
    this.toggleWater = false,
    this.featured = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final String section;
  final String? asset;
  final Color tint;
  final Color accent;
  final bool toggleWater;
  final bool featured;
}

class SoftMoreHeader extends StatelessWidget {
  const SoftMoreHeader({
    super.key,
    required this.admin,
    required this.name,
  });

  final bool admin;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin ? 'Klinik araçları' : 'Daha fazla',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                admin
                    ? 'Merhaba $name — klinik operasyon merkezi'
                    : 'Merhaba $name — keşfet, takip et, geliş',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconAppsAll,
            size: 32,
            fallback: Icons.apps_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftMoreHero extends StatelessWidget {
  const SoftMoreHero({
    super.key,
    required this.admin,
    required this.count,
  });

  final bool admin;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    admin ? 'Yönetim merkezi' : 'Araç kutusu',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  admin
                      ? '$count klinik aracı tek yerde'
                      : '$count kısayol · ara ve aç',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.2,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  admin
                      ? 'Bildirim, öğün, diyet planı ve blog araçları.'
                      : 'Blog, sohbet, rapor ve günlük araçlar.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SoftModernIcon(
            admin ? DiyetselAssets.modernIconService : DiyetselAssets.modernIconAppsAll,
            size: 72,
            fallback: Icons.grid_view_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftMoreQuickStats extends StatelessWidget {
  const SoftMoreQuickStats({
    super.key,
    required this.score,
    required this.streak,
    required this.checkIns,
  });

  final int score;
  final int streak;
  final int checkIns;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Skor',
        '$score',
        DiyetselAssets.modernIconCheck,
        Icons.insights_rounded,
        AppColors.primary,
        () => context.push('/app/reports'),
      ),
      (
        'Seri',
        '$streak',
        DiyetselAssets.modernIconStreak,
        Icons.local_fire_department_rounded,
        const Color(0xFFE07A5F),
        null,
      ),
      (
        'Check-in',
        '$checkIns',
        DiyetselAssets.modernIconDietScale,
        Icons.favorite_rounded,
        const Color(0xFF5BA3C9),
        () => context.push('/app/check-in'),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: items[i].$6,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftModernIcon(
                      items[i].$3,
                      size: 26,
                      fallback: items[i].$4,
                      fallbackColor: items[i].$5,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: items[i].$5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftMoreAdminQuickStats extends StatelessWidget {
  const SoftMoreAdminQuickStats({
    super.key,
    required this.activeClients,
    required this.pendingAppts,
    required this.broadcasts,
  });

  final int activeClients;
  final int pendingAppts;
  final int broadcasts;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Aktif',
        '$activeClients',
        DiyetselAssets.modernIconCheck,
        Icons.groups_rounded,
        AppColors.primary,
        () => context.push('/admin/clients'),
      ),
      (
        'Bekleyen',
        '$pendingAppts',
        DiyetselAssets.modernIconCalendar,
        Icons.event_available_rounded,
        const Color(0xFF5BA3C9),
        () => context.push('/admin/appointments'),
      ),
      (
        'Bildirim',
        '$broadcasts',
        DiyetselAssets.modernIconBell,
        Icons.notifications_active_rounded,
        const Color(0xFFE07A5F),
        () => context.push('/admin/notifications'),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: items[i].$6,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SoftModernIcon(
                      items[i].$3,
                      size: 22,
                      fallback: items[i].$4,
                      fallbackColor: items[i].$5,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      items[i].$1,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      items[i].$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftMoreFeaturedRail extends StatelessWidget {
  const SoftMoreFeaturedRail({
    super.key,
    required this.items,
    required this.onOpen,
  });

  final List<SoftMoreItem> items;
  final ValueChanged<SoftMoreItem> onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sık kullanılanlar',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
            color: AppColors.primaryDeep,
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
              return SoftTap(
                onTap: () => onOpen(item),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 118,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: item.accent.withValues(alpha: 0.22)),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.tint,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: item.asset != null
                            ? SoftModernIcon(
                                item.asset!,
                                size: 24,
                                fallback: item.icon,
                                fallbackColor: item.accent,
                              )
                            : Icon(item.icon, color: item.accent, size: 22),
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          height: 1.2,
                          color: AppColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (40 * i).ms, duration: 260.ms);
            },
          ),
        ),
      ],
    );
  }
}

class SoftMoreSearchField extends StatelessWidget {
  const SoftMoreSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDeep,
        ),
        decoration: InputDecoration(
          hintText: 'Blog, rapor, tarif… ara',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 10, right: 6),
            child: SoftModernIcon(
              DiyetselAssets.modernIconSearch,
              size: 22,
              fallback: Icons.search_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}

class SoftMoreSectionTitle extends StatelessWidget {
  const SoftMoreSectionTitle({super.key, required this.title, this.count});

  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
            color: AppColors.primaryDeep,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftMoreTile extends StatelessWidget {
  const SoftMoreTile({
    super.key,
    required this.item,
    required this.waterOn,
    required this.onTap,
  });

  final SoftMoreItem item;
  final bool waterOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.tint,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: item.asset != null
                  ? SoftModernIcon(
                      item.asset!,
                      size: 28,
                      fallback: item.icon,
                      fallbackColor: item.accent,
                    )
                  : Icon(item.icon, color: item.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            if (item.route == '/app/water-shortcut')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: waterOn
                      ? const Color(0xFFE3F2F8)
                      : AppColors.modernWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: waterOn
                        ? const Color(0xFFB8DCEC)
                        : AppColors.modernLine,
                  ),
                ),
                child: Text(
                  waterOn ? 'Açık' : 'Kapalı',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: waterOn
                        ? const Color(0xFF5BA3C9)
                        : AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary.withValues(alpha: 0.35),
              ),
          ],
        ),
      ),
    );
  }
}

class SoftMoreSpotlight extends StatelessWidget {
  const SoftMoreSpotlight({
    super.key,
    required this.admin,
    required this.onTap,
  });

  final bool admin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: admin
                ? const [Color(0xFFFFF0E8), Color(0xFFFFF6E9)]
                : const [Color(0xFFFFF0E8), Color(0xFFFFF6E9)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE07A5F).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            SoftModernIcon(
              admin
                  ? DiyetselAssets.modernIconBell
                  : DiyetselAssets.modernIconStory,
              size: 44,
              fallback: admin ? Icons.notifications_active_rounded : Icons.auto_awesome_rounded,
              fallbackColor: const Color(0xFFE07A5F),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin ? 'Özel bildirim gönder' : 'Hikaye kartı',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    admin
                        ? 'Danışanlara anlık mesaj bırak — tümü veya seçili'
                        : 'İlerlemeyi paylaşılabilir PNG olarak çıkar',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      height: 1.3,
                      color: AppColors.primaryDeep.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              color: const Color(0xFFE07A5F),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftMoreFooterTip extends StatelessWidget {
  const SoftMoreFooterTip({super.key, required this.admin});

  final bool admin;

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
            fallback: Icons.tips_and_updates_outlined,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              admin
                  ? 'Bildirimler sekmesinden özel mesaj gönder; öğün inbox’tan hızlı not bırak.'
                  : 'Ana sekmelere sığmayan her şey burada. Sık kullandıklarını ara ile hızlı bul.',
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

class SoftMoreEmpty extends StatelessWidget {
  const SoftMoreEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconSearch,
            size: 48,
            fallback: Icons.search_off_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aramanla eşleşen araç yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Başka bir kelime dene veya bölümleri kaydır.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
