import 'package:flutter/material.dart';

/// Soft tint plate + illustrated PNG or Material icon fallback.
class CartoonGlyph extends StatelessWidget {
  const CartoonGlyph({
    super.key,
    this.icon,
    required this.accent,
    this.asset,
    this.size = 58,
    this.iconSize,
    this.radius = 20,
    this.filled = true,
  }) : assert(icon != null || asset != null);

  final IconData? icon;
  final Color accent;
  final String? asset;
  final double size;
  final double? iconSize;
  final double radius;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final plate = filled ? Color.lerp(accent, Colors.white, 0.78)! : Colors.white;
    final inner = asset != null && asset!.isNotEmpty
        ? Image.asset(
            asset!,
            width: iconSize ?? size * 0.52,
            height: iconSize ?? size * 0.52,
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
            size: iconSize ?? size * 0.42,
            color: accent,
          );

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: plate,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.withValues(alpha: 0.22), width: 1.2),
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
