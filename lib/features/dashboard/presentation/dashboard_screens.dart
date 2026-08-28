import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/utils/pdf_report.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/marketplace.dart';
import '../../../core/widgets/style_icon.dart';
import '../../../core/widgets/kawaii_doodle.dart';
import '../../../core/widgets/story_viewer.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../blog/presentation/blog_screens.dart';
import '../../gamification/presentation/gamification_screens.dart';
import '../../learn/presentation/learn_screens.dart';
import '../../recipes/presentation/recipe_screens.dart';
import 'cartoon_configured_home.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider).valueOrNull ?? [];
    final appointments = ref.watch(appointmentsProvider).valueOrNull ?? [];
    final payments = ref.watch(paymentsProvider).valueOrNull ?? [];
    final clients = users.where((u) => u.role == UserRole.client).toList();
    final active = clients.where((c) => c.isActive).length;
    final monthSessions = appointments
        .where((a) => a.startAt.month == DateTime.now().month && a.status == AppointmentStatus.completed)
        .length;
    final due = payments.where((p) => p.status != PaymentStatus.paid).fold<double>(0, (s, p) => s + p.amount);
    final paid = payments.where((p) => p.status == PaymentStatus.paid).fold<double>(0, (s, p) => s + p.amount);

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              MarketHeroHeader(
                greeting: 'Klinik paneli',
                subtitle: 'Randevu, tahsilat ve içerik tek bakışta',
                trailing: IconButton(
                  tooltip: 'PDF',
                  color: context.isDesktopLayout || context.isModern
                      ? AppColors.primary
                      : Colors.white,
                  onPressed: () => PdfReport.sharePracticeSummary(
                    clients: clients,
                    appointments: appointments,
                    payments: payments,
                  ),
                  icon: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: context.isDesktopLayout || context.isModern
                        ? AppColors.primary
                        : Colors.white,
                  ),
                ),
                search: MarketSearchBar(
                  hint: 'Danışan, hizmet veya yazı ara',
                  onSubmitted: (q) {
                    if (q.trim().isEmpty) {
                      context.push('/admin/clients');
                    } else {
                      context.push('/admin/clients');
                    }
                  },
                ),
              ),
              Padding(
                padding: context.homePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PromoSlider(
                      slides: [
                        PromoSlide(
                          emoji: '👥',
                          title: '$active aktif danışan',
                          subtitle: 'Toplam ${clients.length} kişi klinik kaydında',
                          cta: 'Danışanlar',
                          route: '/admin/clients',
                          color: context.brandPrimary,
                        ),
                        PromoSlide(
                          emoji: '📅',
                          title: 'Bu ay $monthSessions seans',
                          subtitle: 'Takvimden yeni slot açabilirsin',
                          cta: 'Takvim',
                          route: '/admin/appointments',
                          color: context.brandDeep,
                        ),
                        PromoSlide(
                          emoji: '💰',
                          title: '₺${paid.toStringAsFixed(0)} tahsil edildi',
                          subtitle: 'Bekleyen bakiye ₺${due.toStringAsFixed(0)}',
                          cta: 'CRM',
                          route: '/admin',
                          color: context.isLuxury ? AppColors.luxuryGold : AppColors.accent,
                        ),
                        PromoSlide(
                          emoji: '📝',
                          title: 'Blog ve tarifler',
                          subtitle: 'Yeni yazı ve menü önerisi yayınla',
                          cta: 'Editör',
                          route: '/admin/blog',
                          color: context.isLuxury ? AppColors.luxuryBronze : context.brandBright,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CategoryShortcuts(
                      items: [
                        HomeCategory(label: 'Danışan', emoji: '👥', icon: Icons.groups_rounded, route: '/admin/clients', tint: context.brandPrimary),
                        HomeCategory(
                          label: 'Takvim',
                          emoji: '📅',
                          icon: Icons.event,
                          route: '/admin/appointments',
                          tint: context.isLuxury ? AppColors.luxuryBronze : context.brandBright,
                        ),
                        HomeCategory(
                          label: 'Sohbet',
                          emoji: '💬',
                          icon: Icons.chat,
                          route: '/admin/chat',
                          tint: context.isLuxury ? AppColors.luxuryGold : AppColors.accent,
                        ),
                        HomeCategory(label: 'Blog', emoji: '📰', icon: Icons.article, route: '/admin/blog', tint: context.brandDeep),
                        HomeCategory(label: 'Hizmet', emoji: '🎁', icon: Icons.storefront, route: '/admin/services', tint: context.brandPrimary),
                        HomeCategory(
                          label: 'Tarif',
                          emoji: '🍲',
                          icon: Icons.menu_book,
                          route: '/admin/recipes',
                          tint: context.isLuxury ? AppColors.luxuryBronze : context.brandPrimary,
                        ),
                        HomeCategory(
                          label: 'Diyet',
                          emoji: '🥗',
                          icon: Icons.restaurant,
                          route: '/admin/diet-plans',
                          tint: context.isLuxury ? AppColors.luxuryGold : AppColors.accent,
                        ),
                        const HomeCategory(label: 'Ayarlar', emoji: '⚙️', icon: Icons.settings, route: '/admin/settings', tint: Color(0xFF57534E)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _kpi(context, 'Aktif danışan', '$active / ${clients.length}', Icons.favorite, '🧡', context.isLuxury ? AppColors.luxuryGold : AppColors.accent),
                        _kpi(context, 'Bu ay seans', '$monthSessions', Icons.event_available, '📅', context.brandPrimary),
                        _kpi(context, 'Tahsil edilen', '₺${paid.toStringAsFixed(0)}', Icons.payments, '💰', AppColors.success),
                        _kpi(context, 'Bekleyen bakiye', '₺${due.toStringAsFixed(0)}', Icons.account_balance_wallet, '⏳', AppColors.warning),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: 20),
                    if (context.isDesktopLayout)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: DiyetselCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SectionHeader(title: 'Aylık seans ritmi', subtitle: 'Onaylanan / tamamlanan'),
                                  SizedBox(
                                    height: 200,
                                    child: BarChart(
                                      BarChartData(
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (v, _) => Text(['P', 'S', 'Ç', 'P', 'C', 'C', 'P'][v.toInt() % 7]),
                                            ),
                                          ),
                                        ),
                                        barGroups: List.generate(7, (i) {
                                          final count = appointments.where((a) => a.startAt.weekday == i + 1).length.toDouble();
                                          return BarChartGroupData(
                                            x: i,
                                            barRods: [
                                              BarChartRodData(
                                                toY: count + 1,
                                                color: context.brandPrimary,
                                                width: 16,
                                                borderRadius: BorderRadius.circular(context.isLuxury ? 6 : 8),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(flex: 2, child: _QuietClientsCard()),
                        ],
                      )
                    else ...[
                      DiyetselCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Aylık seans ritmi', subtitle: 'Onaylanan / tamamlanan'),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (v, _) => Text(['P', 'S', 'Ç', 'P', 'C', 'C', 'P'][v.toInt() % 7]),
                                      ),
                                    ),
                                  ),
                                  barGroups: List.generate(7, (i) {
                                    final count = appointments.where((a) => a.startAt.weekday == i + 1).length.toDouble();
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: count + 1,
                                          color: context.brandPrimary,
                                          width: 16,
                                          borderRadius: BorderRadius.circular(context.isLuxury ? 6 : 8),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _QuietClientsCard(),
                    ],
                    const SizedBox(height: 16),
                    DiyetselCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: 'Danışan bakiyeleri',
                            action: TextButton(
                              onPressed: () => _addPayment(context, ref, clients),
                              child: const Text('Kayıt ekle'),
                            ),
                          ),
                          if (context.isWide)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Danışan')),
                                  DataColumn(label: Text('Tutar')),
                                  DataColumn(label: Text('Durum')),
                                  DataColumn(label: Text('Tarih')),
                                  DataColumn(label: Text('Not')),
                                ],
                                rows: [
                                  for (final p in payments)
                                    DataRow(
                                      cells: [
                                        DataCell(Text(p.clientName)),
                                        DataCell(Text('₺${p.amount.toStringAsFixed(0)}')),
                                        DataCell(StatusChip(label: p.status.name, color: _payColor(p.status))),
                                        DataCell(Text(DateFormat('d MMM', 'tr').format(p.date))),
                                        DataCell(Text(p.note ?? '—')),
                                      ],
                                    ),
                                ],
                              ),
                            )
                          else
                            ...payments.map(
                              (p) => ListTile(
                                title: Text(p.clientName),
                                subtitle: Text(p.note ?? ''),
                                trailing: Text('₺${p.amount.toStringAsFixed(0)}'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _payColor(PaymentStatus s) => switch (s) {
        PaymentStatus.paid => AppColors.success,
        PaymentStatus.due => AppColors.warning,
        PaymentStatus.overdue => AppColors.danger,
      };

  Widget _kpi(BuildContext context, String label, String value, IconData icon, String emoji, Color color) {
    return SizedBox(
      width: context.isDesktopLayout
          ? 250
          : (context.isWide ? 240 : double.infinity),
      child: DiyetselCard(
        child: Row(
          children: [
            StyleIcon(icon: icon, emoji: emoji, size: 22, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPayment(BuildContext context, WidgetRef ref, List<UserProfile> clients) async {
    if (clients.isEmpty) return;
    var client = clients.first;
    final amount = TextEditingController();
    final note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ödeme kaydı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<UserProfile>(
              initialValue: client,
              items: [for (final c in clients) DropdownMenuItem(value: c, child: Text(c.displayName))],
              onChanged: (v) => client = v ?? client,
            ),
            TextField(controller: amount, decoration: const InputDecoration(labelText: 'Tutar'), keyboardType: TextInputType.number),
            TextField(controller: note, decoration: const InputDecoration(labelText: 'Not')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              await ref.read(appStoreProvider).savePayment(
                    PaymentRecord(
                      id: newId(),
                      clientId: client.id,
                      clientName: client.displayName,
                      amount: double.tryParse(amount.text) ?? 0,
                      status: PaymentStatus.due,
                      date: DateTime.now(),
                      note: note.text,
                    ),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final _seenStories = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _afterFrame());
  }

  Future<void> _afterFrame() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || !mounted) return;
    final store = ref.read(appStoreProvider);
    await SmartNotificationService.instance.sync(store, user);
    await AchievementService.instance.checkAndAward(store, user.id);
    if (mounted) await maybeShowBadgeCelebrations(context, ref, user.id);
  }

  List<HomeCategory> _homeCats(BuildContext context) => [
        HomeCategory(label: 'Diyet', emoji: '🥗', icon: Icons.restaurant_rounded, route: '/app/diet', tint: context.brandPrimary),
        HomeCategory(
          label: 'Su',
          emoji: '💧',
          icon: Icons.water_drop_rounded,
          route: '/app/track',
          tint: context.isLuxury
              ? AppColors.luxuryGold
              : (context.isModern ? AppColors.modernSage : AppColors.accent),
        ),
        HomeCategory(label: 'Randevu', emoji: '📅', icon: Icons.event_available_rounded, route: '/app/appointments', tint: context.brandDeep),
        HomeCategory(
          label: 'Hizmet',
          emoji: '🎁',
          icon: Icons.storefront_rounded,
          route: '/app/services',
          tint: context.isLuxury
              ? AppColors.luxuryBronze
              : (context.isModern ? AppColors.primaryBright : context.brandBright),
        ),
        HomeCategory(label: 'Tarif', emoji: '🍲', icon: Icons.menu_book_rounded, route: '/app/recipes', tint: context.brandPrimary),
        HomeCategory(label: 'Blog', emoji: '📰', icon: Icons.article_rounded, route: '/app/blog', tint: context.brandDeep),
        HomeCategory(
          label: 'Alışveriş',
          emoji: '🛒',
          icon: Icons.shopping_cart_rounded,
          route: '/app/shopping',
          tint: context.isLuxury ? AppColors.luxuryGold : AppColors.accent,
        ),
        HomeCategory(
          label: 'Sohbet',
          emoji: '💬',
          icon: Icons.chat_rounded,
          route: '/app/chat',
          tint: context.isLuxury ? AppColors.luxuryBronze : context.brandPrimary,
        ),
        HomeCategory(label: 'Barkod', emoji: '📷', icon: Icons.qr_code_scanner_rounded, route: '/app/barcode', tint: context.brandPrimary),
        HomeCategory(
          label: 'Check-in',
          emoji: '❤️',
          icon: Icons.favorite_rounded,
          route: '/app/check-in',
          tint: context.isLuxury ? AppColors.luxuryGold : AppColors.accent,
        ),
        HomeCategory(
          label: 'Dışarıda',
          emoji: '🍽️',
          icon: Icons.restaurant_menu_rounded,
          route: '/app/eat-out',
          tint: context.isLuxury ? AppColors.luxuryBronze : context.brandBright,
        ),
        HomeCategory(label: 'Oruç', emoji: '⏳', icon: Icons.hourglass_bottom, route: '/app/fasting', tint: context.brandDeep),
      ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final firstName = user.displayName.split(' ').first;

    if (context.isCartoon) {
      return Scaffold(
        backgroundColor: AppColors.kawaiiSurfaceCream,
        body: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
              child: CartoonConfiguredHome(
                userName: firstName,
                avatarUrl: user.photoUrl,
              ),
            ),
          ),
        ),
      );
    }

    final store = ref.watch(appStoreProvider);
    final appointments = ref.watch(appointmentsProvider).valueOrNull ?? [];
    final services = (ref.watch(servicesProvider).valueOrNull ?? []).where((s) => s.active).toList();
    final posts = (ref.watch(blogProvider).valueOrNull ?? []).where((p) => p.published).toList();
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final next = appointments
        .where((a) => a.clientId == user.id && a.startAt.isAfter(DateTime.now()) && a.status == AppointmentStatus.approved)
        .toList();
    ref.watch(waterLogsProvider);
    ref.watch(dietPlansProvider);
    ref.watch(streaksProvider);
    ref.watch(userProgressProvider(user.id));
    ref.watch(settingsProvider);
    ref.watch(usersProvider);
    final water = store.waterLog(user.id, DateTime.now());
    final plan = store.dietPlanForClient(user.id);
    final streak = store.streak(user.id);
    final todayMeals = plan?.days
            .where((d) => DateUtils.isSameDay(d.date, DateTime.now()))
            .expand((d) => d.meals)
            .toList() ??
        [];
    final leftover = todayMeals.where((m) => !m.consumed).toList();
    final catsAll = _homeCats(context).where((c) {
      final id = AppModule.fromRoute(c.route);
      return id == null || store.moduleOn(user.id, id);
    }).toList();
    final cats = context.isCartoon
        ? catsAll
            .where((c) => const {
                  'Diyet',
                  'Su',
                  'Randevu',
                  'Hizmet',
                  'Tarif',
                  'Blog',
                  'Alışveriş',
                  'Sohbet',
                }.contains(c.label))
            .take(8)
            .toList()
        : context.isModern
            ? catsAll
                .where((c) => const {'Diyet', 'Su', 'Randevu', 'Hizmet'}.contains(c.label))
                .take(4)
                .toList()
            : catsAll;

    final recipePhoto = recipes.isNotEmpty
        ? diyetselFoodImage(imageUrl: recipes.first.imageUrl, seed: recipes.first.title)
        : diyetselFoodImage(seed: 'bowl');

    final slides = <PromoSlide>[
      if (store.moduleOn(user.id, AppModule.diet))
        PromoSlide(
          emoji: leftover.isEmpty ? '🎉' : '🥗',
          title: leftover.isEmpty ? 'Bugünkü plan tamam' : '${leftover.length} öğün kaldı',
          subtitle: plan == null
              ? 'Diyet listen hazır olunca burada görünür'
              : 'Kampanyalar ve tarifler aşağıda, öğünler tek kartta',
          cta: 'Diyetim',
          route: '/app/diet',
          color: context.brandPrimary,
          kind: leftover.isEmpty ? KawaiiKind.sparkle : KawaiiKind.diet,
          imageUrl: recipePhoto,
        ),
      if (store.moduleOn(user.id, AppModule.water))
        PromoSlide(
          emoji: water.progress >= 1 ? '🥳' : '💧',
          title: 'Su: ${water.amountMl} / ${water.goalMl} ml',
          subtitle: water.progress >= 1
              ? 'Hedef doldu, harika gidiyorsun'
              : '%${(water.progress * 100).round()} tamamlandı — bir bardak daha',
          cta: 'Takip',
          route: '/app/track',
          color: context.isLuxury
              ? AppColors.luxuryGold
              : (context.isCartoon ? AppColors.kawaiiSky : AppColors.modernSage),
          kind: KawaiiKind.water,
          imageUrl: diyetselFoodImage(seed: 'su'),
        ),
      if (store.moduleOn(user.id, AppModule.appointments) && next.isNotEmpty)
        PromoSlide(
          emoji: '⏳',
          title: next.first.serviceTitle ?? 'Yaklaşan seans',
          subtitle: DateFormat('d MMMM HH:mm', 'tr').format(next.first.startAt),
          cta: 'Takvim',
          route: '/app/appointments',
          color: context.brandDeep,
          kind: KawaiiKind.hourglass,
          imageUrl: recipePhoto,
        )
      else if (store.moduleOn(user.id, AppModule.appointments))
        PromoSlide(
          emoji: '📅',
          title: 'Seansını planla',
          subtitle: 'Müsait slotlardan randevu talep et',
          cta: 'Randevu al',
          route: '/app/appointments',
          color: context.brandDeep,
          kind: KawaiiKind.calendar,
          imageUrl: recipePhoto,
        ),
      if (store.moduleOn(user.id, AppModule.services) && services.isNotEmpty)
        PromoSlide(
          emoji: '🎁',
          title: services.first.title,
          subtitle: '₺${services.first.price.toStringAsFixed(0)} • ${services.first.durationMinutes} dk',
          cta: 'Kampanya',
          route: '/app/services',
          color: context.isLuxury
              ? AppColors.luxuryBronze
              : (context.isCartoon ? AppColors.kawaiiLilac : AppColors.primaryBright),
          kind: KawaiiKind.gift,
          imageUrl: recipePhoto,
        )
      else if (store.moduleOn(user.id, AppModule.services))
        PromoSlide(
          emoji: '✨',
          title: 'Yeni paketler yolda',
          subtitle: 'Detoks ve online seans seçeneklerine bak',
          cta: 'Keşfet',
          route: '/app/services',
          color: context.isLuxury
              ? AppColors.luxuryBronze
              : (context.isCartoon ? AppColors.kawaiiLilac : AppColors.primaryBright),
          kind: KawaiiKind.sparkle,
          imageUrl: recipePhoto,
        ),
    ];

    final stories = <StoryBundle>[
      const StoryBundle(
        id: 'mine',
        label: 'Hikayem',
        kind: KawaiiKind.sparkle,
        isMine: true,
        createRoute: '/app/story',
      ),
      StoryBundle(
        id: 'streak',
        label: 'Seri',
        kind: KawaiiKind.fire,
        pages: [
          StoryPageData(
            title: '${streak.current} gün',
            subtitle: 'Rekor ${streak.best} gün',
            detail: streak.freezeUsed ? 'Bu ay dondurma kullanıldı' : 'Bu ay 1 dondurma hakkın var',
            kind: KawaiiKind.fire,
            colors: const [AppColors.modernFire, AppColors.modernFireBright],
            ctaLabel: 'Paylaş',
            ctaRoute: '/app/story',
          ),
        ],
      ),
      StoryBundle(
        id: 'water',
        label: 'Su',
        kind: KawaiiKind.water,
        pages: [
          StoryPageData(
            title: '%${(water.progress * 100).round()}',
            subtitle: '${water.amountMl} / ${water.goalMl} ml',
            detail: water.progress >= 1 ? 'Hedef doldu!' : 'Bir yudum daha, seri bozulmasın.',
            kind: KawaiiKind.water,
            colors: const [AppColors.primaryBright, AppColors.accent],
            ctaLabel: 'Su ekle',
            ctaRoute: '/app/track',
          ),
        ],
      ),
      StoryBundle(
        id: 'plan',
        label: 'Plan',
        kind: KawaiiKind.diet,
        pages: [
          StoryPageData(
            title: leftover.isEmpty ? 'Tamam' : '${leftover.length} kaldı',
            subtitle: leftover.isEmpty
                ? 'Bugünkü öğünler işaretli'
                : leftover.take(3).map((m) => m.name).join(' • '),
            kind: KawaiiKind.plate,
            colors: context.isModern
                ? const [AppColors.primary, AppColors.modernSage]
                : context.isCartoon
                    ? const [AppColors.kawaiiRose, AppColors.kawaiiLemon]
                    : const [AppColors.luxuryCopper, AppColors.luxuryBronze],
            ctaLabel: 'Diyetim',
            ctaRoute: '/app/diet',
          ),
        ],
      ),
      StoryBundle(
        id: 'all',
        label: 'Tümü',
        kind: KawaiiKind.sparkle,
        pages: [
          StoryPageData(
            title: 'Tüm hikayeler',
            subtitle: 'Seri, su, plan ve daha fazlası',
            kind: KawaiiKind.sparkle,
            colors: context.isModern
                ? const [AppColors.primaryBright, AppColors.primary]
                : context.isCartoon
                    ? const [AppColors.kawaiiCoralBright, AppColors.kawaiiMint]
                    : const [AppColors.luxuryCopperBright, AppColors.luxuryChampagne],
            ctaLabel: 'Aç',
            ctaRoute: '/app/story',
          ),
        ],
      ),
      for (final post in posts.take(4))
        StoryBundle(
          id: 'blog-${post.id}',
          label: post.category,
          kind: KawaiiKindX.forBlog(post.category),
          pages: [
            StoryPageData(
              title: post.title,
              subtitle: post.subtitle,
              kind: KawaiiKindX.forBlog(post.category),
              colors: context.isModern
                  ? const [AppColors.primary, AppColors.primaryDeep]
                  : context.isCartoon
                      ? const [AppColors.kawaiiLilac, AppColors.kawaiiMint]
                      : const [AppColors.luxuryCopperDeep, AppColors.primaryDeep],
              ctaLabel: 'Oku',
              ctaRoute: '/app/blog',
            ),
          ],
        ),
      if (recipes.isNotEmpty)
        StoryBundle(
          id: 'recipe',
          label: 'Tarif',
          kind: KawaiiKind.recipe,
          pages: [
            StoryPageData(
              title: recipes.first.title,
              subtitle: '${recipes.first.calories} kcal • ${recipes.first.prepMinutes} dk',
              kind: KawaiiKind.recipe,
              colors: context.isModern
                  ? const [AppColors.primaryBright, AppColors.modernSage]
                  : context.isCartoon
                      ? const [AppColors.kawaiiMint, AppColors.kawaiiSky]
                      : const [AppColors.luxuryCopper, AppColors.luxuryBronze],
              ctaLabel: 'Tarifler',
              ctaRoute: '/app/recipes',
            ),
          ],
        ),
    ];
    final visibleStories = stories.where((s) {
      if (s.id == 'mine' || s.id == 'streak' || s.id == 'all') {
        return store.moduleOn(user.id, AppModule.story);
      }
      if (s.id == 'water') return store.moduleOn(user.id, AppModule.water);
      if (s.id == 'plan') return store.moduleOn(user.id, AppModule.diet);
      if (s.id.startsWith('blog')) return store.moduleOn(user.id, AppModule.blog);
      if (s.id == 'recipe') return store.moduleOn(user.id, AppModule.recipes);
      return true;
    }).toList();

    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              MarketHeroHeader(
                greeting: 'Merhaba, $firstName',
                subtitle: context.isCartoon
                    ? 'Pastel planlar, tatlı tarifler ve minik sürprizler burada'
                    : context.isLuxury
                        ? 'Planın, tariflerin ve seçkin kampanyaların tek yerde'
                        : 'Bugün için yumuşak bir ritim — plan, tarif ve kampanyalar',
                trailing: CartoonAvatar(name: user.displayName, size: 40),
                search: MarketSearchBar(
                  hint: context.isCartoon ? 'Tatlı bir tarif veya yazı ara' : 'Tarif, yazı veya hizmet ara',
                  onSubmitted: (q) => _openHomeSearch(
                    context,
                    query: q,
                    recipes: recipes,
                    services: services,
                    posts: posts,
                  ),
                ),
              ),
              Padding(
                padding: context.isModern
                    ? EdgeInsets.fromLTRB(
                        context.isDesktopLayout ? 28 : 18,
                        context.isDesktopLayout ? 22 : 18,
                        context.isDesktopLayout ? 28 : 18,
                        context.isDesktopLayout ? 40 : 34,
                      )
                    : context.isCartoon
                        ? EdgeInsets.fromLTRB(
                            context.isDesktopLayout ? 28 : 18,
                            context.isDesktopLayout ? 20 : 16,
                            context.isDesktopLayout ? 28 : 18,
                            context.isDesktopLayout ? 36 : 32,
                          )
                        : context.homePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visibleStories.isNotEmpty && !context.isDesktopLayout)
                      _homeStagger(
                        context,
                        0,
                        StoryRail(
                          items: visibleStories,
                          seenIds: _seenStories,
                          onSeen: (id) => setState(() => _seenStories.add(id)),
                        ),
                      ),
                    if (visibleStories.isNotEmpty && !context.isDesktopLayout)
                      SizedBox(height: context.isCartoon ? 14 : (context.isModern ? 16 : 8)),
                    _homeStagger(
                      context,
                      1,
                      PromoSlider(slides: slides, height: context.isModern ? 210 : 168),
                    ),
                    SizedBox(height: context.isCartoon ? 16 : (context.isModern ? 18 : 12)),
                    if (context.isCartoon && store.moduleOn(user.id, AppModule.water)) ...[
                      _homeStagger(
                        context,
                        2,
                        WaterProgressCard(
                          amountMl: water.amountMl,
                          goalMl: water.goalMl,
                          onTrack: () {
                            store.addWaterSip(user.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('+250 ml — minik bir yudum!'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(milliseconds: 900),
                                backgroundColor: AppColors.kawaiiCoral,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _homeStagger(context, 3, CategoryStrip(items: cats)),
                    SizedBox(height: context.isCartoon ? 16 : (context.isModern ? 18 : 12)),
                    if (!context.isModern) ...[
                      _homeStagger(context, 4, const BadgeHomeStrip()),
                      SizedBox(height: context.isCartoon ? 16 : 12),
                    ],
                    _homeStagger(
                      context,
                      5,
                      TodayStrip(
                        items: [
                          if (store.moduleOn(user.id, AppModule.story))
                            TodayStat(
                              label: 'Seri',
                              value: '${streak.current} gün',
                              kind: KawaiiKind.fire,
                              color: context.isCartoon
                                  ? AppColors.kawaiiRose
                                  : (context.isModern ? AppColors.modernFire : context.brandPrimary),
                              onTap: () => context.push('/app/story'),
                            ),
                          if (store.moduleOn(user.id, AppModule.water))
                            TodayStat(
                              label: 'Su',
                              value: '%${(water.progress * 100).round()}',
                              kind: KawaiiKind.water,
                              color: context.isLuxury
                                  ? AppColors.luxuryGold
                                  : (context.isCartoon
                                      ? AppColors.kawaiiSky
                                      : (context.isModern ? AppColors.modernSage : AppColors.accent)),
                              onTap: () {
                                store.addWaterSip(user.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.isCartoon ? '+250 ml — minik bir yudum!' : '+250 ml eklendi',
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(milliseconds: 900),
                                    backgroundColor: context.isLuxury
                                        ? AppColors.luxuryCopper
                                        : (context.isCartoon
                                            ? AppColors.kawaiiCoral
                                            : (context.isModern ? AppColors.primary : AppColors.accent)),
                                  ),
                                );
                              },
                            ),
                          if (store.moduleOn(user.id, AppModule.diet))
                            TodayStat(
                              label: 'Öğün',
                              value: leftover.isEmpty
                                  ? (context.isCartoon ? 'Hepsi tamam' : 'Tamam')
                                  : '${leftover.length} kaldı',
                              kind: KawaiiKind.plate,
                              color: context.isLuxury
                                  ? AppColors.luxuryBronze
                                  : (context.isCartoon
                                      ? AppColors.kawaiiRose
                                      : (context.isModern ? AppColors.primaryBright : context.brandBright)),
                              onTap: () => context.go('/app/diet'),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.isCartoon ? 16 : (context.isModern ? 18 : 12)),
                    if (store.moduleOn(user.id, AppModule.recipes) && recipes.isNotEmpty) ...[
                      _homeStagger(context, 6, const RecipeTonightCard()),
                      SizedBox(height: context.isCartoon ? 12 : (context.isModern ? 12 : 8)),
                    ],
                    if (context.isModern) ...[
                      _homeStagger(context, 7, const BadgeHomeStrip()),
                      const SizedBox(height: 12),
                    ],
                    if (store.moduleOn(user.id, AppModule.blog)) ...[
                      _homeStagger(context, 8, const LearnHomeRail()),
                      SizedBox(height: context.isCartoon ? 12 : (context.isModern ? 12 : 8)),
                    ],
                    if (store.moduleOn(user.id, AppModule.services) && services.isNotEmpty)
                      _homeStagger(
                        context,
                        9,
                        HorizontalRail(
                          title: context.isCartoon ? 'Minik kampanyalar' : 'Kampanyalar',
                          onSeeAll: () => context.push('/app/services'),
                          children: [
                            for (final s in services.take(8))
                              ProductTile(
                                emoji: '🎁',
                                title: s.title,
                                meta: '₺${s.price.toStringAsFixed(0)} • ${s.durationMinutes} dk',
                                onTap: () => context.push('/app/services'),
                              ),
                          ],
                        ),
                      ),
                    if (store.moduleOn(user.id, AppModule.recipes) && recipes.isNotEmpty)
                      _homeStagger(
                        context,
                        10,
                        HorizontalRail(
                          title: context.isCartoon ? 'Sana özel tatlı tarifler' : 'Sana özel tarifler',
                          onSeeAll: () => context.push('/app/recipes'),
                          children: [
                            for (final r in recipes.take(8))
                              ProductTile(
                                emoji: '🍲',
                                title: r.title,
                                meta: '${r.calories} kcal • ${r.prepMinutes} dk',
                                onTap: () => context.push('/app/recipes'),
                              ),
                          ],
                        ),
                      ),
                    if (store.moduleOn(user.id, AppModule.blog) && posts.isNotEmpty)
                      _homeStagger(
                        context,
                        11,
                        HorizontalRail(
                          title: 'Öne çıkan yazılar',
                          onSeeAll: () => context.push('/app/blog'),
                          children: [
                            for (final p in posts.take(8))
                              ProductTile(
                                emoji: '📰',
                                title: p.title,
                                meta: p.category,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => BlogDetailScreen(post: p, admin: false)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (store.moduleOn(user.id, AppModule.diet)) ...[
                      _homeStagger(
                        context,
                        12,
                        SectionHeader(
                          title: 'Bugünün planı',
                          action: TextButton(onPressed: () => context.go('/app/diet'), child: const Text('Tümü')),
                        ),
                      ),
                      if (todayMeals.isEmpty)
                        _homeStagger(
                          context,
                          13,
                          const EmptyState(
                            icon: Icons.restaurant,
                            title: 'Bugün için öğün yok',
                            subtitle: 'Diyet listen gelince buradan devam edersin.',
                          ),
                        )
                      else
                        _homeStagger(
                          context,
                          13,
                          DiyetselCard(
                            padding: context.isModern
                                ? const EdgeInsets.fromLTRB(18, 16, 18, 14)
                                : const EdgeInsets.all(18),
                            child: Column(
                              children: [
                                for (final m in leftover.take(3))
                                  CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    value: m.consumed,
                                    secondary: StyleIcon(icon: Icons.restaurant, emoji: m.type.emoji, size: 22),
                                    title: Text(
                                      m.name,
                                      style: TextStyle(
                                        fontWeight: context.isModern ? FontWeight.w700 : FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: Text('${m.type.tr} • ${m.calories} kcal'),
                                    onChanged: plan == null
                                        ? null
                                        : (_) {
                                            final dayIndex = plan.days.indexWhere(
                                              (d) => DateUtils.isSameDay(d.date, DateTime.now()),
                                            );
                                            if (dayIndex >= 0) {
                                              ref.read(appStoreProvider).toggleMealConsumed(plan, dayIndex, m.id);
                                            }
                                          },
                                  ),
                                if (leftover.isEmpty)
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'Tüm öğünler tamam',
                                      style: TextStyle(
                                        fontWeight: context.isModern ? FontWeight.w700 : FontWeight.w800,
                                      ),
                                    ),
                                    subtitle: const Text('Harika gidiyorsun'),
                                  )
                                else if (leftover.length > 3)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () => context.go('/app/diet'),
                                      child: Text('+${leftover.length - 3} öğün daha'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                    SizedBox(height: context.isModern ? 14 : 10),
                    if (store.moduleOn(user.id, AppModule.appointments))
                      if (next.isEmpty)
                        _homeStagger(
                          context,
                          14,
                          DiyetselCard(
                            onTap: () => context.go('/app/appointments'),
                            padding: context.isModern
                                ? const EdgeInsets.fromLTRB(16, 16, 16, 16)
                                : const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                StyleIcon(
                                  icon: Icons.event,
                                  emoji: '📅',
                                  size: 26,
                                  color: context.isModern ? AppColors.modernSage : context.brandDeep,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Randevu al',
                                        style: TextStyle(
                                          fontWeight: context.isModern ? FontWeight.w700 : FontWeight.w800,
                                        ),
                                      ),
                                      Text('Müsait slotlara bak', style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        _homeStagger(context, 14, CountdownCard(appointment: next.first)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeStagger(BuildContext context, int index, Widget child) {
    if (context.isLuxury) return child;
    final delay = (context.isCartoon ? 40 : 55) * index;
    return child
        .animate()
        .fadeIn(duration: context.isCartoon ? 360.ms : 420.ms, delay: delay.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: context.isCartoon ? 0.04 : 0.035,
          end: 0,
          duration: context.isCartoon ? 400.ms : 460.ms,
          delay: delay.ms,
          curve: Curves.easeOutCubic,
        );
  }

  void _openHomeSearch(
    BuildContext context, {
    required String query,
    required List<Recipe> recipes,
    required List<ServicePackage> services,
    required List<BlogPost> posts,
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      context.push('/app/recipes');
      return;
    }
    final foundRecipes = recipes.where((r) => '${r.title} ${r.category} ${r.description}'.toLowerCase().contains(q)).toList();
    final foundServices = services.where((s) => '${s.title} ${s.description}'.toLowerCase().contains(q)).toList();
    final foundPosts = posts.where((p) => '${p.title} ${p.subtitle} ${p.tags.join()}'.toLowerCase().contains(q)).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        if (foundRecipes.isEmpty && foundServices.isEmpty && foundPosts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: EmptyState(icon: Icons.search, title: 'Sonuç yok', subtitle: 'Tarif, hizmet veya yazı adıyla tekrar dene.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            for (final s in foundServices)
              ListTile(
                leading: const StyleIcon(icon: Icons.storefront_rounded, emoji: '🎁', size: 22),
                title: Text(s.title),
                subtitle: Text('₺${s.price.toStringAsFixed(0)}'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/services');
                },
              ),
            for (final r in foundRecipes)
              ListTile(
                leading: const StyleIcon(icon: Icons.menu_book_rounded, emoji: '🍲', size: 22),
                title: Text(r.title),
                subtitle: Text('${r.calories} kcal'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/app/recipes');
                },
              ),
            for (final p in foundPosts)
              ListTile(
                leading: StyleIcon(icon: Icons.article_rounded, emoji: '📰', size: 22),
                title: Text(p.title),
                subtitle: Text(p.category),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute<void>(builder: (_) => BlogDetailScreen(post: p, admin: false)));
                },
              ),
          ],
        );
      },
    );
  }
}

class CountdownCard extends StatelessWidget {
  const CountdownCard({super.key, required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final left = appointment.startAt.difference(DateTime.now());
    final hours = left.inHours;
    final mins = left.inMinutes.remainder(60);
    return CartoonContainer(
      emoji: '⏳',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yaklaşan randevu', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(
            '${appointment.serviceTitle ?? 'Seans'} • ${DateFormat('d MMM HH:mm', 'tr').format(appointment.startAt)}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            '$hours sa $mins dk',
            style: TextStyle(
              color: context.brandPrimary,
              fontWeight: context.isLuxury ? FontWeight.w600 : FontWeight.w900,
              fontSize: 22,
              letterSpacing: context.isLuxury ? 0.4 : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuietClientsCard extends ConsumerWidget {
  const _QuietClientsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersProvider);
    ref.watch(checkInsProvider);
    final store = ref.watch(appStoreProvider);
    final quiet = store.silentClients();
    final checkIns = store.checkIns();
    return DiyetselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: '3 gündür sessiz',
            subtitle: 'Su, öğün işareti veya check-in gelmeyen danışanlar',
          ),
          if (quiet.isEmpty)
            const Text('Herkes aktif görünüyor.')
          else
            for (final c in quiet)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(
                  c.lastActiveAt == null
                      ? 'Hiç aktivite yok'
                      : 'Son: ${DateFormat('d MMM HH:mm', 'tr').format(c.lastActiveAt!)}',
                ),
                trailing: const StatusChip(label: 'sessiz', color: AppColors.warning),
              ),
          if (checkIns.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Son check-in’ler', style: TextStyle(fontWeight: FontWeight.w800)),
            for (final item in checkIns.take(5))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.userName),
                subtitle: Text('${item.weight ?? '-'} kg • ${item.note}'),
                trailing: Text(DateFormat('d MMM', 'tr').format(item.createdAt)),
              ),
          ],
        ],
      ),
    );
  }
}
