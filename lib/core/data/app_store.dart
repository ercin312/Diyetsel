import 'package:collection/collection.dart';
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../models/enums.dart';
import '../models/home_theme_config.dart';
import '../models/models.dart';
import '../network/local_database.dart';
import 'seed_data.dart';

const _uuid = Uuid();

String newId() => _uuid.v4();

String hashPassword(String password) => sha256.convert(utf8.encode('diyetsel::$password')).toString();

String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

class AppStore {
  AppStore(this.db);

  final LocalDatabase db;

  Stream<String> watch(String collection) => db.watch(collection);

  List<T> _map<T>(String collection, T Function(Map<String, dynamic>) parse) =>
      db.list(collection).map(parse).toList();

  AppSettings settings() {
    final raw = db.get('settings', 'app');
    return raw == null ? const AppSettings() : AppSettings.fromMap(raw);
  }

  Future<void> saveSettings(AppSettings value) =>
      db.put('settings', 'app', value.toMap(), syncCloud: false);

  HomeThemeConfig homeThemeConfig() {
    final raw = db.get('home_theme', 'cartoon');
    if (raw == null) return HomeThemeConfig.defaults();
    return HomeThemeConfig.fromMap(raw);
  }

  Future<void> saveHomeThemeConfig(HomeThemeConfig value) =>
      db.put('home_theme', 'cartoon', value.toMap());

  Future<void> resetHomeThemeConfig() => saveHomeThemeConfig(HomeThemeConfig.defaults());

  bool moduleOn(String userId, String module) {
    if (settings().clinicModules[module] == false) return false;
    final profile = user(userId);
    if (profile?.moduleOverrides[module] == false) return false;
    return true;
  }

  Future<void> setClinicModule(String module, bool enabled) async {
    final next = Map<String, bool>.from(settings().clinicModules)..[module] = enabled;
    await saveSettings(settings().copyWith(clinicModules: next));
  }

  Future<void> setUserModule(String userId, String module, bool enabled) async {
    final profile = user(userId);
    if (profile == null) return;
    final next = Map<String, bool>.from(profile.moduleOverrides)..[module] = enabled;
    await saveUser(profile.copyWith(moduleOverrides: next));
  }

  Future<void> setWaterGoal(String userId, int ml) async {
    final profile = user(userId);
    if (profile == null) return;
    final goal = ml.clamp(1000, 5000);
    await saveUser(profile.copyWith(waterGoalMl: goal));
    final log = waterLog(userId, DateTime.now());
    await saveWater(
      WaterLog(userId: userId, day: log.day, amountMl: log.amountMl, goalMl: goal),
    );
  }

  Future<void> setClinicWaterGoal(int ml, {bool applyToAllClients = false}) async {
    final goal = ml.clamp(1000, 5000);
    await saveSettings(settings().copyWith(defaultWaterGoalMl: goal));
    if (!applyToAllClients) return;
    for (final profile in users().where((u) => !u.isAdmin)) {
      await setWaterGoal(profile.id, goal);
    }
  }

  List<UserProfile> users() => _map(FirestorePaths.users, UserProfile.fromMap);

  UserProfile? user(String id) {
    final raw = db.get(FirestorePaths.users, id);
    return raw == null ? null : UserProfile.fromMap(raw);
  }

  UserProfile? userByEmail(String email) {
    final lower = email.toLowerCase();
    for (final u in users()) {
      if (u.email.toLowerCase() == lower) return u;
    }
    return null;
  }

  bool get hasAdmin => users().any((u) => u.role == UserRole.admin);

  Future<void> saveUser(UserProfile user) => db.put(FirestorePaths.users, user.id, user.toMap());

  Future<void> saveCredential(String email, String passwordHash) =>
      db.put(FirestorePaths.credentials, email.toLowerCase(), {'email': email.toLowerCase(), 'hash': passwordHash});

  bool verifyPassword(String email, String password) {
    final raw = db.get(FirestorePaths.credentials, email.toLowerCase());
    if (raw == null) return false;
    return raw['hash'] == hashPassword(password);
  }

  List<Appointment> appointments() {
    final items = _map(FirestorePaths.appointments, Appointment.fromMap);
    items.sort((a, b) => a.startAt.compareTo(b.startAt));
    return items;
  }

  Future<void> saveAppointment(Appointment item) =>
      db.put(FirestorePaths.appointments, item.id, item.toMap());

  List<AvailabilityRule> availability() =>
      _map(FirestorePaths.availability, AvailabilityRule.fromMap);

  Future<void> saveAvailability(AvailabilityRule item) =>
      db.put(FirestorePaths.availability, item.id, item.toMap());

  List<ServicePackage> services() => _map(FirestorePaths.services, ServicePackage.fromMap);

  Future<void> saveService(ServicePackage item) =>
      db.put(FirestorePaths.services, item.id, item.toMap());

  Future<void> deleteService(String id) => db.delete(FirestorePaths.services, id);

  List<ServiceRequest> serviceRequests() =>
      _map(FirestorePaths.serviceRequests, ServiceRequest.fromMap);

  Future<void> saveServiceRequest(ServiceRequest item) =>
      db.put(FirestorePaths.serviceRequests, item.id, item.toMap());

  List<DietPlan> dietPlans() => _map(FirestorePaths.dietPlans, DietPlan.fromMap);

  DietPlan? dietPlanForClient(String clientId) {
    final plans = dietPlans().where((p) => p.clientId == clientId).toList()
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    return plans.isEmpty ? null : plans.first;
  }

  Future<void> saveDietPlan(DietPlan item) =>
      db.put(FirestorePaths.dietPlans, item.id, item.toMap());

  WaterLog waterLog(String userId, DateTime date) {
    final key = '$userId-${dayKey(date)}';
    final raw = db.get(FirestorePaths.waterLogs, key);
    if (raw == null) {
      final user = this.user(userId);
      return WaterLog(
        userId: userId,
        day: dayKey(date),
        amountMl: 0,
        goalMl: user?.waterGoalMl ?? AppConstants.defaultWaterGoalMl,
      );
    }
    return WaterLog.fromMap(raw);
  }

  List<WaterLog> waterLogs() => _map(FirestorePaths.waterLogs, WaterLog.fromMap);

  Future<void> saveWater(WaterLog log) =>
      db.put(FirestorePaths.waterLogs, '${log.userId}-${log.day}', log.toMap());

  Future<void> addWaterSip(String userId, {int ml = AppConstants.waterSipMl}) async {
    final log = waterLog(userId, DateTime.now());
    await saveWater(
      WaterLog(
        userId: userId,
        day: log.day,
        amountMl: log.amountMl + ml,
        goalMl: log.goalMl,
      ),
    );
    await touchActivity(userId);
  }

  List<BodyMeasurement> allMeasurements() =>
      _map(FirestorePaths.measurements, BodyMeasurement.fromMap);

  List<BodyMeasurement> measurements(String userId) {
    final items = allMeasurements().where((e) => e.userId == userId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Future<void> saveMeasurement(BodyMeasurement item) =>
      db.put(FirestorePaths.measurements, item.id, item.toMap());

  List<MealPhotoLog> mealLogs({String? clientId}) {
    final items = _map(FirestorePaths.mealLogs, MealPhotoLog.fromMap)
        .where((e) => clientId == null || e.clientId == clientId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveMealLog(MealPhotoLog item, {bool countActivity = true}) async {
    await db.put(FirestorePaths.mealLogs, item.id, item.toMap());
    if (countActivity) await touchActivity(item.clientId);
  }

  List<BlogPost> blogPosts({bool publishedOnly = false}) {
    final items = _map(FirestorePaths.blogPosts, BlogPost.fromMap)
        .where((e) => !publishedOnly || e.published)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveBlog(BlogPost item) => db.put(FirestorePaths.blogPosts, item.id, item.toMap());

  bool isLiked(String userId, String postId) =>
      db.get(FirestorePaths.blogInteractions, '${userId}_$postId')?['liked'] == true;

  bool isBookmarked(String userId, String postId) =>
      db.get(FirestorePaths.blogInteractions, '${userId}_$postId')?['bookmarked'] == true;

  Future<void> toggleLike(String userId, BlogPost post) async {
    final key = '${userId}_${post.id}';
    final raw = db.get(FirestorePaths.blogInteractions, key) ?? {};
    final liked = raw['liked'] == true;
    await db.put(FirestorePaths.blogInteractions, key, {
      'id': key,
      'liked': !liked,
      'bookmarked': raw['bookmarked'] == true,
    });
    await saveBlog(BlogPost(
      id: post.id,
      title: post.title,
      subtitle: post.subtitle,
      authorId: post.authorId,
      authorName: post.authorName,
      category: post.category,
      tags: post.tags,
      body: post.body,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
      coverUrl: post.coverUrl,
      published: post.published,
      likes: (post.likes + (liked ? -1 : 1)).clamp(0, 99999),
    ));
  }

  Future<void> toggleBookmark(String userId, String postId) async {
    final key = '${userId}_$postId';
    final raw = db.get(FirestorePaths.blogInteractions, key) ?? {};
    await db.put(FirestorePaths.blogInteractions, key, {
      'id': key,
      'liked': raw['liked'] == true,
      'bookmarked': raw['bookmarked'] != true,
    });
  }

  List<Recipe> recipes() => _map(FirestorePaths.recipes, Recipe.fromMap);

  Future<void> saveRecipe(Recipe item) => db.put(FirestorePaths.recipes, item.id, item.toMap());

  Future<void> deleteRecipe(String id) => db.delete(FirestorePaths.recipes, id);

  bool isRecipeLiked(String userId, String recipeId) =>
      db.get(FirestorePaths.recipeInteractions, '${userId}_$recipeId')?['liked'] == true;

  bool isRecipeSaved(String userId, String recipeId) =>
      db.get(FirestorePaths.recipeInteractions, '${userId}_$recipeId')?['saved'] == true;

  List<Recipe> likedRecipes(String userId) {
    final ids = {
      for (final raw in db.list(FirestorePaths.recipeInteractions))
        if (raw['id'] is String &&
            '${raw['id']}'.startsWith('${userId}_') &&
            raw['liked'] == true)
          '${raw['id']}'.substring(userId.length + 1),
    };
    return recipes().where((r) => ids.contains(r.id)).toList();
  }

  List<Recipe> savedRecipes(String userId) {
    final ids = {
      for (final raw in db.list(FirestorePaths.recipeInteractions))
        if (raw['id'] is String &&
            '${raw['id']}'.startsWith('${userId}_') &&
            raw['saved'] == true)
          '${raw['id']}'.substring(userId.length + 1),
    };
    return recipes().where((r) => ids.contains(r.id)).toList();
  }

  Future<void> toggleRecipeLike(String userId, Recipe recipe) async {
    final key = '${userId}_${recipe.id}';
    final raw = db.get(FirestorePaths.recipeInteractions, key) ?? {};
    final liked = raw['liked'] == true;
    await db.put(FirestorePaths.recipeInteractions, key, {
      'id': key,
      'userId': userId,
      'recipeId': recipe.id,
      'liked': !liked,
      'saved': raw['saved'] == true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    await saveRecipe(recipe.copyWith(
      likes: (recipe.likes + (liked ? -1 : 1)).clamp(0, 99999),
    ));
  }

  Future<void> toggleRecipeSave(String userId, String recipeId) async {
    final key = '${userId}_$recipeId';
    final raw = db.get(FirestorePaths.recipeInteractions, key) ?? {};
    await db.put(FirestorePaths.recipeInteractions, key, {
      'id': key,
      'userId': userId,
      'recipeId': recipeId,
      'liked': raw['liked'] == true,
      'saved': raw['saved'] != true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  List<ChatThread> threadsFor(String userId) {
    final items = _map(FirestorePaths.chats, ChatThread.fromMap)
        .where((e) => e.participantIds.contains(userId))
        .toList()
      ..sort((a, b) => b.lastAt.compareTo(a.lastAt));
    return items;
  }

  List<ChatMessage> messages(String threadId) {
    final items = _map(FirestorePaths.messages, ChatMessage.fromMap)
        .where((e) => e.threadId == threadId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return items;
  }

  Future<ChatThread> ensureThread(UserProfile a, UserProfile b) async {
    for (final t in _map(FirestorePaths.chats, ChatThread.fromMap)) {
      if (t.participantIds.contains(a.id) && t.participantIds.contains(b.id)) {
        return t;
      }
    }
    final thread = ChatThread(
      id: newId(),
      participantIds: [a.id, b.id],
      participantNames: [a.displayName, b.displayName],
      lastMessage: '',
      lastAt: DateTime.now(),
    );
    await db.put(FirestorePaths.chats, thread.id, thread.toMap());
    return thread;
  }

  Future<void> sendMessage(ChatMessage message, ChatThread thread) async {
    await db.put(FirestorePaths.messages, message.id, message.toMap());
    await db.put(
      FirestorePaths.chats,
      thread.id,
      ChatThread(
        id: thread.id,
        participantIds: thread.participantIds,
        participantNames: thread.participantNames,
        lastMessage: message.type == ChatMediaType.text ? message.content : message.type.name,
        lastAt: message.createdAt,
      ).toMap(),
    );
  }

  List<VaultFile> allDocuments() => _map(FirestorePaths.documents, VaultFile.fromMap);

  List<VaultFile> documents(String userId) {
    final items = allDocuments().where((e) => e.userId == userId).toList()
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    return items;
  }

  Future<void> saveDocument(VaultFile item) =>
      db.put(FirestorePaths.documents, item.id, item.toMap());

  Future<void> deleteDocument(String id) => db.delete(FirestorePaths.documents, id);

  List<PaymentRecord> payments() => _map(FirestorePaths.payments, PaymentRecord.fromMap);

  Future<void> savePayment(PaymentRecord item) =>
      db.put(FirestorePaths.payments, item.id, item.toMap());

  List<ShoppingItem> shoppingList(String userId) {
    final raw = db.get(FirestorePaths.shoppingLists, userId);
    if (raw == null) return const [];
    return (raw['items'] as List? ?? [])
        .whereType<Map>()
        .map((e) => ShoppingItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  String? preferredShoppingPlatform(String userId) {
    final raw = db.get(FirestorePaths.shoppingLists, userId);
    final v = raw?['preferredPlatform'];
    return v is String && v.isNotEmpty ? v : null;
  }

  Future<void> saveShoppingList(
    String userId,
    List<ShoppingItem> items, {
    String? preferredPlatform,
  }) {
    final raw = db.get(FirestorePaths.shoppingLists, userId);
    final platform = preferredPlatform ??
        (raw?['preferredPlatform'] is String
            ? raw!['preferredPlatform'] as String
            : null);
    return db.put(
      FirestorePaths.shoppingLists,
      userId,
      {
        'id': userId,
        'items': items.map((e) => e.toMap()).toList(),
        if (platform != null && platform.isNotEmpty)
          'preferredPlatform': platform,
      },
    );
  }

  Future<void> savePreferredShoppingPlatform(
    String userId,
    String platformId,
  ) {
    final items = shoppingList(userId);
    return saveShoppingList(userId, items, preferredPlatform: platformId);
  }

  NotificationPrefs prefs(String userId) {
    final raw = db.get(FirestorePaths.prefs, userId);
    return raw == null ? const NotificationPrefs() : NotificationPrefs.fromMap(raw);
  }

  Future<void> savePrefs(String userId, NotificationPrefs value) =>
      db.put(FirestorePaths.prefs, userId, {'id': userId, ...value.toMap()});

  List<DateTime> openSlots({
    required String dietitianId,
    required DateTime day,
  }) {
    final weekday = day.weekday;
    final rules = availability().where((r) => r.dietitianId == dietitianId && r.weekday == weekday);
    final taken = appointments()
        .where((a) =>
            a.dietitianId == dietitianId &&
            a.status != AppointmentStatus.rejected &&
            a.startAt.year == day.year &&
            a.startAt.month == day.month &&
            a.startAt.day == day.day)
        .map((a) => a.startAt)
        .toSet();
    final slots = <DateTime>[];
    for (final rule in rules) {
      final startParts = rule.start.split(':');
      final endParts = rule.end.split(':');
      var cursor = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(startParts[0]),
        int.parse(startParts[1]),
      );
      final end = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(endParts[0]),
        int.parse(endParts[1]),
      );
      while (cursor.add(Duration(minutes: rule.slotMinutes)).isBefore(end) ||
          cursor.add(Duration(minutes: rule.slotMinutes)).isAtSameMomentAs(end)) {
        if (!taken.any((t) => t.isAtSameMomentAs(cursor))) {
          slots.add(cursor);
        }
        cursor = cursor.add(Duration(minutes: rule.slotMinutes));
      }
    }
    return slots;
  }

  Future<void> toggleMealConsumed(DietPlan plan, int dayIndex, String mealId) async {
    final days = [...plan.days];
    final meals = [
      for (final meal in days[dayIndex].meals)
        if (meal.id == mealId) meal.copyWith(consumed: !meal.consumed) else meal,
    ];
    days[dayIndex] = DietDay(date: days[dayIndex].date, meals: meals);
    await saveDietPlan(plan.copyWith(days: days));
    await touchActivity(plan.clientId);
  }

  /// Apply the same reminder clock to every meal of [type] across the week.
  Future<void> updateMealReminder(String planId, MealType type, String timeHhMm) async {
    final plan = dietPlans().where((p) => p.id == planId).firstOrNull;
    if (plan == null) return;
    final days = [
      for (final day in plan.days)
        DietDay(
          date: day.date,
          meals: [
            for (final meal in day.meals)
              if (meal.type == type) meal.copyWith(reminderTime: timeHhMm) else meal,
          ],
        ),
    ];
    await saveDietPlan(plan.copyWith(days: days));
  }

  /// Replace or create a weekly plan from a parsed meal template for [client].
  Future<DietPlan> assignDietFromMeals({
    required UserProfile client,
    required String dietitianId,
    required String title,
    required List<DietMeal> templateMeals,
  }) async {
    var monday = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    monday = DateTime(monday.year, monday.month, monday.day);
    final existing = dietPlanForClient(client.id);
    final id = existing?.id ?? newId();
    final plan = DietPlan(
      id: id,
      clientId: client.id,
      clientName: client.displayName,
      dietitianId: dietitianId,
      title: title,
      weekStart: monday,
      days: [
        for (var i = 0; i < 7; i++)
          DietDay(
            date: monday.add(Duration(days: i)),
            meals: [
              for (final m in templateMeals)
                DietMeal(
                  id: newId(),
                  type: m.type,
                  name: m.name,
                  description: m.description,
                  calories: m.calories,
                  protein: m.protein,
                  carbs: m.carbs,
                  fat: m.fat,
                  ingredients: m.ingredients,
                  reminderTime: m.reminderTime ?? m.type.defaultReminderTime,
                ),
            ],
          ),
      ],
    );
    await saveDietPlan(plan);
    return plan;
  }

  Future<UserProfile> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    if (userByEmail(email) != null) {
      throw StateError('Bu e-posta zaten kayıtlı');
    }
    if (role == UserRole.admin && hasAdmin) {
      throw StateError('Diyetisyen hesabı zaten mevcut');
    }
    String id = newId();
    if (Firebase.apps.isNotEmpty) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        id = cred.user?.uid ?? id;
      } catch (_) {}
    }
    final profile = UserProfile(
      id: id,
      email: email,
      displayName: displayName,
      role: role,
      createdAt: DateTime.now(),
      waterGoalMl: role == UserRole.client ? settings().defaultWaterGoalMl : 2500,
    );
    await saveUser(profile);
    await saveCredential(email, hashPassword(password));
    await _mirrorAuthIdentity(profile);
    return profile;
  }

  Future<UserProfile> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final local = userByEmail(normalized);
    final localOk = local != null && verifyPassword(normalized, password);

    if (Firebase.apps.isNotEmpty) {
      final firebaseUser =
          await _ensureFirebaseSession(normalized, password, localOk: localOk);
      if (firebaseUser != null) {
        final profile = user(firebaseUser.uid) ?? userByEmail(normalized) ?? local;
        if (profile != null) {
          await _mirrorAuthIdentity(profile);
          return profile;
        }
      }
    }

    if (local == null || !localOk) {
      throw StateError('E-posta veya şifre hatalı');
    }
    await _mirrorAuthIdentity(local);
    return local;
  }

  /// Sign in (or create) Firebase Auth so Firestore rules see request.auth.
  Future<User?> _ensureFirebaseSession(
    String email,
    String password, {
    required bool localOk,
  }) async {
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      final missing = e.code == 'user-not-found' ||
          e.code == 'invalid-credential' ||
          e.code == 'INVALID_LOGIN_CREDENTIALS';
      if (!localOk || !missing) return FirebaseAuth.instance.currentUser;

      try {
        final created = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        return created.user;
      } on FirebaseAuthException catch (createErr) {
        if (createErr.code == 'email-already-in-use') {
          // Cloud password differs from local demo hash — stay local-only.
          return null;
        }
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Write users/{authUid} so security rules can resolve role for the signed-in user.
  Future<void> _mirrorAuthIdentity(UserProfile profile) async {
    if (Firebase.apps.isEmpty) return;
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;
    final mirror = {
      ...profile.toMap(),
      'id': authUser.uid,
      'email': profile.email.toLowerCase(),
      'legacyId': profile.id,
      'role': profile.role.name,
    };
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(authUser.uid)
          .set(mirror, SetOptions(merge: true));
    } catch (_) {}
    // Keep the legacy/demo profile doc too so existing FKs (admin-demo, client-demo) stay valid.
    if (profile.id != authUser.uid) {
      await saveUser(profile);
    }
  }

  Future<void> logout() async {
    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
  }

  Future<void> seedIfNeeded() async {
    if (settings().seeded) return;
    await SeedData.seed(this);
    await saveSettings(settings().copyWith(seeded: true));
  }

  Future<void> touchActivity(String userId) async {
    final profile = user(userId);
    if (profile == null || profile.isAdmin) return;
    await saveUser(profile.copyWith(lastActiveAt: DateTime.now()));
    await tickStreak(userId);
  }

  StreakState streak(String userId) {
    final raw = db.get(FirestorePaths.streaks, userId);
    return raw == null ? StreakState(userId: userId) : StreakState.fromMap(raw);
  }

  List<StreakState> streaks() => _map(FirestorePaths.streaks, StreakState.fromMap);

  Future<void> saveStreak(StreakState value) =>
      db.put(FirestorePaths.streaks, value.userId, value.toMap());

  Future<void> tickStreak(String userId) async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final todayKey = dayKey(today);
    final yesterday = today.subtract(const Duration(days: 1));
    final month = DateFormat('yyyy-MM').format(today);
    var state = streak(userId);
    if (state.freezeMonth != month) {
      state = state.copyWith(freezeMonth: month, freezeUsed: false);
    }
    if (state.lastDay == todayKey) {
      await saveStreak(state);
      return;
    }

    DateTime? last;
    if (state.lastDay != null) {
      last = DateTime.tryParse(state.lastDay!);
      if (last != null) last = DateTime(last.year, last.month, last.day);
    }

    var current = 1;
    var freezeUsed = state.freezeUsed;
    if (last == yesterday) {
      current = state.current + 1;
    } else if (last == yesterday.subtract(const Duration(days: 1)) && !state.freezeUsed) {
      current = state.current + 1;
      freezeUsed = true;
    } else if (last == null) {
      current = 1;
    } else {
      current = 1;
    }

    final best = current > state.best ? current : state.best;
    await saveStreak(
      state.copyWith(
        current: current,
        best: best,
        lastDay: todayKey,
        freezeMonth: month,
        freezeUsed: freezeUsed,
      ),
    );
  }

  List<WeeklyCheckIn> checkIns({String? userId}) {
    final items = _map(FirestorePaths.checkIns, WeeklyCheckIn.fromMap)
        .where((e) => userId == null || e.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveCheckIn(WeeklyCheckIn item) async {
    await db.put(FirestorePaths.checkIns, item.id, item.toMap());
    if (item.weight != null || item.waist != null) {
      await saveMeasurement(
        BodyMeasurement(
          id: item.id,
          userId: item.userId,
          date: item.createdAt,
          weight: item.weight,
          waist: item.waist,
        ),
      );
    }
    await touchActivity(item.userId);
  }

  FastingSession fasting(String userId) {
    final raw = db.get(FirestorePaths.fasting, userId);
    return raw == null ? FastingSession(userId: userId) : FastingSession.fromMap(raw);
  }

  List<FastingSession> fastingSessions() => _map(FirestorePaths.fasting, FastingSession.fromMap);

  Future<void> startFasting(String userId, {int windowHours = 16}) => db.put(
        FirestorePaths.fasting,
        userId,
        FastingSession(userId: userId, startAt: DateTime.now(), windowHours: windowHours, active: true).toMap(),
      );

  Future<void> stopFasting(String userId) async {
    final current = fasting(userId);
    await db.put(
      FirestorePaths.fasting,
      userId,
      FastingSession(userId: userId, windowHours: current.windowHours).toMap(),
    );
  }

  List<DietMeal> mealsToday(String clientId) {
    final plan = dietPlanForClient(clientId);
    if (plan == null) return const [];
    final today = DateTime.now();
    for (final day in plan.days) {
      if (day.date.year == today.year && day.date.month == today.month && day.date.day == today.day) {
        return day.meals;
      }
    }
    return const [];
  }

  int remainingKcal(String clientId) {
    final plan = dietPlanForClient(clientId);
    final eaten = mealsToday(clientId).where((m) => m.consumed).fold<int>(0, (s, m) => s + m.calories);
    return ((plan?.calorieTarget ?? 1800) - eaten).clamp(0, 99999);
  }

  List<UserProfile> silentClients({int days = 3}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return users()
        .where((u) => !u.isAdmin && (u.lastActiveAt == null || u.lastActiveAt!.isBefore(cutoff)))
        .toList();
  }

  UserProgress userProgress(String userId) {
    final raw = db.get(FirestorePaths.userProgress, userId);
    return raw == null ? UserProgress(userId: userId) : UserProgress.fromMap(raw);
  }

  Future<void> saveUserProgress(UserProgress value) =>
      db.put(FirestorePaths.userProgress, value.userId, value.toMap());

  Future<void> queueFeedbackNotification(String clientId, String message) async {
    final progress = userProgress(clientId);
    await saveUserProgress(progress.copyWith(pendingFeedbackNote: message));
  }

  List<AdminBroadcast> adminBroadcasts() {
    final items = _map(FirestorePaths.adminBroadcasts, AdminBroadcast.fromMap)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> saveAdminBroadcast(AdminBroadcast item) =>
      db.put(FirestorePaths.adminBroadcasts, item.id, item.toMap());

  /// Queues a custom admin notification for target clients and stores history.
  Future<AdminBroadcast> sendAdminBroadcast({
    required String adminId,
    required String title,
    required String body,
    String route = '',
    bool targetAll = true,
    List<String> targetUserIds = const [],
  }) async {
    final clients = users().where((u) => !u.isAdmin).toList();
    final targets = targetAll
        ? clients
        : clients.where((u) => targetUserIds.contains(u.id)).toList();

    for (final client in targets) {
      final progress = userProgress(client.id);
      await saveUserProgress(
        progress.copyWith(
          pendingAdminTitle: title.trim(),
          pendingAdminBody: body.trim(),
          pendingAdminRoute: route.trim(),
        ),
      );
    }

    final broadcast = AdminBroadcast(
      id: 'bcast_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
      createdBy: adminId,
      targetAll: targetAll,
      targetUserIds: targets.map((e) => e.id).toList(),
      targetLabels: targets.map((e) => e.displayName).toList(),
      route: route.trim(),
      recipientCount: targets.length,
    );
    await saveAdminBroadcast(broadcast);
    return broadcast;
  }
}

final appStoreProvider = Provider<AppStore>((ref) {
  return AppStore(ref.watch(localDatabaseProvider));
});

class StoreListenable extends Stream<void> {
  StoreListenable(this.store, this.collection);
  final AppStore store;
  final String collection;

  @override
  StreamSubscription<void> listen(
    void Function(void event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return store.watch(collection).listen(
          (_) => onData?.call(null),
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError,
        );
  }
}
