import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_more_widgets.dart';

/// Soft premium modern "Daha fazla" hub — richer than the old grid.
class SoftMoreScreen extends ConsumerStatefulWidget {
  const SoftMoreScreen({super.key, required this.admin});

  final bool admin;

  @override
  ConsumerState<SoftMoreScreen> createState() => _SoftMoreScreenState();
}

class _SoftMoreScreenState extends ConsumerState<SoftMoreScreen> {
  String _query = '';

  static const _blue = Color(0xFF5BA3C9);
  static const _coral = Color(0xFFE07A5F);
  static const _mint = Color(0xFFE8F5F0);
  static const _sky = Color(0xFFE3F2F8);
  static const _peach = Color(0xFFFFF0E8);
  static const _lemon = Color(0xFFFFF8E8);

  List<SoftMoreItem> _catalog(UserProfile user, AppStore store) {
    if (widget.admin) {
      return const [
        SoftMoreItem(
          icon: Icons.edit_note_rounded,
          title: 'Blog editörü',
          subtitle: 'Yazı ekle, düzenle, yayınla',
          route: '/admin/blog',
          section: 'İçerik',
          asset: DiyetselAssets.modernIconStory,
          tint: _mint,
          accent: AppColors.primary,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.medical_services_rounded,
          title: 'Hizmetler',
          subtitle: 'Paketler ve talepler',
          route: '/admin/services',
          section: 'İçerik',
          asset: DiyetselAssets.modernIconService,
          tint: _peach,
          accent: _coral,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.menu_book_rounded,
          title: 'Tarifler',
          subtitle: 'Danışanlara özel tarifler',
          route: '/admin/recipes',
          section: 'İçerik',
          asset: DiyetselAssets.modernIconPlan,
          tint: _sky,
          accent: _blue,
        ),
        SoftMoreItem(
          icon: Icons.restaurant_rounded,
          title: 'Diyet planları',
          subtitle: 'Plan oluştur ve ata',
          route: '/admin/diet-plans',
          section: 'Klinik',
          asset: DiyetselAssets.modernIconPlan,
          tint: _lemon,
          accent: AppColors.primary,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.photo_camera_rounded,
          title: 'Öğün günlüğü',
          subtitle: 'Gelen öğün fotoğrafları',
          route: '/admin/meals',
          section: 'Klinik',
          asset: DiyetselAssets.modernIconDietScale,
          tint: _sky,
          accent: _blue,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.notifications_active_rounded,
          title: 'Bildirimler',
          subtitle: 'Danışanlara özel bildirim gönder',
          route: '/admin/notifications',
          section: 'Klinik',
          asset: DiyetselAssets.modernIconBell,
          tint: _peach,
          accent: _coral,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.palette_outlined,
          title: 'Ana sayfa düzeni',
          subtitle: 'Bölümleri göster/gizle, slider, tema',
          route: '/admin/home-theme',
          section: 'Sistem',
          asset: DiyetselAssets.modernIconStory,
          tint: _peach,
          accent: _coral,
          featured: true,
        ),
        SoftMoreItem(
          icon: Icons.settings_rounded,
          title: 'Ayarlar',
          subtitle: 'Tema, bildirim, hesap',
          route: '/admin/settings',
          section: 'Sistem',
          asset: DiyetselAssets.modernIconAppsAll,
          tint: _mint,
          accent: AppColors.primary,
          featured: true,
        ),
      ];
    }

    final all = <SoftMoreItem>[
      const SoftMoreItem(
        icon: Icons.article_rounded,
        title: 'Blog',
        subtitle: 'Beslenme yazıları ve ipuçları',
        route: '/app/blog',
        section: 'Keşfet',
        asset: DiyetselAssets.modernIconStory,
        tint: _mint,
        accent: AppColors.primary,
        featured: true,
      ),
      const SoftMoreItem(
        icon: Icons.storefront_rounded,
        title: 'Hizmetler',
        subtitle: 'Online / klinik paketler',
        route: '/app/services',
        section: 'Keşfet',
        asset: DiyetselAssets.modernIconService,
        tint: _peach,
        accent: _coral,
        featured: true,
      ),
      const SoftMoreItem(
        icon: Icons.menu_book_rounded,
        title: 'Tarifler',
        subtitle: 'Ölçülü, adım adım yemekler',
        route: '/app/recipes',
        section: 'Keşfet',
        asset: DiyetselAssets.modernIconPlan,
        tint: _sky,
        accent: _blue,
      ),
      const SoftMoreItem(
        icon: Icons.restaurant_menu_rounded,
        title: 'Dışarıda ne yesem?',
        subtitle: 'Restoran seçenekleri ve swap’ler',
        route: '/app/eat-out',
        section: 'Keşfet',
        tint: _lemon,
        accent: _coral,
      ),
      const SoftMoreItem(
        icon: Icons.chat_bubble_rounded,
        title: 'Sohbet',
        subtitle: 'Diyetisyeninle mesajlaş',
        route: '/app/chat',
        section: 'Destek',
        asset: DiyetselAssets.modernIconService,
        tint: _sky,
        accent: _blue,
        featured: true,
      ),
      const SoftMoreItem(
        icon: Icons.favorite_rounded,
        title: 'Check-in',
        subtitle: 'Haftalık kilo, bel, ruh hali',
        route: '/app/check-in',
        section: 'Takip',
        asset: DiyetselAssets.modernIconDietScale,
        tint: _peach,
        accent: _coral,
        featured: true,
      ),
      const SoftMoreItem(
        icon: Icons.insights_rounded,
        title: 'Raporlar',
        subtitle: 'Haftalık / aylık skor ve PDF',
        route: '/app/reports',
        section: 'Takip',
        asset: DiyetselAssets.modernIconCheck,
        tint: _mint,
        accent: AppColors.primary,
        featured: true,
      ),
      const SoftMoreItem(
        icon: Icons.shopping_cart_rounded,
        title: 'Alışveriş listesi',
        subtitle: 'Reyon ipuçlarıyla market listesi',
        route: '/app/shopping',
        section: 'Plan',
        asset: DiyetselAssets.modernIconPlan,
        tint: _mint,
        accent: AppColors.primary,
      ),
      const SoftMoreItem(
        icon: Icons.folder_special_rounded,
        title: 'Belge kasası',
        subtitle: 'Lab, plan ve form PDF’leri',
        route: '/app/documents',
        section: 'Plan',
        tint: _sky,
        accent: _blue,
      ),
      const SoftMoreItem(
        icon: Icons.school_rounded,
        title: 'Mini dersler',
        subtitle: 'Kısa eğitim serileri',
        route: '/app/learn',
        section: 'Gelişim',
        asset: DiyetselAssets.modernIconStory,
        tint: _lemon,
        accent: _coral,
      ),
      const SoftMoreItem(
        icon: Icons.emoji_events_rounded,
        title: 'Rozetler',
        subtitle: 'Kazanılan başarılar',
        route: '/app/badges',
        section: 'Gelişim',
        asset: DiyetselAssets.modernIconStreak,
        tint: _peach,
        accent: _coral,
      ),
      const SoftMoreItem(
        icon: Icons.auto_awesome_rounded,
        title: 'Hikaye kartı',
        subtitle: 'Paylaşılabilir ilerleme PNG’si',
        route: '/app/story',
        section: 'Gelişim',
        asset: DiyetselAssets.modernIconStory,
        tint: _mint,
        accent: AppColors.primary,
      ),
      const SoftMoreItem(
        icon: Icons.qr_code_scanner_rounded,
        title: 'Barkod',
        subtitle: 'Ürün etiketi tara',
        route: '/app/barcode',
        section: 'Araçlar',
        asset: DiyetselAssets.modernIconSearch,
        tint: _mint,
        accent: AppColors.primary,
      ),
      const SoftMoreItem(
        icon: Icons.hourglass_bottom_rounded,
        title: 'Aralıklı oruç',
        subtitle: '16:8 penceresi ve fazlar',
        route: '/app/fasting',
        section: 'Araçlar',
        asset: DiyetselAssets.modernIconCalendar,
        tint: _sky,
        accent: _blue,
      ),
      const SoftMoreItem(
        icon: Icons.water_drop_rounded,
        title: 'Su kısayolu',
        subtitle: 'Bildirim, hızlı +250 ml ve ilerleme',
        route: '/app/water-shortcut',
        section: 'Araçlar',
        asset: DiyetselAssets.modernIconWaterDrop,
        tint: _sky,
        accent: _blue,
      ),
      const SoftMoreItem(
        icon: Icons.settings_rounded,
        title: 'Ayarlar',
        subtitle: 'Tema, bildirim, hesap',
        route: '/app/settings',
        section: 'Hesap',
        asset: DiyetselAssets.modernIconAppsAll,
        tint: _mint,
        accent: AppColors.primary,
        featured: true,
      ),
    ];

    return all.where((item) {
      if (item.route == '/app/water-shortcut') return store.moduleOn(user.id, AppModule.water);
      if (item.route == '/app/reports' ||
          item.route == '/app/settings' ||
          item.route == '/app/badges' ||
          item.route == '/app/learn') {
        return true;
      }
      final id = AppModule.fromRoute(item.route);
      return id == null || store.moduleOn(user.id, id);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(settingsProvider);
    ref.watch(usersProvider);
    ref.watch(waterLogsProvider);
    ref.watch(streaksProvider);
    ref.watch(checkInsProvider);
    ref.watch(appointmentsProvider);
    ref.watch(adminBroadcastsProvider);

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

    final waterOn = store.prefs(user.id).waterShortcut;
    final featured = items.where((e) => e.featured).take(5).toList();
    final weekly = widget.admin
        ? null
        : buildPeriodReport(store: store, user: user, period: ReportPeriod.weekly);
    final streak = widget.admin ? null : store.streak(user.id);
    final checkIns = widget.admin ? 0 : store.checkIns(userId: user.id).length;
    final searching = q.isNotEmpty;

    final clients = widget.admin
        ? store.users().where((u) => u.role == UserRole.client).toList()
        : const <UserProfile>[];
    final activeClients = clients.where((c) => c.isActive).length;
    final pendingAppts = widget.admin
        ? store.appointments().where((a) => a.status == AppointmentStatus.pending).length
        : 0;
    final broadcastCount = widget.admin ? store.adminBroadcasts().length : 0;
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              SoftMoreHeader(admin: widget.admin, name: user.displayName)
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftMoreHero(admin: widget.admin, count: items.length)
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              if (!widget.admin) ...[
                const SizedBox(height: 14),
                SoftDailyTipBanner(onTap: () => context.push('/app/learn'))
                    .animate()
                    .fadeIn(delay: 55.ms, duration: 280.ms),
              ],
              if (widget.admin) ...[
                const SizedBox(height: 14),
                SoftMoreAdminQuickStats(
                  activeClients: activeClients,
                  pendingAppts: pendingAppts,
                  broadcasts: broadcastCount,
                ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
              ] else if (weekly != null && streak != null) ...[
                const SizedBox(height: 14),
                SoftMoreQuickStats(
                  score: weekly.wellnessScore,
                  streak: streak.current,
                  checkIns: checkIns,
                ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
              ],
              if (!searching && featured.isNotEmpty) ...[
                const SizedBox(height: 16),
                SoftMoreFeaturedRail(
                  items: featured,
                  onOpen: (item) => _open(context, store, user, item),
                ).animate().fadeIn(delay: 90.ms, duration: 300.ms),
              ],
              const SizedBox(height: 14),
              SoftMoreSearchField(
                onChanged: (v) => setState(() => _query = v),
              ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
              if (!searching) ...[
                const SizedBox(height: 14),
                SoftMoreSpotlight(
                  admin: widget.admin,
                  onTap: () => context.push(
                    widget.admin ? '/admin/notifications' : '/app/story',
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
              ],
              const SizedBox(height: 18),
              if (filtered.isEmpty)
                const SoftMoreEmpty()
              else
                for (var s = 0; s < sections.length; s++) ...[
                  SoftMoreSectionTitle(
                    title: sections[s],
                    count: filtered.where((e) => e.section == sections[s]).length,
                  ).animate().fadeIn(delay: (80 + 20 * s).ms, duration: 240.ms),
                  const SizedBox(height: 8),
                  if (desktop)
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: context.isExtraWide ? 3 : 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 3.2,
                      children: [
                        for (final item in filtered.where((e) => e.section == sections[s]))
                          SoftMoreTile(
                            item: item,
                            waterOn: waterOn,
                            onTap: () => _open(context, store, user, item),
                          ),
                      ],
                    )
                  else
                    ...filtered.where((e) => e.section == sections[s]).toList().asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoftMoreTile(
                          item: item,
                          waterOn: waterOn,
                          onTap: () => _open(context, store, user, item),
                        )
                            .animate()
                            .fadeIn(delay: (90 + 22 * i + 28 * s).ms, duration: 260.ms)
                            .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                      );
                    }),
                  const SizedBox(height: 6),
                ],
              SoftMoreFooterTip(admin: widget.admin)
                  .animate()
                  .fadeIn(delay: 180.ms, duration: 280.ms),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open(
    BuildContext context,
    AppStore store,
    UserProfile user,
    SoftMoreItem item,
  ) async {
    context.push(item.route);
  }
}
