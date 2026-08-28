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
    this.avgMood,
    this.waistStart,
    this.waistEnd,
    this.highlights = const [],
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
  final double? avgMood;
  final double? waistStart;
  final double? waistEnd;
  final List<String> highlights;

  String get periodLabel => period == ReportPeriod.weekly ? 'Haftalık rapor' : 'Aylık rapor';

  String get periodShort => period == ReportPeriod.weekly ? 'Bu hafta' : 'Bu ay';

  double get dietCompliance =>
      dietMealsTotal == 0 ? 0 : (dietMealsConsumed / dietMealsTotal).clamp(0, 1);

  double get waterGoalRate => waterDays == 0 ? 0 : (waterGoalDays / waterDays).clamp(0, 1);

  double? get weightDelta =>
      weightStart != null && weightEnd != null ? weightEnd! - weightStart! : null;

  double? get waistDelta =>
      waistStart != null && waistEnd != null ? waistEnd! - waistStart! : null;

  /// 0–100 composite for UI hero.
  int get wellnessScore {
    var parts = 0.0;
    var weight = 0.0;
    if (waterDays > 0) {
      parts += waterGoalRate * 35;
      weight += 35;
    }
    if (dietMealsTotal > 0) {
      parts += dietCompliance * 35;
      weight += 35;
    }
    if (streakCurrent > 0 || streakBest > 0) {
      final s = (streakCurrent / (streakBest == 0 ? 7 : streakBest)).clamp(0.0, 1.0);
      parts += s * 20;
      weight += 20;
    }
    if (checkIns > 0) {
      parts += (checkIns >= 1 ? 1.0 : 0) * 10;
      weight += 10;
    }
    if (weight == 0) return 0;
    return ((parts / weight) * 100).round().clamp(0, 100);
  }

  String get scoreLabel {
    final s = wellnessScore;
    if (s >= 85) return 'Harika tempo';
    if (s >= 70) return 'İyi gidiyorsun';
    if (s >= 50) return 'Dengede tut';
    if (s > 0) return 'Küçük adımlar';
    return 'Veri toplanıyor';
  }
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

List<String> _buildHighlights({
  required PeriodReportData draft,
}) {
  final out = <String>[];
  final compliance = (draft.dietCompliance * 100).round();

  if (draft.waterDays == 0 && draft.dietMealsTotal == 0 && draft.checkIns == 0) {
    out.add('Henüz bu dönemde kayıt yok. Su ve öğün işaretlemeye başla; rapor kendiliğinden dolacak.');
    return out;
  }

  if (draft.waterDays > 0) {
    if (draft.waterGoalRate >= 0.8) {
      out.add('Su hedefini günlerin %${(draft.waterGoalRate * 100).round()}’inde tuttun — hidrasyon süper.');
    } else if (draft.waterGoalRate < 0.4) {
      out.add('Su günleri zayıf kaldı. Sabah ilk bardak + öğün yanına 1 bardak ritüeli dene.');
    } else {
      out.add('Ortalama ${(draft.avgWaterMl / 1000).toStringAsFixed(1)} L su — hedefe yaklaşmak için öğleden sonra hatırlatıcı kur.');
    }
  }

  if (draft.dietMealsTotal > 0) {
    if (compliance >= 80) {
      out.add('Diyet uyumu %$compliance — planındaki ${draft.dietMealsConsumed}/${draft.dietMealsTotal} öğünü tamamladın.');
    } else if (compliance < 50) {
      out.add('Öğün işaretleme %$compliance. En kolay öğünden başla; tutarlılık mükemmellikten önemli.');
    } else {
      out.add('Diyet uyumu %$compliance. Eksik kalan öğünleri yarın için yeniden planla.');
    }
  }

  if (draft.weightDelta != null) {
    final d = draft.weightDelta!;
    if (d.abs() < 0.3) {
      out.add('Kilo neredeyse sabit (${d >= 0 ? '+' : ''}${d.toStringAsFixed(1)} kg) — ölçüm gürültüsü normal.');
    } else if (d < 0) {
      out.add('Dönem içinde ${d.abs().toStringAsFixed(1)} kg düşüş kaydedildi. Trend için haftalık aynı saatte tartıl.');
    } else {
      out.add('Kilo +${d.toStringAsFixed(1)} kg. Su tutulması veya kas artışı da olabilir; bel çevresine bak.');
    }
  }

  if (draft.waistDelta != null && draft.waistDelta!.abs() >= 0.5) {
    final w = draft.waistDelta!;
    out.add(w < 0
        ? 'Bel çevresi ${w.abs().toStringAsFixed(1)} cm inceldi — iyi bir vücut kompozisyonu sinyali.'
        : 'Bel +${w.toStringAsFixed(1)} cm; ölçümü sabah aç karnına tekrarla.');
  }

  if (draft.streakCurrent >= 3) {
    out.add('${draft.streakCurrent} günlük aktif serin var (rekor ${draft.streakBest}). Zinciri kırma!');
  } else if (draft.streakCurrent == 0 && draft.streakBest > 0) {
    out.add('Seri sıfırlandı ama rekorun ${draft.streakBest} gün — yarın yeniden başlat.');
  }

  if (draft.avgMood != null) {
    final m = draft.avgMood!;
    if (m >= 4) {
      out.add('Ortalama ruh hali ${m.toStringAsFixed(1)}/5 — enerji yüksek görünüyor.');
    } else if (m <= 2.5) {
      out.add('Ruh hali ortalaması düşük (${m.toStringAsFixed(1)}/5). Uyku ve öğün zamanlamasını gözden geçir.');
    }
  }

  if (draft.mealPhotos > 0) {
    out.add('${draft.mealPhotos} öğün fotoğrafı paylaştın — diyetisyenin için değerli geri bildirim.');
  }

  if (draft.appointments > 0) {
    out.add('${draft.appointments} seans/randevu bu dönemde tamamlandı veya planlandı.');
  }

  return out.take(5).toList();
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
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final checkInItems = store
      .checkIns(userId: user.id)
      .where((c) => _inRange(c.createdAt, start, end))
      .toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

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
  double? waistStart;
  double? waistEnd;

  if (measures.isNotEmpty) {
    weightStart = measures.first.weight;
    weightEnd = measures.last.weight;
    waistStart = measures.first.waist;
    waistEnd = measures.last.waist;
  } else if (checkInItems.isNotEmpty) {
    weightStart = checkInItems.first.weight;
    weightEnd = checkInItems.last.weight;
    waistStart = checkInItems.first.waist;
    waistEnd = checkInItems.last.waist;
  }

  double? avgMood;
  if (checkInItems.isNotEmpty) {
    avgMood = checkInItems.fold<int>(0, (s, c) => s + c.mood) / checkInItems.length;
  }

  final draft = PeriodReportData(
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
    avgMood: avgMood,
    waistStart: waistStart,
    waistEnd: waistEnd,
  );

  return PeriodReportData(
    period: draft.period,
    start: draft.start,
    end: draft.end,
    user: draft.user,
    waterDays: draft.waterDays,
    waterGoalDays: draft.waterGoalDays,
    avgWaterMl: draft.avgWaterMl,
    totalWaterMl: draft.totalWaterMl,
    dietMealsTotal: draft.dietMealsTotal,
    dietMealsConsumed: draft.dietMealsConsumed,
    mealPhotos: draft.mealPhotos,
    checkIns: draft.checkIns,
    appointments: draft.appointments,
    streakCurrent: draft.streakCurrent,
    streakBest: draft.streakBest,
    weightStart: draft.weightStart,
    weightEnd: draft.weightEnd,
    measurements: draft.measurements,
    dailyWater: draft.dailyWater,
    avgMood: draft.avgMood,
    waistStart: draft.waistStart,
    waistEnd: draft.waistEnd,
    highlights: _buildHighlights(draft: draft),
  );
}
