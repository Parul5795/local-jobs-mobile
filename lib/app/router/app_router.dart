import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/jobs/screens/home_screen.dart';
import '../../features/jobs/screens/job_details_screen.dart';
import '../../features/jobs/screens/job_list_screen.dart';
import '../../features/applications/screens/my_applications_screen.dart';
import '../../features/applications/screens/application_details_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import 'route_names.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) {
      final isSplash = state.matchedLocation == RoutePaths.splash;
      final isLoggingIn =
          state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register ||
          state.matchedLocation == RoutePaths.forgotPassword;

      if (authState is AuthInitial || authState is AuthLoading && isSplash) {
        return null; // Stay on splash while loading initially
      }

      if (authState is Unauthenticated || authState is AuthError) {
        return isLoggingIn ? null : RoutePaths.login;
      }

      if (authState is Authenticated) {
        return isLoggingIn || isSplash ? RoutePaths.home : null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.jobs,
        name: RouteNames.jobs,
        builder: (context, state) => const JobListScreen(),
      ),
      GoRoute(
        path: RoutePaths.jobDetails,
        name: RouteNames.jobDetails,
        builder: (context, state) {
          final jobId = state.pathParameters['id'] ?? '';
          return JobDetailsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: RoutePaths.myApplications,
        name: RouteNames.myApplications,
        builder: (context, state) => const MyApplicationsScreen(),
      ),
      GoRoute(
        path: RoutePaths.applicationDetails,
        name: RouteNames.applicationDetails,
        builder: (context, state) {
          final applicationId = state.pathParameters['id'] ?? '';
          return ApplicationDetailsScreen(applicationId: applicationId);
        },
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
