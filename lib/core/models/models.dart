import 'enums.dart';

DateTime _dt(dynamic v, [DateTime? fallback]) {
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v) ?? fallback ?? DateTime.now();
  return fallback ?? DateTime.now();
}

int _i(dynamic v, [int d = 0]) => v is int ? v : int.tryParse('$v') ?? d;
double _d(dynamic v, [double d = 0]) =>
    v is double ? v : (v is int ? v.toDouble() : double.tryParse('$v') ?? d);
bool _b(dynamic v, [bool d = false]) => v is bool ? v : d;
String _s(dynamic v, [String d = '']) => v?.toString() ?? d;

Map<String, bool> _boolMap(dynamic v) {
  if (v is Map) {
    return v.map((k, val) => MapEntry('$k', val == true || val == 'true' || val == 1));
  }
  return {};
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    this.photoUrl,
    this.phone,
    required this.createdAt,
    this.heightCm,
    this.targetWeightKg,
    this.waterGoalMl = 2500,
    this.isActive = true,
    this.notes,
    this.fcmTokens = const [],
    this.lastActiveAt,
    this.moduleOverrides = const {},
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final DateTime createdAt;
  final double? heightCm;
  final double? targetWeightKg;
  final int waterGoalMl;
  final bool isActive;
  final String? notes;
  final List<String> fcmTokens;
  final DateTime? lastActiveAt;
  final Map<String, bool> moduleOverrides;

  bool get isAdmin => role == UserRole.admin;

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? phone,
    double? heightCm,
    double? targetWeightKg,
    int? waterGoalMl,
    bool? isActive,
    String? notes,
    UserRole? role,
    DateTime? lastActiveAt,
    Map<String, bool>? moduleOverrides,
  }) {
    return UserProfile(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      heightCm: heightCm ?? this.heightCm,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      waterGoalMl: waterGoalMl ?? this.waterGoalMl,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      fcmTokens: fcmTokens,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      moduleOverrides: moduleOverrides ?? this.moduleOverrides,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'photoUrl': photoUrl,
        'phone': phone,
        'createdAt': createdAt.toIso8601String(),
        'heightCm': heightCm,
        'targetWeightKg': targetWeightKg,
        'waterGoalMl': waterGoalMl,
        'isActive': isActive,
        'notes': notes,
        'fcmTokens': fcmTokens,
        'lastActiveAt': lastActiveAt?.toIso8601String(),
        'moduleOverrides': moduleOverrides,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: _s(map['id']),
        email: _s(map['email']),
        displayName: _s(map['displayName']),
        role: UserRoleX.from(_s(map['role'])),
        photoUrl: map['photoUrl'] as String?,
        phone: map['phone'] as String?,
        createdAt: _dt(map['createdAt']),
        heightCm: map['heightCm'] == null ? null : _d(map['heightCm']),
        targetWeightKg:
            map['targetWeightKg'] == null ? null : _d(map['targetWeightKg']),
        waterGoalMl: _i(map['waterGoalMl'], 2500),
        isActive: _b(map['isActive'], true),
        notes: map['notes'] as String?,
        fcmTokens: (map['fcmTokens'] as List?)?.map((e) => '$e').toList() ?? const [],
        lastActiveAt: map['lastActiveAt'] == null ? null : _dt(map['lastActiveAt']),
        moduleOverrides: _boolMap(map['moduleOverrides']),
      );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.dietitianId,
    required this.clientId,
    required this.clientName,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.serviceId,
    this.serviceTitle,
    this.clinicalNotes,
    this.recommendations,
    this.rescheduleReason,
  });

  final String id;
  final String dietitianId;
  final String clientId;
  final String clientName;
  final DateTime startAt;
  final DateTime endAt;
  final AppointmentStatus status;
  final String? serviceId;
  final String? serviceTitle;
  final String? clinicalNotes;
  final String? recommendations;
  final String? rescheduleReason;

  Appointment copyWith({
    AppointmentStatus? status,
    DateTime? startAt,
    DateTime? endAt,
    String? clinicalNotes,
    String? recommendations,
    String? rescheduleReason,
  }) {
    return Appointment(
      id: id,
      dietitianId: dietitianId,
      clientId: clientId,
      clientName: clientName,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      serviceId: serviceId,
      serviceTitle: serviceTitle,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      recommendations: recommendations ?? this.recommendations,
      rescheduleReason: rescheduleReason ?? this.rescheduleReason,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'dietitianId': dietitianId,
        'clientId': clientId,
        'clientName': clientName,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'status': status.name,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'clinicalNotes': clinicalNotes,
        'recommendations': recommendations,
        'rescheduleReason': rescheduleReason,
      };

  factory Appointment.fromMap(Map<String, dynamic> map) => Appointment(
        id: _s(map['id']),
        dietitianId: _s(map['dietitianId']),
        clientId: _s(map['clientId']),
        clientName: _s(map['clientName']),
        startAt: _dt(map['startAt']),
        endAt: _dt(map['endAt']),
        status: AppointmentStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => AppointmentStatus.pending,
        ),
        serviceId: map['serviceId'] as String?,
        serviceTitle: map['serviceTitle'] as String?,
        clinicalNotes: map['clinicalNotes'] as String?,
        recommendations: map['recommendations'] as String?,
        rescheduleReason: map['rescheduleReason'] as String?,
      );
}

class AvailabilityRule {
  const AvailabilityRule({
    required this.id,
    required this.dietitianId,
    required this.weekday,
    required this.start,
    required this.end,
    this.slotMinutes = 45,
  });

  final String id;
  final String dietitianId;
  final int weekday;
  final String start;
  final String end;
  final int slotMinutes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'dietitianId': dietitianId,
        'weekday': weekday,
        'start': start,
        'end': end,
        'slotMinutes': slotMinutes,
      };

  factory AvailabilityRule.fromMap(Map<String, dynamic> map) => AvailabilityRule(
        id: _s(map['id']),
        dietitianId: _s(map['dietitianId']),
        weekday: _i(map['weekday'], 1),
        start: _s(map['start'], '09:00'),
        end: _s(map['end'], '18:00'),
        slotMinutes: _i(map['slotMinutes'], 45),
      );
}

class ServicePackage {
  const ServicePackage({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.bullets,
    this.active = true,
    this.category = 'Paket',
    this.tagline = '',
    this.tags = const [],
    this.imageUrl,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final int durationMinutes;
  final List<String> bullets;
  final bool active;
  final String category;
  final String tagline;
  final List<String> tags;
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'durationMinutes': durationMinutes,
        'bullets': bullets,
        'active': active,
        'category': category,
        'tagline': tagline,
        'tags': tags,
        'imageUrl': imageUrl,
      };

  factory ServicePackage.fromMap(Map<String, dynamic> map) => ServicePackage(
        id: _s(map['id']),
        title: _s(map['title']),
        description: _s(map['description']),
        price: _d(map['price']),
        durationMinutes: _i(map['durationMinutes'], 45),
        bullets: (map['bullets'] as List?)?.map((e) => '$e').toList() ?? const [],
        active: _b(map['active'], true),
        category: _s(map['category'], 'Paket'),
        tagline: _s(map['tagline']),
        tags: (map['tags'] as List?)?.map((e) => '$e').toList() ?? const [],
        imageUrl: map['imageUrl'] as String?,
      );
}

class ServiceRequest {
  const ServiceRequest({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.serviceId,
    required this.serviceTitle,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String serviceId;
  final String serviceTitle;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'serviceId': serviceId,
        'serviceTitle': serviceTitle,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceRequest.fromMap(Map<String, dynamic> map) => ServiceRequest(
        id: _s(map['id']),
        clientId: _s(map['clientId']),
        clientName: _s(map['clientName']),
        serviceId: _s(map['serviceId']),
        serviceTitle: _s(map['serviceTitle']),
        status: _s(map['status'], 'pending'),
        createdAt: _dt(map['createdAt']),
      );
}

class Ingredient {
  const Ingredient({
    required this.name,
    required this.amount,
    this.category = 'other',
  });

  final String name;
  final String amount;
  final String category;

  Map<String, dynamic> toMap() => {
        'name': name,
        'amount': amount,
        'category': category,
      };

  factory Ingredient.fromMap(Map<String, dynamic> map) => Ingredient(
        name: _s(map['name']),
        amount: _s(map['amount']),
        category: _s(map['category'], 'other'),
      );
}

class DietMeal {
  const DietMeal({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.consumed = false,
    this.ingredients = const [],
    this.reminderTime,
  });

  final String id;
  final MealType type;
  final String name;
  final String description;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool consumed;
  final List<Ingredient> ingredients;
  /// Optional daily reminder `HH:mm`. Falls back to [MealTypeX.defaultReminderTime].
  final String? reminderTime;

  String get effectiveReminderTime => reminderTime ?? type.defaultReminderTime;

  DietMeal copyWith({
    bool? consumed,
    String? name,
    String? description,
    String? reminderTime,
    bool clearReminderTime = false,
  }) =>
      DietMeal(
        id: id,
        type: type,
        name: name ?? this.name,
        description: description ?? this.description,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        consumed: consumed ?? this.consumed,
        ingredients: ingredients,
        reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'name': name,
        'description': description,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'consumed': consumed,
        'ingredients': ingredients.map((e) => e.toMap()).toList(),
        if (reminderTime != null) 'reminderTime': reminderTime,
      };

  factory DietMeal.fromMap(Map<String, dynamic> map) => DietMeal(
        id: _s(map['id']),
        type: MealType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MealType.lunch,
        ),
        name: _s(map['name']),
        description: _s(map['description']),
        calories: _i(map['calories']),
        protein: _i(map['protein']),
        carbs: _i(map['carbs']),
        fat: _i(map['fat']),
        consumed: _b(map['consumed']),
        ingredients: (map['ingredients'] as List?)
                ?.whereType<Map>()
                .map((e) => Ingredient.fromMap(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        reminderTime: map['reminderTime'] == null ? null : _s(map['reminderTime']),
      );
}

class DietDay {
  const DietDay({required this.date, required this.meals});

  final DateTime date;
  final List<DietMeal> meals;

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'meals': meals.map((e) => e.toMap()).toList(),
      };

  factory DietDay.fromMap(Map<String, dynamic> map) => DietDay(
        date: _dt(map['date']),
        meals: (map['meals'] as List?)
                ?.whereType<Map>()
                .map((e) => DietMeal.fromMap(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );
}

class DietPlan {
  const DietPlan({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.dietitianId,
    required this.title,
    required this.weekStart,
    required this.days,
    this.calorieTarget = 1800,
    this.proteinTarget = 110,
    this.carbsTarget = 160,
    this.fatTarget = 60,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String dietitianId;
  final String title;
  final DateTime weekStart;
  final List<DietDay> days;
  final int calorieTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;

  DietPlan copyWith({List<DietDay>? days}) => DietPlan(
        id: id,
        clientId: clientId,
        clientName: clientName,
        dietitianId: dietitianId,
        title: title,
        weekStart: weekStart,
        days: days ?? this.days,
        calorieTarget: calorieTarget,
        proteinTarget: proteinTarget,
        carbsTarget: carbsTarget,
        fatTarget: fatTarget,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'dietitianId': dietitianId,
        'title': title,
        'weekStart': weekStart.toIso8601String(),
        'days': days.map((e) => e.toMap()).toList(),
        'calorieTarget': calorieTarget,
        'proteinTarget': proteinTarget,
        'carbsTarget': carbsTarget,
        'fatTarget': fatTarget,
      };

  factory DietPlan.fromMap(Map<String, dynamic> map) => DietPlan(
        id: _s(map['id']),
        clientId: _s(map['clientId']),
        clientName: _s(map['clientName']),
        dietitianId: _s(map['dietitianId']),
        title: _s(map['title']),
        weekStart: _dt(map['weekStart']),
        days: (map['days'] as List?)
                ?.whereType<Map>()
                .map((e) => DietDay.fromMap(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        calorieTarget: _i(map['calorieTarget'], 1800),
        proteinTarget: _i(map['proteinTarget'], 110),
        carbsTarget: _i(map['carbsTarget'], 160),
        fatTarget: _i(map['fatTarget'], 60),
      );
}

class WaterLog {
  const WaterLog({
    required this.userId,
    required this.day,
    required this.amountMl,
    required this.goalMl,
  });

  final String userId;
  final String day;
  final int amountMl;
  final int goalMl;

  double get progress => goalMl == 0 ? 0 : (amountMl / goalMl).clamp(0, 1);

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'day': day,
        'amountMl': amountMl,
        'goalMl': goalMl,
      };

  factory WaterLog.fromMap(Map<String, dynamic> map) => WaterLog(
        userId: _s(map['userId']),
        day: _s(map['day']),
        amountMl: _i(map['amountMl']),
        goalMl: _i(map['goalMl'], 2500),
      );
}

class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.userId,
    required this.date,
    this.weight,
    this.waist,
    this.hip,
    this.bodyFat,
    this.muscle,
    this.beforePhotoPath,
    this.afterPhotoPath,
  });

  final String id;
  final String userId;
  final DateTime date;
  final double? weight;
  final double? waist;
  final double? hip;
  final double? bodyFat;
  final double? muscle;
  final String? beforePhotoPath;
  final String? afterPhotoPath;

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'date': date.toIso8601String(),
        'weight': weight,
        'waist': waist,
        'hip': hip,
        'bodyFat': bodyFat,
        'muscle': muscle,
        'beforePhotoPath': beforePhotoPath,
        'afterPhotoPath': afterPhotoPath,
      };

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) => BodyMeasurement(
        id: _s(map['id']),
        userId: _s(map['userId']),
        date: _dt(map['date']),
        weight: map['weight'] == null ? null : _d(map['weight']),
        waist: map['waist'] == null ? null : _d(map['waist']),
        hip: map['hip'] == null ? null : _d(map['hip']),
        bodyFat: map['bodyFat'] == null ? null : _d(map['bodyFat']),
        muscle: map['muscle'] == null ? null : _d(map['muscle']),
        beforePhotoPath: map['beforePhotoPath'] as String?,
        afterPhotoPath: map['afterPhotoPath'] as String?,
      );
}

class MealPhotoLog {
  const MealPhotoLog({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.photoPath,
    required this.createdAt,
    this.caption,
    this.feedbackEmoji,
    this.feedbackNote,
    this.mealType,
    this.estimatedKcal,
    this.stamp,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String photoPath;
  final DateTime createdAt;
  final String? caption;
  final String? feedbackEmoji;
  final String? feedbackNote;
  final MealType? mealType;
  final int? estimatedKcal;
  final String? stamp;

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'photoPath': photoPath,
        'createdAt': createdAt.toIso8601String(),
        'caption': caption,
        'feedbackEmoji': feedbackEmoji,
        'feedbackNote': feedbackNote,
        'mealType': mealType?.name,
        'estimatedKcal': estimatedKcal,
        'stamp': stamp,
      };

  factory MealPhotoLog.fromMap(Map<String, dynamic> map) => MealPhotoLog(
        id: _s(map['id']),
        clientId: _s(map['clientId']),
        clientName: _s(map['clientName']),
        photoPath: _s(map['photoPath']),
        createdAt: _dt(map['createdAt']),
        caption: map['caption'] as String?,
        feedbackEmoji: map['feedbackEmoji'] as String?,
        feedbackNote: map['feedbackNote'] as String?,
        mealType: map['mealType'] == null
            ? null
            : MealType.values.firstWhere((e) => e.name == map['mealType'], orElse: () => MealType.lunch),
        estimatedKcal: map['estimatedKcal'] == null ? null : _i(map['estimatedKcal']),
        stamp: map['stamp'] as String?,
      );

  MealPhotoLog copyWith({
    String? caption,
    String? feedbackEmoji,
    String? feedbackNote,
    MealType? mealType,
    int? estimatedKcal,
    String? stamp,
  }) {
    return MealPhotoLog(
      id: id,
      clientId: clientId,
      clientName: clientName,
      photoPath: photoPath,
      createdAt: createdAt,
      caption: caption ?? this.caption,
      feedbackEmoji: feedbackEmoji ?? this.feedbackEmoji,
      feedbackNote: feedbackNote ?? this.feedbackNote,
      mealType: mealType ?? this.mealType,
      estimatedKcal: estimatedKcal ?? this.estimatedKcal,
      stamp: stamp ?? this.stamp,
    );
  }
}

class RichBlock {
  const RichBlock({
    required this.type,
    required this.text,
    this.bold = false,
    this.italic = false,
    this.imagePath,
  });

  final String type;
  final String text;
  final bool bold;
  final bool italic;
  final String? imagePath;

  Map<String, dynamic> toMap() => {
        'type': type,
        'text': text,
        'bold': bold,
        'italic': italic,
        'imagePath': imagePath,
      };

  factory RichBlock.fromMap(Map<String, dynamic> map) => RichBlock(
        type: _s(map['type'], 'paragraph'),
        text: _s(map['text']),
        bold: _b(map['bold']),
        italic: _b(map['italic']),
        imagePath: map['imagePath'] as String?,
      );
}

class BlogPost {
  const BlogPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authorId,
    required this.authorName,
    required this.category,
    required this.tags,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.coverUrl,
    this.published = false,
    this.likes = 0,
  });

  final String id;
  final String title;
  final String subtitle;
  final String authorId;
  final String authorName;
  final String category;
  final List<String> tags;
  final List<RichBlock> body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverUrl;
  final bool published;
  final int likes;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'authorId': authorId,
        'authorName': authorName,
        'category': category,
        'tags': tags,
        'body': body.map((e) => e.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'coverUrl': coverUrl,
        'published': published,
        'likes': likes,
      };

  factory BlogPost.fromMap(Map<String, dynamic> map) => BlogPost(
        id: _s(map['id']),
        title: _s(map['title']),
        subtitle: _s(map['subtitle']),
        authorId: _s(map['authorId']),
        authorName: _s(map['authorName']),
        category: _s(map['category']),
        tags: (map['tags'] as List?)?.map((e) => '$e').toList() ?? const [],
        body: (map['body'] as List?)
                ?.whereType<Map>()
                .map((e) => RichBlock.fromMap(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        createdAt: _dt(map['createdAt']),
        updatedAt: _dt(map['updatedAt']),
        coverUrl: map['coverUrl'] as String?,
        published: _b(map['published']),
        likes: _i(map['likes']),
      );
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    required this.prepMinutes,
    required this.allergens,
    required this.steps,
    required this.ingredients,
    required this.category,
    this.imageUrl,
    this.proteinGrams = 0,
    this.carbsGrams = 0,
    this.fatGrams = 0,
    this.servings = 1,
    this.cookMinutes = 0,
    this.tags = const [],
    this.tips = const [],
  });

  final String id;
  final String title;
  final String description;
  final int calories;
  final int prepMinutes;
  final List<String> allergens;
  final List<String> steps;
  final List<Ingredient> ingredients;
  final String category;
  final String? imageUrl;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final int servings;
  final int cookMinutes;
  final List<String> tags;
  final List<String> tips;

  int get totalMinutes => prepMinutes + (cookMinutes > 0 ? cookMinutes : 0);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'calories': calories,
        'prepMinutes': prepMinutes,
        'allergens': allergens,
        'steps': steps,
        'ingredients': ingredients.map((e) => e.toMap()).toList(),
        'category': category,
        'imageUrl': imageUrl,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatGrams': fatGrams,
        'servings': servings,
        'cookMinutes': cookMinutes,
        'tags': tags,
        'tips': tips,
      };

  factory Recipe.fromMap(Map<String, dynamic> map) => Recipe(
        id: _s(map['id']),
        title: _s(map['title']),
        description: _s(map['description']),
        calories: _i(map['calories']),
        prepMinutes: _i(map['prepMinutes']),
        allergens: (map['allergens'] as List?)?.map((e) => '$e').toList() ?? const [],
        steps: (map['steps'] as List?)?.map((e) => '$e').toList() ?? const [],
        ingredients: (map['ingredients'] as List?)
                ?.whereType<Map>()
                .map((e) => Ingredient.fromMap(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
        category: _s(map['category']),
        imageUrl: map['imageUrl'] as String?,
        proteinGrams: _i(map['proteinGrams']),
        carbsGrams: _i(map['carbsGrams']),
        fatGrams: _i(map['fatGrams']),
        servings: _i(map['servings'], 1).clamp(1, 99),
        cookMinutes: _i(map['cookMinutes']),
        tags: (map['tags'] as List?)?.map((e) => '$e').toList() ?? const [],
        tips: (map['tips'] as List?)?.map((e) => '$e').toList() ?? const [],
      );
}

class ChatThread {
  const ChatThread({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.lastAt,
  });

  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final String lastMessage;
  final DateTime lastAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'participantIds': participantIds,
        'participantNames': participantNames,
        'lastMessage': lastMessage,
        'lastAt': lastAt.toIso8601String(),
      };

  factory ChatThread.fromMap(Map<String, dynamic> map) => ChatThread(
        id: _s(map['id']),
        participantIds:
            (map['participantIds'] as List?)?.map((e) => '$e').toList() ?? const [],
        participantNames:
            (map['participantNames'] as List?)?.map((e) => '$e').toList() ?? const [],
        lastMessage: _s(map['lastMessage']),
        lastAt: _dt(map['lastAt']),
      );
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String senderId;
  final ChatMediaType type;
  final String content;
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
        'id': id,
        'threadId': threadId,
        'senderId': senderId,
        'type': type.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: _s(map['id']),
        threadId: _s(map['threadId']),
        senderId: _s(map['senderId']),
        type: ChatMediaType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => ChatMediaType.text,
        ),
        content: _s(map['content']),
        createdAt: _dt(map['createdAt']),
      );
}

class VaultFile {
  const VaultFile({
    required this.id,
    required this.userId,
    required this.name,
    required this.path,
    required this.mime,
    required this.uploadedAt,
    this.category = 'other',
    this.note = '',
    this.sizeBytes = 0,
    this.ownerName = '',
  });

  final String id;
  final String userId;
  final String name;
  final String path;
  final String mime;
  final DateTime uploadedAt;
  final String category;
  final String note;
  final int sizeBytes;
  final String ownerName;

  VaultFile copyWith({
    String? name,
    String? path,
    String? mime,
    String? category,
    String? note,
    int? sizeBytes,
    String? ownerName,
  }) =>
      VaultFile(
        id: id,
        userId: userId,
        name: name ?? this.name,
        path: path ?? this.path,
        mime: mime ?? this.mime,
        uploadedAt: uploadedAt,
        category: category ?? this.category,
        note: note ?? this.note,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        ownerName: ownerName ?? this.ownerName,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'name': name,
        'path': path,
        'mime': mime,
        'uploadedAt': uploadedAt.toIso8601String(),
        'category': category,
        'note': note,
        'sizeBytes': sizeBytes,
        'ownerName': ownerName,
      };

  factory VaultFile.fromMap(Map<String, dynamic> map) => VaultFile(
        id: _s(map['id']),
        userId: _s(map['userId']),
        name: _s(map['name']),
        path: _s(map['path']),
        mime: _s(map['mime']),
        uploadedAt: _dt(map['uploadedAt']),
        category: _s(map['category'], 'other'),
        note: _s(map['note']),
        sizeBytes: _i(map['sizeBytes']),
        ownerName: _s(map['ownerName']),
      );
}

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.amount,
    required this.status,
    required this.date,
    this.note,
    this.appointmentId,
  });

  final String id;
  final String clientId;
  final String clientName;
  final double amount;
  final PaymentStatus status;
  final DateTime date;
  final String? note;
  final String? appointmentId;

  Map<String, dynamic> toMap() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'amount': amount,
        'status': status.name,
        'date': date.toIso8601String(),
        'note': note,
        'appointmentId': appointmentId,
      };

  factory PaymentRecord.fromMap(Map<String, dynamic> map) => PaymentRecord(
        id: _s(map['id']),
        clientId: _s(map['clientId']),
        clientName: _s(map['clientName']),
        amount: _d(map['amount']),
        status: PaymentStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => PaymentStatus.due,
        ),
        date: _dt(map['date']),
        note: map['note'] as String?,
        appointmentId: map['appointmentId'] as String?,
      );
}

class ShoppingItem {
  const ShoppingItem({
    this.id = '',
    required this.name,
    required this.amount,
    required this.category,
    this.checked = false,
    this.tip = '',
    this.note = '',
    this.aisle = '',
    this.imageUrl,
    this.priority = false,
  });

  final String id;
  final String name;
  final String amount;
  final String category;
  final bool checked;
  final String tip;
  final String note;
  final String aisle;
  final String? imageUrl;
  final bool priority;

  String get key => id.isNotEmpty ? id : '$category|$name|$amount';

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? amount,
    String? category,
    bool? checked,
    String? tip,
    String? note,
    String? aisle,
    String? imageUrl,
    bool? priority,
  }) =>
      ShoppingItem(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        checked: checked ?? this.checked,
        tip: tip ?? this.tip,
        note: note ?? this.note,
        aisle: aisle ?? this.aisle,
        imageUrl: imageUrl ?? this.imageUrl,
        priority: priority ?? this.priority,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'amount': amount,
        'category': category,
        'checked': checked,
        'tip': tip,
        'note': note,
        'aisle': aisle,
        'imageUrl': imageUrl,
        'priority': priority,
      };

  factory ShoppingItem.fromMap(Map<String, dynamic> map) => ShoppingItem(
        id: _s(map['id']),
        name: _s(map['name']),
        amount: _s(map['amount']),
        category: _s(map['category'], 'other'),
        checked: _b(map['checked']),
        tip: _s(map['tip']),
        note: _s(map['note']),
        aisle: _s(map['aisle']),
        imageUrl: map['imageUrl'] as String?,
        priority: _b(map['priority']),
      );
}

class NotificationPrefs {
  const NotificationPrefs({
    this.waterIntervalHours = 2,
    this.breakfast = '08:00',
    this.lunch = '13:00',
    this.snack = '16:00',
    this.dinner = '19:30',
    this.appointmentReminders = true,
    this.blogNotifications = true,
    this.waterShortcut = false,
    this.smartReminders = true,
    this.feedbackAlerts = true,
    this.inactivityAlerts = true,
  });

  final int waterIntervalHours;
  final String breakfast;
  final String lunch;
  final String snack;
  final String dinner;
  final bool appointmentReminders;
  final bool blogNotifications;
  final bool waterShortcut;
  final bool smartReminders;
  final bool feedbackAlerts;
  final bool inactivityAlerts;

  NotificationPrefs copyWith({
    int? waterIntervalHours,
    String? breakfast,
    String? lunch,
    String? snack,
    String? dinner,
    bool? appointmentReminders,
    bool? blogNotifications,
    bool? waterShortcut,
    bool? smartReminders,
    bool? feedbackAlerts,
    bool? inactivityAlerts,
  }) {
    return NotificationPrefs(
      waterIntervalHours: waterIntervalHours ?? this.waterIntervalHours,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      snack: snack ?? this.snack,
      dinner: dinner ?? this.dinner,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      blogNotifications: blogNotifications ?? this.blogNotifications,
      waterShortcut: waterShortcut ?? this.waterShortcut,
      smartReminders: smartReminders ?? this.smartReminders,
      feedbackAlerts: feedbackAlerts ?? this.feedbackAlerts,
      inactivityAlerts: inactivityAlerts ?? this.inactivityAlerts,
    );
  }

  Map<String, dynamic> toMap() => {
        'waterIntervalHours': waterIntervalHours,
        'breakfast': breakfast,
        'lunch': lunch,
        'snack': snack,
        'dinner': dinner,
        'appointmentReminders': appointmentReminders,
        'blogNotifications': blogNotifications,
        'waterShortcut': waterShortcut,
        'smartReminders': smartReminders,
        'feedbackAlerts': feedbackAlerts,
        'inactivityAlerts': inactivityAlerts,
      };

  factory NotificationPrefs.fromMap(Map<String, dynamic> map) => NotificationPrefs(
        waterIntervalHours: _i(map['waterIntervalHours'], 2),
        breakfast: _s(map['breakfast'], '08:00'),
        lunch: _s(map['lunch'], '13:00'),
        snack: _s(map['snack'], '16:00'),
        dinner: _s(map['dinner'], '19:30'),
        appointmentReminders: _b(map['appointmentReminders'], true),
        blogNotifications: _b(map['blogNotifications'], true),
        waterShortcut: _b(map['waterShortcut']),
        smartReminders: _b(map['smartReminders'], true),
        feedbackAlerts: _b(map['feedbackAlerts'], true),
        inactivityAlerts: _b(map['inactivityAlerts'], true),
      );
}

class AppSettings {
  const AppSettings({
    this.themeMode = 'light',
    this.visualStyle = VisualStyle.modern,
    this.locale = 'tr',
    this.seeded = false,
    this.sessionUserId,
    this.clinicModules = const {},
    this.defaultWaterGoalMl = 2500,
  });

  final String themeMode;
  final VisualStyle visualStyle;
  final String locale;
  final bool seeded;
  final String? sessionUserId;
  final Map<String, bool> clinicModules;
  final int defaultWaterGoalMl;

  AppSettings copyWith({
    String? themeMode,
    VisualStyle? visualStyle,
    String? locale,
    bool? seeded,
    String? sessionUserId,
    bool clearSession = false,
    Map<String, bool>? clinicModules,
    int? defaultWaterGoalMl,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      visualStyle: visualStyle ?? this.visualStyle,
      locale: locale ?? this.locale,
      seeded: seeded ?? this.seeded,
      sessionUserId: clearSession ? null : (sessionUserId ?? this.sessionUserId),
      clinicModules: clinicModules ?? this.clinicModules,
      defaultWaterGoalMl: defaultWaterGoalMl ?? this.defaultWaterGoalMl,
    );
  }

  Map<String, dynamic> toMap() => {
        'themeMode': themeMode,
        'visualStyle': visualStyle.name,
        'locale': locale,
        'seeded': seeded,
        'sessionUserId': sessionUserId,
        'clinicModules': clinicModules,
        'defaultWaterGoalMl': defaultWaterGoalMl,
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        themeMode: _s(map['themeMode'], 'light'),
        visualStyle: VisualStyle.values.firstWhere(
          (e) => e.name == map['visualStyle'],
          orElse: () => VisualStyle.modern,
        ),
        locale: _s(map['locale'], 'tr'),
        seeded: _b(map['seeded']),
        sessionUserId: map['sessionUserId'] as String?,
        clinicModules: _boolMap(map['clinicModules']),
        defaultWaterGoalMl: _i(map['defaultWaterGoalMl'], 2500).clamp(1000, 5000),
      );
}

class StreakState {
  const StreakState({
    required this.userId,
    this.current = 0,
    this.best = 0,
    this.lastDay,
    this.freezeMonth,
    this.freezeUsed = false,
  });

  final String userId;
  final int current;
  final int best;
  final String? lastDay;
  final String? freezeMonth;
  final bool freezeUsed;

  StreakState copyWith({
    int? current,
    int? best,
    String? lastDay,
    String? freezeMonth,
    bool? freezeUsed,
  }) {
    return StreakState(
      userId: userId,
      current: current ?? this.current,
      best: best ?? this.best,
      lastDay: lastDay ?? this.lastDay,
      freezeMonth: freezeMonth ?? this.freezeMonth,
      freezeUsed: freezeUsed ?? this.freezeUsed,
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'current': current,
        'best': best,
        'lastDay': lastDay,
        'freezeMonth': freezeMonth,
        'freezeUsed': freezeUsed,
      };

  factory StreakState.fromMap(Map<String, dynamic> map) => StreakState(
        userId: _s(map['userId']),
        current: _i(map['current']),
        best: _i(map['best']),
        lastDay: map['lastDay'] as String?,
        freezeMonth: map['freezeMonth'] as String?,
        freezeUsed: _b(map['freezeUsed']),
      );
}

class WeeklyCheckIn {
  const WeeklyCheckIn({
    required this.id,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.weight,
    this.waist,
    this.mood = 3,
    this.energy = 3,
    this.adherence = 3,
    this.sleepHours,
    this.note = '',
    this.photoPath,
    this.tags = const [],
    this.dietitianNote,
    this.dietitianNoteAt,
  });

  final String id;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final double? weight;
  final double? waist;
  final int mood;
  final int energy;
  final int adherence;
  final double? sleepHours;
  final String note;
  final String? photoPath;
  final List<String> tags;
  final String? dietitianNote;
  final DateTime? dietitianNoteAt;

  WeeklyCheckIn copyWith({
    double? weight,
    double? waist,
    int? mood,
    int? energy,
    int? adherence,
    double? sleepHours,
    String? note,
    String? photoPath,
    List<String>? tags,
    String? dietitianNote,
    DateTime? dietitianNoteAt,
  }) =>
      WeeklyCheckIn(
        id: id,
        userId: userId,
        userName: userName,
        createdAt: createdAt,
        weight: weight ?? this.weight,
        waist: waist ?? this.waist,
        mood: mood ?? this.mood,
        energy: energy ?? this.energy,
        adherence: adherence ?? this.adherence,
        sleepHours: sleepHours ?? this.sleepHours,
        note: note ?? this.note,
        photoPath: photoPath ?? this.photoPath,
        tags: tags ?? this.tags,
        dietitianNote: dietitianNote ?? this.dietitianNote,
        dietitianNoteAt: dietitianNoteAt ?? this.dietitianNoteAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'createdAt': createdAt.toIso8601String(),
        'weight': weight,
        'waist': waist,
        'mood': mood,
        'energy': energy,
        'adherence': adherence,
        'sleepHours': sleepHours,
        'note': note,
        'photoPath': photoPath,
        'tags': tags,
        'dietitianNote': dietitianNote,
        'dietitianNoteAt': dietitianNoteAt?.toIso8601String(),
      };

  factory WeeklyCheckIn.fromMap(Map<String, dynamic> map) => WeeklyCheckIn(
        id: _s(map['id']),
        userId: _s(map['userId']),
        userName: _s(map['userName']),
        createdAt: _dt(map['createdAt']),
        weight: map['weight'] == null ? null : _d(map['weight']),
        waist: map['waist'] == null ? null : _d(map['waist']),
        mood: _i(map['mood'], 3),
        energy: _i(map['energy'], 3),
        adherence: _i(map['adherence'], 3),
        sleepHours: map['sleepHours'] == null ? null : _d(map['sleepHours']),
        note: _s(map['note']),
        photoPath: map['photoPath'] as String?,
        tags: (map['tags'] as List?)?.map((e) => '$e').toList() ?? const [],
        dietitianNote: map['dietitianNote'] as String?,
        dietitianNoteAt: map['dietitianNoteAt'] == null ? null : _dt(map['dietitianNoteAt']),
      );
}

class FastingSession {
  const FastingSession({
    required this.userId,
    this.startAt,
    this.windowHours = 16,
    this.active = false,
  });

  final String userId;
  final DateTime? startAt;
  final int windowHours;
  final bool active;

  Duration get elapsed => startAt == null ? Duration.zero : DateTime.now().difference(startAt!);
  double get progress {
    final total = windowHours * 3600;
    if (total <= 0) return 0;
    return (elapsed.inSeconds / total).clamp(0, 1);
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'startAt': startAt?.toIso8601String(),
        'windowHours': windowHours,
        'active': active,
      };

  factory FastingSession.fromMap(Map<String, dynamic> map) => FastingSession(
        userId: _s(map['userId']),
        startAt: map['startAt'] == null ? null : _dt(map['startAt']),
        windowHours: _i(map['windowHours'], 16),
        active: _b(map['active']),
      );
}

class UserProgress {
  const UserProgress({
    required this.userId,
    this.earnedBadgeIds = const [],
    this.completedLessonDays = const {},
    this.pendingCelebrations = const [],
    this.lastNotificationKeys = const {},
    this.pendingFeedbackNote,
  });

  final String userId;
  final List<String> earnedBadgeIds;
  final Map<String, List<int>> completedLessonDays;
  final List<String> pendingCelebrations;
  final Map<String, String> lastNotificationKeys;
  final String? pendingFeedbackNote;

  UserProgress copyWith({
    List<String>? earnedBadgeIds,
    Map<String, List<int>>? completedLessonDays,
    List<String>? pendingCelebrations,
    Map<String, String>? lastNotificationKeys,
    String? pendingFeedbackNote,
    bool clearFeedback = false,
  }) =>
      UserProgress(
        userId: userId,
        earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
        completedLessonDays: completedLessonDays ?? this.completedLessonDays,
        pendingCelebrations: pendingCelebrations ?? this.pendingCelebrations,
        lastNotificationKeys: lastNotificationKeys ?? this.lastNotificationKeys,
        pendingFeedbackNote: clearFeedback ? null : (pendingFeedbackNote ?? this.pendingFeedbackNote),
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'earnedBadgeIds': earnedBadgeIds,
        'completedLessonDays': completedLessonDays.map((k, v) => MapEntry(k, v)),
        'pendingCelebrations': pendingCelebrations,
        'lastNotificationKeys': lastNotificationKeys,
        'pendingFeedbackNote': pendingFeedbackNote,
      };

  factory UserProgress.fromMap(Map<String, dynamic> map) => UserProgress(
        userId: _s(map['userId']),
        earnedBadgeIds: (map['earnedBadgeIds'] as List?)?.map((e) => '$e').toList() ?? const [],
        completedLessonDays: (map['completedLessonDays'] as Map?)?.map(
              (k, v) => MapEntry('$k', (v as List?)?.map((e) => _i(e)).toList() ?? const []),
            ) ??
            const {},
        pendingCelebrations: (map['pendingCelebrations'] as List?)?.map((e) => '$e').toList() ?? const [],
        lastNotificationKeys: (map['lastNotificationKeys'] as Map?)?.map((k, v) => MapEntry('$k', '$v')) ?? const {},
        pendingFeedbackNote: map['pendingFeedbackNote'] as String?,
      );
}
