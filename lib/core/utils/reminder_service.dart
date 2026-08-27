import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/app_store.dart';
import '../models/models.dart';

class ReminderService {
  ReminderService._();
  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  AppStore? _store;

  bool get supportsNative => !kIsWeb && !Platform.isWindows && !Platform.isLinux;

  void attach(AppStore store) => _store = store;

  Future<void> init() async {
    if (!supportsNative) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: _onResponse,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  void _onResponse(NotificationResponse response) {
    if (response.actionId == 'sip' || response.payload == 'water-sip') {
      _sip();
    }
  }

  Future<void> _sip() async {
    final store = _store;
    final userId = store?.settings().sessionUserId;
    if (store == null || userId == null) return;
    await store.addWaterSip(userId);
    await showWaterShortcut();
  }

  Future<void> resync(NotificationPrefs prefs) async {
    if (!_ready) return;
    await _plugin.cancelAll();
    if (prefs.waterShortcut) {
      await showWaterShortcut();
    }
  }

  Future<void> cancelIds(List<int> ids) async {
    if (!_ready) return;
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }

  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_ready) return;
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    const android = AndroidNotificationDetails(
      'diyetsel_smart',
      'Akıllı hatırlatıcılar',
      channelDescription: 'Su, öğün ve randevu bildirimleri',
      importance: Importance.high,
    );
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        matchDateTimeComponents: DateTimeComponents.time,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        notificationDetails: const NotificationDetails(
          android: android,
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (_) {}
  }

  Future<void> showSmart({
    required int id,
    required String title,
    required String body,
    String channel = 'diyetsel_smart',
    String channelName = 'Akıllı hatırlatıcılar',
  }) async {
    if (!_ready) return;
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel,
          channelName,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showWaterShortcut() async {
    if (!_ready) return;
    final userId = _store?.settings().sessionUserId;
    final log = userId == null ? null : _store?.waterLog(userId, DateTime.now());
    await _plugin.show(
      id: 40,
      title: 'Su • ${log?.amountMl ?? 0} / ${log?.goalMl ?? 2500} ml',
      body: 'Hızlı eklemek için +250 ml',
      payload: 'water-sip',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'diyetsel_water',
          'Su kısayolu',
          channelDescription: 'Kalıcı su ekleme bildirimi',
          ongoing: true,
          autoCancel: false,
          importance: Importance.low,
          actions: [
            AndroidNotificationAction('sip', '+250 ml', cancelNotification: false, showsUserInterface: false),
          ],
        ),
      ),
    );
  }

  Future<void> hideWaterShortcut() async {
    if (!_ready) return;
    await _plugin.cancel(id: 40);
  }

  Future<void> banner(String title, String body) async {
    await showSmart(id: 99, title: title, body: body);
  }
}
