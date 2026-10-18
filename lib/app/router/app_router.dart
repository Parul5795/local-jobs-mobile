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
import '../../features/employer/screens/job_form_screen.dart';
import '../../features/local_ads/screens/classified_details_screen.dart';
import '../../features/local_ads/screens/create_local_ad_screen.dart';
import '../../features/local_ads/screens/local_ads_screen.dart';
import '../../features/local_discovery/screens/local_search_screen.dart';
import '../../features/local_discovery/screens/person_profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
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
        return null;
      }
      if (authState is Unauthenticated || authState is AuthError) {
        return isLoggingIn ? null : RoutePaths.login;
      }
      if (authState is Authenticated && (isLoggingIn || isSplash)) {
        return RoutePaths.home;
      }
      if (authState is Authenticated &&
          state.matchedLocation == RoutePaths.localJobCreate &&
          !authState.user.role.toLowerCase().contains('employer')) {
        return RoutePaths.home;
      }
      if (authState is Authenticated &&
          state.matchedLocation.startsWith('/people/') &&
          !authState.user.role.toLowerCase().contains('employer')) {
        return RoutePaths.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.localSearch,
        name: RouteNames.localSearch,
        builder: (_, state) => LocalSearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
        ),
      ),
      GoRoute(
        path: RoutePaths.localPerson,
        name: RouteNames.localPerson,
        builder: (_, state) =>
            PersonProfileScreen(personId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.localJobCreate,
        name: RouteNames.localJobCreate,
        builder: (_, _) => const JobFormScreen(),
      ),
      GoRoute(
        path: RoutePaths.localJobDetails,
        name: RouteNames.localJobDetails,
        builder: (_, state) =>
            JobDetailsScreen(jobId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.localAds,
        name: RouteNames.localAds,
        builder: (_, _) => const LocalAdsScreen(),
      ),
      GoRoute(
        path: RoutePaths.localAdCreate,
        name: RouteNames.localAdCreate,
        builder: (_, _) => const CreateLocalAdScreen(),
      ),
      GoRoute(
        path: RoutePaths.classifiedDetails,
        name: RouteNames.classifiedDetails,
        builder: (_, state) =>
            ClassifiedDetailsScreen(adId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: RoutePaths.profile,
        name: RouteNames.profile,
        builder: (_, _) => const ProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (_, _) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.employerDashboard,
        redirect: (_, _) => RoutePaths.home,
      ),
    ],
  );
});
