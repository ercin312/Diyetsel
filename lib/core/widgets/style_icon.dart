import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'kawaii_doodle.dart';
import 'luxury_glyph.dart';
import 'modern_glyph.dart';

class StyleIcon extends StatelessWidget {
  const StyleIcon({
    super.key,
    required this.icon,
    required this.emoji,
    this.size = 28,
    this.color,
    this.sticker = true,
    this.selected = false,
  });

  final IconData icon;
  final String emoji;
  final double size;
  final Color? color;
  final bool sticker;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final kind = KawaiiKindX.from(icon: icon, emoji: emoji);
    if (context.isCartoon) {
      if (!sticker) return KawaiiDoodle(kind: kind, size: size);
      return KawaiiTile(kind: kind, size: size + 22, selected: selected);
    }
    if (context.isLuxury) {
      if (!sticker) {
        return LuxuryGlyph(kind: kind, size: size, color: color);
      }
      return LuxuryIconTile(
        kind: kind,
        color: color,
        size: size + 16,
        selected: selected,
      );
    }
    if (!sticker) {
      return ModernGlyph(kind: kind, size: size, color: color);
    }
    return ModernIconTile(
      kind: kind,
      color: color,
      size: size + 18,
      selected: selected,
    );
  }
}

/// Soft circular tint tile — story-row / wellness chrome for modern theme.
class ModernIconTile extends StatelessWidget {
  const ModernIconTile({
    super.key,
    this.kind,
    this.icon,
    this.color,
    this.size = 52,
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = color ?? ModernPalette.accent(_kind);
    final glyph = size * 0.42;

    if (inverted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.2),
        ),
        child: Icon(_kind.materialIcon, size: glyph, color: Colors.white),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? accent.withValues(alpha: dark ? 0.28 : 0.16)
            : (dark ? const Color(0xFF2A2A2A) : Color.lerp(Colors.white, accent, 0.1)),
        border: Border.all(
          color: selected ? accent.withValues(alpha: 0.55) : accent.withValues(alpha: 0.18),
          width: selected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.modernSoftShadow,
            blurRadius: selected ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(_kind.materialIcon, size: glyph, color: accent),
    );
  }
}

class CartoonSticker extends StatelessWidget {
  const CartoonSticker({
    super.key,
    required this.child,
    this.size = 48,
    this.fill = AppColors.kawaiiPeach,
    this.borderColor = const Color(0xFF3F342C),
  });

  final Widget child;
  final double size;
  final Color fill;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF2A221C) : fill,
        borderRadius: BorderRadius.circular(size * 0.36),
        boxShadow: const [
          BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: child,
    );
  }
}

class CartoonAvatar extends StatelessWidget {
  const CartoonAvatar({super.key, required this.name, this.size = 44});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (context.isCartoon) {
      return CartoonSticker(
        size: size,
        fill: AppColors.kawaiiPeach,
        child: KawaiiDoodle(kind: KawaiiKind.people, size: size * 0.72),
      );
    }
    if (context.isLuxury) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.luxuryCopperBright,
              AppColors.luxuryCopper,
              AppColors.luxuryCopperDeep,
            ],
            stops: [0, 0.5, 1],
          ),
          border: Border.all(color: AppColors.luxuryChampagne.withValues(alpha: 0.45), width: 1),
          boxShadow: [
            BoxShadow(color: AppColors.luxuryCopper.withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Text(
          name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: size * 0.34,
            letterSpacing: 0.4,
          ),
        ),
      );
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D9B82), Color(0xFF1F6B5A)],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Text(
        name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

class DoodleBadge extends StatelessWidget {
  const DoodleBadge({super.key, required this.label, this.emoji = '⭐'});

  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    if (context.isCartoon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.kawaiiLemon.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Text(
          '$emoji $label',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: AppColors.kawaiiInk,
          ),
        ),
      );
    }
    if (context.isLuxury) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.luxuryPlate,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.luxuryCopper.withValues(alpha: 0.55), width: 0.9),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: AppColors.luxuryGoldSoft,
            letterSpacing: 0.6,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.16),
            AppColors.accent.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: AppColors.primaryDeep,
        ),
      ),
    );
  }
}
