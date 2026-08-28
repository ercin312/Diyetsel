import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'kawaii_doodle.dart';

/// Soft wellness accents — teal brand + sage/water semantics; fire for streaks.
class ModernPalette {
  ModernPalette._();

  static const Color teal = AppColors.primary;
  static const Color tealDeep = AppColors.primaryDeep;
  static const Color fire = AppColors.modernFire;
  static const Color sage = AppColors.modernSage;
  static const Color sageDeep = AppColors.modernSageDeep;
  static const Color stone = Color(0xFF78716C);
  static const Color water = Color(0xFF5B9BD5);

  /// Legacy aliases
  static const Color orange = teal;
  static const Color orangeDeep = tealDeep;

  static Color accent(KawaiiKind kind) {
    return switch (kind) {
      KawaiiKind.water || KawaiiKind.hourglass => water,
      KawaiiKind.settings || KawaiiKind.search => stone,
      KawaiiKind.diet || KawaiiKind.plate || KawaiiKind.recipe => sageDeep,
      KawaiiKind.blog || KawaiiKind.chart || KawaiiKind.sparkle => sage,
      KawaiiKind.fire || KawaiiKind.orange => fire,
      _ => teal,
    };
  }

  static List<Color> wash(KawaiiKind kind) {
    final c = accent(kind);
    return [
      Color.lerp(Colors.white, c, 0.14)!,
      Color.lerp(Colors.white, c, 0.06)!,
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
    final resolved = inverted ? Colors.white : (color ?? ModernPalette.accent(kind));
    return Icon(kind.materialIcon, size: size, color: resolved);
  }
}
