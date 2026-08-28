import 'package:flutter/material.dart';

/// Premium Cartoon Wellness spacing + radii + shadows.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 28;

  static const double pageH = 18;
  static const double pageV = 12;

  static const double radiusSm = 14;
  static const double radiusMd = 18;
  static const double radiusCard = 22;
  static const double radiusHero = 26;
  static const double radiusSearch = 22;
  static const double radiusNav = 26;
  static const double radiusPill = 20;

  static List<BoxShadow> get soft => const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get softLift => const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get nav => const [
        BoxShadow(
          color: Color(0x10000000),
          blurRadius: 18,
          offset: Offset(0, -4),
        ),
      ];
}
