import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/models.dart';
import '../../../../core/utils/desktop.dart';
import '../../../dashboard/domain/home_feed_models.dart';
import 'premium_home_widgets.dart' show SoftTap, DiyetselLogoMark;
import 'soft_home_widgets.dart' show SoftModernIcon, SoftShortcutRail;

class _SoftAdminSectionTitle extends StatelessWidget {
  const _SoftAdminSectionTitle({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDeep,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftAdminHomeHeader extends StatelessWidget {
  const SoftAdminHomeHeader({
    super.key,
    required this.name,
    this.onPdf,
  });

  final String name;
  final VoidCallback? onPdf;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DiyetselLogoMark(height: 32),
              const SizedBox(height: 12),
              const Text(
                'Klinik paneli',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Merhaba $name — randevu, içerik ve danışanlar',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.55),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SoftTap(
          onTap: onPdf,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Icon(
              Icons.picture_as_pdf_outlined,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SoftTap(
          onTap: () => context.push('/admin/settings'),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            padding: const EdgeInsets.all(8),
            child: const SoftModernIcon(
              DiyetselAssets.modernIconAppsAll,
              size: 24,
              fallback: Icons.settings_rounded,
              fallbackColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class SoftAdminHomeHero extends StatelessWidget {
  const SoftAdminHomeHero({
    super.key,
    required this.active,
    required this.total,
    required this.pendingAppts,
    required this.monthSessions,
  });

  final int active;
  final int total;
  final int pendingAppts;
  final int monthSessions;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push('/admin/clients'),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
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
                    child: const Text(
                      'Bugünün özeti',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$active aktif danışan',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: AppColors.primaryDeep,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toplam $total · $pendingAppts bekleyen randevu · bu ay $monthSessions seans',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primary.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
            const SoftModernIcon(
              DiyetselAssets.modernCardClinic,
              size: 64,
              fallback: Icons.groups_rounded,
              fallbackColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class SoftAdminHomeKpis extends StatelessWidget {
  const SoftAdminHomeKpis({
    super.key,
    required this.activeLabel,
    required this.sessions,
    required this.paid,
    required this.due,
  });

  final String activeLabel;
  final String sessions;
  final String paid;
  final String due;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Aktif',
        activeLabel,
        DiyetselAssets.modernIconCheck,
        Icons.favorite_rounded,
        AppColors.primary,
        () => context.push('/admin/clients'),
      ),
      (
        'Seans',
        sessions,
        DiyetselAssets.modernIconCalendar,
        Icons.event_available_rounded,
        const Color(0xFF5BA3C9),
        () => context.push('/admin/appointments'),
      ),
      (
        'Tahsilat',
        paid,
        DiyetselAssets.modernIconPlan,
        Icons.payments_rounded,
        const Color(0xFF2F6B4F),
        null,
      ),
      (
        'Bekleyen',
        due,
        DiyetselAssets.modernIconBell,
        Icons.account_balance_wallet_rounded,
        const Color(0xFFE07A5F),
        null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.isDesktopLayout ? 4 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: context.isDesktopLayout ? 1.85 : 1.55,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        return SoftTap(
          onTap: item.$6,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftModernIcon(
                  item.$3,
                  size: 26,
                  fallback: item.$4,
                  fallbackColor: item.$5,
                ),
                const Spacer(),
                Text(
                  item.$1,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<HomeShortcutModel> softAdminShortcuts() => const [
      HomeShortcutModel(
        id: 'clients',
        title: 'Danışan',
        route: '/admin/clients',
        accent: Color(0xFFE8F5F0),
        iconAsset: DiyetselAssets.modernIconCheck,
        icon: Icons.groups_rounded,
      ),
      HomeShortcutModel(
        id: 'calendar',
        title: 'Takvim',
        route: '/admin/appointments',
        accent: Color(0xFFE3F2F8),
        iconAsset: DiyetselAssets.modernIconCalendar,
        icon: Icons.event_rounded,
      ),
      HomeShortcutModel(
        id: 'notif',
        title: 'Bildirim',
        route: '/admin/notifications',
        accent: Color(0xFFFFF0E8),
        iconAsset: DiyetselAssets.modernIconBell,
        icon: Icons.notifications_active_rounded,
      ),
      HomeShortcutModel(
        id: 'meals',
        title: 'Öğün',
        route: '/admin/meals',
        accent: Color(0xFFFFF8E8),
        iconAsset: DiyetselAssets.modernIconDietScale,
        icon: Icons.photo_camera_rounded,
      ),
      HomeShortcutModel(
        id: 'diet',
        title: 'Diyet',
        route: '/admin/diet-plans',
        accent: Color(0xFFE8F5F0),
        iconAsset: DiyetselAssets.modernIconPlan,
        icon: Icons.restaurant_rounded,
      ),
      HomeShortcutModel(
        id: 'chat',
        title: 'Sohbet',
        route: '/admin/chat',
        accent: Color(0xFFE3F2F8),
        iconAsset: DiyetselAssets.modernIconService,
        icon: Icons.chat_rounded,
      ),
      HomeShortcutModel(
        id: 'blog',
        title: 'Blog',
        route: '/admin/blog',
        accent: Color(0xFFFFF0E8),
        iconAsset: DiyetselAssets.modernIconStory,
        icon: Icons.article_rounded,
      ),
      HomeShortcutModel(
        id: 'home',
        title: 'Ana sayfa',
        route: '/admin/home-theme',
        accent: Color(0xFFEDE8F8),
        iconAsset: DiyetselAssets.modernIconAppsAll,
        icon: Icons.dashboard_customize_rounded,
      ),
      HomeShortcutModel(
        id: 'more',
        title: 'Araçlar',
        route: '/admin/more',
        accent: Color(0xFFE8F5F0),
        iconAsset: DiyetselAssets.modernIconAppsAll,
        icon: Icons.apps_rounded,
      ),
    ];

class SoftAdminHomeShortcuts extends StatelessWidget {
  const SoftAdminHomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final items = softAdminShortcuts();
    final desktop = context.isDesktopLayout;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SoftAdminSectionTitle(title: 'Hızlı işlemler', subtitle: 'Klinik günlük akış'),
        const SizedBox(height: 10),
        if (!desktop)
          SoftShortcutRail(items: items)
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in items)
                SoftTap(
                  onTap: () => context.push(item.route),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 118,
                    padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.modernLine),
                      boxShadow: AppSpacing.soft,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.accent,
                            boxShadow: AppSpacing.soft,
                          ),
                          alignment: Alignment.center,
                          child: SoftModernIcon(
                            item.iconAsset,
                            size: 26,
                            fallback: item.icon,
                            fallbackColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class SoftAdminHomeQuietCard extends StatelessWidget {
  const SoftAdminHomeQuietCard({super.key, required this.quiet});

  final List<UserProfile> quiet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SoftAdminSectionTitle(
                  title: '3 gündür sessiz',
                  subtitle: 'Aktivite gelmeyen danışanlar',
                ),
              ),
              SoftTap(
                onTap: () => context.push('/admin/clients'),
                borderRadius: BorderRadius.circular(12),
                child: Text(
                  'Tümü',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (quiet.isEmpty)
            Text(
              'Herkes aktif görünüyor.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            )
          else
            for (final c in quiet.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SoftTap(
                  onTap: () => context.push('/admin/clients'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.modernWash,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: const Color(0xFFFFF0E8),
                          child: Text(
                            c.displayName.isNotEmpty ? c.displayName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFE07A5F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDeep,
                                ),
                              ),
                              Text(
                                c.lastActiveAt == null
                                    ? 'Hiç aktivite yok'
                                    : 'Son: ${DateFormat('d MMM HH:mm', 'tr').format(c.lastActiveAt!)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.primary.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'sessiz',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                              color: Color(0xFFC45A3C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class SoftAdminHomePaymentsCard extends StatelessWidget {
  const SoftAdminHomePaymentsCard({
    super.key,
    required this.payments,
    required this.onAdd,
  });

  final List<PaymentRecord> payments;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SoftAdminSectionTitle(
                  title: 'Son bakiyeler',
                  subtitle: 'Tahsilat ve bekleyen tutarlar',
                ),
              ),
              SoftTap(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Kayıt ekle',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (payments.isEmpty)
            Text(
              'Henüz ödeme kaydı yok.',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            )
          else
            for (final p in payments.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.clientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                          Text(
                            DateFormat('d MMM y', 'tr').format(p.date),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₺${p.amount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.status == PaymentStatus.paid
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : const Color(0xFFE07A5F).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        p.status == PaymentStatus.paid ? 'ödendi' : 'bekliyor',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          color: p.status == PaymentStatus.paid
                              ? AppColors.primary
                              : const Color(0xFFC45A3C),
                        ),
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

class SoftAdminHomeTip extends StatelessWidget {
  const SoftAdminHomeTip({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push('/admin/notifications'),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            const SoftModernIcon(
              DiyetselAssets.modernIconBell,
              size: 28,
              fallback: Icons.campaign_rounded,
              fallbackColor: Color(0xFFE07A5F),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Özel bildirim gönder — tüm danışanlara veya seçtiklerine anlık mesaj bırak.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.primary.withValues(alpha: 0.65),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ],
        ),
      ),
    );
  }
}
