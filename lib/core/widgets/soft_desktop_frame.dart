import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../utils/desktop.dart';

/// Centers soft modern content on Windows / wide desktop monitors.
/// Mobile: passes [child] through unchanged (caller keeps its own padding).
class SoftDesktopFrame extends StatelessWidget {
  const SoftDesktopFrame({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.backgroundColor = AppColors.modernWash,
    this.scroll = true,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color backgroundColor;
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    if (!desktop) return child;

    final pad = padding ?? context.pagePadding;
    final width = maxWidth ?? context.contentMaxWidth;

    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: scroll
            ? SingleChildScrollView(
                padding: pad,
                child: child,
              )
            : Padding(padding: pad, child: child),
      ),
    );

    return ColoredBox(color: backgroundColor, child: content);
  }
}

/// Soft desktop body for screens that already own a [ListView] / scroll.
/// Only constrains width + horizontal gutters; does not nest another scroll.
class SoftDesktopBody extends StatelessWidget {
  const SoftDesktopBody({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktopLayout) return child;

    final pad = padding ??
        EdgeInsets.fromLTRB(
          context.pagePadding.left,
          0,
          context.pagePadding.right,
          0,
        );
    final width = maxWidth ?? context.contentMaxWidth;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}
