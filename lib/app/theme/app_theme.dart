import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/models/enums.dart';
import 'app_colors.dart';

class DiyetselThemeExt extends ThemeExtension<DiyetselThemeExt> {
  const DiyetselThemeExt({
    required this.style,
    required this.cardRadius,
    required this.borderWidth,
    required this.stickerOffset,
  });

  final VisualStyle style;
  final double cardRadius;
  final double borderWidth;
  final Offset stickerOffset;

  bool get isCartoon => style == VisualStyle.cartoon;

  @override
  DiyetselThemeExt copyWith({
    VisualStyle? style,
    double? cardRadius,
    double? borderWidth,
    Offset? stickerOffset,
  }) {
    return DiyetselThemeExt(
      style: style ?? this.style,
      cardRadius: cardRadius ?? this.cardRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      stickerOffset: stickerOffset ?? this.stickerOffset,
    );
  }

  @override
  DiyetselThemeExt lerp(ThemeExtension<DiyetselThemeExt>? other, double t) {
    if (other is! DiyetselThemeExt) return this;
    return t < 0.5 ? this : other;
  }
}

class AppTheme {
  static ThemeData build({
    required Brightness brightness,
    required VisualStyle style,
  }) {
    final isDark = brightness == Brightness.dark;
    final isCartoon = style == VisualStyle.cartoon;
    final ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final surface = isDark
        ? AppColors.darkCard
        : (isCartoon ? const Color(0xFFFFFBF5) : AppColors.lightSurface);
    final canvas = isDark
        ? AppColors.dark
        : (isCartoon ? AppColors.kawaiiCream : AppColors.lightBg);

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: isCartoon ? AppColors.peachDeep : AppColors.primaryDeep,
      onSecondary: isCartoon ? AppColors.lightInk : Colors.white,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      error: AppColors.danger,
      onError: Colors.white,
    ).copyWith(
      surfaceContainerLowest: canvas,
      surfaceContainerHighest: isDark
          ? const Color(0xFF2A2A2A)
          : (isCartoon ? const Color(0xFFF1EDE8) : AppColors.modernWash),
      outline: isDark
          ? const Color(0xFF44403C)
          : (isCartoon ? const Color(0xFFD6D3D1) : AppColors.modernLine),
      outlineVariant: isDark
          ? const Color(0xFF3F3F46)
          : (isCartoon ? const Color(0xFFE7E5E4) : const Color(0xFFE8E4DD)),
    );

    final rawText = isCartoon ? GoogleFonts.fredokaTextTheme() : GoogleFonts.soraTextTheme();
    final textTheme = rawText.apply(bodyColor: ink, displayColor: ink).copyWith(
          bodySmall: rawText.bodySmall?.copyWith(color: muted, height: 1.45, letterSpacing: 0.15),
          bodyMedium: rawText.bodyMedium?.copyWith(color: ink, height: 1.5, letterSpacing: 0.05),
          bodyLarge: rawText.bodyLarge?.copyWith(color: ink, height: 1.5),
          titleSmall: rawText.titleSmall?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: -0.15),
          titleMedium: rawText.titleMedium?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: -0.25),
          titleLarge: rawText.titleLarge?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.4),
          headlineSmall: rawText.headlineSmall?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.5),
          headlineMedium: rawText.headlineMedium?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.6),
          displaySmall: rawText.displaySmall?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.8),
          labelLarge: rawText.labelLarge?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          labelMedium: rawText.labelMedium?.copyWith(color: muted, fontWeight: FontWeight.w500),
        );

    final radius = isCartoon ? 28.0 : 16.0;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      iconTheme: IconThemeData(color: ink, size: 22),
      primaryIconTheme: const IconThemeData(color: AppColors.primary),
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: isCartoon ? Colors.transparent : canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: ink),
        titleTextStyle: textTheme.titleLarge,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: ink,
        textColor: ink,
        subtitleTextStyle: textTheme.bodySmall,
        titleTextStyle: textTheme.titleMedium,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: muted,
        indicatorColor: AppColors.primary,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF2A2A2A)
            : (isCartoon ? AppColors.peach.withValues(alpha: 0.45) : AppColors.modernWash),
        selectedColor: AppColors.primary.withValues(alpha: 0.14),
        labelStyle: TextStyle(color: ink, fontWeight: FontWeight.w600),
        secondaryLabelStyle: TextStyle(color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCartoon ? 20 : 10),
          side: BorderSide(
            color: isCartoon ? AppColors.kawaiiPeach : AppColors.modernLine,
            width: isCartoon ? 0 : 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: isCartoon ? BorderSide.none : BorderSide(color: scheme.outline.withValues(alpha: 0.55)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : surface,
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.9)),
        prefixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isCartoon ? 22 : 12),
          borderSide: BorderSide(color: isCartoon ? AppColors.kawaiiPeach : scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isCartoon ? 22 : 12),
          borderSide: BorderSide(color: isCartoon ? AppColors.kawaiiPeach : scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isCartoon ? 22 : 12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: isCartoon ? Colors.transparent : AppColors.primary.withValues(alpha: 0.12),
        backgroundColor: isCartoon ? const Color(0xFFFFFBF5) : surface,
        surfaceTintColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.primary : muted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? AppColors.primary : muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
            letterSpacing: -0.1,
          );
        }),
        height: isCartoon ? 86 : 64,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedLabelTextStyle: TextStyle(color: muted, fontWeight: FontWeight.w500),
        selectedLabelTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: muted, width: 1.5),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: ink,
        collapsedIconColor: muted,
        textColor: ink,
        collapsedTextColor: ink,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCartoon ? 22 : 12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      extensions: [
        DiyetselThemeExt(
          style: style,
          cardRadius: radius,
          borderWidth: isCartoon ? 0 : 1,
          stickerOffset: isCartoon ? const Offset(0, 6) : Offset.zero,
        ),
      ],
    );
  }
}

extension ThemeX on BuildContext {
  DiyetselThemeExt get diyetselTheme =>
      Theme.of(this).extension<DiyetselThemeExt>() ??
      const DiyetselThemeExt(
        style: VisualStyle.modern,
        cardRadius: 16,
        borderWidth: 1,
        stickerOffset: Offset.zero,
      );

  bool get isCartoon => diyetselTheme.isCartoon;
  bool get isWide => MediaQuery.sizeOf(this).width >= AppConstants.desktopBreakpoint;
}

/// Compact Material density + scrollbar for desktop shells.
ThemeData applyDesktopChrome(ThemeData base) {
  return base.copyWith(
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(8),
      thumbVisibility: const WidgetStatePropertyAll(true),
      thumbColor: WidgetStatePropertyAll(
        base.colorScheme.onSurface.withValues(alpha: 0.28),
      ),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      dense: true,
      visualDensity: VisualDensity.compact,
      minVerticalPadding: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    ),
    appBarTheme: base.appBarTheme.copyWith(
      toolbarHeight: 48,
      titleTextStyle: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: (base.filledButtonTheme.style ?? const ButtonStyle()).merge(
        FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          minimumSize: const Size(64, 36),
        ),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: base.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      dataTextStyle: base.textTheme.bodyMedium,
      headingRowHeight: 40,
      dataRowMinHeight: 40,
      dataRowMaxHeight: 52,
    ),
  );
}
