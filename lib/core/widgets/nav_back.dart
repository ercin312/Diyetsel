import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_theme.dart';
import '../utils/desktop.dart';
import '../l10n/ui_string.dart';

/// Prefer GoRouter pop; if the stack is empty, jump to admin/client home.
void navigateBackOrHome(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null && router.canPop()) {
    router.pop();
    return;
  }
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return;
  }
  context.go(homePathFor(context));
}

bool canNavigateBack(BuildContext context) {
  final router = GoRouter.maybeOf(context);
  if (router != null && router.canPop()) return true;
  return Navigator.of(context).canPop();
}

String homePathFor(BuildContext context) {
  try {
    final path = GoRouterState.of(context).uri.path;
    return path.startsWith('/admin') ? '/admin' : '/app';
  } catch (_) {
    return '/app';
  }
}

/// Soft rounded back control — falls back to Ana sayfa on desktop when stack is empty.
class SoftNavBackButton extends StatelessWidget {
  const SoftNavBackButton({super.key, this.showLabelOnDesktop = true});

  final bool showLabelOnDesktop;

  @override
  Widget build(BuildContext context) {
    final canBack = canNavigateBack(context);
    final desktop = context.isDesktopLayout;
    final label = canBack ? 'Geri' : 'Ana sayfa';
    final icon = canBack ? Icons.arrow_back_rounded : Icons.home_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => navigateBackOrHome(context),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: desktop && showLabelOnDesktop ? 12 : 0,
              vertical: 0,
            ),
            child: SizedBox(
              height: 44,
              width: desktop && showLabelOnDesktop ? null : 44,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.primary.withValues(alpha: 0.8), size: 22),
                  if (desktop && showLabelOnDesktop) ...[
                    const SizedBox(width: 8),
                    Text((label).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Desktop / AppPage chrome: Geri or Ana sayfa.
class AppPageNavButton extends StatelessWidget {
  const AppPageNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canBack = canNavigateBack(context);
    final cartoon = context.isCartoon;
    final modern = context.isModern;
    final label = canBack ? 'Geri' : 'Ana sayfa';
    final icon = canBack ? Icons.arrow_back_rounded : Icons.home_rounded;

    final fg = cartoon
        ? AppColors.kawaiiInk
        : modern
            ? AppColors.primaryDeep
            : Theme.of(context).colorScheme.onSurface;

    return TextButton.icon(
      onPressed: () => navigateBackOrHome(context),
      icon: Icon(icon, size: 20, color: fg),
      label: Text((label).ui,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}
