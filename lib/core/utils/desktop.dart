import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// True on Windows / macOS / Linux desktop runtimes.
bool get isDesktopOs {
  if (kIsWeb) return false;
  try {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  } catch (_) {
    return false;
  }
}

bool get isWindowsDesktop {
  if (kIsWeb) return false;
  try {
    return Platform.isWindows;
  } catch (_) {
    return false;
  }
}

extension DesktopLayoutX on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);

  /// Use desktop chrome (sidebar, compact toolbars, denser content).
  /// On Windows/macOS/Linux, prefer desktop layout even at moderate widths.
  bool get isDesktopLayout {
    final w = _size.width;
    if (isDesktopOs) return w >= 760;
    return w >= AppConstants.desktopBreakpoint;
  }

  bool get isExtraWide => _size.width >= AppConstants.wideBreakpoint;

  /// Content column max width for reading comfort on large monitors.
  double get contentMaxWidth => isDesktopLayout ? 1120 : 1200;

  EdgeInsets get pagePadding => isDesktopLayout
      ? const EdgeInsets.fromLTRB(28, 20, 28, 32)
      : const EdgeInsets.fromLTRB(20, 12, 20, 24);

  EdgeInsets get homePadding => isDesktopLayout
      ? const EdgeInsets.fromLTRB(28, 20, 28, 36)
      : const EdgeInsets.fromLTRB(16, 14, 16, 28);
}
