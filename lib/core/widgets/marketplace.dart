import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../constants/diyetsel_assets.dart';
import '../utils/desktop.dart';
import 'diyetsel_widgets.dart';
import 'kawaii_doodle.dart';
import 'modern_glyph.dart';
import 'style_icon.dart';
import '../l10n/ui_string.dart';

class PromoSlide {
  const PromoSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.route,
    required this.color,
    this.kind,
    this.imageUrl,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String cta;
  final String route;
  final Color color;
  final KawaiiKind? kind;
  final String? imageUrl;

  KawaiiKind get doodle => kind ?? KawaiiKindX.from(emoji: emoji);
}

/// Soft food photo for modern hero / recipe cards when seed has no imageUrl.
String diyetselFoodImage({String? imageUrl, String? seed}) {
  if (imageUrl != null && imageUrl.trim().isNotEmpty) return imageUrl.trim();
  final key = (seed ?? 'bowl').toLowerCase();
  if (key.contains('somon') || key.contains('balık') || key.contains('fish')) {
    return 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=640&q=80';
  }
  if (key.contains('çorba') || key.contains('soup') || key.contains('mercimek')) {
    return 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=640&q=80';
  }
  if (key.contains('yoğurt') || key.contains('yogurt') || key.contains('kase')) {
    return 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=640&q=80';
  }
  if (key.contains('omlet') || key.contains('yumurta')) {
    return 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=640&q=80';
  }
  return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=640&q=80';
}

Widget diyetselFoodPhoto({
  required String url,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
}) {
  final Widget image;
  if (url.startsWith('assets/')) {
    image = Image.asset(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppColors.kawaiiMint,
        alignment: Alignment.center,
        child: const Icon(Icons.restaurant_rounded, color: AppColors.kawaiiLeaf)));
  } else {
    image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => Container(
        width: width,
        height: height,
        color: AppColors.modernSageSoft,
        alignment: Alignment.center,
        child: const Icon(Icons.restaurant_rounded, color: AppColors.modernSage)),
      errorWidget: (_, _, _) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.modernSageSoft, AppColors.modernWash])),
        alignment: Alignment.center,
        child: const Icon(Icons.restaurant_rounded, color: AppColors.modernSage)));
  }
  if (borderRadius != null) {
    return ClipRRect(borderRadius: borderRadius, child: image);
  }
  return image;
}

class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key, required this.slides, this.height = 168});

  final List<PromoSlide> slides;
  final double height;

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.slides.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_index + 1) % widget.slides.length;
        _controller.animateToPage(next, duration: 420.ms, curve: Curves.easeOutCubic);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();
    if (context.isDesktopLayout) return _desktopGrid(context);
    if (!context.isCartoon) return _modernStrip(context);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.slides.length,
            itemBuilder: (context, i) {
              final slide = widget.slides[i];
              final tint = Color.lerp(AppColors.kawaiiBubble, slide.color, 0.16)!;
              final wash = Color.lerp(AppColors.kawaiiCream, slide.color, 0.1)!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(slide.route),
                    borderRadius: BorderRadius.circular(28),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [tint, wash, AppColors.kawaiiMint.withValues(alpha: 0.55)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.kawaiiShadow,
                            blurRadius: 22,
                            offset: Offset(0, 10)),
                        ]),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                        child: Row(
                          children: [
                            KawaiiTile(kind: slide.doodle, size: 68),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((slide.title).ui,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.kawaiiInk,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17)),
                                  Text((slide.subtitle).ui,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: AppColors.kawaiiInk.withValues(alpha: 0.68),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.kawaiiCoral,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: AppColors.kawaiiGlow,
                                          blurRadius: 12,
                                          offset: Offset(0, 4)),
                                      ]),
                                    child: Text((slide.cta).ui,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                                ])),
                          ]))))));
            })),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.slides.length; i++)
              AnimatedContainer(
                duration: 240.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.kawaiiCoral : AppColors.kawaiiSage.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10))),
          ]),
      ]);
  }

  Widget _desktopGrid(BuildContext context) {
    final cartoon = context.isCartoon;
    final radius = cartoon ? 30.0 : (22.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.slides.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: cartoon ? 14 : (14),
            crossAxisSpacing: cartoon ? 14 : (14),
            childAspectRatio: cartoon ? 2.35 : 2.55),
          itemBuilder: (context, i) {
            final slide = widget.slides[i];
            final tint = slide.color;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(slide.route),
                borderRadius: BorderRadius.circular(radius),
                hoverColor: tint.withValues(alpha: 0.08),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    color: cartoon
                            ? Color.lerp(AppColors.kawaiiBubble, tint, 0.18)
                            : Color.lerp(Theme.of(context).colorScheme.surface, tint, 0.08),
                    border: cartoon
                            ? null
                            : Border.all(color: AppColors.modernLine, width: 1),
                    boxShadow: cartoon
                        ? const [
                            BoxShadow(
                              color: AppColors.kawaiiShadow,
                              blurRadius: 18,
                              offset: Offset(0, 8)),
                          ]
                        : const [
                                BoxShadow(
                                  color: AppColors.modernSoftShadow,
                                  blurRadius: 16,
                                  offset: Offset(0, 6)),
                              ]),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(cartoon ? 16 : 14, cartoon ? 14 : 12, cartoon ? 16 : 14, cartoon ? 14 : 12),
                    child: Row(
                      children: [
                        if (cartoon)
                          KawaiiTile(kind: slide.doodle, size: 48)
                        else
                          ModernIconTile(kind: slide.doodle, size: 40),
                        SizedBox(width: cartoon ? 14 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text((slide.title).ui,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  letterSpacing: -0.2,
                                  color: cartoon ? AppColors.kawaiiInk : null)),
                              SizedBox(height: cartoon ? 4 : 2),
                              Text((slide.subtitle).ui,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall),
                            ])),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: cartoon
                              ? AppColors.kawaiiCoral
                              : (AppColors.modernSage)),
                      ])))));
          });
      });
  }



  /// Soft wellness promo — large photo-led sage hero, teal CTA.
  Widget _modernStrip(BuildContext context) {
    final slide = widget.slides[_index.clamp(0, widget.slides.length - 1)];
    final radius = BorderRadius.circular(26);
    final photo = diyetselFoodImage(imageUrl: slide.imageUrl, seed: slide.title);
    final heroH = widget.height < 200 ? 200.0 : widget.height;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(slide.route),
            borderRadius: radius,
            child: Ink(
              height: heroH,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.modernWash,
                    AppColors.modernSageSoft,
                    Color(0xFFC8DCCF),
                  ],
                  stops: [0, 0.55, 1]),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.modernSoftShadow,
                    blurRadius: 28,
                    offset: Offset(0, 12)),
                ]),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text((slide.title).ui,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppColors.primaryDeep,
                                  fontWeight: FontWeight.w600,
                                  height: 1.15)),
                          const SizedBox(height: 6),
                          Text((slide.subtitle).ui,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.lightMuted.withValues(alpha: 0.95),
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w500)),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                              ]),
                            child: Text((slide.cta).ui,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13))),
                        ])),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 9,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.18),
                                blurRadius: 18,
                                offset: const Offset(0, 8)),
                            ],
                            border: Border.all(color: Colors.white, width: 4)),
                          clipBehavior: Clip.antiAlias,
                          child: diyetselFoodPhoto(url: photo, width: 124, height: 124)))),
                  ]))))),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.slides.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.primary : AppColors.modernSage.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(8)))),
            ]),
        ],
      ]);
  }
}

class HomeCategory {
  const HomeCategory({
    required this.label,
    required this.emoji,
    required this.icon,
    required this.route,
    required this.tint,
  });

  final String label;
  final String emoji;
  final IconData icon;
  final String route;
  final Color tint;
}

class CategoryShortcuts extends StatelessWidget {
  const CategoryShortcuts({super.key, required this.items});

  final List<HomeCategory> items;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) return _desktop(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: context.isCartoon ? 14 : 10,
        crossAxisSpacing: context.isCartoon ? 10 : 8,
        childAspectRatio: context.isCartoon ? 0.74 : 0.78),
      itemBuilder: (context, i) {
        final item = items[i];
        final cartoon = context.isCartoon;
        final kind = KawaiiKindX.from(icon: item.icon, emoji: item.emoji);
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: BorderRadius.circular(cartoon ? 28 : (22)),
          child: Column(
            children: [
              if (cartoon)
                KawaiiTile(kind: kind, size: 62)
              else
                ModernIconTile(kind: kind, size: 48),
              SizedBox(height: cartoon ? 10 : 6),
              Text((item.label).ui,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: cartoon ? 11.5 : 11,
                  height: 1.15,
                  letterSpacing: -0.1,
                  color: cartoon ? AppColors.kawaiiInk : Theme.of(context).colorScheme.onSurface)),
            ]));
      });
  }

  Widget _desktop(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cartoon = context.isCartoon;
    final modern = !cartoon;
    final radius = (modern ? 20.0 : 28.0);
    return Wrap(
      spacing: cartoon ? 12 : 8,
      runSpacing: cartoon ? 12 : 8,
      children: [
        for (final item in items)
          Material(
            color: cartoon
                    ? AppColors.kawaiiBubble
                    : scheme.surface,
            borderRadius: BorderRadius.circular(radius),
            child: InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(radius),
              hoverColor: (item.tint).withValues(alpha: 0.1),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: modern
                            ? AppColors.modernLine
                            : AppColors.kawaiiOutline,
                    width: cartoon ? 2.0 : 1),
                  boxShadow: modern
                      ? const [
                          BoxShadow(
                            color: AppColors.modernSoftShadow,
                            blurRadius: 10,
                            offset: Offset(0, 3)),
                        ]
                      : cartoon
                          ? const [
                              BoxShadow(
                                color: AppColors.kawaiiShadow,
                                blurRadius: 12,
                                offset: Offset(0, 6)),
                            ]
                          : null),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: cartoon ? 14 : 12, vertical: cartoon ? 10 : 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 18,
                        color: modern
                                ? AppColors.modernSage
                                : item.tint),
                      SizedBox(width: cartoon ? 10 : 8),
                      Text((item.label).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0,
                          color: cartoon ? AppColors.kawaiiInk : null)),
                    ]))))),
      ]);
  }
}

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key, required this.items});

  final List<HomeCategory> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (context.isDesktopLayout) {
      final cartoon = context.isCartoon;
      final modern = !cartoon;
      final scheme = Theme.of(context).colorScheme;
      final radius = (modern ? 20.0 : 28.0);
      return Wrap(
        spacing: cartoon ? 12 : 8,
        runSpacing: cartoon ? 12 : 8,
        children: [
          for (final item in items)
            Material(
              color: cartoon
                      ? AppColors.kawaiiBubble
                      : scheme.surface,
              borderRadius: BorderRadius.circular(radius),
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: BorderRadius.circular(radius),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: modern
                              ? AppColors.modernLine
                              : AppColors.kawaiiOutline,
                      width: cartoon ? 2.0 : 1),
                    boxShadow: modern
                        ? const [
                            BoxShadow(
                              color: AppColors.modernSoftShadow,
                              blurRadius: 10,
                              offset: Offset(0, 3)),
                          ]
                        : cartoon
                            ? const [
                                BoxShadow(
                                  color: AppColors.kawaiiShadow,
                                  blurRadius: 12,
                                  offset: Offset(0, 6)),
                              ]
                            : null),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: cartoon ? 14 : 12, vertical: cartoon ? 10 : 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 18,
                          color: modern
                                  ? AppColors.modernSage
                                  : item.tint),
                        SizedBox(width: cartoon ? 10 : 8),
                        Text((item.label).ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            letterSpacing: 0,
                            color: cartoon ? AppColors.kawaiiInk : null)),
                      ]))))),
        ]);
    }
    if (!context.isCartoon) return _modern(context);

    final gridItems = items.take(8).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78),
      itemBuilder: (context, i) {
        final item = gridItems[i];
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: BorderRadius.circular(28),
          child: Column(
            children: [
              KawaiiTile(kind: KawaiiKindX.from(icon: item.icon, emoji: item.emoji), size: 62),
              const SizedBox(height: 8),
              Text((item.label).ui,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  height: 1.15,
                  color: AppColors.kawaiiInk)),
            ]));
      });
  }



  Widget _modern(BuildContext context) {
    final gridItems = items.take(4).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55),
      itemBuilder: (context, i) {
        final item = gridItems[i];
        final kind = KawaiiKindX.from(icon: item.icon, emoji: item.emoji);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(item.route),
            borderRadius: BorderRadius.circular(22),
            child: Ink(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.modernSoftShadow,
                    blurRadius: 18,
                    offset: Offset(0, 6)),
                ]),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  children: [
                    ModernIconTile(kind: kind, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text((item.label).ui,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.lightInk,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.15))),
                  ])))));
      });
  }
}

class TodayStat {
  const TodayStat({
    required this.label,
    required this.value,
    required this.kind,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final KawaiiKind kind;
  final Color color;
  final VoidCallback onTap;
}

class TodayStrip extends StatelessWidget {
  const TodayStrip({super.key, required this.items});

  final List<TodayStat> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (!context.isCartoon) return _modern(context);

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: DiyetselCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              color: Color.lerp(AppColors.kawaiiBubble, items[i].color, 0.12),
              onTap: items[i].onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KawaiiTile(kind: items[i].kind, size: 44),
                  const SizedBox(height: 10),
                  Text((items[i].value).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppColors.kawaiiInk)),
                  Text((items[i].label).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kawaiiInk.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600)),
                ]))),
        ],
      ]);
  }



  Widget _modern(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: DiyetselCard(
              padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
              onTap: items[i].onTap,
              color: Color.lerp(Colors.white, ModernPalette.accent(items[i].kind), 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernIconTile(kind: items[i].kind, size: 40),
                  const SizedBox(height: 10),
                  Text((items[i].value).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      letterSpacing: -0.2,
                      color: ModernPalette.accent(items[i].kind))),
                  Text((items[i].label).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightMuted)),
                ]))),
        ],
      ]);
  }
}

/// Soft kawaii water tracker — cream card, sage bar, coral CTA.
class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({
    super.key,
    required this.amountMl,
    required this.goalMl,
    required this.onTrack,
  });

  final int amountMl;
  final int goalMl;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    final progress = goalMl <= 0 ? 0.0 : (amountMl / goalMl).clamp(0.0, 1.0);
    return DiyetselCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          const KawaiiDoodle(kind: KawaiiKind.water, size: 64),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(('Su: $amountMl / $goalMl ml').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.kawaiiInk)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.kawaiiMint.withValues(alpha: 0.55),
                    color: AppColors.kawaiiSage)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTrack,
                      borderRadius: BorderRadius.circular(22),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.kawaiiCoral,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.kawaiiGlow,
                              blurRadius: 14,
                              offset: Offset(0, 5)),
                          ]),
                        child: Text(('Takip').ui,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)))))),
              ])),
        ]));
  }
}

class HorizontalRail extends StatelessWidget {
  const HorizontalRail({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.children,
  });

  final String title;
  final VoidCallback onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            action: TextButton(onPressed: onSeeAll, child: Text(('Tümü').ui))),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 1000 ? 4 : 3;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15),
                itemBuilder: (context, i) => children[i]);
            }),
        ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          action: TextButton(onPressed: onSeeAll, child: Text(('Tümü').ui))),
        SizedBox(
          height: context.isCartoon ? 176 : 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (context, index) => SizedBox(width: context.isCartoon ? 12 : 10),
            itemBuilder: (context, i) => children[i])),
      ]);
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = KawaiiKindX.from(emoji: emoji);
    final desktop = context.isDesktopLayout;
    final cartoon = context.isCartoon;
    if (cartoon) {
      return SizedBox(
        width: desktop ? null : 152,
        height: desktop ? null : 176,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(28),
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.kawaiiBubble,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.kawaiiShadow,
                    blurRadius: 20,
                    offset: Offset(0, 8)),
                ]),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KawaiiTile(kind: kind, size: desktop ? 42 : 54),
                    if (desktop) const SizedBox(height: 12) else const Spacer(),
                    Text((title).ui,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: desktop ? 13.5 : 14,
                        height: 1.25,
                        color: AppColors.kawaiiInk)),
                    const SizedBox(height: 4),
                    Text((meta).ui,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.kawaiiInk.withValues(alpha: 0.65),
                            fontWeight: FontWeight.w600)),
                  ]))))));
    }
    return SizedBox(
      width: desktop ? null : 148,
      height: desktop ? null : 168,
      child: DiyetselCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        color: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                          ModernIconTile(kind: kind, size: desktop ? 36 : 46),
            if (desktop) const SizedBox(height: 10) else const Spacer(),
            Text((title).ui,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: desktop ? 13.5 : 14,
                letterSpacing: -0.2,
                height: 1.25)),
            const SizedBox(height: 4),
            Text((meta).ui,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    letterSpacing: null)),
          ])));
  }
}

class MarketSearchBar extends StatelessWidget {
  const MarketSearchBar({super.key, required this.hint, required this.onSubmitted, this.onTap});

  final String hint;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final modern = !cartoon;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final desktop = context.isDesktopLayout;
    final scheme = Theme.of(context).colorScheme;
    final radius = cartoon
        ? 30.0
        : 28.0;
    final field = TextField(
      onSubmitted: onSubmitted,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: cartoon
            ? AppColors.kawaiiInk
            : ((dark || desktop) ? null : AppColors.lightInk),
        letterSpacing: null),
      decoration: InputDecoration(
        hintText: (hint).ui,
        hintStyle: TextStyle(
          color: cartoon
              ? AppColors.kawaiiInk.withValues(alpha: 0.45)
              : AppColors.lightMuted.withValues(alpha: 0.9),
          letterSpacing: null),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: cartoon
              ? const KawaiiDoodle(kind: KawaiiKind.search, size: 22)
              : Icon(
                      Icons.search_rounded,
                      color: modern ? AppColors.modernSage : AppColors.primary)),
        filled: true,
        fillColor: dark
            ? (const Color(0xFF2A2A2A))
            : cartoon
                ? AppColors.kawaiiBubble
                : desktop
                    ? (modern ? Color.lerp(Colors.white, AppColors.modernWash, 0.35)! : scheme.surfaceContainerHighest.withValues(alpha: 0.55))
                    : (modern ? Color.lerp(Colors.white, AppColors.modernWash, 0.4)! : Colors.white),
        contentPadding: EdgeInsets.symmetric(horizontal: cartoon ? 16 : 14, vertical: desktop ? 10 : (cartoon ? 16 : 14)),
        isDense: desktop,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: cartoon
                ? AppColors.kawaiiOutline.withValues(alpha: 0.55)
                : modern
                        ? AppColors.modernLine.withValues(alpha: 0.8)
                        : scheme.outlineVariant,
            width: cartoon ? 1 : (1))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: cartoon
                ? AppColors.kawaiiCoral.withValues(alpha: 0.55)
                : AppColors.primary,
            width: cartoon ? 1.4 : (1.6)))));
    if (cartoon) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.kawaiiShadow,
              blurRadius: 16,
              offset: Offset(0, 6)),
          ]),
        child: field);
    }
    if (!modern) return field;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.modernSoftShadow,
            blurRadius: 12,
            offset: Offset(0, 4)),
        ]),
      child: field);
  }
}

class MarketHeroHeader extends StatelessWidget {
  const MarketHeroHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.search,
    this.trailing,
  });

  final String greeting;
  final String subtitle;
  final Widget search;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) return _desktop(context);
    if (context.isCartoon) return _cartoon(context);
    return _modern(context);
  }

  Widget _desktop(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final modern = !context.isCartoon;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: modern
                      ? AppColors.modernLine
                      : scheme.outlineVariant.withValues(alpha: 0.9)))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((greeting).ui,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4)),
                    const SizedBox(height: 2),
                    Text((subtitle).ui,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: modern ? AppColors.lightMuted : scheme.onSurfaceVariant,
                            letterSpacing: null)),
                  ])),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: search),
              if (trailing != null) const SizedBox(width: 12),
              ?trailing,
            ]))));
  }

  Widget _cartoon(BuildContext context) {
    final onHero = AppColors.kawaiiInk;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.kawaiiCream,
            Color(0xFFF3FBF6),
            AppColors.kawaiiMint,
          ],
          stops: [0, 0.55, 1]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28))),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      DiyetselAssets.logo,
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Icons.eco_rounded, color: onHero, size: 28),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(('e-Diyet').ui,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: onHero,
                          fontWeight: FontWeight.w800,
                          fontSize: 22)),
                  const Spacer(),
                  const KawaiiDoodle(kind: KawaiiKind.sparkle, size: 22),
                  if (trailing != null) const SizedBox(width: 10),
                  ?trailing,
                ]),
              const SizedBox(height: 16),
              Text((greeting).ui,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: onHero,
                      fontWeight: FontWeight.w700,
                      height: 1.15)),
              const SizedBox(height: 6),
              Text((subtitle).ui,
                style: TextStyle(
                  color: onHero.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              search,
            ]))));
  }



  Widget _modern(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF1C1917), Color(0xFF292524)]
              : const [
                  AppColors.modernWash,
                  AppColors.modernSageSoft,
                  Color(0xFFE8F2EB),
                ],
          stops: dark ? null : [0, 0.5, 1])),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      DiyetselAssets.logo,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primaryDeep,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(('e-Diyet').ui,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primaryDeep,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            height: 1,
                            fontSize: 28))),
                  if (trailing != null)
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.modernSoftShadow,
                            blurRadius: 12,
                            offset: Offset(0, 4)),
                        ],
                        border: Border.all(color: AppColors.modernLine.withValues(alpha: 0.7))),
                      child: trailing!),
                ]),
              const SizedBox(height: 16),
              Text((greeting).ui,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.lightInk,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2)),
              const SizedBox(height: 4),
              Text((subtitle).ui,
                style: TextStyle(
                  color: AppColors.lightMuted.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
              const SizedBox(height: 16),
              search,
            ]))));
  }
}
