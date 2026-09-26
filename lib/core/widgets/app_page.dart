import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../utils/desktop.dart';
import 'nav_back.dart';
import '../l10n/ui_string.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.fab,
    this.padding,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;
  final EdgeInsets? padding;
  /// Desktop header back / Ana sayfa control. Mobile uses Scaffold AppBar leading.
  final bool showBack;

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
              color: cartoon ? AppColors.kawaiiBubble : scheme.surface,
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
                  padding: const EdgeInsets.fromLTRB(16, 10, 20, 10),
                  child: Row(
                    children: [
                      if (showBack) ...[
                        const AppPageNavButton(),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text((title).ui,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: cartoon ? FontWeight.w900 : FontWeight.w700,
                                letterSpacing: cartoon ? 0.1 : -0.4,
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
        title: Text((title).ui,
          style: cartoon
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.kawaiiInk,
                  )
              : null,
        ),
        leading: showBack
            ? IconButton(
                tooltip: (canNavigateBack(context) ? 'Geri' : 'Ana sayfa').ui,
                icon: Icon(
                  canNavigateBack(context) ? Icons.arrow_back_rounded : Icons.home_rounded,
                ),
                onPressed: () => navigateBackOrHome(context),
              )
            : null,
        automaticallyImplyLeading: showBack,
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
