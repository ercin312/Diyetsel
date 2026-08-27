import '../data/app_store.dart';
import '../models/models.dart';

enum ReportPeriod { weekly, monthly }

class PeriodReportData {
  const PeriodReportData({
    required this.period,
    required this.start,
    required this.end,
    required this.user,
    required this.waterDays,
    required this.waterGoalDays,
    required this.avgWaterMl,
    required this.totalWaterMl,
    required this.dietMealsTotal,
    required this.dietMealsConsumed,
    required this.mealPhotos,
    required this.checkIns,
    required this.appointments,
    required this.streakCurrent,
    required this.streakBest,
    required this.weightStart,
    required this.weightEnd,
    required this.measurements,
    required this.dailyWater,
  });

  final ReportPeriod period;
  final DateTime start;
  final DateTime end;
  final UserProfile user;
  final int waterDays;
  final int waterGoalDays;
  final int avgWaterMl;
  final int totalWaterMl;
  final int dietMealsTotal;
  final int dietMealsConsumed;
  final int mealPhotos;
  final int checkIns;
  final int appointments;
  final int streakCurrent;
  final int streakBest;
  final double? weightStart;
  final double? weightEnd;
  final List<BodyMeasurement> measurements;
  final List<WaterLog> dailyWater;

  String get periodLabel => period == ReportPeriod.weekly ? 'Haftalık rapor' : 'Aylık rapor';

  double get dietCompliance =>
      dietMealsTotal == 0 ? 0 : (dietMealsConsumed / dietMealsTotal).clamp(0, 1);

  double? get weightDelta =>
      weightStart != null && weightEnd != null ? weightEnd! - weightStart! : null;
}

DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _parseDayKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return DateTime.now();
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

bool _inRange(DateTime date, DateTime start, DateTime end) {
  final d = _dayOnly(date);
  return !d.isBefore(_dayOnly(start)) && !d.isAfter(_dayOnly(end));
}

(DateTime start, DateTime end) periodRange(ReportPeriod period, [DateTime? anchor]) {
  final now = anchor ?? DateTime.now();
  final today = _dayOnly(now);
  if (period == ReportPeriod.weekly) {
    return (today.subtract(const Duration(days: 6)), today);
  }
  return (DateTime(today.year, today.month, 1), today);
}

PeriodReportData buildPeriodReport({
  required AppStore store,
  required UserProfile user,
  required ReportPeriod period,
  DateTime? anchor,
}) {
  final range = periodRange(period, anchor);
  final start = range.$1;
  final end = range.$2;

  final waterInPeriod = store
      .waterLogs()
      .where((w) => w.userId == user.id && _inRange(_parseDayKey(w.day), start, end))
      .toList()
    ..sort((a, b) => a.day.compareTo(b.day));

  final waterGoalDays = waterInPeriod.where((w) => w.progress >= 1).length;
  final totalWater = waterInPeriod.fold<int>(0, (s, w) => s + w.amountMl);
  final avgWater = waterInPeriod.isEmpty ? 0 : (totalWater / waterInPeriod.length).round();

  final plan = store.dietPlanForClient(user.id);
  var mealsTotal = 0;
  var mealsConsumed = 0;
  if (plan != null) {
    for (final day in plan.days) {
      if (_inRange(day.date, start, end)) {
        mealsTotal += day.meals.length;
        mealsConsumed += day.meals.where((m) => m.consumed).length;
      }
    }
  }

  final measures = store
      .measurements(user.id)
      .where((m) => _inRange(m.date, start, end))
      .toList();

  final checkInItems = store
      .checkIns(userId: user.id)
      .where((c) => _inRange(c.createdAt, start, end))
      .toList();

  final appointmentItems = store
      .appointments()
      .where((a) => a.clientId == user.id && _inRange(a.startAt, start, end))
      .toList();

  final mealPhotoCount = store
      .mealLogs(clientId: user.id)
      .where((m) => _inRange(m.createdAt, start, end))
      .length;

  final streak = store.streak(user.id);

  double? weightStart;
  double? weightEnd;
  if (measures.isNotEmpty) {
    weightStart = measures.first.weight;
    weightEnd = measures.last.weight;
  } else if (checkInItems.isNotEmpty) {
    final sorted = checkInItems.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    weightStart = sorted.first.weight;
    weightEnd = sorted.last.weight;
  }

  return PeriodReportData(
    period: period,
    start: start,
    end: end,
    user: user,
    waterDays: waterInPeriod.length,
    waterGoalDays: waterGoalDays,
    avgWaterMl: avgWater,
    totalWaterMl: totalWater,
    dietMealsTotal: mealsTotal,
    dietMealsConsumed: mealsConsumed,
    mealPhotos: mealPhotoCount,
    checkIns: checkInItems.length,
    appointments: appointmentItems.length,
    streakCurrent: streak.current,
    streakBest: streak.best,
    weightStart: weightStart,
    weightEnd: weightEnd,
    measurements: measures,
    dailyWater: waterInPeriod,
  );
}
