import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../core/models/models.dart';
import '../../core/network/local_database.dart';

class ThemeState {
  const ThemeState({
    this.mode = ThemeMode.light,
    this.style = VisualStyle.modern,
  });

  final ThemeMode mode;
  final VisualStyle style;

  ThemeState copyWith({ThemeMode? mode, VisualStyle? style}) =>
      ThemeState(mode: mode ?? this.mode, style: style ?? this.style);
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final db = ref.watch(localDatabaseProvider);
    final raw = db.get('settings', 'app');
    if (raw == null) return const ThemeState();
    final settings = AppSettings.fromMap(raw);
    return ThemeState(
      mode: switch (settings.themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.light,
      },
      // Former "luxury" preference maps to modern (style removed).
      style: settings.visualStyle == VisualStyle.cartoon
          ? VisualStyle.cartoon
          : VisualStyle.modern,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    await _persist();
  }

  Future<void> setStyle(VisualStyle style) async {
    state = state.copyWith(style: style);
    await _persist();
  }

  Future<void> _persist() async {
    final db = ref.read(localDatabaseProvider);
    final current = db.get('settings', 'app');
    final settings = current == null ? const AppSettings() : AppSettings.fromMap(current);
    await db.put(
      'settings',
      'app',
      settings
          .copyWith(
            themeMode: switch (state.mode) {
              ThemeMode.light => 'light',
              ThemeMode.dark => 'dark',
              ThemeMode.system => 'system',
            },
            visualStyle: state.style,
          )
          .toMap(),
    );
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(ThemeController.new);
