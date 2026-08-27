import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/pdf_report.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key, this.clientId});

  final String? clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    ref.watch(measurementsProvider);
    ref.watch(checkInsProvider);
    ref.watch(appointmentsProvider);
    ref.watch(dietPlansProvider);

    final subject = clientId != null
        ? store.user(clientId!)
        : auth.user;
    if (subject == null) {
      return const AppPage(title: 'Raporlar', child: EmptyState(icon: Icons.person, title: 'Kullanıcı bulunamadı'));
    }

    final weekly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.weekly);
    final monthly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.monthly);
    final isAdminView = clientId != null;

    return AppPage(
      title: isAdminView ? '${subject.displayName} — raporlar' : 'Raporlarım',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.insights_rounded,
            emoji: '📊',
            title: isAdminView ? 'Danışan özeti' : 'İlerlemen tek PDF’te',
            subtitle: 'Haftalık ve aylık özet; su, diyet uyumu, kilo ve seanslar bir arada.',
          ),
          const SizedBox(height: 14),
          _PeriodCard(
            report: weekly,
            onPdf: () => PdfReport.sharePeriodReport(weekly),
          ),
          const SizedBox(height: 12),
          _PeriodCard(
            report: monthly,
            onPdf: () => PdfReport.sharePeriodReport(monthly),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Tam geçmiş raporu',
                  subtitle: 'Tüm diyet planı, ölçümler ve klinik notları.',
                ),
                DiyetselButton(
                  label: 'Tam PDF oluştur',
                  icon: Icons.picture_as_pdf_rounded,
                  tonal: true,
                  onPressed: () => PdfReport.shareClientReport(
                    user: subject,
                    plan: store.dietPlanForClient(subject.id),
                    measurements: store.measurements(subject.id),
                    appointments: store.appointments().where((a) => a.clientId == subject.id).toList(),
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

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.report, required this.onPdf});

  final PeriodReportData report;
  final VoidCallback onPdf;

  @override
  Widget build(BuildContext context) {
    final range = '${DateFormat('d MMM', 'tr').format(report.start)} – ${DateFormat('d MMM y', 'tr').format(report.end)}';
    final compliance = (report.dietCompliance * 100).round();

    return DiyetselCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StyleIcon(
                icon: report.period == ReportPeriod.weekly ? Icons.date_range_rounded : Icons.calendar_month_rounded,
                emoji: report.period == ReportPeriod.weekly ? '📅' : '🗓️',
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.periodLabel, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(range, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(
                icon: Icons.water_drop_rounded,
                emoji: '💧',
                label: 'Su ort.',
                value: report.waterDays == 0 ? '—' : '${(report.avgWaterMl / 1000).toStringAsFixed(1)} L',
              ),
              _StatChip(
                icon: Icons.check_circle_rounded,
                emoji: '✅',
                label: 'Su hedefi',
                value: '${report.waterGoalDays}/${report.waterDays} gün',
              ),
              _StatChip(
                icon: Icons.restaurant_rounded,
                emoji: '🥗',
                label: 'Diyet',
                value: report.dietMealsTotal == 0 ? '—' : '%$compliance',
              ),
              _StatChip(
                icon: Icons.local_fire_department_rounded,
                emoji: '🔥',
                label: 'Seri',
                value: '${report.streakCurrent} gün',
              ),
              if (report.weightDelta != null)
                _StatChip(
                  icon: Icons.monitor_weight_rounded,
                  emoji: '⚖️',
                  label: 'Kilo',
                  value: '${report.weightDelta! <= 0 ? '' : '+'}${report.weightDelta!.toStringAsFixed(1)} kg',
                ),
              _StatChip(
                icon: Icons.event_available_rounded,
                emoji: '📅',
                label: 'Seans',
                value: '${report.appointments}',
              ),
              _StatChip(
                icon: Icons.favorite_rounded,
                emoji: '❤️',
                label: 'Check-in',
                value: '${report.checkIns}',
              ),
            ],
          ),
          if (report.dailyWater.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text('Su günlük', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            for (final log in report.dailyWater)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('d MMM EEE', 'tr').format(_parseDayKey(log.day)),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      '${log.amountMl} / ${log.goalMl} ml',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: log.progress >= 1 ? AppColors.success : null,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 14),
          DiyetselButton(
            label: 'PDF indir / paylaş',
            icon: Icons.ios_share_rounded,
            onPressed: onPdf,
          ),
        ],
      ),
    );
  }

  DateTime _parseDayKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.emoji,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StyleIcon(icon: icon, emoji: emoji, size: 16, sticker: false, color: AppColors.primary),
          const SizedBox(width: 6),
          Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
