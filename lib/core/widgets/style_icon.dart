import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'kawaii_doodle.dart';
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
    if (!context.isCartoon) {
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
    if (!sticker) return KawaiiDoodle(kind: kind, size: size);
    return KawaiiTile(kind: kind, size: size + 22, selected: selected);
  }
}

/// Soft colored wash + vivid icon — modern, colorful, always readable.
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
    final radius = size * 0.30;
    final glyph = size * 0.44;

    if (inverted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.32),
              Colors.white.withValues(alpha: 0.12),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(_kind.materialIcon, size: glyph, color: Colors.white),
      );
    }

    final washes = ModernPalette.wash(_kind);
    final top = color != null ? Color.lerp(Colors.white, accent, dark ? 0.28 : 0.2)! : washes[0];
    final bottom = color != null ? Color.lerp(Colors.white, accent, dark ? 0.14 : 0.08)! : washes[1];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [accent.withValues(alpha: 0.32), accent.withValues(alpha: 0.14)]
              : [top, bottom],
        ),
        border: Border.all(
          color: accent.withValues(alpha: selected ? 0.55 : 0.22),
          width: selected ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: selected ? 0.28 : 0.14),
            blurRadius: selected ? 14 : 10,
            offset: const Offset(0, 5),
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
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: const [
          BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 12, offset: Offset(0, 6)),
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
    if (!context.isCartoon) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB06A), Color(0xFFFF6B00)],
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
    return CartoonSticker(
      size: size,
      fill: AppColors.kawaiiPeach,
      child: KawaiiDoodle(kind: KawaiiKind.people, size: size * 0.72),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.kawaiiLemon,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text('$emoji $label', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
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
