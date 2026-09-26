import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/soft_ui_kit.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/l10n/ui_string.dart';

class SoftTrackerHeader extends StatelessWidget {
  const SoftTrackerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(('Takip').ui,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text((softTimeGreeting() == 'Günaydın'
                    ? 'Sabah suyuyla güne başla — vücut, kilo ve öğünler burada'
                    : 'Su, vücut ve öğün fotoğrafların tek yerde').ui,
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconCheck,
            size: 32,
            fallback: Icons.insights_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftTrackerTabs extends StatelessWidget {
  const SoftTrackerTabs({super.key, required this.controller});

  final TabController controller;

  static final _items = [
    (label: 'Su', asset: DiyetselAssets.modernIconWaterDrop, fallback: Icons.water_drop_rounded, accent: const Color(0xFF5BA3C9)),
    (label: 'Vücut', asset: DiyetselAssets.modernIconDietScale, fallback: Icons.monitor_weight_outlined, accent: AppColors.primary),
    (label: 'Öğün', asset: DiyetselAssets.modernIconPlan, fallback: Icons.photo_camera_rounded, accent: const Color(0xFFE07A5F)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
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
                  child: SoftTap(
                    onTap: () => controller.animateTo(i),
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: controller.index == i ? _items[i].accent : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: controller.index == i
                            ? [
                                BoxShadow(
                                  color: _items[i].accent.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SoftModernIcon(
                            _items[i].asset,
                            size: 24,
                            fallback: _items[i].fallback,
                            fallbackColor: controller.index == i ? Colors.white : AppColors.primary.withValues(alpha: 0.45),
                          ),
                          const SizedBox(height: 4),
                          Text((_items[i].label).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: controller.index == i
                                  ? Colors.white
                                  : AppColors.primary.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
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

class SoftWaterHero extends StatelessWidget {
  const SoftWaterHero({
    super.key,
    required this.amountMl,
    required this.goalMl,
    required this.progress,
    required this.glass,
  });

  final int amountMl;
  final int goalMl;
  final double progress;
  final Widget glass;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round().clamp(0, 100);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2F8), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFB8DCEC)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5BA3C9).withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF5BA3C9).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(('Bugünkü su').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFF2A6B8A),
                  ),
                ),
              ),
              const Spacer(),
              Text(('%$pct').ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: Color(0xFF2A6B8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          glass,
          Text(('$amountMl / $goalMl ml').ui,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 24,
              color: AppColors.primaryDeep,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text((progress >= 1 ? 'Hedef doldu — süper iş!' : 'Bardağa veya hızlı ekle’ye dokun.').ui,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.7),
              color: const Color(0xFF5BA3C9),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftWaterQuickAdds extends StatelessWidget {
  const SoftWaterQuickAdds({super.key, required this.onAdd});

  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int ml) {
      return Expanded(
        child: SoftTap(
          onTap: () => onAdd(ml),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8DCEC)),
              boxShadow: AppSpacing.soft,
            ),
            child: Column(
              children: [
                Text(('+$ml').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Color(0xFF2A6B8A),
                  ),
                ),
                Text((label).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('yudum', 200),
        const SizedBox(width: 8),
        chip('bardak', 250),
        const SizedBox(width: 8),
        chip('şişe', 500),
      ],
    );
  }
}

class SoftWaterWeekStrip extends StatelessWidget {
  const SoftWaterWeekStrip({super.key, required this.days});

  /// Each entry: (label, progress 0-1)
  final List<(String, double)> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('Son 7 gün').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 8 + days[i].$2.clamp(0.0, 1.0) * 48,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            const Color(0xFF5BA3C9).withValues(alpha: 0.2),
                            const Color(0xFF5BA3C9),
                            days[i].$2.clamp(0.0, 1.0),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text((days[i].$1).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class SoftBodyHero extends StatelessWidget {
  const SoftBodyHero({super.key, this.latest});

  final BodyMeasurement? latest;

  @override
  Widget build(BuildContext context) {
    if (latest == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.modernLine),
        ),
        child: Column(
          children: [
            SoftModernIcon(
              DiyetselAssets.modernIconDietScale,
              size: 64,
              fallback: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 12),
            Text(('Henüz ölçüm yok').ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 4),
            Text(('İlk kilonu ekle — grafik ve önce/sonra burada canlanır.').ui,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      );
    }

    final m = latest!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(('Son ölçüm').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text((m.weight != null ? '${m.weight} kg' : 'Kilo yok').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(([
                    if (m.waist != null) 'Bel ${m.waist} cm',
                    if (m.bodyFat != null) 'Yağ %${m.bodyFat}',
                    DateFormat('d MMM', 'tr').format(m.date),
                  ].join(' · ')).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 2),
            ),
            padding: const EdgeInsets.all(14),
            child: SoftModernIcon(
              DiyetselAssets.modernIconDietScale,
              size: 48,
              fallback: Icons.monitor_weight_outlined,
              fallbackColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftBodyStatRow extends StatelessWidget {
  const SoftBodyStatRow({super.key, required this.items});

  final List<(String, String, Color)> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Color.lerp(items[i].$3, Colors.white, 0.85),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: items[i].$3.withValues(alpha: 0.22)),
              ),
              child: Column(
                children: [
                  Text((items[i].$2).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$3,
                    ),
                  ),
                  Text((items[i].$1).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftChartCard extends StatelessWidget {
  const SoftChartCard({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.softLift,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((title).ui,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class SoftBodyHistoryTile extends StatelessWidget {
  const SoftBodyHistoryTile({super.key, required this.m, required this.index});

  final BodyMeasurement m;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text((m.weight != null ? '${m.weight!.round()}' : '—').ui,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(('${m.weight ?? '-'} kg · bel ${m.waist ?? '-'}').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                  ),
                ),
                Text((DateFormat('d MMMM y', 'tr').format(m.date)).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: (40 * index).ms)
        .fadeIn(duration: 260.ms)
        .slideX(begin: 0.04, curve: Curves.easeOutCubic);
  }
}

class SoftPrimaryButton extends StatelessWidget {
  const SoftPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon = Icons.add_rounded,
    this.color = AppColors.primary,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text((label).ui,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftMealEmpty extends StatelessWidget {
  const SoftMealEmpty({super.key, this.onCapture});

  final VoidCallback? onCapture;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.softLift,
              ),
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                DiyetselAssets.foodSaladBowl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.restaurant_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -6, duration: 1800.ms, curve: Curves.easeInOut),
            const SizedBox(height: 18),
            Text(('Henüz öğün fotoğrafı yok').ui,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 8),
            Text(('Tabağını çek, diyetisyenin görsün ve sana not bıraksın.').ui,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
            if (onCapture != null) ...[
              const SizedBox(height: 20),
              SoftPrimaryButton(
                label: 'İlk fotoğrafı çek',
                icon: Icons.camera_alt_rounded,
                onTap: onCapture!,
                color: const Color(0xFFE07A5F),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SoftMealPhotoCard extends StatelessWidget {
  const SoftMealPhotoCard({
    super.key,
    required this.log,
    required this.index,
    this.feedback,
  });

  final MealPhotoLog log;
  final int index;
  final String? feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text((DateFormat('d MMM · HH:mm', 'tr').format(log.createdAt)).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
              if (log.stamp != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((log.stamp!).ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.file(
              File(log.photoPath),
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 120,
                color: AppColors.modernWash,
                alignment: Alignment.center,
                child: Text(('Görsel yüklenemedi').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          if (log.caption?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text((log.caption!).ui,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: AppColors.primaryDeep,
              ),
            ),
          ],
          if (feedback != null || log.feedbackNote != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(('Diyetisyen: ${feedback ?? log.feedbackNote}').ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    )
        .animate(delay: (45 * index).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.06, curve: Curves.easeOutCubic);
  }
}

LineChartData softWeightChart(List<BodyMeasurement> items) {
  return LineChartData(
    gridData: FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (v) => FlLine(
        color: AppColors.modernLine,
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
          getTitlesWidget: (v, _) => Text((v.toStringAsFixed(0)).ui,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    lineBarsData: [
      LineChartBarData(
        isCurved: true,
        color: AppColors.primary,
        barWidth: 3.5,
        dotData: FlDotData(
          show: true,
          getDotPainter: (s, p, b, i) => FlDotCirclePainter(
            radius: 4.5,
            color: AppColors.primary,
            strokeWidth: 2,
            strokeColor: Colors.white,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        spots: [
          for (var i = 0; i < items.length; i++) FlSpot(i.toDouble(), items[i].weight ?? 0),
        ],
      ),
    ],
  );
}
