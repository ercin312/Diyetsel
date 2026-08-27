import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../data/app_store.dart';
import '../data/providers.dart';
import '../models/app_modules.dart';
import 'app_page.dart';
import 'diyetsel_widgets.dart';

/// Returns a locked page when the clinic or this client has the module off.
/// Admins always see the real screen.
Widget? lockedIfOff(WidgetRef ref, {required String module, required String title}) {
  final user = ref.watch(authControllerProvider).user;
  if (user == null || user.isAdmin) return null;
  ref.watch(settingsProvider);
  ref.watch(usersProvider);
  if (ref.watch(appStoreProvider).moduleOn(user.id, module)) return null;
  return AppPage(
    title: title,
    child: ModuleLocked(title: AppModule.label(module)),
  );
}
