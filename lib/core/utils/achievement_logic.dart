import '../data/app_store.dart';
import '../models/achievements.dart';
import '../models/models.dart';

class BadgeProgress {
  const BadgeProgress({required this.badge, required this.current, required this.earned});

  final BadgeDef badge;
  final int current;
  final bool earned;

  double get ratio => badge.target == 0 ? 0 : (current / badge.target).clamp(0, 1);
}

int consecutiveWaterGoalDays(AppStore store, String userId, {int lookback = 14}) {
  final user = store.user(userId);
  if (user == null) return 0;
  var streak = 0;
  for (var i = 0; i < lookback; i++) {
    final day = DateTime.now().subtract(Duration(days: i));
    final log = store.waterLog(userId, day);
    if (log.amountMl >= log.goalMl) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

int weeklyCheckInCount(AppStore store, String userId, {int weeks = 8}) {
  final cutoff = DateTime.now().subtract(Duration(days: weeks * 7));
  return store.checkIns(userId: userId).where((c) => c.createdAt.isAfter(cutoff)).length;
}

int mealPhotoCount(AppStore store, String userId) =>
    store.mealLogs(clientId: userId).length;

BadgeProgress progressForBadge(AppStore store, String userId, BadgeDef badge, UserProgress saved) {
  var current = 0;
  if (badge.id == 'water_week') {
    current = consecutiveWaterGoalDays(store, userId);
  } else if (badge.id == 'checkin_4') {
    current = weeklyCheckInCount(store, userId);
  } else if (badge.id == 'meal_photos_10') {
    current = mealPhotoCount(store, userId);
  } else if (badge.id == 'streak_7') {
    current = store.streak(userId).current;
  } else if (badge.lessonSeriesId != null) {
    current = saved.completedLessonDays[badge.lessonSeriesId]?.length ?? 0;
  }
  final earned = saved.earnedBadgeIds.contains(badge.id) || current >= badge.target;
  return BadgeProgress(badge: badge, current: current.clamp(0, badge.target), earned: earned);
}

List<BadgeProgress> allBadgeProgress(AppStore store, String userId, UserProgress saved) =>
    BadgeCatalog.all.map((b) => progressForBadge(store, userId, b, saved)).toList();

List<String> newlyEarnedBadges(AppStore store, String userId, UserProgress saved) {
  final fresh = <String>[];
  for (final badge in BadgeCatalog.all) {
    if (saved.earnedBadgeIds.contains(badge.id)) continue;
    final p = progressForBadge(store, userId, badge, saved);
    if (p.current >= badge.target) fresh.add(badge.id);
  }
  return fresh;
}
