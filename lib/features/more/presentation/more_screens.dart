import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import 'soft_more_screen.dart';

class _MoreItem {
  const _MoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.section,
    this.tint = AppColors.kawaiiMint,
    this.accent = AppColors.kawaiiLeafDeep,
    this.toggleWater = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String route;
  final String section;
  final Color tint;
  final Color accent;
  final bool toggleWater;
}

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key, required this.admin});

  final bool admin;

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String _query = '';

  List<_MoreItem> _catalog(UserProfile user, AppStore store) {
    if (widget.admin) {
      return const [
        _MoreItem(
          icon: Icons.edit_note_rounded,
          title: 'Blog editörü',
          subtitle: 'Yazı ekle, düzenle, yayınla',
          route: '/admin/blog',
          section: 'İçerik',
          tint: AppColors.kawaiiLilac,
          accent: AppColors.kawaiiPurple,
        ),
        _MoreItem(
          icon: Icons.medical_services_rounded,
          title: 'Hizmetler',
          subtitle: 'Paketler ve talepler',
          route: '/admin/services',
          section: 'İçerik',
          tint: AppColors.kawaiiPeach,
          accent: AppColors.kawaiiCoralDeep,
        ),
        _MoreItem(
          icon: Icons.menu_book_rounded,
          title: 'Tarifler',
          subtitle: 'Danışanlara özel tarifler',
          route: '/admin/recipes',
          section: 'İçerik',
          tint: AppColors.kawaiiMint,
          accent: AppColors.kawaiiLeafDeep,
        ),
        _MoreItem(
          icon: Icons.restaurant_rounded,
          title: 'Diyet planları',
          subtitle: 'Plan oluştur ve ata',
          route: '/admin/diet-plans',
          section: 'Klinik',
          tint: AppColors.kawaiiLemon,
          accent: AppColors.kawaiiSalmon,
        ),
        _MoreItem(
          icon: Icons.photo_camera_rounded,
          title: 'Öğün günlüğü',
          subtitle: 'Gelen öğün fotoğrafları',
          route: '/admin/meals',
          section: 'Klinik',
          tint: AppColors.kawaiiSky,
          accent: AppColors.kawaiiSkyBlue,
        ),
        _MoreItem(
          icon: Icons.notifications_active_rounded,
          title: 'Bildirimler',
          subtitle: 'Danışanlara özel bildirim gönder',
          route: '/admin/notifications',
          section: 'Klinik',
          tint: AppColors.kawaiiPeach,
          accent: AppColors.kawaiiCoralDeep,
        ),
        _MoreItem(
          icon: Icons.palette_outlined,
          title: 'Ana sayfa düzeni',
          subtitle: 'Bölümleri göster/gizle, slider, tema',
          route: '/admin/home-theme',
          section: 'Sistem',
          tint: AppColors.kawaiiRose,
          accent: AppColors.kawaiiCoralDeep,
        ),
        _MoreItem(
          icon: Icons.settings_rounded,
          title: 'Ayarlar',
          subtitle: 'Tema, bildirim, hesap',
          route: '/admin/settings',
          section: 'Sistem',
          tint: AppColors.kawaiiSurfaceCream,
          accent: AppColors.kawaiiMuted,
        ),
      ];
    }

    final all = <_MoreItem>[
      const _MoreItem(
        icon: Icons.article_rounded,
        title: 'Blog',
        subtitle: 'Beslenme yazıları ve ipuçları',
        route: '/app/blog',
        section: 'Keşfet',
        tint: AppColors.kawaiiLilac,
        accent: AppColors.kawaiiPurple,
      ),
      const _MoreItem(
        icon: Icons.storefront_rounded,
        title: 'Hizmetler',
        subtitle: 'Online / klinik paketler',
        route: '/app/services',
        section: 'Keşfet',
        tint: AppColors.kawaiiPeach,
        accent: AppColors.kawaiiCoralDeep,
      ),
      const _MoreItem(
        icon: Icons.menu_book_rounded,
        title: 'Tarifler',
        subtitle: 'Ölçülü, adım adım yemekler',
        route: '/app/recipes',
        section: 'Keşfet',
        tint: AppColors.kawaiiMint,
        accent: AppColors.kawaiiLeafDeep,
      ),
      const _MoreItem(
        icon: Icons.restaurant_menu_rounded,
        title: 'Dışarıda ne yesem?',
        subtitle: 'Restoran seçenekleri ve swap’ler',
        route: '/app/eat-out',
        section: 'Keşfet',
        tint: AppColors.kawaiiLemon,
        accent: AppColors.kawaiiSalmon,
      ),
      const _MoreItem(
        icon: Icons.chat_bubble_rounded,
        title: 'Sohbet',
        subtitle: 'Diyetisyeninle mesajlaş',
        route: '/app/chat',
        section: 'Destek',
        tint: AppColors.kawaiiSky,
        accent: AppColors.kawaiiSkyBlue,
      ),
      const _MoreItem(
        icon: Icons.favorite_rounded,
        title: 'Check-in',
        subtitle: 'Haftalık kilo, bel, ruh hali',
        route: '/app/check-in',
        section: 'Takip',
        tint: AppColors.kawaiiRose,
        accent: AppColors.kawaiiCoralDeep,
      ),
      const _MoreItem(
        icon: Icons.insights_rounded,
        title: 'Raporlar',
        subtitle: 'Haftalık / aylık skor ve PDF',
        route: '/app/reports',
        section: 'Takip',
        tint: AppColors.kawaiiLilac,
        accent: AppColors.kawaiiPurple,
      ),
      const _MoreItem(
        icon: Icons.shopping_cart_rounded,
        title: 'Alışveriş listesi',
        subtitle: 'Reyon ipuçlarıyla market listesi',
        route: '/app/shopping',
        section: 'Plan',
        tint: AppColors.kawaiiMint,
        accent: AppColors.kawaiiLeafDeep,
      ),
      const _MoreItem(
        icon: Icons.folder_special_rounded,
        title: 'Belge kasası',
        subtitle: 'Lab, plan ve form PDF’leri',
        route: '/app/documents',
        section: 'Plan',
        tint: AppColors.kawaiiSky,
        accent: AppColors.kawaiiSkyBlue,
      ),
      const _MoreItem(
        icon: Icons.school_rounded,
        title: 'Mini dersler',
        subtitle: 'Kısa eğitim serileri',
        route: '/app/learn',
        section: 'Gelişim',
        tint: AppColors.kawaiiLemon,
        accent: AppColors.kawaiiSalmon,
      ),
      const _MoreItem(
        icon: Icons.emoji_events_rounded,
        title: 'Rozetler',
        subtitle: 'Kazanılan başarılar',
        route: '/app/badges',
        section: 'Gelişim',
        tint: AppColors.kawaiiPeach,
        accent: AppColors.kawaiiCoralDeep,
      ),
      const _MoreItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Hikaye kartı',
        subtitle: 'Paylaşılabilir ilerleme PNG’si',
        route: '/app/story',
        section: 'Gelişim',
        tint: AppColors.kawaiiLilac,
        accent: AppColors.kawaiiPurple,
      ),
      const _MoreItem(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Barkod',
        subtitle: 'Ürün etiketi tara',
        route: '/app/barcode',
        section: 'Araçlar',
        tint: AppColors.kawaiiMint,
        accent: AppColors.kawaiiLeafDeep,
      ),
      const _MoreItem(
        icon: Icons.hourglass_bottom_rounded,
        title: 'Aralıklı oruç',
        subtitle: '16:8 penceresi ve fazlar',
        route: '/app/fasting',
        section: 'Araçlar',
        tint: AppColors.kawaiiSky,
        accent: AppColors.kawaiiSkyBlue,
      ),
      const _MoreItem(
        icon: Icons.water_drop_rounded,
        title: 'Su kısayolu',
        subtitle: 'Kalıcı su bildirimi aç/kapa',
        route: '/app/water-shortcut',
        section: 'Araçlar',
        tint: AppColors.kawaiiSky,
        accent: AppColors.kawaiiSkyBlue,
        toggleWater: true,
      ),
      const _MoreItem(
        icon: Icons.settings_rounded,
        title: 'Ayarlar',
        subtitle: 'Tema, bildirim, hesap',
        route: '/app/settings',
        section: 'Hesap',
        tint: AppColors.kawaiiSurfaceCream,
        accent: AppColors.kawaiiMuted,
      ),
    ];

    return all.where((item) {
      if (item.toggleWater) return store.moduleOn(user.id, AppModule.water);
      if (item.route == '/app/reports' || item.route == '/app/settings' || item.route == '/app/badges' || item.route == '/app/learn') {
        return true;
      }
      final id = AppModule.fromRoute(item.route);
      return id == null || store.moduleOn(user.id, id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftMoreScreen(admin: widget.admin);
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(settingsProvider);
    ref.watch(usersProvider);
    ref.watch(waterLogsProvider);
    ref.watch(streaksProvider);
    ref.watch(checkInsProvider);

    final items = _catalog(user, store);
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items
            .where((e) => '${e.title} ${e.subtitle} ${e.section}'.toLowerCase().contains(q))
            .toList();

    final sections = <String>[];
    for (final e in filtered) {
      if (!sections.contains(e.section)) sections.add(e.section);
    }

    final cartoon = context.isCartoon;
    final waterOn = store.prefs(user.id).waterShortcut;

    if (cartoon) {
      final weekly = widget.admin ? null : buildPeriodReport(store: store, user: user, period: ReportPeriod.weekly);
      final streak = widget.admin ? null : store.streak(user.id);
      final checkIns = widget.admin ? 0 : store.checkIns(userId: user.id).length;

      return AppPage(
        title: 'Daha fazla',
        padding: EdgeInsets.zero,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _MoreHero(admin: widget.admin, name: user.displayName, count: items.length)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              if (!widget.admin && weekly != null && streak != null) ...[
                _QuickStats(
                  score: weekly.wellnessScore,
                  streak: streak.current,
                  checkIns: checkIns,
                ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
                const SizedBox(height: 14),
              ],
              _SearchField(
                onChanged: (v) => setState(() => _query = v),
              ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(
                    'Aramanla eşleşen araç yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                )
              else
                for (var s = 0; s < sections.length; s++) ...[
                  _SectionTitle(title: sections[s])
                      .animate()
                      .fadeIn(delay: (70 + 20 * s).ms, duration: 240.ms),
                  const SizedBox(height: 8),
                  ...filtered.where((e) => e.section == sections[s]).toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MoreTile(
                        item: item,
                        waterOn: waterOn,
                        onTap: () => _open(context, store, user, item),
                      )
                          .animate()
                          .fadeIn(delay: (80 + 25 * i + 30 * s).ms, duration: 260.ms)
                          .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                    );
                  }),
                  const SizedBox(height: 6),
                ],
              _FooterTip(admin: widget.admin).animate().fadeIn(delay: 160.ms, duration: 280.ms),
            ],
          ),
        ),
      );
    }

    return SoftMoreScreen(admin: widget.admin);
  }

  Future<void> _open(BuildContext context, AppStore store, UserProfile user, _MoreItem item) async {
    if (item.toggleWater) {
      final prefs = store.prefs(user.id);
      final next = !prefs.waterShortcut;
      await store.savePrefs(user.id, prefs.copyWith(waterShortcut: next));
      if (next) {
        await ReminderService.instance.showWaterShortcut();
      } else {
        await ReminderService.instance.hideWaterShortcut();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            next
                ? (ReminderService.instance.supportsNative
                    ? 'Kalıcı su bildirimi açıldı'
                    : 'Android’de kalıcı bildirim olur. Windows’ta widget yok.')
                : 'Su kısayolu kapatıldı',
          ),
        ),
      );
      setState(() {});
      return;
    }
    context.push(item.route);
  }
}

class _MoreHero extends StatelessWidget {
  const _MoreHero({required this.admin, required this.name, required this.count});

  final bool admin;
  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiLilac, AppColors.kawaiiSurfaceCream, AppColors.kawaiiMint],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
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
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    admin ? 'Klinik merkezi' : 'Araç kutusu',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  admin ? 'Merhaba, $name' : 'Merhaba $name',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1.15, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 6),
                Text(
                  admin
                      ? '$count yönetim aracı — içerik, plan ve sistem.'
                      : '$count kısayol · ara, grupla, tek dokunuşla aç.',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(
            admin ? DiyetselAssets.characterWoman : DiyetselAssets.mascotAvocado,
            height: 88,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.score, required this.streak, required this.checkIns});

  final int score;
  final int streak;
  final int checkIns;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.insights_rounded, AppColors.kawaiiMint, AppColors.kawaiiLeafDeep, 'Skor', '$score'),
      (Icons.local_fire_department_rounded, AppColors.kawaiiPeach, AppColors.kawaiiCoralDeep, 'Seri', '$streak'),
      (Icons.favorite_rounded, AppColors.kawaiiRose, AppColors.kawaiiCoralDeep, 'Check-in', '$checkIns'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: () {
                if (i == 0) context.push('/app/reports');
                if (i == 2) context.push('/app/check-in');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.kawaiiOutline),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(color: items[i].$2, borderRadius: BorderRadius.circular(10)),
                      child: Icon(items[i].$1, size: 16, color: items[i].$3),
                    ),
                    const SizedBox(height: 8),
                    Text(items[i].$4, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
                    Text(items[i].$5, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.kawaiiInk)),
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Blog, rapor, tarif… ara',
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.kawaiiLeafDeep),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.kawaiiInk),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.item,
    required this.waterOn,
    required this.onTap,
  });

  final _MoreItem item;
  final bool waterOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: item.tint, borderRadius: BorderRadius.circular(14)),
              child: Icon(item.icon, color: item.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk)),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                  ),
                ],
              ),
            ),
            if (item.toggleWater)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: waterOn ? AppColors.kawaiiMint : AppColors.kawaiiSurfaceCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: Text(
                  waterOn ? 'Açık' : 'Kapalı',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: waterOn ? AppColors.kawaiiLeafDeep : AppColors.kawaiiMuted,
                  ),
                ),
              )
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.kawaiiMuted),
          ],
        ),
      ),
    );
  }
}

class _FooterTip extends StatelessWidget {
  const _FooterTip({required this.admin});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: AppColors.kawaiiLeafDeep),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              admin
                  ? 'Danışanlara özel modülleri Ayarlar’dan açıp kapatabilirsin.'
                  : 'Ana sekmelere sığmayan her şey burada. Sık kullandıklarını ara ile hızlı bul.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
            ),
          ),
        ],
      ),
    );
  }
}
