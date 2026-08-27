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
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
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
                  color: context.isDesktopLayout ? null : Colors.white,
                  onPressed: () => PdfReport.sharePracticeSummary(
                    clients: clients,
                    appointments: appointments,
                    payments: payments,
                  ),
                  icon: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: context.isDesktopLayout ? null : Colors.white,
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
                          color: AppColors.primary,
                        ),
                        PromoSlide(
                          emoji: '📅',
                          title: 'Bu ay $monthSessions seans',
                          subtitle: 'Takvimden yeni slot açabilirsin',
                          cta: 'Takvim',
                          route: '/admin/appointments',
                          color: AppColors.primaryDeep,
                        ),
                        PromoSlide(
                          emoji: '💰',
                          title: '₺${paid.toStringAsFixed(0)} tahsil edildi',
                          subtitle: 'Bekleyen bakiye ₺${due.toStringAsFixed(0)}',
                          cta: 'CRM',
                          route: '/admin',
                          color: AppColors.accent,
                        ),
                        PromoSlide(
                          emoji: '📝',
                          title: 'Blog ve tarifler',
                          subtitle: 'Yeni yazı ve menü önerisi yayınla',
                          cta: 'Editör',
                          route: '/admin/blog',
                          color: AppColors.peachDeep,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CategoryShortcuts(
                      items: const [
                        HomeCategory(label: 'Danışan', emoji: '👥', icon: Icons.groups_rounded, route: '/admin/clients', tint: AppColors.primary),
                        HomeCategory(label: 'Takvim', emoji: '📅', icon: Icons.event, route: '/admin/appointments', tint: AppColors.peachDeep),
                        HomeCategory(label: 'Sohbet', emoji: '💬', icon: Icons.chat, route: '/admin/chat', tint: AppColors.accent),
                        HomeCategory(label: 'Blog', emoji: '📰', icon: Icons.article, route: '/admin/blog', tint: AppColors.primaryDeep),
                        HomeCategory(label: 'Hizmet', emoji: '🎁', icon: Icons.storefront, route: '/admin/services', tint: AppColors.primary),
                        HomeCategory(label: 'Tarif', emoji: '🍲', icon: Icons.menu_book, route: '/admin/recipes', tint: AppColors.peachDeep),
                        HomeCategory(label: 'Diyet', emoji: '🥗', icon: Icons.restaurant, route: '/admin/diet-plans', tint: AppColors.accent),
                        HomeCategory(label: 'Ayarlar', emoji: '⚙️', icon: Icons.settings, route: '/admin/settings', tint: Color(0xFF57534E)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _kpi(context, 'Aktif danışan', '$active / ${clients.length}', Icons.favorite, '🧡', AppColors.accent),
                        _kpi(context, 'Bu ay seans', '$monthSessions', Icons.event_available, '📅', AppColors.primary),
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
                                                color: AppColors.primary,
                                                width: 16,
                                                borderRadius: BorderRadius.circular(8),
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
                                          color: AppColors.primary,
                                          width: 16,
                                          borderRadius: BorderRadius.circular(8),
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

  static const _homeCats = [
    HomeCategory(label: 'Diyet', emoji: '🥗', icon: Icons.restaurant_rounded, route: '/app/diet', tint: AppColors.primary),
    HomeCategory(label: 'Su', emoji: '💧', icon: Icons.water_drop_rounded, route: '/app/track', tint: AppColors.accent),
    HomeCategory(label: 'Randevu', emoji: '📅', icon: Icons.event_available_rounded, route: '/app/appointments', tint: AppColors.primaryDeep),
    HomeCategory(label: 'Hizmet', emoji: '🎁', icon: Icons.storefront_rounded, route: '/app/services', tint: AppColors.peachDeep),
    HomeCategory(label: 'Tarif', emoji: '🍲', icon: Icons.menu_book_rounded, route: '/app/recipes', tint: AppColors.primary),
    HomeCategory(label: 'Blog', emoji: '📰', icon: Icons.article_rounded, route: '/app/blog', tint: AppColors.primaryDeep),
    HomeCategory(label: 'Alışveriş', emoji: '🛒', icon: Icons.shopping_cart_rounded, route: '/app/shopping', tint: AppColors.accent),
    HomeCategory(label: 'Sohbet', emoji: '💬', icon: Icons.chat_rounded, route: '/app/chat', tint: AppColors.peachDeep),
    HomeCategory(label: 'Barkod', emoji: '📷', icon: Icons.qr_code_scanner_rounded, route: '/app/barcode', tint: AppColors.primary),
    HomeCategory(label: 'Check-in', emoji: '❤️', icon: Icons.favorite_rounded, route: '/app/check-in', tint: AppColors.accent),
    HomeCategory(label: 'Dışarıda', emoji: '🍽️', icon: Icons.restaurant_menu_rounded, route: '/app/eat-out', tint: AppColors.peachDeep),
    HomeCategory(label: 'Oruç', emoji: '⏳', icon: Icons.hourglass_bottom, route: '/app/fasting', tint: AppColors.primaryDeep),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
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
    final firstName = user.displayName.split(' ').first;
    final cats = _homeCats.where((c) {
      final id = AppModule.fromRoute(c.route);
      return id == null || store.moduleOn(user.id, id);
    }).toList();

    final slides = <PromoSlide>[
      if (store.moduleOn(user.id, AppModule.diet))
      PromoSlide(
        emoji: leftover.isEmpty ? '🎉' : '🥗',
        title: leftover.isEmpty ? 'Bugünkü plan tamam' : '${leftover.length} öğün kaldı',
        subtitle: plan == null ? 'Diyet listen hazır olunca burada görünür' : 'Kampanyalar ve tarifler aşağıda, öğünler tek kartta',
        cta: 'Diyetim',
        route: '/app/diet',
        color: AppColors.primary,
        kind: leftover.isEmpty ? KawaiiKind.sparkle : KawaiiKind.diet,
      ),
      if (store.moduleOn(user.id, AppModule.water))
      PromoSlide(
        emoji: water.progress >= 1 ? '🥳' : '💧',
        title: 'Su: ${water.amountMl} / ${water.goalMl} ml',
        subtitle: water.progress >= 1 ? 'Hedef doldu, harika gidiyorsun' : '%${(water.progress * 100).round()} tamamlandı — bir bardak daha',
        cta: 'Takip',
        route: '/app/track',
        color: AppColors.accent,
        kind: KawaiiKind.water,
      ),
      if (store.moduleOn(user.id, AppModule.appointments) && next.isNotEmpty)
        PromoSlide(
          emoji: '⏳',
          title: next.first.serviceTitle ?? 'Yaklaşan seans',
          subtitle: DateFormat('d MMMM HH:mm', 'tr').format(next.first.startAt),
          cta: 'Takvim',
          route: '/app/appointments',
          color: AppColors.primaryDeep,
          kind: KawaiiKind.hourglass,
        )
      else if (store.moduleOn(user.id, AppModule.appointments))
        const PromoSlide(
          emoji: '📅',
          title: 'Seansını planla',
          subtitle: 'Müsait slotlardan randevu talep et',
          cta: 'Randevu al',
          route: '/app/appointments',
          color: AppColors.primaryDeep,
          kind: KawaiiKind.calendar,
        ),
      if (store.moduleOn(user.id, AppModule.services) && services.isNotEmpty)
        PromoSlide(
          emoji: '🎁',
          title: services.first.title,
          subtitle: '₺${services.first.price.toStringAsFixed(0)} • ${services.first.durationMinutes} dk',
          cta: 'Kampanya',
          route: '/app/services',
          color: AppColors.peachDeep,
          kind: KawaiiKind.gift,
        )
      else if (store.moduleOn(user.id, AppModule.services))
        const PromoSlide(
          emoji: '✨',
          title: 'Yeni paketler yolda',
          subtitle: 'Detoks ve online seans seçeneklerine bak',
          cta: 'Keşfet',
          route: '/app/services',
          color: AppColors.peachDeep,
          kind: KawaiiKind.sparkle,
        ),
    ];

    final stories = <StoryBundle>[
      const StoryBundle(
        id: 'mine',
        label: 'Hikayen',
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
            colors: const [Color(0xFFFF7A18), Color(0xFFFF4D6D)],
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
            colors: const [Color(0xFF2EC4B6), Color(0xFF4D96FF)],
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
            subtitle: leftover.isEmpty ? 'Bugünkü öğünler işaretli' : leftover.take(3).map((m) => m.name).join(' • '),
            kind: KawaiiKind.plate,
            colors: const [Color(0xFFFF8A4C), Color(0xFFFFC56D)],
            ctaLabel: 'Diyetim',
            ctaRoute: '/app/diet',
          ),
        ],
      ),
      for (final post in posts.take(6))
        StoryBundle(
          id: 'blog-${post.id}',
          label: post.category,
          kind: KawaiiKindX.forBlog(post.category),
          pages: [
            StoryPageData(
              title: post.title,
              subtitle: post.subtitle,
              kind: KawaiiKindX.forBlog(post.category),
              colors: const [Color(0xFFE85D04), Color(0xFF0F766E)],
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
              colors: const [Color(0xFF2EC4B6), Color(0xFFFF8A4C)],
              ctaLabel: 'Tarifler',
              ctaRoute: '/app/recipes',
            ),
          ],
        ),
    ];
    final visibleStories = stories.where((s) {
      if (s.id == 'mine' || s.id == 'streak') return store.moduleOn(user.id, AppModule.story);
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
                subtitle: context.isCartoon ? 'Planın, tariflerin ve minik kampanyaların burada' : 'Planın, tariflerin ve kampanyaların tek yerde',
                trailing: CartoonAvatar(name: user.displayName, size: 40),
                search: MarketSearchBar(
                  hint: 'Tarif, yazı veya hizmet ara',
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
                padding: context.homePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visibleStories.isNotEmpty && !context.isDesktopLayout)
                      StoryRail(
                        items: visibleStories,
                        seenIds: _seenStories,
                        onSeen: (id) => setState(() => _seenStories.add(id)),
                      ),
                    if (visibleStories.isNotEmpty && !context.isDesktopLayout) const SizedBox(height: 8),
                    PromoSlider(slides: slides),
                    const SizedBox(height: 12),
                    CategoryStrip(items: cats),
                    const SizedBox(height: 12),
                    const BadgeHomeStrip(),
                    const SizedBox(height: 12),
                    if (store.moduleOn(user.id, AppModule.recipes) && recipes.isNotEmpty) ...[
                      const RecipeTonightCard(),
                      const SizedBox(height: 8),
                    ],
                    if (store.moduleOn(user.id, AppModule.blog)) ...[
                      const LearnHomeRail(),
                      const SizedBox(height: 8),
                    ],
                    TodayStrip(
                      items: [
                        if (store.moduleOn(user.id, AppModule.story))
                          TodayStat(
                            label: 'Seri',
                            value: '${streak.current} gün',
                            kind: KawaiiKind.fire,
                            color: AppColors.primary,
                            onTap: () => context.push('/app/story'),
                          ),
                        if (store.moduleOn(user.id, AppModule.water))
                          TodayStat(
                            label: 'Su',
                            value: '%${(water.progress * 100).round()}',
                            kind: KawaiiKind.water,
                            color: AppColors.accent,
                            onTap: () {
                              store.addWaterSip(user.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('+250 ml eklendi'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(milliseconds: 900),
                                  backgroundColor: AppColors.accent,
                                ),
                              );
                            },
                          ),
                        if (store.moduleOn(user.id, AppModule.diet))
                          TodayStat(
                            label: 'Öğün',
                            value: leftover.isEmpty ? 'Tamam' : '${leftover.length} kaldı',
                            kind: KawaiiKind.plate,
                            color: AppColors.peachDeep,
                            onTap: () => context.go('/app/diet'),
                          ),
                      ],
                    ),
                    if (store.moduleOn(user.id, AppModule.services) && services.isNotEmpty)
                      HorizontalRail(
                        title: 'Kampanyalar',
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
                    if (store.moduleOn(user.id, AppModule.recipes) && recipes.isNotEmpty)
                      HorizontalRail(
                        title: 'Sana özel tarifler',
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
                    if (store.moduleOn(user.id, AppModule.blog) && posts.isNotEmpty)
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
                    if (store.moduleOn(user.id, AppModule.diet)) ...[
                    SectionHeader(
                      title: 'Bugünün planı',
                      action: TextButton(onPressed: () => context.go('/app/diet'), child: const Text('Tümü')),
                    ),
                    if (todayMeals.isEmpty)
                      const EmptyState(icon: Icons.restaurant, title: 'Bugün için öğün yok', subtitle: 'Diyet listen gelince buradan devam edersin.')
                    else
                      DiyetselCard(
                        child: Column(
                          children: [
                            for (final m in leftover.take(3))
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                value: m.consumed,
                                secondary: StyleIcon(icon: Icons.restaurant, emoji: m.type.emoji, size: 22),
                                title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('${m.type.tr} • ${m.calories} kcal'),
                                onChanged: plan == null
                                    ? null
                                    : (_) {
                                        final dayIndex = plan.days.indexWhere((d) => DateUtils.isSameDay(d.date, DateTime.now()));
                                        if (dayIndex >= 0) {
                                          ref.read(appStoreProvider).toggleMealConsumed(plan, dayIndex, m.id);
                                        }
                                      },
                              ),
                            if (leftover.isEmpty)
                              const ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('Tüm öğünler tamam', style: TextStyle(fontWeight: FontWeight.w800)),
                                subtitle: Text('Harika gidiyorsun'),
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
                    ],
                    const SizedBox(height: 10),
                    if (store.moduleOn(user.id, AppModule.appointments))
                    if (next.isEmpty)
                      DiyetselCard(
                        onTap: () => context.go('/app/appointments'),
                        child: Row(
                          children: [
                            const StyleIcon(icon: Icons.event, emoji: '📅', size: 26, color: AppColors.primaryDeep),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Randevu al', style: TextStyle(fontWeight: FontWeight.w800)),
                                  Text('Müsait slotlara bak', style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      CountdownCard(appointment: next.first),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
          Text('$hours sa $mins dk', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 22)),
        ],
      ),
    );
  }
}

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key, required this.admin});
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(settingsProvider);
    ref.watch(usersProvider);
    final raw = admin
        ? const [
            (Icons.edit_note, '📝', 'Blog editörü', '/admin/blog'),
            (Icons.medical_services, '🎁', 'Hizmetler', '/admin/services'),
            (Icons.menu_book, '🍲', 'Tarifler', '/admin/recipes'),
            (Icons.restaurant, '🥗', 'Diyet planları', '/admin/diet-plans'),
            (Icons.photo, '📷', 'Öğün günlüğü', '/admin/meals'),
            (Icons.settings, '⚙️', 'Ayarlar', '/admin/settings'),
          ]
        : const [
            (Icons.article, '📰', 'Blog', '/app/blog'),
            (Icons.storefront, '🎁', 'Hizmetler', '/app/services'),
            (Icons.chat, '💬', 'Sohbet', '/app/chat'),
            (Icons.menu_book, '🍲', 'Tarifler', '/app/recipes'),
            (Icons.shopping_cart, '🛒', 'Alışveriş listesi', '/app/shopping'),
            (Icons.folder, '📁', 'Belge kasası', '/app/documents'),
            (Icons.insights_rounded, '📊', 'Haftalık / aylık rapor', '/app/reports'),
            (Icons.emoji_events_rounded, '🏆', 'Rozetler', '/app/badges'),
            (Icons.school_rounded, '📚', 'Mini dersler', '/app/learn'),
            (Icons.qr_code_scanner, '📷', 'Barkod', '/app/barcode'),
            (Icons.favorite, '❤️', 'Check-in', '/app/check-in'),
            (Icons.restaurant_menu, '🍽️', 'Dışarıda ne yesem', '/app/eat-out'),
            (Icons.auto_awesome, '✨', 'Hikaye kartı', '/app/story'),
            (Icons.hourglass_bottom, '⏳', 'Aralıklı oruç', '/app/fasting'),
            (Icons.water_drop, '💧', 'Su kısayolu', '/app/water-shortcut'),
            (Icons.settings, '⚙️', 'Ayarlar', '/app/settings'),
          ];
    final items = admin
        ? raw
        : raw.where((item) {
            if (item.$4 == '/app/reports' || item.$4 == '/app/water-shortcut' || item.$4 == '/app/settings' || item.$4 == '/app/badges' || item.$4 == '/app/learn') {
              return item.$4 != '/app/water-shortcut' || store.moduleOn(user.id, AppModule.water);
            }
            final id = AppModule.fromRoute(item.$4);
            return id == null || store.moduleOn(user.id, id);
          }).toList();
    return AppPage(
      title: 'Daha fazla',
      child: GridView.count(
        crossAxisCount: context.isDesktopLayout ? 4 : (context.isWide ? 3 : 2),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          for (final item in items)
            DiyetselCard(
              onTap: () {
                if (item.$4 == '/app/water-shortcut') {
                  final user = ref.read(authControllerProvider).user!;
                  final store = ref.read(appStoreProvider);
                  final prefs = store.prefs(user.id);
                  final next = !prefs.waterShortcut;
                  store.savePrefs(user.id, prefs.copyWith(waterShortcut: next));
                  if (next) {
                    ReminderService.instance.showWaterShortcut();
                  } else {
                    ReminderService.instance.hideWaterShortcut();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        next
                            ? (ReminderService.instance.supportsNative
                                ? 'Kalıcı su bildirimi açıldı.'
                                : 'Android’de kalıcı bildirim olur. Windows’ta widget yok.')
                            : 'Su kısayolu kapatıldı.',
                      ),
                    ),
                  );
                  return;
                }
                context.push(item.$4);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StyleIcon(icon: item.$1, emoji: item.$2, size: 28),
                  const SizedBox(height: 10),
                  Text(item.$3, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
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
