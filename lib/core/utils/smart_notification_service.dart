import 'package:flutter/material.dart' show DateUtils;

import '../data/app_store.dart';
import '../models/enums.dart';
import '../models/models.dart';
import 'achievement_logic.dart';
import 'reminder_service.dart';

class SmartNotificationService {
  SmartNotificationService._();
  static final instance = SmartNotificationService._();

  static const _mealIds = [101, 102, 103, 104, 105];
  static const _waterBaseId = 110;
  static const _appointmentId = 120;
  static const _missYouId = 130;
  static const _adminSilentId = 131;

  Future<void> sync(AppStore store, UserProfile user) async {
    if (!ReminderService.instance.supportsNative) return;
    final prefs = store.prefs(user.id);
    await ReminderService.instance.cancelIds([
      ..._mealIds,
      for (var i = 0; i < 8; i++) _waterBaseId + i,
      _appointmentId,
      _missYouId,
      _adminSilentId,
    ]);

    if (user.isAdmin) {
      await _syncAdmin(store, user, prefs);
      return;
    }

    if (prefs.smartReminders) {
      await _scheduleMeals(store, user, prefs);
      await _scheduleWater(prefs);
      if (prefs.appointmentReminders) await _scheduleAppointment(store, user.id);
    }

    await _evaluateImmediate(store, user, prefs);
    if (!user.isAdmin && prefs.feedbackAlerts) await _deliverFeedback(store, user);
    if (!user.isAdmin) await _deliverAdminBroadcast(store, user);
    await AchievementService.instance.checkAndAward(store, user.id);
  }

  Future<void> _deliverFeedback(AppStore store, UserProfile user) async {
    final progress = store.userProgress(user.id);
    final note = progress.pendingFeedbackNote;
    if (note == null || note.isEmpty) return;
    await notifyDietitianFeedback(note);
    await store.saveUserProgress(progress.copyWith(clearFeedback: true));
  }

  Future<void> _deliverAdminBroadcast(AppStore store, UserProfile user) async {
    final progress = store.userProgress(user.id);
    final title = progress.pendingAdminTitle?.trim();
    final body = progress.pendingAdminBody?.trim();
    if (title == null || title.isEmpty || body == null || body.isEmpty) return;
    await ReminderService.instance.showSmart(
      id: 220,
      title: title,
      body: body,
      channel: 'diyetsel_admin',
      channelName: 'Diyetisyen bildirimleri',
    );
    await store.saveUserProgress(progress.copyWith(clearAdminNotification: true));
  }

  Future<void> notifyDietitianFeedback(String note) async {
    await ReminderService.instance.showSmart(
      id: 210,
      title: 'Diyetisyenin bir not bıraktı 💬',
      body: note,
      channel: 'diyetsel_feedback',
      channelName: 'Diyetisyen geri bildirimi',
    );
  }

  Future<void> _scheduleMeals(AppStore store, UserProfile user, NotificationPrefs prefs) async {
    final plan = store.dietPlanForClient(user.id);
    final today = plan?.days.where((d) => DateUtils.isSameDay(d.date, DateTime.now())).firstOrNull ??
        plan?.days.firstOrNull;

    if (today != null && today.meals.isNotEmpty) {
      final seen = <MealType>{};
      for (final meal in today.meals) {
        if (seen.contains(meal.type)) continue;
        seen.add(meal.type);
        final parts = meal.effectiveReminderTime.split(':');
        if (parts.length < 2) continue;
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;
        await ReminderService.instance.scheduleDaily(
          id: meal.type.notificationId,
          hour: hour,
          minute: minute,
          title: '${meal.type.tr} zamanı ${meal.type.emoji}',
          body: meal.description.isNotEmpty
              ? meal.description.split('\n').first
              : '${meal.name} — planına göz at ve işaretle.',
        );
      }
      return;
    }

    // Fallback: global prefs slots when no plan meals exist.
    final slots = [
      (MealType.breakfast.notificationId, prefs.breakfast, 'Kahvaltı zamanı ☀️', 'Planındaki kahvaltıya göz at.'),
      (MealType.lunch.notificationId, prefs.lunch, 'Öğle molası 🥗', 'Öğle öğününü unutma.'),
      (MealType.morningSnack.notificationId, prefs.snack, 'Ara öğün 🍎', 'Küçük bir ara öğün enerjini dengeler.'),
      (MealType.dinner.notificationId, prefs.dinner, 'Akşam sofrası 🌙', 'Akşam yemeğini planına göre tamamla.'),
    ];
    for (final slot in slots) {
      final parts = slot.$2.split(':');
      await ReminderService.instance.scheduleDaily(
        id: slot.$1,
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
        title: slot.$3,
        body: slot.$4,
      );
    }
  }

  Future<void> _scheduleWater(NotificationPrefs prefs) async {
    var hour = 9;
    var idx = 0;
    while (hour <= 21 && idx < 8) {
      await ReminderService.instance.scheduleDaily(
        id: _waterBaseId + idx,
        hour: hour,
        minute: 0,
        title: 'Su molası 💧',
        body: 'Bir bardak su — hedefe bir adım daha.',
      );
      hour += prefs.waterIntervalHours.clamp(1, 4);
      idx++;
    }
  }

  Future<void> _scheduleAppointment(AppStore store, String userId) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final appt = store
        .appointments()
        .where((a) =>
            a.clientId == userId &&
            a.status == AppointmentStatus.approved &&
            a.startAt.year == tomorrow.year &&
            a.startAt.month == tomorrow.month &&
            a.startAt.day == tomorrow.day)
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    if (appt.isEmpty) return;
    final first = appt.first;
    final time =
        '${first.startAt.hour.toString().padLeft(2, '0')}:${first.startAt.minute.toString().padLeft(2, '0')}';
    await ReminderService.instance.scheduleDaily(
      id: _appointmentId,
      hour: 20,
      minute: 0,
      title: 'Yarın randevun var 📅',
      body: '${first.serviceTitle ?? 'Seans'} • saat $time — hazırlıklı ol.',
    );
  }

  Future<void> _evaluateImmediate(AppStore store, UserProfile user, NotificationPrefs prefs) async {
    if (!user.isAdmin && prefs.smartReminders) {
      await _waterRemaining(store, user);
      await _dinnerReminder(store, user, prefs);
      if (prefs.inactivityAlerts) await _missYouClient(store, user);
    }
  }

  Future<void> _waterRemaining(AppStore store, UserProfile user) async {
    final now = DateTime.now();
    if (now.hour < 15) return;
    final log = store.waterLog(user.id, now);
    if (log.amountMl >= log.goalMl) return;
    final leftMl = log.goalMl - log.amountMl;
    if (leftMl <= 0) return;
    final leftL = (leftMl / 1000).toStringAsFixed(1);
    final key = 'water_left_${_dayKey(now)}';
    if (!_shouldSend(store, user.id, key)) return;
    await _markSent(store, user.id, key);
    await ReminderService.instance.showSmart(
      id: 201,
      title: 'Bugün $leftL L kaldı 💧',
      body: 'Hedefine az kaldı — bir bardak su serini canlı tutar.',
    );
  }

  Future<void> _dinnerReminder(AppStore store, UserProfile user, NotificationPrefs prefs) async {
    final parts = prefs.dinner.split(':');
    final dinner = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    ).add(const Duration(minutes: 45));
    if (DateTime.now().isBefore(dinner)) return;

    final plan = store.dietPlanForClient(user.id);
    if (plan == null) return;
    final todayMeals = plan.days
        .where((d) => _sameDay(d.date, DateTime.now()))
        .expand((d) => d.meals)
        .where((m) => m.type == MealType.dinner && !m.consumed)
        .toList();
    if (todayMeals.isEmpty) return;

    final key = 'dinner_miss_${_dayKey(DateTime.now())}';
    if (!_shouldSend(store, user.id, key)) return;
    await _markSent(store, user.id, key);
    await ReminderService.instance.showSmart(
      id: 202,
      title: 'Akşam yemeğini işaretlemedin 🌙',
      body: '${todayMeals.first.name} — planına uygun mu kontrol et.',
    );
  }

  Future<void> _missYouClient(AppStore store, UserProfile user) async {
    final last = user.lastActiveAt;
    if (last == null) return;
    if (DateTime.now().difference(last).inDays < 3) return;
    final key = 'miss_you_${_dayKey(DateTime.now())}';
    if (!_shouldSend(store, user.id, key)) return;
    await _markSent(store, user.id, key);
    await ReminderService.instance.showSmart(
      id: _missYouId,
      title: 'Seni özledik 🧡',
      body: '3 gündür görüşemedik. Küçük bir su kaydı bile serini korur — gel!',
    );
  }

  Future<void> _syncAdmin(AppStore store, UserProfile admin, NotificationPrefs prefs) async {
    if (!prefs.inactivityAlerts) return;
    final quiet = store.silentClients(days: 3);
    if (quiet.isEmpty) return;
    final key = 'admin_silent_${_dayKey(DateTime.now())}';
    if (!_shouldSend(store, admin.id, key)) return;
    await _markSent(store, admin.id, key);
    final names = quiet.take(2).map((c) => c.displayName.split(' ').first).join(', ');
    final extra = quiet.length > 2 ? ' +${quiet.length - 2}' : '';
    await ReminderService.instance.showSmart(
      id: _adminSilentId,
      title: '${quiet.length} sessiz danışan ⚠️',
      body: '$names$extra — 3+ gündür uygulamaya girmedi.',
    );
  }

  bool _shouldSend(AppStore store, String userId, String key) {
    final progress = store.userProgress(userId);
    return progress.lastNotificationKeys[key] != _dayKey(DateTime.now());
  }

  Future<void> _markSent(AppStore store, String userId, String key) async {
    final progress = store.userProgress(userId);
    await store.saveUserProgress(
      progress.copyWith(
        lastNotificationKeys: {...progress.lastNotificationKeys, key: _dayKey(DateTime.now())},
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class AchievementService {
  AchievementService._();
  static final instance = AchievementService._();

  Future<List<String>> checkAndAward(AppStore store, String userId) async {
    var progress = store.userProgress(userId);
    final fresh = newlyEarnedBadges(store, userId, progress);
    if (fresh.isEmpty) return const [];

    progress = progress.copyWith(
      earnedBadgeIds: [...progress.earnedBadgeIds, ...fresh],
      pendingCelebrations: [...progress.pendingCelebrations, ...fresh],
    );
    await store.saveUserProgress(progress);
    return fresh;
  }

  Future<void> completeLessonDay(AppStore store, String userId, String seriesId, int day) async {
    var progress = store.userProgress(userId);
    final days = {...progress.completedLessonDays};
    final list = <int>[...(days[seriesId] ?? const <int>[])];
    if (!list.contains(day)) list.add(day);
    list.sort();
    days[seriesId] = list;
    progress = progress.copyWith(completedLessonDays: days);
    await store.saveUserProgress(progress);
    await checkAndAward(store, userId);
  }
}
