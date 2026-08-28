import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/cartoon_asset_icon.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/visuals.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../engage/presentation/engage_screens.dart';

class TrackerHubScreen extends ConsumerStatefulWidget {
  const TrackerHubScreen({super.key});

  @override
  ConsumerState<TrackerHubScreen> createState() => _TrackerHubScreenState();
}

class _TrackerHubScreenState extends ConsumerState<TrackerHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.water, title: 'Takip');
    if (locked != null) return locked;

    final cartoon = context.isCartoon;
    if (!cartoon) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Takip'),
          bottom: TabBar(
            controller: _tabs,
            tabs: const [
              Tab(text: 'Su'),
              Tab(text: 'Vücut'),
              Tab(text: 'Öğün foto'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabs,
          children: const [
            WaterTrackerScreen(),
            BodyTrackerScreen(),
            MealPhotoScreen(embedded: true),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.kawaiiSurfaceCream,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Takip',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.kawaiiInk,
                            letterSpacing: -0.4,
                          ),
                        ),
                        Text(
                          'Su, vücut ve öğün fotoğrafların tek yerde',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.kawaiiMuted.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    DiyetselAssets.mascotAvocado,
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(width: 48, height: 48),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.06, curve: Curves.easeOutCubic),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CartoonTrackerTabs(controller: _tabs),
            ).animate().fadeIn(delay: 60.ms, duration: 320.ms).slideY(begin: 0.08, curve: Curves.easeOutBack),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  WaterTrackerScreen(),
                  BodyTrackerScreen(),
                  MealPhotoScreen(embedded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartoonTrackerTabs extends StatelessWidget {
  const _CartoonTrackerTabs({required this.controller});

  final TabController controller;

  static const _items = [
    (label: 'Su', asset: DiyetselAssets.iconWaterDrop, fallback: Icons.water_drop_rounded),
    (label: 'Vücut', asset: DiyetselAssets.iconDietScale, fallback: Icons.monitor_weight_outlined),
    (label: 'Öğün', asset: DiyetselAssets.foodSaladBowl, fallback: Icons.photo_camera_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Row(
            children: [
              for (var i = 0; i < _items.length; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _CartoonTabChip(
                    label: _items[i].label,
                    asset: _items[i].asset,
                    fallback: _items[i].fallback,
                    selected: controller.index == i,
                    onTap: () => controller.animateTo(i),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _CartoonTabChip extends StatelessWidget {
  const _CartoonTabChip({
    required this.label,
    required this.asset,
    required this.fallback,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String asset;
  final IconData fallback;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.kawaiiLeaf : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.kawaiiLeaf.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.08 : 1,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: CartoonAssetIcon(
                  asset,
                  size: 26,
                  fallback: fallback,
                  fallbackColor: selected ? Colors.white : AppColors.kawaiiMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: selected ? Colors.white : AppColors.kawaiiMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    final log = store.waterLog(user.id, DateTime.now());
    final cartoon = context.isCartoon;
    final pct = (log.progress * 100).round().clamp(0, 100);

    if (!cartoon) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: WaterSipGlass(
              progress: log.progress,
              amountMl: log.amountMl,
              cartoon: false,
              sipLabel: '+ ${AppConstants.waterSipMl} ml',
              onAdd: () => store.addWaterSip(user.id),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${log.amountMl} / ${log.goalMl} ml',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              log.progress >= 1 ? 'Kahraman gibi içtin! 🏆' : 'Bardağa veya + tuşuna basarak su ekle.',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          DiyetselButton(
            label: 'Su ekle  +${AppConstants.waterSipMl} ml',
            accent: true,
            icon: Icons.water_drop,
            onPressed: () => store.addWaterSip(user.id),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.softLift,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.kawaiiSky.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: const Text(
                      'Bugünkü su',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiInk),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '%$pct',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.kawaiiSkyBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              WaterSipGlass(
                progress: log.progress,
                amountMl: log.amountMl,
                cartoon: true,
                size: 200,
                sipLabel: '+ ${AppConstants.waterSipMl} ml',
                onAdd: () => store.addWaterSip(user.id),
              ),
              Text(
                '${log.amountMl} / ${log.goalMl} ml',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: AppColors.kawaiiInk,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                log.progress >= 1
                    ? 'Hedef doldu — süper iş! 🎉'
                    : 'Damla ya da + tuşuna bas, bardak dolsun.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: AppColors.kawaiiMuted.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: log.progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.kawaiiSky.withValues(alpha: 0.55),
                  color: AppColors.kawaiiSkyBlue,
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 320.ms)
            .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 480.ms),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _WaterStatPill(
                asset: DiyetselAssets.iconWaterBottle,
                label: 'Kalan',
                value: '${(log.goalMl - log.amountMl).clamp(0, log.goalMl)} ml',
                accent: AppColors.kawaiiSkyBlue,
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms).slideX(begin: -0.06),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _WaterStatPill(
                asset: DiyetselAssets.iconWaterDrop,
                label: 'Yudum',
                value: '+${AppConstants.waterSipMl} ml',
                accent: AppColors.kawaiiLeaf,
              ).animate().fadeIn(delay: 140.ms, duration: 300.ms).slideX(begin: 0.06),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.kawaiiSky.withValues(alpha: 0.75),
                AppColors.kawaiiMint.withValues(alpha: 0.55),
              ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.kawaiiOutline),
          ),
          child: Row(
            children: [
              const CartoonAssetIcon(
                DiyetselAssets.iconWaterDrop,
                size: 40,
                fallback: Icons.water_drop_rounded,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Hedef: ${log.goalMl} ml — her yudum sayılır, gün boyu küçük adımlar yeter!',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiInk, height: 1.35),
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 160.ms, duration: 320.ms)
            .slideY(begin: 0.08, curve: Curves.easeOutCubic),
        const SizedBox(height: 16),
        Material(
          color: AppColors.kawaiiSkyBlue,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            onTap: () => store.addWaterSip(user.id),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CartoonAssetIcon(
                    DiyetselAssets.iconWaterDrop,
                    size: 22,
                    fallback: Icons.water_drop,
                    fallbackColor: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Su ekle',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
      ],
    );
  }
}

class _WaterStatPill extends StatelessWidget {
  const _WaterStatPill({
    required this.asset,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String asset;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          CartoonAssetIcon(asset, size: 32, fallback: Icons.water_drop),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted)),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BodyTrackerScreen extends ConsumerWidget {
  const BodyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(measurementsProvider);
    final items = store.measurements(user.id);
    final cartoon = context.isCartoon;
    final latest = items.isNotEmpty ? items.last : null;

    if (!cartoon) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DiyetselCard(
            child: SizedBox(
              height: 220,
              child: items.length < 2
                  ? const Center(child: Text('En az iki ölçüm ekleyin'))
                  : LineChart(_lineData(context, items)),
            ),
          ),
          const SizedBox(height: 12),
          BeforeAfterSlider(
            before: items.isNotEmpty && items.first.beforePhotoPath != null
                ? FileImage(File(items.first.beforePhotoPath!))
                : null,
            after: items.isNotEmpty && items.last.afterPhotoPath != null
                ? FileImage(File(items.last.afterPhotoPath!))
                : null,
          ),
          const SizedBox(height: 12),
          DiyetselButton(
            label: 'Ölçüm ekle',
            icon: Icons.add,
            onPressed: () => _add(context, store, user.id),
          ),
          for (final m in items.reversed)
            ListTile(
              title: Text('${m.weight ?? '-'} kg • bel ${m.waist ?? '-'}'),
              subtitle: Text(DateFormat('d MMM y', 'tr').format(m.date)),
            ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        if (latest != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.kawaiiLilac, AppColors.kawaiiSurfaceCream],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
              border: Border.all(color: AppColors.kawaiiOutline),
              boxShadow: AppSpacing.softLift,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Son ölçüm',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latest.weight != null ? '${latest.weight} kg' : 'Kilo yok',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.kawaiiInk),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (latest.waist != null) 'Bel ${latest.waist} cm',
                          if (latest.bodyFat != null) 'Yağ %${latest.bodyFat}',
                          DateFormat('d MMM', 'tr').format(latest.date),
                        ].join(' · '),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.kawaiiMuted),
                      ),
                    ],
                  ),
                ),
                const CartoonAssetIcon(
                  DiyetselAssets.iconDietScale,
                  size: 72,
                  fallback: Icons.monitor_weight_outlined,
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: -0.05, curve: Curves.easeOutCubic),
        if (latest == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
              border: Border.all(color: AppColors.kawaiiOutline),
            ),
            child: Column(
              children: [
                Image.asset(DiyetselAssets.characterActiveBoy, height: 100, fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(height: 80)),
                const SizedBox(height: 10),
                const Text(
                  'Henüz ölçüm yok',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 4),
                const Text(
                  'İlk kilonu ekle — grafik ve önce/sonra burada canlanır.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kilo grafiği',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.kawaiiInk),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: items.length < 2
                    ? const Center(
                        child: Text(
                          'Grafik için en az iki ölçüm ekle',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
                        ),
                      )
                    : LineChart(_lineData(context, items, cartoon: true)),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: 320.ms)
            .slideY(begin: 0.06, curve: Curves.easeOutCubic),
        const SizedBox(height: 14),
        BeforeAfterSlider(
          before: items.isNotEmpty && items.first.beforePhotoPath != null
              ? FileImage(File(items.first.beforePhotoPath!))
              : null,
          after: items.isNotEmpty && items.last.afterPhotoPath != null
              ? FileImage(File(items.last.afterPhotoPath!))
              : null,
        ).animate().fadeIn(delay: 120.ms, duration: 320.ms),
        const SizedBox(height: 14),
        Material(
          color: AppColors.kawaiiLeaf,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: InkWell(
            onTap: () => _add(context, store, user.id, cartoon: true),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white),
                  SizedBox(width: 6),
                  Text('Ölçüm ekle', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 160.ms).scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            'Geçmiş',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.reversed.length; i++)
            _BodyHistoryTile(m: items.reversed.elementAt(i))
                .animate()
                .fadeIn(delay: (180 + i * 40).ms, duration: 280.ms)
                .slideX(begin: 0.04, curve: Curves.easeOutCubic),
        ],
      ],
    );
  }

  LineChartData _lineData(BuildContext context, List<BodyMeasurement> items, {bool cartoon = false}) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => FlLine(
          color: cartoon ? AppColors.kawaiiOutline.withValues(alpha: 0.7) : Theme.of(context).dividerColor,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text(
              v.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: cartoon ? AppColors.kawaiiMuted : null,
              ),
            ),
          ),
        ),
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: true,
          color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
          barWidth: cartoon ? 3.5 : 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (s, p, b, i) => FlDotCirclePainter(
              radius: cartoon ? 4.5 : 3.5,
              color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
          belowBarData: BarAreaData(
            show: cartoon,
            color: AppColors.kawaiiLeaf.withValues(alpha: 0.12),
          ),
          spots: [
            for (var i = 0; i < items.length; i++) FlSpot(i.toDouble(), items[i].weight ?? 0),
          ],
        ),
      ],
    );
  }

  Future<void> _add(BuildContext context, AppStore store, String userId, {bool cartoon = false}) async {
    final w = TextEditingController();
    final waist = TextEditingController();
    final fat = TextEditingController();
    String? before;
    String? after;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          backgroundColor: cartoon ? AppColors.kawaiiCream : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cartoon ? AppSpacing.radiusCard : 12),
          ),
          title: Text(
            'Yeni ölçüm',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: cartoon ? AppColors.kawaiiInk : null,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: w, decoration: const InputDecoration(labelText: 'Kilo (kg)'), keyboardType: TextInputType.number),
              TextField(controller: waist, decoration: const InputDecoration(labelText: 'Bel (cm)'), keyboardType: TextInputType.number),
              TextField(controller: fat, decoration: const InputDecoration(labelText: 'Yağ %'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                  setLocal(() => before = file?.path ?? before);
                },
                child: Text(before == null ? 'Önce foto' : 'Önce foto seçildi'),
              ),
              TextButton(
                onPressed: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                  setLocal(() => after = file?.path ?? after);
                },
                child: Text(after == null ? 'Sonra foto' : 'Sonra foto seçildi'),
              ),
            ],
          ),
          actions: [
            FilledButton(
              style: cartoon
                  ? FilledButton.styleFrom(
                      backgroundColor: AppColors.kawaiiLeaf,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    )
                  : null,
              onPressed: () async {
                await store.saveMeasurement(
                  BodyMeasurement(
                    id: newId(),
                    userId: userId,
                    date: DateTime.now(),
                    weight: double.tryParse(w.text),
                    waist: double.tryParse(waist.text),
                    bodyFat: double.tryParse(fat.text),
                    beforePhotoPath: before,
                    afterPhotoPath: after,
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyHistoryTile extends StatelessWidget {
  const _BodyHistoryTile({required this.m});
  final BodyMeasurement m;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.kawaiiOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.kawaiiMint.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              m.weight != null ? '${m.weight!.round()}' : '—',
              style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.kawaiiLeafDeep),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${m.weight ?? '-'} kg · bel ${m.waist ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiInk),
                ),
                Text(
                  DateFormat('d MMMM y', 'tr').format(m.date),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MealPhotoScreen extends ConsumerWidget {
  const MealPhotoScreen({super.key, this.admin = false, this.embedded = false});
  final bool admin;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final logs = (ref.watch(mealLogsProvider).valueOrNull ?? []).where((e) => admin || e.clientId == user.id).toList();
    final cartoon = context.isCartoon;

    final body = logs.isEmpty
        ? (cartoon
            ? _CartoonMealEmpty(onCapture: admin ? null : () => capturePlatePhoto(context, ref))
            : const EmptyState(icon: Icons.photo, title: 'Henüz foto yok'))
        : ListView(
            padding: EdgeInsets.fromLTRB(cartoon ? 18 : 0, cartoon ? 8 : 0, cartoon ? 18 : 0, cartoon ? 88 : 0),
            children: [
              if (cartoon && !admin)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Öğün günlüğün',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk),
                        ),
                      ),
                      Material(
                        color: AppColors.kawaiiLeaf,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => capturePlatePhoto(context, ref),
                          borderRadius: BorderRadius.circular(16),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text('Çek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 280.ms),
              for (var i = 0; i < logs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealLogCard(log: logs[i], admin: admin, store: store, index: i),
                ),
            ],
          );

    if (embedded || (cartoon && !admin)) {
      return cartoon
          ? Stack(
              children: [
                ColoredBox(color: AppColors.kawaiiSurfaceCream, child: body),
                if (!admin && logs.isNotEmpty)
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: Material(
                      color: AppColors.kawaiiLeaf,
                      shape: const CircleBorder(),
                      elevation: 4,
                      shadowColor: AppColors.kawaiiLeaf.withValues(alpha: 0.4),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => capturePlatePhoto(context, ref),
                        child: const SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.camera_alt_rounded, color: Colors.white),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
                  ),
              ],
            )
          : body;
    }

    return AppPage(
      title: 'Öğün foto günlüğü',
      fab: admin
          ? null
          : FloatingActionButton(
              onPressed: () => capturePlatePhoto(context, ref),
              child: const Icon(Icons.camera_alt),
            ),
      child: body,
    );
  }
}

class _CartoonMealEmpty extends StatelessWidget {
  const _CartoonMealEmpty({this.onCapture});
  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              DiyetselAssets.foodLentilSoup,
              height: 140,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.restaurant, size: 64),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut),
            const SizedBox(height: 16),
            const Text(
              'Henüz öğün fotoğrafı yok',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tabağını çek, diyetisyenin görsün ve sana not bıraksın.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted, height: 1.4),
            ),
            if (onCapture != null) ...[
              const SizedBox(height: 20),
              Material(
                color: AppColors.kawaiiLeaf,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: onCapture,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                    child: Text('İlk fotoğrafı çek', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 360.ms).scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack);
  }
}

class _MealLogCard extends StatelessWidget {
  const _MealLogCard({
    required this.log,
    required this.admin,
    required this.store,
    required this.index,
  });

  final MealPhotoLog log;
  final bool admin;
  final AppStore store;
  final int index;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final card = DiyetselCard(
      color: cartoon ? Colors.white : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            log.clientName,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: cartoon ? AppColors.kawaiiInk : null,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(
              cartoon ? AppSpacing.radiusCard : (context.isLuxury ? 8 : 20),
            ),
            child: Image.file(
              File(log.photoPath),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox(
                height: 80,
                child: Center(child: Text('Görsel yüklenemedi')),
              ),
            ),
          ),
          if (log.caption != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(log.caption!, style: TextStyle(fontWeight: cartoon ? FontWeight.w600 : FontWeight.w400)),
            ),
          if (log.stamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: StatusChip(label: stampLabel(log.stamp), color: stampColor(log.stamp)),
            ),
          Wrap(
            spacing: 8,
            children: [
              for (final e in ['👏 Harika seçim', '⚠️ Porsiyon fazla', '💪 Devam'])
                ActionChip(
                  label: Text(e),
                  onPressed: admin
                      ? () async {
                          await store.saveMealLog(
                            log.copyWith(
                              feedbackEmoji: e.split(' ').first,
                              feedbackNote: e,
                            ),
                            countActivity: false,
                          );
                          await store.queueFeedbackNotification(
                            log.clientId,
                            'Diyetisyenin bugün senin için bir not bıraktı: $e',
                          );
                        }
                      : null,
                ),
            ],
          ),
          if (log.feedbackNote != null)
            Text(
              'Diyetisyen: ${log.feedbackNote}',
              style: TextStyle(color: context.brandPrimary, fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );

    if (!cartoon) return card;
    return card
        .animate(delay: (50 * index).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic)
        .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack, duration: 400.ms);
  }
}
