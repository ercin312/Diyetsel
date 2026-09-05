import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/pdf_report.dart';
import '../../../core/utils/report_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_reports_widgets.dart';

/// Soft premium modern reports — skor, metrikler, su grafiği, içgörüler ve PDF.
class SoftReportsScreen extends ConsumerStatefulWidget {
  const SoftReportsScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<SoftReportsScreen> createState() => _SoftReportsScreenState();
}

class _SoftReportsScreenState extends ConsumerState<SoftReportsScreen> {
  ReportPeriod _period = ReportPeriod.weekly;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    ref.watch(measurementsProvider);
    ref.watch(checkInsProvider);
    ref.watch(appointmentsProvider);
    ref.watch(dietPlansProvider);

    final subject = widget.clientId != null ? store.user(widget.clientId!) : auth.user;
    if (subject == null) {
      return const AppPage(
        title: 'Raporlar',
        child: EmptyState(icon: Icons.person, title: 'Kullanıcı bulunamadı'),
      );
    }

    final weekly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.weekly);
    final monthly = buildPeriodReport(store: store, user: subject, period: ReportPeriod.monthly);
    final report = _period == ReportPeriod.weekly ? weekly : monthly;
    final isAdminView = widget.clientId != null;
    final adminName = isAdminView ? subject.displayName : null;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            SoftReportsHeader(adminName: adminName)
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftReportsHero(report: report, adminName: adminName)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftReportsCompareStrip(
              weekly: weekly,
              monthly: monthly,
              active: _period,
            ).animate().fadeIn(delay: 55.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftReportsPeriodToggle(
              period: _period,
              onChanged: (p) => setState(() => _period = p),
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftTipCard(
              title: 'İçgörü ipucu',
              body: report.wellnessScore >= 70
                  ? 'Skor güçlü — su ve öğün tutarlılığını koru; küçük sapmalar haftalık ortalamayı bozmaz.'
                  : 'Skoru yükseltmek için suyu ve check-in’i düzenli tut; PDF’i diyetisyeninle paylaşarak net geri bildirim al.',
              icon: Icons.insights_rounded,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ).animate().fadeIn(delay: 80.ms, duration: 280.ms),
            const SizedBox(height: 16),
            SoftReportsMetricGrid(report: report)
                .animate()
                .fadeIn(delay: 90.ms, duration: 300.ms)
                .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftScoreBreakdownCard(report: report)
                .animate()
                .fadeIn(delay: 105.ms, duration: 300.ms),
            const SizedBox(height: 14),
            SoftWaterChartCard(report: report)
                .animate()
                .fadeIn(delay: 120.ms, duration: 300.ms),
            const SizedBox(height: 14),
            SoftReportsSecondaryStats(report: report)
                .animate()
                .fadeIn(delay: 140.ms, duration: 280.ms),
            if (report.highlights.isNotEmpty) ...[
              const SizedBox(height: 14),
              SoftInsightsCard(highlights: report.highlights)
                  .animate()
                  .fadeIn(delay: 160.ms, duration: 300.ms),
            ],
            const SizedBox(height: 14),
            SoftPdfPrimaryButton(
              onTap: () => PdfReport.sharePeriodReport(report),
            ).animate().fadeIn(delay: 180.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftFullHistoryCard(
              onTap: () => PdfReport.shareClientReport(
                user: subject,
                plan: store.dietPlanForClient(subject.id),
                measurements: store.measurements(subject.id),
                appointments: store.appointments().where((a) => a.clientId == subject.id).toList(),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 280.ms),
            const SizedBox(height: 12),
            const SoftReportsFooterTip()
                .animate()
                .fadeIn(delay: 220.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
