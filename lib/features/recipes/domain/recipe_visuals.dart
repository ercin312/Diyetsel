import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/models/models.dart';

/// Visual + display helpers for Premium Cartoon recipe UI.
class RecipeVisuals {
  RecipeVisuals._();

  static String imageFor(Recipe r) {
    final url = r.imageUrl?.trim() ?? '';
    return url;
  }

  static List<String> displayTags(Recipe r) {
    if (r.tags.isNotEmpty) return r.tags;
    final out = <String>[r.category];
    if (r.prepMinutes > 0 && r.prepMinutes <= 15) out.add('Hızlı');
    return out.take(4).toList();
  }

  static ColorTint tintFor(Recipe r) {
    final c = r.category.toLowerCase();
    if (c.contains('kahvalt')) return ColorTint.lemon;
    if (c.contains('öğle') || c.contains('ogle')) return ColorTint.mint;
    if (c.contains('akşam') || c.contains('aksam')) return ColorTint.lilac;
    return ColorTint.peach;
  }

  /// Soft modern wash tint.
  static Color softTintFor(Recipe r) {
    switch (tintFor(r)) {
      case ColorTint.lemon:
        return const Color(0xFFFFF8E8);
      case ColorTint.mint:
        return const Color(0xFFE8F5F0);
      case ColorTint.lilac:
        return const Color(0xFFE3F2F8);
      case ColorTint.peach:
        return const Color(0xFFFFF0E8);
      case ColorTint.sky:
        return const Color(0xFFE3F2F8);
    }
  }

  static Color softAccentFor(Recipe r) {
    switch (tintFor(r)) {
      case ColorTint.lemon:
        return const Color(0xFFD4A017);
      case ColorTint.mint:
        return AppColors.primary;
      case ColorTint.lilac:
        return const Color(0xFF5BA3C9);
      case ColorTint.peach:
        return const Color(0xFFE07A5F);
      case ColorTint.sky:
        return const Color(0xFF5BA3C9);
    }
  }
}

enum ColorTint { lemon, mint, lilac, peach, sky }
