import 'package:flutter/material.dart';

/// Soft illustrated PNG icon from the Premium Cartoon Wellness set.
class CartoonAssetIcon extends StatelessWidget {
  const CartoonAssetIcon(
    this.asset, {
    super.key,
    this.size = 28,
    this.fallback,
    this.fallbackColor,
  });

  final String asset;
  final double size;
  final IconData? fallback;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Icon(
        fallback ?? Icons.circle,
        size: size * 0.85,
        color: fallbackColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
