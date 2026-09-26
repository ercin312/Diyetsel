import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/data/app_store.dart';
import '../core/network/local_database.dart';
import '../core/network/social_auth.dart';
import '../core/utils/reminder_service.dart';
import '../firebase_options.dart';

class BootstrapResult {
  const BootstrapResult({required this.database, this.firebaseReady = false});
  final LocalDatabase database;
  final bool firebaseReady;
}

Future<BootstrapResult> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting('tr');
  await initializeDateFormatting('en');
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
  await Hive.initFlutter();
  final box = await Hive.openBox<String>('diyetsel_store');
  final db = LocalDatabase(box);
  final store = AppStore(db);
  await store.seedIfNeeded();
  await store.ensureDietitianName();
  final appearance = store.settings();
  if (appearance.themeMode != 'light') {
    await store.saveSettings(appearance.copyWith(themeMode: 'light'));
  }

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
    try {
      await SocialAuth.ensureInitialized();
    } catch (_) {}
    try {
      await FirebaseMessaging.instance.requestPermission();
      await FirebaseMessaging.instance.subscribeToTopic('clients');
    } catch (_) {}
  } catch (_) {}

  ReminderService.instance.attach(store);
  await ReminderService.instance.init();
  if (firebaseReady) {
    FirebaseMessaging.onMessage.listen((message) async {
      final note = message.notification;
      final title = note?.title ?? message.data['title'];
      final body = note?.body ?? message.data['body'];
      if (title == null || title.isEmpty) return;
      await ReminderService.instance.showSmart(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body ?? '',
        channel: 'diyetsel_admin',
        channelName: 'Diyetisyen bildirimleri',
      );
    });
  }
  return BootstrapResult(database: db, firebaseReady: firebaseReady);
}
