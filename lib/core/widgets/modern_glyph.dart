import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'kawaii_doodle.dart';

/// Vibrant but cohesive accents for modern theme (not kawaii, not purple-AI).
class ModernPalette {
  ModernPalette._();

  static Color accent(KawaiiKind kind) {
    return switch (kind) {
      KawaiiKind.home => const Color(0xFFFF6B00),
      KawaiiKind.diet => const Color(0xFF16A34A),
      KawaiiKind.water => const Color(0xFF14B8A6),
      KawaiiKind.calendar => const Color(0xFFF59E0B),
      KawaiiKind.shop || KawaiiKind.gift => const Color(0xFFFF6B00),
      KawaiiKind.recipe => const Color(0xFFEA580C),
      KawaiiKind.blog => const Color(0xFF0D9488),
      KawaiiKind.cart => const Color(0xFFD97706),
      KawaiiKind.chat => const Color(0xFF06B6D4),
      KawaiiKind.people => const Color(0xFFF43F5E),
      KawaiiKind.settings => const Color(0xFF78716C),
      KawaiiKind.sparkle => const Color(0xFFEAB308),
      KawaiiKind.camera || KawaiiKind.barcode => const Color(0xFF0891B2),
      KawaiiKind.folder => const Color(0xFFF59E0B),
      KawaiiKind.document => const Color(0xFFE11D48),
      KawaiiKind.chart => const Color(0xFF10B981),
      KawaiiKind.search => const Color(0xFF0EA5E9),
      KawaiiKind.orange => AppColors.primary,
      KawaiiKind.heart => const Color(0xFFF43F5E),
      KawaiiKind.fire => const Color(0xFFFF6B00),
      KawaiiKind.hourglass => const Color(0xFF14B8A6),
      KawaiiKind.plate => const Color(0xFF22C55E),
    };
  }

  static List<Color> wash(KawaiiKind kind) {
    final c = accent(kind);
    return [
      Color.lerp(Colors.white, c, 0.18)!,
      Color.lerp(Colors.white, c, 0.08)!,
    ];
  }
}

class ModernGlyph extends StatelessWidget {
  const ModernGlyph({
    super.key,
    required this.kind,
    this.size = 24,
    this.inverted = false,
    this.color,
    this.emphasized = true,
  });

  final KawaiiKind kind;
  final double size;
  final bool inverted;
  final Color? color;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final resolved = inverted
        ? Colors.white
        : (color ?? ModernPalette.accent(kind));
    return Icon(kind.materialIcon, size: size, color: resolved);
  }
}
