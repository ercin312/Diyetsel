import 'package:flutter/material.dart';

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

    if (desktop) {
      return Scaffold(
        floatingActionButton: fab,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: scheme.surface,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.85)),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 14, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.4,
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
      appBar: AppBar(title: Text(title), actions: actions),
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
