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
  bool get isModern => style == VisualStyle.modern;

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

    final Color brand = isCartoon ? AppColors.kawaiiLeaf : AppColors.primary;
    final Color brandDeep = isCartoon ? AppColors.kawaiiLeafDeep : AppColors.primaryDeep;
    final Color tertiary = isCartoon ? AppColors.kawaiiSalmon : AppColors.modernSage;

    final Color ink;
    final Color muted;
    final Color surface;
    final Color canvas;
    final Color wash;
    final Color line;

    if (isCartoon) {
      ink = isDark ? AppColors.darkInk : AppColors.kawaiiInk;
      muted = isDark ? AppColors.darkMuted : AppColors.kawaiiMuted;
      surface = isDark ? AppColors.darkCard : AppColors.kawaiiBubble;
      canvas = isDark ? AppColors.dark : AppColors.kawaiiCream;
      wash = isDark ? const Color(0xFF2A2A2A) : AppColors.kawaiiSurfaceCream;
      line = isDark ? const Color(0xFF44403C) : AppColors.kawaiiOutline;
    } else {
      ink = isDark ? AppColors.darkInk : AppColors.lightInk;
      muted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
      surface = isDark ? AppColors.darkCard : AppColors.lightSurface;
      canvas = isDark ? AppColors.dark : AppColors.lightBg;
      wash = isDark ? const Color(0xFF2A2A2A) : AppColors.modernWash;
      line = isDark ? const Color(0xFF44403C) : AppColors.modernLine;
    }

    final scheme = ColorScheme.fromSeed(
      seedColor: brand,
      brightness: brightness,
      primary: brand,
      onPrimary: Colors.white,
      secondary: isCartoon ? AppColors.kawaiiWarmYellow : brandDeep,
      onSecondary: isCartoon ? AppColors.kawaiiInk : Colors.white,
      tertiary: tertiary,
      onTertiary: Colors.white,
      surface: surface,
      onSurface: ink,
      onSurfaceVariant: muted,
      error: AppColors.danger,
      onError: Colors.white,
    ).copyWith(
      surfaceContainerLowest: canvas,
      surfaceContainerHighest: wash,
      outline: line,
      outlineVariant: isDark
          ? const Color(0xFF3F3F46)
          : (isCartoon ? AppColors.kawaiiOutline : AppColors.modernLine),
      primaryContainer:
          isCartoon ? AppColors.kawaiiMint.withValues(alpha: 0.55) : AppColors.modernSageSoft,
    );

    final TextTheme rawText;
    if (isCartoon) {
      rawText = GoogleFonts.nunitoTextTheme();
    } else {
      final display = GoogleFonts.cormorantGaramondTextTheme();
      final body = GoogleFonts.nunitoTextTheme();
      rawText = body.copyWith(
        displayLarge: display.displayLarge,
        displayMedium: display.displayMedium,
        displaySmall: display.displaySmall,
        headlineLarge: display.headlineLarge?.copyWith(fontWeight: FontWeight.w600),
        headlineMedium: display.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        headlineSmall: display.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.15),
      );
    }

    final textTheme = rawText.apply(bodyColor: ink, displayColor: ink).copyWith(
          bodySmall: rawText.bodySmall?.copyWith(color: muted, height: 1.5, letterSpacing: 0.15),
          bodyMedium: rawText.bodyMedium?.copyWith(color: ink, height: 1.55, letterSpacing: 0.05),
          bodyLarge: rawText.bodyLarge?.copyWith(color: ink, height: 1.55),
          titleSmall: rawText.titleSmall?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: -0.15),
          titleMedium: rawText.titleMedium?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: -0.25),
          titleLarge: rawText.titleLarge?.copyWith(
            color: ink,
            fontWeight: isCartoon ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isCartoon ? -0.2 : 0.1,
          ),
          headlineSmall: rawText.headlineSmall?.copyWith(
            color: ink,
            fontWeight: isCartoon ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isCartoon ? -0.3 : 0,
          ),
          headlineMedium: rawText.headlineMedium?.copyWith(
            color: ink,
            fontWeight: isCartoon ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isCartoon ? -0.4 : -0.2,
          ),
          displaySmall: rawText.displaySmall?.copyWith(color: ink, fontWeight: FontWeight.w700, letterSpacing: -0.8),
          labelLarge: rawText.labelLarge?.copyWith(color: ink, fontWeight: FontWeight.w600, letterSpacing: 0.1),
          labelMedium: rawText.labelMedium?.copyWith(color: muted, fontWeight: FontWeight.w500),
        );

    final radius = isCartoon ? 28.0 : 22.0;
    final inputRadius = isCartoon ? 28.0 : 28.0;
    final chipRadius = isCartoon ? 20.0 : 16.0;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      iconTheme: IconThemeData(color: ink, size: 22),
      primaryIconTheme: IconThemeData(color: brand),
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
        labelColor: brand,
        unselectedLabelColor: muted,
        indicatorColor: brand,
        dividerColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isCartoon ? AppColors.kawaiiLemon.withValues(alpha: 0.55) : wash,
        selectedColor: brand.withValues(alpha: isCartoon ? 0.18 : 0.14),
        labelStyle: TextStyle(color: ink, fontWeight: FontWeight.w700),
        secondaryLabelStyle: TextStyle(color: ink),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(chipRadius),
          side: BorderSide(
            color: isCartoon ? AppColors.kawaiiOutline.withValues(alpha: 0.7) : AppColors.modernLine,
            width: 0.8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shadowColor: isCartoon ? AppColors.kawaiiShadow : AppColors.modernSoftShadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: isCartoon
              ? BorderSide.none
              : BorderSide(color: AppColors.modernLine.withValues(alpha: 0.7), width: 0.6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2A2A2A)
            : (isCartoon ? AppColors.kawaiiBubble : AppColors.modernWash),
        labelStyle: TextStyle(color: muted),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.9)),
        prefixIconColor: muted,
        contentPadding: EdgeInsets.symmetric(horizontal: isCartoon ? 16 : 18, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: line.withValues(alpha: 0.6), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: line.withValues(alpha: 0.55), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide(color: brand, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        indicatorColor: isCartoon ? Colors.transparent : brand.withValues(alpha: 0.12),
        indicatorShape: isCartoon ? null : RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: isCartoon ? AppColors.kawaiiCream : surface,
        surfaceTintColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(size: 22, color: selected ? brand : muted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? brand : muted,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            fontSize: isCartoon ? 11.5 : 11,
            letterSpacing: -0.1,
          );
        }),
        height: isCartoon ? 72 : 70,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: brand.withValues(alpha: 0.14),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedIconTheme: IconThemeData(color: brand),
        unselectedLabelTextStyle: TextStyle(color: muted, fontWeight: FontWeight.w500),
        selectedLabelTextStyle: TextStyle(color: brand, fontWeight: FontWeight.w700),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return brand;
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
          backgroundColor: brand,
          foregroundColor: Colors.white,
          elevation: isCartoon ? 0 : 2,
          shadowColor: isCartoon ? AppColors.kawaiiGlow : AppColors.modernSoftShadow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
        ),
      ),
      extensions: [
        DiyetselThemeExt(
          style: style,
          cardRadius: radius,
          borderWidth: isCartoon ? 0 : 0.6,
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
  bool get isModern => diyetselTheme.isModern;
  bool get isWide => MediaQuery.sizeOf(this).width >= AppConstants.desktopBreakpoint;

  /// Brand by visual style: teal (modern) or leaf green (cartoon).
  Color get brandPrimary => isCartoon ? AppColors.kawaiiLeaf : AppColors.primary;
  Color get brandDeep => isCartoon ? AppColors.kawaiiLeafDeep : AppColors.primaryDeep;
  Color get brandBright => isCartoon ? AppColors.kawaiiLeafBright : AppColors.primaryBright;
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
