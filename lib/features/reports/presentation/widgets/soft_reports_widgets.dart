import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/utils/report_logic.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/widgets/nav_back.dart';
import '../../../../core/l10n/ui_string.dart';


class SoftReportsHeader extends StatelessWidget {
  const SoftReportsHeader({super.key, this.adminName});

  final String? adminName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((adminName != null ? 'Danışan raporu' : 'Raporlar').ui,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text((adminName ?? 'Haftalık / aylık skor ve PDF').ui,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconCheck,
            size: 28,
            fallback: Icons.insights_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftReportsHero extends StatelessWidget {
  const SoftReportsHero({super.key, required this.report, this.adminName});

  final PeriodReportData report;
  final String? adminName;

  @override
  Widget build(BuildContext context) {
    final score = report.wellnessScore;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92,
                  height: 92,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    color: AppColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(('$score').ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 26,
                        color: AppColors.primaryDeep,
                        height: 1,
                      ),
                    ),
                    Text(('skor').ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((adminName ?? report.periodShort).ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text((report.scoreLabel).ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(('${DateFormat('d MMM', 'tr').format(report.start)} – ${DateFormat('d MMM y', 'tr').format(report.end)}').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernIconCheck,
            size: 56,
            fallback: Icons.emoji_events_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftReportsPeriodToggle extends StatelessWidget {
  const SoftReportsPeriodToggle({
    super.key,
    required this.period,
    required this.onChanged,
  });

  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          _cell('Haftalık', ReportPeriod.weekly, Icons.date_range_rounded),
          _cell('Aylık', ReportPeriod.monthly, Icons.calendar_month_rounded),
        ],
      ),
    );
  }

  Widget _cell(String label, ReportPeriod value, IconData icon) {
    final selected = period == value;
    return Expanded(
      child: SoftTap(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.primary.withValues(alpha: 0.45)),
              const SizedBox(width: 6),
              Text((label).ui,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: selected ? Colors.white : AppColors.primaryDeep,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SoftReportsMetricGrid extends StatelessWidget {
  const SoftReportsMetricGrid({super.key, required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final compliance = (report.dietCompliance * 100).round();
    final water = report.waterDays == 0 ? '—' : '${(report.avgWaterMl / 1000).toStringAsFixed(1)} L';
    final diet = report.dietMealsTotal == 0 ? '—' : '%$compliance';
    final weight = report.weightDelta == null
        ? '—'
        : '${report.weightDelta! <= 0 ? '' : '+'}${report.weightDelta!.toStringAsFixed(1)} kg';

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.32,
      children: [
        SoftMetricTile(
          accent: const Color(0xFF5BA3C9),
          icon: Icons.water_drop_rounded,
          asset: DiyetselAssets.modernIconWaterDrop,
          label: 'Su ortalaması',
          value: water,
          sub: report.waterDays == 0 ? 'kayıt yok' : '${report.waterGoalDays}/${report.waterDays} hedef gün',
        ),
        SoftMetricTile(
          accent: AppColors.primary,
          icon: Icons.restaurant_rounded,
          asset: DiyetselAssets.modernIconPlan,
          label: 'Diyet uyumu',
          value: diet,
          sub: report.dietMealsTotal == 0
              ? 'plan yok'
              : '${report.dietMealsConsumed}/${report.dietMealsTotal} öğün',
        ),
        SoftMetricTile(
          accent: const Color(0xFFE07A5F),
          icon: Icons.monitor_weight_rounded,
          asset: DiyetselAssets.modernIconDietScale,
          label: 'Kilo değişimi',
          value: weight,
          sub: report.weightStart != null && report.weightEnd != null
              ? '${report.weightStart!.toStringAsFixed(1)} → ${report.weightEnd!.toStringAsFixed(1)}'
              : 'ölçüm yok',
        ),
        SoftMetricTile(
          accent: const Color(0xFFD4A017),
          icon: Icons.local_fire_department_rounded,
          asset: DiyetselAssets.modernIconStreak,
          label: 'Aktif seri',
          value: '${report.streakCurrent} gün',
          sub: 'rekor ${report.streakBest} gün',
        ),
      ],
    );
  }
}

class SoftMetricTile extends StatelessWidget {
  const SoftMetricTile({
    super.key,
    required this.accent,
    required this.icon,
    required this.asset,
    required this.label,
    required this.value,
    required this.sub,
  });

  final Color accent;
  final IconData icon;
  final String asset;
  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftModernIcon(asset, size: 28, fallback: icon, fallbackColor: accent),
          const Spacer(),
          Text((label).ui,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text((value).ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: accent,
            ),
          ),
          Text((sub).ui,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftWaterChartCard extends StatelessWidget {
  const SoftWaterChartCard({super.key, required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final logs = report.dailyWater;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftModernIcon(
                DiyetselAssets.modernIconWaterDrop,
                size: 22,
                fallback: Icons.water_drop_rounded,
                fallbackColor: const Color(0xFF5BA3C9),
              ),
              const SizedBox(width: 6),
              Text(('Günlük su').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text((logs.isEmpty
                ? 'Bu dönemde su kaydı yok.'
                : 'Toplam ${(report.totalWaterMl / 1000).toStringAsFixed(1)} L · hedef gün ${report.waterGoalDays}').ui,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
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
                      child: SoftWaterBar(
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

class SoftWaterBar extends StatelessWidget {
  const SoftWaterBar({
    super.key,
    required this.progress,
    required this.label,
    required this.met,
  });

  final double progress;
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final h = 72 * progress.clamp(0.08, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: h,
            decoration: BoxDecoration(
              color: met ? const Color(0xFF5BA3C9) : const Color(0xFFB8DCEC),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 6),
          Text((label).ui,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftReportsSecondaryStats extends StatelessWidget {
  const SoftReportsSecondaryStats({super.key, required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, Color, String, String)>[
      (Icons.favorite_rounded, DiyetselAssets.modernIconDietScale, const Color(0xFFE07A5F), 'Check-in', '${report.checkIns}'),
      (Icons.event_available_rounded, DiyetselAssets.modernIconCalendar, const Color(0xFF5BA3C9), 'Seans', '${report.appointments}'),
      (Icons.photo_camera_rounded, DiyetselAssets.modernIconPlan, const Color(0xFFD4A017), 'Öğün foto', '${report.mealPhotos}'),
      if (report.avgMood != null)
        (Icons.sentiment_satisfied_alt_rounded, DiyetselAssets.modernIconCheck, AppColors.primary, 'Ruh hali', '${report.avgMood!.toStringAsFixed(1)}/5'),
      if (report.waistDelta != null)
        (
          Icons.straighten_rounded,
          DiyetselAssets.modernIconDietScale,
          const Color(0xFFE07A5F),
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
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SoftModernIcon(i.$2, size: 24, fallback: i.$1, fallbackColor: i.$3),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((i.$4).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    Text((i.$5).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: i.$3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SoftInsightsCard extends StatelessWidget {
  const SoftInsightsCard({super.key, required this.highlights});

  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SoftModernIcon(
                DiyetselAssets.modernIconStory,
                size: 22,
                fallback: Icons.auto_awesome_rounded,
                fallbackColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(('Öne çıkanlar').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                  color: AppColors.primaryDeep,
                ),
              ),
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(('${i + 1}').ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text((highlights[i]).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.4,
                      color: AppColors.primaryDeep.withValues(alpha: 0.88),
                    ),
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

class SoftPdfPrimaryButton extends StatelessWidget {
  const SoftPdfPrimaryButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(('PDF indir / paylaş').ui,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftFullHistoryCard extends StatelessWidget {
  const SoftFullHistoryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            SoftModernIcon(
              DiyetselAssets.modernIconPlan,
              size: 40,
              fallback: Icons.picture_as_pdf_rounded,
              fallbackColor: const Color(0xFFE07A5F),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(('Tam geçmiş raporu').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(('Tüm plan, ölçümler ve seanslar tek PDF’te').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: AppColors.primary.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

class SoftReportsFooterTip extends StatelessWidget {
  const SoftReportsFooterTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.info_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(('Skor; su hedefi, diyet uyumu, seri ve check-in’lerden hesaplanır. PDF’i diyetisyeninle paylaşabilirsin.').ui,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftReportsCompareStrip extends StatelessWidget {
  const SoftReportsCompareStrip({
    super.key,
    required this.weekly,
    required this.monthly,
    required this.active,
  });

  final PeriodReportData weekly;
  final PeriodReportData monthly;
  final ReportPeriod active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SoftComparePill(
            label: 'Haftalık',
            score: weekly.wellnessScore,
            subtitle: weekly.scoreLabel,
            selected: active == ReportPeriod.weekly,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SoftComparePill(
            label: 'Aylık',
            score: monthly.wellnessScore,
            subtitle: monthly.scoreLabel,
            selected: active == ReportPeriod.monthly,
          ),
        ),
      ],
    );
  }
}

class SoftComparePill extends StatelessWidget {
  const SoftComparePill({
    super.key,
    required this.label,
    required this.score,
    required this.subtitle,
    required this.selected,
  });

  final String label;
  final int score;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.primary.withValues(alpha: 0.35) : AppColors.modernLine,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((label).ui,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(('$score').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1,
              color: selected ? AppColors.primary : AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text((subtitle).ui,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftScoreBreakdownCard extends StatelessWidget {
  const SoftScoreBreakdownCard({super.key, required this.report});

  final PeriodReportData report;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, double, Color, IconData)>[
      ('Su hedefi', report.waterDays > 0 ? report.waterGoalRate : 0, const Color(0xFF5BA3C9), Icons.water_drop_rounded),
      ('Diyet uyumu', report.dietMealsTotal > 0 ? report.dietCompliance : 0, AppColors.primary, Icons.restaurant_rounded),
      (
        'Seri',
        report.streakBest == 0 && report.streakCurrent == 0
            ? 0
            : (report.streakCurrent / (report.streakBest == 0 ? 7 : report.streakBest)).clamp(0.0, 1.0),
        const Color(0xFFE07A5F),
        Icons.local_fire_department_rounded,
      ),
      ('Check-in', report.checkIns > 0 ? 1.0 : 0, const Color(0xFFD4A017), Icons.favorite_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('Skor dağılımı').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(('Wellness skorunu oluşturan bileşenler').ui,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            SoftScoreBar(
              label: rows[i].$1,
              value: rows[i].$2,
              color: rows[i].$3,
              icon: rows[i].$4,
            ),
          ],
        ],
      ),
    );
  }
}

class SoftScoreBar extends StatelessWidget {
  const SoftScoreBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final double value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text((label).ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.primaryDeep,
                ),
              ),
            ),
            Text(('%$pct').ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.12),
            color: color,
          ),
        ),
      ],
    );
  }
}
