import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import 'app_store.dart';

Stream<T> _watch<T>(AppStore store, String collection, T Function() read) async* {
  yield read();
  await for (final _ in store.watch(collection)) {
    yield read();
  }
}

final usersProvider = StreamProvider<List<UserProfile>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.users, store.users);
});

final appointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.appointments, store.appointments);
});

final servicesProvider = StreamProvider<List<ServicePackage>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.services, store.services);
});

final dietPlansProvider = StreamProvider<List<DietPlan>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.dietPlans, store.dietPlans);
});

final blogProvider = StreamProvider<List<BlogPost>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.blogPosts, store.blogPosts);
});

final recipesProvider = StreamProvider<List<Recipe>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.recipes, store.recipes);
});

final paymentsProvider = StreamProvider<List<PaymentRecord>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.payments, store.payments);
});

final mealLogsProvider = StreamProvider<List<MealPhotoLog>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.mealLogs, store.mealLogs);
});

final waterLogsProvider = StreamProvider<List<WaterLog>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.waterLogs, () => store.waterLogs());
});

final chatsProvider = StreamProvider.family<List<ChatThread>, String>((ref, userId) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.chats, () => store.threadsFor(userId));
});

final messagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, threadId) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.messages, () => store.messages(threadId));
});

final measurementsProvider = StreamProvider<List<BodyMeasurement>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.measurements, store.allMeasurements);
});

final documentsProvider = StreamProvider<List<VaultFile>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.documents, store.allDocuments);
});

final shoppingListsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.shoppingLists, () => store.db.list(FirestorePaths.shoppingLists));
});

final prefsProvider = StreamProvider.family<NotificationPrefs, String>((ref, userId) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.prefs, () => store.prefs(userId));
});

final blogInteractionsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.blogInteractions, () => store.db.list(FirestorePaths.blogInteractions));
});

final availabilityProvider = StreamProvider<List<AvailabilityRule>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.availability, store.availability);
});

final serviceRequestsProvider = StreamProvider<List<ServiceRequest>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.serviceRequests, store.serviceRequests);
});

final streaksProvider = StreamProvider<List<StreakState>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.streaks, store.streaks);
});

final checkInsProvider = StreamProvider<List<WeeklyCheckIn>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.checkIns, store.checkIns);
});

final userProgressProvider = StreamProvider.family<UserProgress, String>((ref, userId) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.userProgress, () => store.userProgress(userId));
});

final fastingProvider = StreamProvider<List<FastingSession>>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, FirestorePaths.fasting, store.fastingSessions);
});

final settingsProvider = StreamProvider<AppSettings>((ref) {
  final store = ref.watch(appStoreProvider);
  return _watch(store, 'settings', store.settings);
});
