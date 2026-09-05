import 'package:flutter/material.dart';

/// Ana sayfa — sıcak turuncu / kırmızı ember wellness dili.
/// Teal modern tokenlardan bağımsız; soft home ekranı için.
abstract final class SoftHomeColors {
  static const Color ember = Color(0xFFE4572E);
  static const Color emberBright = Color(0xFFFF6B3D);
  static const Color emberDeep = Color(0xFF9B2F14);
  static const Color emberDark = Color(0xFF5C1C0C);
  static const Color flame = Color(0xFFFF5722);
  static const Color apricot = Color(0xFFFF9A6C);
  static const Color blush = Color(0xFFFFD8C8);
  static const Color blushSoft = Color(0xFFFFEDE6);
  static const Color parchment = Color(0xFFFFF5F0);
  static const Color cream = Color(0xFFFFFBF8);
  static const Color line = Color(0xFFF0D5C8);
  static const Color ink = Color(0xFF2A1610);
  static const Color inkSoft = Color(0xFF5C3A2E);
  static const Color muted = Color(0xFF9A7464);
  static const Color water = Color(0xFF5B8FB8);
  static const Color waterSoft = Color(0xFFD9EAF5);
  static const Color amberSoft = Color(0xFFFFE4C4);
  static const Color wine = Color(0xFFC43B2E);
  static const Color shadow = Color(0x1AE4572E);

  static const LinearGradient washGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE8DE), parchment, cream],
    stops: [0, 0.28, 1],
  );

  static const LinearGradient emberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B3D), Color(0xFFE4572E), Color(0xFFC43B2E)],
  );

  static const LinearGradient heroWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF0E8), Color(0xFFFFE4D6), Color(0xFFFFF8F4)],
  );

  static List<BoxShadow> get softShadow => const [
        BoxShadow(color: shadow, blurRadius: 20, offset: Offset(0, 8)),
      ];

  static List<BoxShadow> get liftShadow => const [
        BoxShadow(color: Color(0x24E4572E), blurRadius: 28, offset: Offset(0, 12)),
      ];

  static TextStyle display({
    double size = 26,
    FontWeight weight = FontWeight.w800,
    Color? color,
    double height = 1.12,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? ink,
        height: height,
        letterSpacing: -0.6,
      );

  static TextStyle title({
    double size = 17,
    FontWeight weight = FontWeight.w800,
    Color? color,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? ink,
        height: 1.2,
        letterSpacing: -0.35,
      );

  static TextStyle body({
    double size = 13.5,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.4,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? muted,
        height: height,
        letterSpacing: -0.1,
      );

  static TextStyle label({
    double size = 12,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color ?? inkSoft,
        letterSpacing: 0.1,
      );
}
