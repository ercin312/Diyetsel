import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/enums.dart';
import '../../core/widgets/adaptive_scaffold.dart';
import '../../features/appointment/presentation/appointment_screens.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/blog/presentation/blog_screens.dart';
import '../../features/story/presentation/story_screens.dart';
import '../../features/check_in/presentation/check_in_screens.dart';
import '../../features/chat/presentation/chat_screens.dart';
import '../../features/more/presentation/more_screens.dart';
import '../../features/dashboard/presentation/admin_notifications_screen.dart';
import '../../features/dashboard/presentation/dashboard_screens.dart';
import '../../features/dashboard/presentation/home_theme_editor_screen.dart';
import '../../features/dashboard/presentation/settings_screen.dart';
import '../../features/diet_plan/presentation/diet_screens.dart';
import '../../features/recipes/presentation/recipe_screens.dart';
import '../../features/services/presentation/service_screens.dart';
import '../../features/shopping/presentation/shopping_screens.dart';
import '../../features/documents/presentation/documents_screens.dart';
import '../../features/engage/presentation/engage_screens.dart';
import '../../features/gamification/presentation/gamification_screens.dart';
import '../../features/learn/presentation/learn_screens.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/tracker/presentation/tracker_screens.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = AuthRefresh(ref);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';
      if (!auth.isLoggedIn && !loggingIn) return '/login';
      if (auth.isLoggedIn && loggingIn) {
        return auth.isAdmin ? '/admin' : '/app';
      }
      if (auth.isLoggedIn && auth.isAdmin && loc.startsWith('/app')) return '/admin';
      if (auth.isLoggedIn && !auth.isAdmin && loc.startsWith('/admin')) return '/app';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      StatefulShellRoute.indexedStack(
        builder: (c, s, shell) => AdaptiveScaffold(navigationShell: shell, role: UserRole.admin),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/appointments', builder: (c, s) => const AppointmentCalendarScreen(admin: true))]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/clients', builder: (c, s) => const ClientsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/chat', builder: (c, s) => const ChatListScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/admin/more', builder: (c, s) => const MoreScreen(admin: true))]),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (c, s, shell) => AdaptiveScaffold(navigationShell: shell, role: UserRole.client),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/app', builder: (c, s) => const ClientHomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/diet', builder: (c, s) => const DietPlanScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/track', builder: (c, s) => const TrackerHubScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/appointments', builder: (c, s) => const AppointmentCalendarScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/app/more', builder: (c, s) => const MoreScreen(admin: false))]),
        ],
      ),
      GoRoute(path: '/admin/blog', builder: (c, s) => const BlogListScreen(admin: true)),
      GoRoute(path: '/admin/services', builder: (c, s) => const ServicesScreen(admin: true)),
      GoRoute(path: '/admin/recipes', builder: (c, s) => const RecipesScreen(admin: true)),
      GoRoute(path: '/admin/diet-plans', builder: (c, s) => const DietPlanScreen(admin: true)),
      GoRoute(path: '/admin/meals', builder: (c, s) => const MealPhotoScreen(admin: true)),
      GoRoute(path: '/admin/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/admin/home-theme', builder: (c, s) => const HomeThemeEditorScreen()),
      GoRoute(path: '/admin/notifications', builder: (c, s) => const AdminNotificationsScreen()),
      GoRoute(path: '/app/blog', builder: (c, s) => const BlogListScreen()),
      GoRoute(path: '/app/services', builder: (c, s) => const ServicesScreen()),
      GoRoute(path: '/app/chat', builder: (c, s) => const ChatListScreen()),
      GoRoute(path: '/app/recipes', builder: (c, s) => const RecipesScreen()),
      GoRoute(path: '/app/shopping', builder: (c, s) => const ShoppingScreen()),
      GoRoute(path: '/app/documents', builder: (c, s) => const DocumentsScreen()),
      GoRoute(path: '/app/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/app/barcode', builder: (c, s) => const BarcodeScreen()),
      GoRoute(path: '/app/check-in', builder: (c, s) => const CheckInScreen()),
      GoRoute(path: '/app/eat-out', builder: (c, s) => const EatOutScreen()),
      GoRoute(path: '/app/story', builder: (c, s) => const StoryCardScreen()),
      GoRoute(path: '/app/fasting', builder: (c, s) => const FastingScreen()),
      GoRoute(path: '/app/water-shortcut', builder: (c, s) => const WaterShortcutScreen()),
      GoRoute(path: '/app/reports', builder: (c, s) => const ReportsScreen()),
      GoRoute(path: '/app/badges', builder: (c, s) => const BadgesScreen()),
      GoRoute(path: '/app/learn', builder: (c, s) => const LearnHubScreen()),
      GoRoute(
        path: '/app/learn/:seriesId',
        builder: (c, s) => LessonSeriesScreen(seriesId: s.pathParameters['seriesId']!),
      ),
      GoRoute(
        path: '/app/learn/:seriesId/:day',
        builder: (c, s) => LessonDayScreen(
          seriesId: s.pathParameters['seriesId']!,
          day: int.parse(s.pathParameters['day']!),
        ),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (c, s) => ReportsScreen(clientId: s.uri.queryParameters['clientId']),
      ),
    ],
  );
});
