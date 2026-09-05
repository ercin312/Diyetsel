import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/visuals.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../engage/presentation/engage_screens.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import 'widgets/soft_tracker_widgets.dart';

/// Soft premium modern tracker hub — separate Su / Vücut / Öğün experiences.
class SoftTrackerHubScreen extends ConsumerStatefulWidget {
  const SoftTrackerHubScreen({super.key});

  @override
  ConsumerState<SoftTrackerHubScreen> createState() => _SoftTrackerHubScreenState();
}

class _SoftTrackerHubScreenState extends ConsumerState<SoftTrackerHubScreen>
    with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: SoftTrackerHeader(),
            )
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SoftTrackerTabs(controller: _tabs),
            ).animate().fadeIn(delay: 50.ms, duration: 300.ms),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: const [
                  SoftWaterTrackerScreen(),
                  SoftBodyTrackerScreen(),
                  SoftMealPhotoTrackerScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Su ───────────────────────────────────────────────────────────────────────

class SoftWaterTrackerScreen extends ConsumerWidget {
  const SoftWaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    final log = store.waterLog(user.id, DateTime.now());
    final remaining = (log.goalMl - log.amountMl).clamp(0, log.goalMl);

    final week = <(String, double)>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final w = store.waterLog(user.id, d);
      week.add((DateFormat('E', 'tr').format(d).substring(0, 1), w.progress));
    }

    Future<void> add(int ml) async {
      await store.addWaterSip(user.id, ml: ml);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('+$ml ml eklendi')),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        SoftWaterHero(
          amountMl: log.amountMl,
          goalMl: log.goalMl,
          progress: log.progress,
          glass: WaterSipGlass(
            progress: log.progress,
            amountMl: log.amountMl,
            cartoon: false,
            size: 200,
            sipLabel: '+ ${AppConstants.waterSipMl} ml',
            onAdd: () => add(AppConstants.waterSipMl),
          ),
        ).animate().fadeIn(duration: 320.ms).scale(
              begin: const Offset(0.96, 0.96),
              curve: Curves.easeOutBack,
              duration: 420.ms,
            ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _softPill(
                'Kalan',
                '$remaining ml',
                const Color(0xFF5BA3C9),
                DiyetselAssets.modernIconWaterBottle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _softPill(
                'Hedef',
                '${log.goalMl} ml',
                AppColors.primary,
                DiyetselAssets.modernIconWaterDrop,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SoftWaterQuickAdds(onAdd: add)
            .animate()
            .fadeIn(delay: 80.ms, duration: 280.ms),
        const SizedBox(height: 14),
        SoftTipCard(
          title: log.progress >= 1
              ? 'Hedef tamam'
              : remaining > 500
                  ? 'Hâlâ yolun var'
                  : 'Son düzlük',
          body: log.progress >= 1
              ? 'Bugünkü su hedefini aştın. Fazlasını akşam geç saate bırakma.'
              : 'Her saat başı 150–200 ml hedefle. Kalan: $remaining ml.',
          icon: Icons.tips_and_updates_outlined,
          accent: const Color(0xFF5BA3C9),
          tint: const Color(0xFFE3F2F8),
        ),
        const SizedBox(height: 14),
        SoftWaterWeekStrip(days: week)
            .animate()
            .fadeIn(delay: 120.ms, duration: 300.ms),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE3F2F8), Color(0xFFE8F5F0)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB8DCEC)),
          ),
          child: Row(
            children: [
              SoftModernIcon(
                DiyetselAssets.modernIconWaterDrop,
                size: 36,
                fallback: Icons.water_drop_rounded,
                fallbackColor: const Color(0xFF5BA3C9),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Her öğünde 1 bardak pratik bir ritüel — küçük yudumlar günü tamamlar.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftPrimaryButton(
          label: 'Su ekle  +${AppConstants.waterSipMl} ml',
          icon: Icons.water_drop_rounded,
          color: const Color(0xFF5BA3C9),
          onTap: () => add(AppConstants.waterSipMl),
        ),
      ],
    );
  }

  Widget _softPill(String label, String value, Color accent, String asset) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            asset,
            size: 28,
            fallback: Icons.water_drop_rounded,
            fallbackColor: accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: accent,
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

// ─── Vücut ────────────────────────────────────────────────────────────────────

class SoftBodyTrackerScreen extends ConsumerWidget {
  const SoftBodyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(measurementsProvider);
    final items = store.measurements(user.id);
    final latest = items.isNotEmpty ? items.last : null;
    final first = items.isNotEmpty ? items.first : null;

    double? delta;
    if (first?.weight != null && latest?.weight != null && items.length >= 2) {
      delta = latest!.weight! - first!.weight!;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        SoftBodyHero(latest: latest)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: -0.04, curve: Curves.easeOutCubic),
        const SizedBox(height: 12),
        SoftTipCard(
          title: 'Ölçüm ritmi',
          body: latest == null
              ? 'İlk ölçümünü ekle — aynı tartı, sabah aç karnına, tutarlı bir kıyaslama için.'
              : 'Haftada 1–2 ölçüm yeter. Günlük tartı dalgalanmalarına takılma; trende bak.',
          icon: Icons.monitor_weight_outlined,
          accent: AppColors.primary,
          tint: AppColors.modernMint,
        ),
        if (latest != null) ...[
          const SizedBox(height: 12),
          SoftBodyStatRow(
            items: [
              (
                'kilo',
                latest.weight != null ? '${latest.weight}' : '—',
                AppColors.primary,
              ),
              (
                'bel',
                latest.waist != null ? '${latest.waist}' : '—',
                const Color(0xFF5BA3C9),
              ),
              (
                'değişim',
                delta == null
                    ? '—'
                    : '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}',
                delta == null
                    ? AppColors.primary
                    : (delta <= 0 ? AppColors.success : const Color(0xFFE07A5F)),
              ),
            ],
          ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
        ],
        const SizedBox(height: 14),
        SoftChartCard(
          title: 'Kilo grafiği',
          child: SizedBox(
            height: 200,
            child: items.length < 2
                ? Center(
                    child: Text(
                      'Grafik için en az iki ölçüm ekle',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : LineChart(softWeightChart(items)),
          ),
        ).animate().fadeIn(delay: 90.ms, duration: 300.ms),
        const SizedBox(height: 14),
        SoftChartCard(
          title: 'Önce / sonra',
          child: BeforeAfterSlider(
            before: first?.beforePhotoPath != null
                ? FileImage(File(first!.beforePhotoPath!))
                : null,
            after: latest?.afterPhotoPath != null
                ? FileImage(File(latest!.afterPhotoPath!))
                : null,
          ),
        ).animate().fadeIn(delay: 120.ms, duration: 300.ms),
        const SizedBox(height: 14),
        SoftPrimaryButton(
          label: 'Ölçüm ekle',
          onTap: () => _addMeasurement(context, store, user.id),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 18),
          const Text(
            'Geçmiş',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < items.reversed.length; i++)
            SoftBodyHistoryTile(m: items.reversed.elementAt(i), index: i),
        ],
      ],
    );
  }

  Future<void> _addMeasurement(BuildContext context, AppStore store, String userId) async {
    final w = TextEditingController();
    final waist = TextEditingController();
    final fat = TextEditingController();
    String? before;
    String? after;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 14,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Yeni ölçüm',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: w,
                decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: waist,
                decoration: const InputDecoration(labelText: 'Bel (cm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fat,
                decoration: const InputDecoration(labelText: 'Yağ %'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SoftTap(
                      onTap: () async {
                        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                        setLocal(() => before = file?.path ?? before);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Text(
                          before == null ? 'Önce foto' : 'Önce ✓',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SoftTap(
                      onTap: () async {
                        final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                        setLocal(() => after = file?.path ?? after);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Text(
                          after == null ? 'Sonra foto' : 'Sonra ✓',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SoftPrimaryButton(
                label: 'Kaydet',
                icon: Icons.check_rounded,
                onTap: () async {
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Öğün foto ────────────────────────────────────────────────────────────────

class SoftMealPhotoTrackerScreen extends ConsumerWidget {
  const SoftMealPhotoTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final logs = (ref.watch(mealLogsProvider).valueOrNull ?? [])
        .where((e) => e.clientId == user.id)
        .toList();

    if (logs.isEmpty) {
      return SoftMealEmpty(onCapture: () => capturePlatePhoto(context, ref));
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Öğün günlüğün',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${logs.length} foto',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFFC45A3C),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 260.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Net foto = net geri bildirim',
              body: 'Üstten, iyi ışıkta çek. Porsiyon ve sos görünür olsun — diyetisyenin yorumu daha isabetli olur.',
              icon: Icons.photo_camera_outlined,
              accent: const Color(0xFFE07A5F),
              tint: const Color(0xFFFFF0E8),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < logs.length; i++)
              SoftMealPhotoCard(log: logs[i], index: i),
          ],
        ),
        Positioned(
          right: 18,
          bottom: 18,
          child: Material(
            color: const Color(0xFFE07A5F),
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: const Color(0xFFE07A5F).withValues(alpha: 0.4),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => capturePlatePhoto(context, ref),
              child: const SizedBox(
                width: 58,
                height: 58,
                child: Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 160.ms)
              .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
        ),
      ],
    );
  }
}
