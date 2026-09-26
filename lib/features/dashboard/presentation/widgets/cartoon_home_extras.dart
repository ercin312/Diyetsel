import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/home_theme_config.dart';
import 'premium_home_widgets.dart';
import '../../../../core/l10n/ui_string.dart';

/// Auto-advancing hero slider for cartoon home — uses [HeroPlanCard].
class CartoonHeroSlider extends StatefulWidget {
  const CartoonHeroSlider({
    super.key,
    required this.slides,
    this.height = 192,
  });

  final List<HomeHeroSlideConfig> slides;
  final double height;

  @override
  State<CartoonHeroSlider> createState() => _CartoonHeroSliderState();
}

class _CartoonHeroSliderState extends State<CartoonHeroSlider> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant CartoonHeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _index = _index.clamp(0, (widget.slides.length - 1).clamp(0, 999));
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  static String resolveImage(HomeHeroSlideConfig slide) {
    final url = slide.imageUrl.trim();
    if (url.isNotEmpty) return url;
    return switch (slide.imageKey) {
      'soup' || 'lentil' => DiyetselAssets.foodLentilSoup,
      'smoothie' || 'drink' => DiyetselAssets.foodGreenSmoothie,
      _ => DiyetselAssets.foodSaladBowl,
    };
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget.slides.isEmpty ? HomeHeroSlideConfig.defaults() : widget.slides;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _restartTimer();
            },
            itemBuilder: (context, i) {
              final slide = slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: HeroPlanCard(
                  title: slide.title,
                  subtitle: slide.description,
                  ctaLabel: slide.buttonText,
                  ctaRoute: slide.buttonRoute,
                  imageAsset: resolveImage(slide),
                  bgColor: slide.background,
                ),
              );
            },
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                GestureDetector(
                  onTap: () {
                    _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppColors.kawaiiLeaf
                          : AppColors.kawaiiLeaf.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Kawaii “Bugünün özeti” with water / meal / streak rings.
class CartoonHomeFocusBanner extends StatelessWidget {
  const CartoonHomeFocusBanner({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(('Bugünün özeti').ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(('Su · öğün · seri — tek bakışta').ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.kawaiiMuted,
                      ),
                    ),
                  ],
                ),
              ),
              SoftTap(
                onTap: onStory,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiCoral,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(color: AppColors.kawaiiGlow, blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(('$streakDays gün').ui,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.white,
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
                  child: _CartoonFocusRing(
                    progress: waterProgress,
                    color: AppColors.kawaiiSkyBlue,
                    label: 'Su',
                    value: '%${(waterProgress * 100).round()}',
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onDiet,
                  child: _CartoonFocusRing(
                    progress: mealP,
                    color: AppColors.kawaiiLeaf,
                    label: 'Öğün',
                    value: '$mealsDone/$mealsTotal',
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onStory,
                  child: _CartoonFocusRing(
                    progress: (streakDays / 7).clamp(0.0, 1.0),
                    color: AppColors.kawaiiCoral,
                    label: 'Seri',
                    value: streakDays > 0 ? '$streakDays' : '0',
                    icon: Icons.bolt_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CartoonFocusRing extends StatelessWidget {
  const _CartoonFocusRing({
    required this.progress,
    required this.color,
    required this.label,
    required this.value,
    this.icon,
  });

  final double progress;
  final Color color;
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _CartoonRingPainter(progress: progress.clamp(0.0, 1.0), color: color),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: color, size: 22)
                  : Text((value).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: AppColors.kawaiiInk,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text((label).ui,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.kawaiiMuted,
          ),
        ),
      ],
    );
  }
}

class _CartoonRingPainter extends CustomPainter {
  _CartoonRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const stroke = 7.0;
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.16)
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
  bool shouldRepaint(covariant _CartoonRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

/// Daily tip strip → /app/learn.
class CartoonHomeTipStrip extends StatelessWidget {
  const CartoonHomeTipStrip({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _tips = [
    (title: 'Su ritmi', body: 'Her öğünden önce bir bardak — tokluk ve odak artar.'),
    (title: 'Protein önce', body: 'Tabağında önce proteini bitir; enerji daha dengeli kalır.'),
    (title: 'Yavaş ye', body: 'Her lokmayı iyi çiğne — doyma sinyali geç gelir.'),
    (title: 'Ateş serisi', body: 'Bugün küçük bir check-in bile seriyi canlı tutar.'),
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().difference(DateTime(DateTime.now().year)).inDays % _tips.length];
    return SoftTap(
      onTap: onTap ?? () => context.push('/app/learn'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.kawaiiMint, AppColors.kawaiiLemon],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.kawaiiLeaf,
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(('Günün ipucu · ${tip.title}').ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: AppColors.kawaiiInk,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text((tip.body).ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.kawaiiMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(('Daha fazla öğren →').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.kawaiiLeafDeep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
