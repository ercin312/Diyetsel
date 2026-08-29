import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../utils/desktop.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.fab,
    this.padding,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final desktop = context.isDesktopLayout;
    final pad = padding ?? context.pagePadding;
    final scheme = Theme.of(context).colorScheme;
    final cartoon = context.isCartoon;
    final modern = !cartoon;

    if (desktop) {
      return Scaffold(
        floatingActionButton: fab,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: cartoon
                      ? AppColors.kawaiiBubble
                      : scheme.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cartoon
                              ? AppColors.kawaiiOutline.withValues(alpha: 0.4)
                              : modern
                                  ? AppColors.modernLine
                                  : scheme.outlineVariant.withValues(alpha: 0.85),
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(28, 14, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: cartoon
                                        ? FontWeight.w900
                                        : FontWeight.w700,
                                letterSpacing: (cartoon ? 0.1 : -0.4),
                                color: cartoon ? AppColors.kawaiiInk : null,
                              ),
                        ),
                      ),
                      if (actions != null) ...actions!,
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
                  child: Padding(padding: pad, child: child),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: cartoon
                  ? Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.kawaiiInk,
                      )
                  : null,
        ),
        actions: actions,
      ),
      floatingActionButton: fab,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.contentMaxWidth),
          child: Padding(padding: pad, child: child),
        ),
      ),
    );
  }
}
