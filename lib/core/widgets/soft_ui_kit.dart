import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;

/// Shared soft-modern enrichment primitives used across e-Diyet screens.
class SoftWashBackground extends StatelessWidget {
  const SoftWashBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.modernWash,
      child: Stack(
        children: [
          Positioned(
            top: -48,
            right: -36,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.07),
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            left: -60,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFE8B8).withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.modernSky.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class SoftSurfaceCard extends StatelessWidget {
  const SoftSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = Colors.white,
    this.onTap,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusCard);
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: child,
    );
    if (onTap == null) return box;
    return SoftTap(onTap: onTap, borderRadius: radius, child: box);
  }
}

class SoftTipCard extends StatelessWidget {
  const SoftTipCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.lightbulb_outline_rounded,
    this.accent = AppColors.primary,
    this.tint,
    this.onTap,
    this.actionLabel,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Color? tint;
  final VoidCallback? onTap;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      onTap: onTap,
      color: tint ?? Color.lerp(accent, Colors.white, 0.88)!,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: accent.withValues(alpha: 0.18)),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep.withValues(alpha: 0.95),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    height: 1.4,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
                if (actionLabel != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    actionLabel!,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: accent,
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
}

class SoftMetricTile extends StatelessWidget {
  const SoftMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.accent = AppColors.primary,
    this.progress,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData? icon;
  final Color accent;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppColors.primaryDeep,
              letterSpacing: -0.4,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 2),
            Text(
              caption!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress!.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: accent.withValues(alpha: 0.12),
                color: accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SoftProgressRing extends StatelessWidget {
  const SoftProgressRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 72,
    this.stroke = 7,
    this.color = AppColors.primary,
  });

  final double progress;
  final Widget child;
  final double size;
  final double stroke;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SoftRingPainter(
          progress: progress.clamp(0.0, 1.0),
          color: color,
          stroke: stroke,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _SoftRingPainter extends CustomPainter {
  _SoftRingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _SoftRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class SoftChipRail extends StatelessWidget {
  const SoftChipRail({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          return SoftTap(
            onTap: () => onSelected(i),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.modernLine,
                ),
                boxShadow: selected ? AppSpacing.soft : null,
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  color: selected ? Colors.white : AppColors.primaryDeep,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoftEmptyRich extends StatelessWidget {
  const SoftEmptyRich({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SoftSurfaceCard(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.modernMint,
              border: Border.all(color: AppColors.modernLine),
            ),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.4,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Rotating wellness tips keyed by day-of-year.
class SoftDailyTips {
  SoftDailyTips._();

  static const tips = [
    (title: 'Su ritmi', body: 'Her öğünden 20 dk önce bir bardak su iç — tokluk ve odak artar.', icon: Icons.water_drop_outlined),
    (title: 'Protein önce', body: 'Tabağında önce proteini bitir; kan şekeri daha dengeli kalır.', icon: Icons.restaurant_outlined),
    (title: 'Yavaş çiğne', body: 'Her lokmayı 15–20 kez çiğne — doyma sinyali geç gelir.', icon: Icons.timer_outlined),
    (title: 'Uyku = metabolizma', body: '7+ saat uyku, ertesi gün atıştırmayı azaltır.', icon: Icons.bedtime_outlined),
    (title: 'Yeşil ara öğün', body: 'Öğleden sonra sebze + yoğurt kombinasyonu enerjini korur.', icon: Icons.eco_outlined),
    (title: 'Adım hedefi', body: 'Yemek sonrası 10 dk yürüyüş, glisemik yükü yumuşatır.', icon: Icons.directions_walk_rounded),
    (title: 'Tabağı böl', body: 'Yarım tabak sebze, çeyrek protein, çeyrek kompleks karbonhidrat.', icon: Icons.pie_chart_outline_rounded),
  ];

  static (String title, String body, IconData icon) ofDay([DateTime? now]) {
    final d = now ?? DateTime.now();
    final i = d.difference(DateTime(d.year)).inDays % tips.length;
    final t = tips[i];
    return (t.title, t.body, t.icon);
  }
}

class SoftDailyTipBanner extends StatelessWidget {
  const SoftDailyTipBanner({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tip = SoftDailyTips.ofDay();
    return SoftTipCard(
      title: 'Günün ipucu · ${tip.$1}',
      body: tip.$2,
      icon: tip.$3,
      accent: AppColors.primary,
      tint: AppColors.modernMint,
      onTap: onTap,
      actionLabel: onTap != null ? 'Daha fazla öğren →' : null,
    ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.04, curve: Curves.easeOutCubic);
  }
}

class SoftTodayFocusCard extends StatelessWidget {
  const SoftTodayFocusCard({
    super.key,
    required this.waterProgress,
    required this.mealsDone,
    required this.mealsTotal,
    required this.streakDays,
    this.onWater,
    this.onDiet,
    this.onStory,
  });

  final double waterProgress;
  final int mealsDone;
  final int mealsTotal;
  final int streakDays;
  final VoidCallback? onWater;
  final VoidCallback? onDiet;
  final VoidCallback? onStory;

  @override
  Widget build(BuildContext context) {
    final mealP = mealsTotal == 0 ? 0.0 : mealsDone / mealsTotal;
    return SoftSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bugünün özeti',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
              SoftTap(
                onTap: onStory,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.modernCoralSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFE07A5F)),
                      const SizedBox(width: 4),
                      Text(
                        '$streakDays gün',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFFC45A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SoftTap(
                  onTap: onWater,
                  child: Column(
                    children: [
                      SoftProgressRing(
                        progress: waterProgress,
                        color: const Color(0xFF5BA3C9),
                        child: Text(
                          '%${(waterProgress * 100).round()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Su',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onDiet,
                  child: Column(
                    children: [
                      SoftProgressRing(
                        progress: mealP,
                        color: AppColors.primary,
                        child: Text(
                          '$mealsDone/$mealsTotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Öğün',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onStory,
                  child: Column(
                    children: [
                      SoftProgressRing(
                        progress: (streakDays / 7).clamp(0.0, 1.0),
                        color: const Color(0xFFE07A5F),
                        child: const Icon(Icons.bolt_rounded, color: Color(0xFFE07A5F), size: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Seri',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.98, 0.98), curve: Curves.easeOutCubic);
  }
}

String softTimeGreeting([DateTime? now]) {
  final h = (now ?? DateTime.now()).hour;
  if (h < 6) return 'İyi geceler';
  if (h < 12) return 'Günaydın';
  if (h < 17) return 'İyi günler';
  if (h < 21) return 'İyi akşamlar';
  return 'İyi geceler';
}
