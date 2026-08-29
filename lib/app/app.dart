import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import '../core/data/app_store.dart';
import '../core/utils/desktop.dart';
import '../core/utils/smart_notification_service.dart';
import '../features/auth/presentation/auth_controller.dart';

class DiyetselApp extends ConsumerWidget {
  const DiyetselApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final router = ref.watch(routerProvider);
    final light = AppTheme.build(brightness: Brightness.light, style: theme.style);
    final dark = AppTheme.build(brightness: Brightness.dark, style: theme.style);
    return AppLifecycleSync(
      child: MaterialApp.router(
        title: 'e-Diyet',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: theme.mode,
        routerConfig: router,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        builder: (context, child) {
          final themed = Theme.of(context);
          final desktop = isDesktopOs && MediaQuery.sizeOf(context).width >= 760;
          return Theme(
            data: desktop ? applyDesktopChrome(themed) : themed,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

class AppLifecycleSync extends ConsumerStatefulWidget {
  const AppLifecycleSync({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppLifecycleSync> createState() => _AppLifecycleSyncState();
}

class _AppLifecycleSyncState extends ConsumerState<AppLifecycleSync> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _sync();
  }

  Future<void> _sync() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final store = ref.read(appStoreProvider);
    await SmartNotificationService.instance.sync(store, user);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
