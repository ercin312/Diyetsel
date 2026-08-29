import 'package:flutter/material.dart';

/// Illustrated PNG glyph — transparent by default (no white plate behind assets).
class CartoonGlyph extends StatelessWidget {
  const CartoonGlyph({
    super.key,
    this.icon,
    required this.accent,
    this.asset,
    this.size = 58,
    this.iconSize,
    this.radius = 20,
    this.filled,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final Color accent;
  final String? asset;
  final double size;
  final double? iconSize;
  final double radius;
  /// Soft tint plate. Defaults to on for Material icons, off for PNG assets.
  final bool? filled;

  @override
  Widget build(BuildContext context) {
    final hasAsset = asset != null && asset!.isNotEmpty;
    final showPlate = filled ?? !hasAsset;
    final glyphSize = iconSize ?? (hasAsset ? (showPlate ? size * 0.55 : size * 0.92) : size * 0.42);
    final inner = hasAsset
        ? Image.asset(
            asset!,
            width: glyphSize,
            height: glyphSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, _, _) => Icon(
              icon ?? Icons.circle,
              size: iconSize ?? size * 0.42,
              color: accent,
            ),
          )
        : Icon(
            icon ?? Icons.circle,
            size: glyphSize,
            color: accent,
          );

    if (!showPlate) {
      return SizedBox(
        width: size,
        height: size,
        child: Center(child: inner),
      );
    }

    final plate = Color.lerp(accent, Colors.white, 0.82)!;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: plate,
        shape: radius >= size / 2 - 1 ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius >= size / 2 - 1 ? null : BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: inner,
    );
  }
}
