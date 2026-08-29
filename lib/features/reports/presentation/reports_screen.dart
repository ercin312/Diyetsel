import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/pdf_report.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import 'soft_reports_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftReportsScreen(clientId: widget.clientId);
    }

    final auth = ref.watch(authControllerProvider);
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    ref.watch(measurementsProvider);
    ref.watch(checkInsProvider);
    ref.watch(appointmentsProvider);
    ref.watch(dietPlansProvider);

    final subject = widget.clientId != null ? store.user(widget.clientId!) : auth.user;
    if (subject == null) {
      return const AppPage(title: 'Raporlar', child: EmptyState(icon: Icons.person, title: 'Kullanıcı bulunamadı'));
    }

    final weekly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.weekly);
    final monthly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.monthly);
    final report = _period == ReportPeriod.weekly ? weekly : monthly;
    final isAdminView = widget.clientId != null;

    return AppPage(
      title: isAdminView ? '${subject.displayName} — raporlar' : 'Raporlar',
      padding: EdgeInsets.zero,
      child: ColoredBox(
        color: AppColors.kawaiiSurfaceCream,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            _ReportsHero(report: report, adminName: isAdminView ? subject.displayName : null)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            _PeriodToggle(
              period: _period,
              onChanged: (p) => setState(() => _period = p),
            ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
            const SizedBox(height: 16),
            _MetricGrid(report: report)
                .animate()
                .fadeIn(delay: 60.ms, duration: 300.ms)
                .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            _WaterChartCard(report: report)
                .animate()
                .fadeIn(delay: 90.ms, duration: 300.ms),
            const SizedBox(height: 14),
            _SecondaryStats(report: report)
                .animate()
                .fadeIn(delay: 110.ms, duration: 300.ms),
            if (report.highlights.isNotEmpty) ...[
              const SizedBox(height: 14),
              _InsightsCard(highlights: report.highlights)
                  .animate()
                  .fadeIn(delay: 130.ms, duration: 300.ms),
            ],
            const SizedBox(height: 14),
            SoftTap(
              onTap: () => PdfReport.sharePeriodReport(report),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.kawaiiLeaf,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppSpacing.soft,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'PDF indir / paylaş',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 280.ms),
            const SizedBox(height: 12),
            _FullHistoryCard(
              onTap: () => PdfReport.shareClientReport(
                user: subject,
                plan: store.dietPlanForClient(subject.id),
                measurements: store.measurements(subject.id),
                appointments: store.appointments().where((a) => a.clientId == subject.id).toList(),
              ),
            ).animate().fadeIn(delay: 170.ms, duration: 280.ms),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: AppColors.kawaiiOutline),
                boxShadow: AppSpacing.soft,
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.kawaiiLeafDeep),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Skor; su hedefi, diyet uyumu, seri ve check-in’lerden hesaplanır. PDF’i diyetisyeninle paylaşabilirsin.',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 190.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}

class _ReportsHero extends StatelessWidget {
  const _ReportsHero({required this.report, this.adminName});

  final PeriodReportData report;
  final String? adminName;

  @override
  Widget build(BuildContext context) {
    final score = report.wellnessScore;
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
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.65),
                    color: AppColors.kawaiiLeaf,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppColors.kawaiiInk, height: 1),
                    ),
                    const Text('skor', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.kawaiiMuted)),
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
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    adminName != null ? adminName! : report.periodShort,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  report.scoreLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, height: 1.15, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('d MMM', 'tr').format(report.start)} – ${DateFormat('d MMM y', 'tr').format(report.end)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(DiyetselAssets.mascotAvocado, height: 78, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.period, required this.onChanged});

  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          _toggleCell('Haftalık', ReportPeriod.weekly, Icons.date_range_rounded),
          _toggleCell('Aylık', ReportPeriod.monthly, Icons.calendar_month_rounded),
        ],
      ),
    );
  }

  Widget _toggleCell(String label, ReportPeriod value, IconData icon) {
    final selected = period == value;
    return Expanded(
      child: SoftTap(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.kawaiiLeaf : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.kawaiiMuted),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: selected ? Colors.white : AppColors.kawaiiInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final compliance = (report.dietCompliance * 100).round();
    final water = report.waterDays == 0 ? '—' : '${(report.avgWaterMl / 1000).toStringAsFixed(1)} L';
    final diet = report.dietMealsTotal == 0 ? '—' : '%$compliance';
    final weight = report.weightDelta == null
        ? '—'
        : '${report.weightDelta! <= 0 ? '' : '+'}${report.weightDelta!.toStringAsFixed(1)} kg';
    final streak = '${report.streakCurrent}';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: [
        _MetricTile(
          tint: AppColors.kawaiiSky,
          accent: AppColors.kawaiiSkyBlue,
          icon: Icons.water_drop_rounded,
          label: 'Su ortalaması',
          value: water,
          sub: report.waterDays == 0 ? 'kayıt yok' : '${report.waterGoalDays}/${report.waterDays} hedef gün',
        ),
        _MetricTile(
          tint: AppColors.kawaiiMint,
          accent: AppColors.kawaiiLeafDeep,
          icon: Icons.restaurant_rounded,
          label: 'Diyet uyumu',
          value: diet,
          sub: report.dietMealsTotal == 0
              ? 'plan yok'
              : '${report.dietMealsConsumed}/${report.dietMealsTotal} öğün',
        ),
        _MetricTile(
          tint: AppColors.kawaiiPeach,
          accent: AppColors.kawaiiCoralDeep,
          icon: Icons.monitor_weight_rounded,
          label: 'Kilo değişimi',
          value: weight,
          sub: report.weightStart != null && report.weightEnd != null
              ? '${report.weightStart!.toStringAsFixed(1)} → ${report.weightEnd!.toStringAsFixed(1)}'
              : 'ölçüm yok',
        ),
        _MetricTile(
          tint: AppColors.kawaiiLemon,
          accent: AppColors.kawaiiSalmon,
          icon: Icons.local_fire_department_rounded,
          label: 'Aktif seri',
          value: '$streak gün',
          sub: 'rekor ${report.streakBest} gün',
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.tint,
    required this.accent,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  final Color tint;
  final Color accent;
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: accent),
          ),
          const Spacer(),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.kawaiiMuted)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk)),
          Text(sub, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
        ],
      ),
    );
  }
}

class _WaterChartCard extends StatelessWidget {
  const _WaterChartCard({required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final logs = report.dailyWater;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.water_drop_rounded, color: AppColors.kawaiiSkyBlue, size: 20),
              SizedBox(width: 6),
              Text('Günlük su', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.kawaiiInk)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            logs.isEmpty
                ? 'Bu dönemde su kaydı yok.'
                : 'Toplam ${(report.totalWaterMl / 1000).toStringAsFixed(1)} L · hedef gün ${report.waterGoalDays}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
          ),
          const SizedBox(height: 14),
          if (logs.isEmpty)
            const SizedBox(height: 48)
          else
            SizedBox(
              height: 110,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final log in logs.length > 14 ? logs.sublist(logs.length - 14) : logs) ...[
                    Expanded(
                      child: _WaterBar(
                        progress: log.goalMl <= 0 ? 0 : (log.amountMl / log.goalMl).clamp(0.0, 1.2),
                        label: DateFormat('d', 'tr').format(_parseDay(log.day)),
                        met: log.progress >= 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  DateTime _parseDay(String key) {
    final p = key.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }
}

class _WaterBar extends StatelessWidget {
  const _WaterBar({required this.progress, required this.label, required this.met});

  final double progress;
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final h = (72 * progress.clamp(0.08, 1.0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: h,
            decoration: BoxDecoration(
              color: met ? AppColors.kawaiiSkyBlue : AppColors.kawaiiSky,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.kawaiiMuted)),
        ],
      ),
    );
  }
}

class _SecondaryStats extends StatelessWidget {
  const _SecondaryStats({required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, Color, Color, String, String)>[
      (Icons.favorite_rounded, AppColors.kawaiiRose, AppColors.kawaiiCoralDeep, 'Check-in', '${report.checkIns}'),
      (Icons.event_available_rounded, AppColors.kawaiiLilac, AppColors.kawaiiPurple, 'Seans', '${report.appointments}'),
      (Icons.photo_camera_rounded, AppColors.kawaiiLemon, AppColors.kawaiiSalmon, 'Öğün foto', '${report.mealPhotos}'),
      if (report.avgMood != null)
        (Icons.sentiment_satisfied_alt_rounded, AppColors.kawaiiMint, AppColors.kawaiiLeafDeep, 'Ruh hali', '${report.avgMood!.toStringAsFixed(1)}/5'),
      if (report.waistDelta != null)
        (
          Icons.straighten_rounded,
          AppColors.kawaiiPeach,
          AppColors.kawaiiCoralDeep,
          'Bel',
          '${report.waistDelta! <= 0 ? '' : '+'}${report.waistDelta!.toStringAsFixed(1)} cm'
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.kawaiiOutline),
              boxShadow: AppSpacing.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: i.$2, borderRadius: BorderRadius.circular(10)),
                  child: Icon(i.$1, size: 16, color: i.$3),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.$4, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
                    Text(i.$5, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.highlights});

  final List<String> highlights;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: AppColors.kawaiiLeafDeep, size: 20),
              SizedBox(width: 6),
              Text('Öne çıkanlar', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.kawaiiInk)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiMint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.kawaiiLeafDeep)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    highlights[i],
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.4, color: AppColors.kawaiiInk),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FullHistoryCard extends StatelessWidget {
  const _FullHistoryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(14),
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
              decoration: BoxDecoration(
                color: AppColors.kawaiiLilac,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.kawaiiPurple),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tam geçmiş raporu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk)),
                  SizedBox(height: 2),
                  Text(
                    'Tüm plan, ölçümler ve seanslar tek PDF’te',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.kawaiiLeafDeep),
          ],
        ),
      ),
    );
  }
}
