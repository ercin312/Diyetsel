import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'kawaii_doodle.dart';

/// Single-metal copper accents for dark atelier luxury.
class LuxuryPalette {
  LuxuryPalette._();

  static Color accent(KawaiiKind kind) {
    return switch (kind) {
      KawaiiKind.water || KawaiiKind.hourglass => AppColors.luxuryChampagne,
      KawaiiKind.settings || KawaiiKind.search => AppColors.luxuryMuted,
      KawaiiKind.diet || KawaiiKind.plate || KawaiiKind.recipe => AppColors.luxuryCopperBright,
      KawaiiKind.sparkle || KawaiiKind.fire => AppColors.luxurySheen,
      _ => AppColors.luxuryCopper,
    };
  }

  static List<Color> plate() => const [
        Color(0xFF2A221C),
        AppColors.luxuryPlate,
        Color(0xFF161210),
      ];
}

class LuxuryGlyph extends StatelessWidget {
  const LuxuryGlyph({
    super.key,
    required this.kind,
    this.size = 22,
    this.inverted = false,
    this.color,
  });

  final KawaiiKind kind;
  final double size;
  final bool inverted;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolved = inverted ? Colors.white : (color ?? LuxuryPalette.accent(kind));
    return Icon(kind.materialIcon, size: size, color: resolved);
  }
}

/// Metal-framed plate — not a pastel wash clone of ModernIconTile.
class LuxuryIconTile extends StatelessWidget {
  const LuxuryIconTile({
    super.key,
    this.kind,
    this.icon,
    this.color,
    this.size = 48,
    this.inverted = false,
    this.selected = false,
  }) : assert(kind != null || icon != null);

  final KawaiiKind? kind;
  final IconData? icon;
  final Color? color;
  final double size;
  final bool inverted;
  final bool selected;

  KawaiiKind get _kind => kind ?? KawaiiKindX.from(icon: icon);

  @override
  Widget build(BuildContext context) {
    final accent = color ?? LuxuryPalette.accent(_kind);
    final radius = size * 0.18;
    final glyph = size * 0.38;
    final plates = LuxuryPalette.plate();

    if (inverted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.luxuryChampagne.withValues(alpha: 0.55), width: 1),
        ),
        child: Icon(_kind.materialIcon, size: glyph, color: Colors.white),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: plates,
        ),
        border: Border.all(
          color: selected ? accent : AppColors.luxuryCopper.withValues(alpha: 0.55),
          width: selected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: selected ? 14 : 10,
            offset: const Offset(0, 5),
          ),
          if (selected)
            BoxShadow(
              color: accent.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 0),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.14,
            left: size * 0.14,
            right: size * 0.14,
            child: Container(
              height: 1,
              color: AppColors.luxuryChampagne.withValues(alpha: 0.22),
            ),
          ),
          Icon(_kind.materialIcon, size: glyph, color: accent),
        ],
      ),
    );
  }
}

/// Subtle copper diagonal shimmer for luxury surfaces.
class LuxurySheen extends StatelessWidget {
  const LuxurySheen({super.key, required this.child, this.borderRadius});

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: const GradientRotation(-math.pi / 7),
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      AppColors.luxurySheen.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.35, 0.5, 0.65],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
