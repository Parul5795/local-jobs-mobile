import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/models/auth_state.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/jobs/screens/job_details_screen.dart';
import '../../features/jobs/screens/job_list_screen.dart';
import '../../features/jobs/screens/local_home_screen.dart';
import '../../features/local_discovery/screens/local_search_screen.dart';
import '../../features/local_discovery/screens/person_profile_screen.dart';
import '../../features/local_ads/screens/local_ads_screen.dart';
import '../../features/local_ads/screens/classified_details_screen.dart';
import '../../features/local_ads/screens/create_local_ad_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/employer/screens/job_form_screen.dart';
import '../../features/employer/screens/my_jobs_screen.dart';
import '../../features/localjobs/models/localjobs_models.dart';
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
        if (isLoggingIn || isSplash) return RoutePaths.home;
        final isEmployer = authState.user.role.toLowerCase().contains(
          'employer',
        );
        final path = state.matchedLocation;
        if (!isEmployer &&
            (path.startsWith('/workers/') ||
                path == RoutePaths.myJobs ||
                path == RoutePaths.employerCreateJob ||
                (path.startsWith('/jobs/') && path.endsWith('/edit')))) {
          return RoutePaths.home;
        }
        if (isEmployer && path == RoutePaths.editProfile) {
          return RoutePaths.profile;
        }
        return null;
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
        builder: (context, state) => const LocalHomeScreen(),
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
          return JobDetailsScreen(
            jobId: jobId,
            initialJob: state.extra is JobPost ? state.extra as JobPost : null,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.localSearch,
        name: RouteNames.localSearch,
        builder: (context, state) => LocalSearchScreen(
          initialQuery: state.uri.queryParameters['q'] ?? '',
          initialCategoryId: int.tryParse(
            state.uri.queryParameters['categoryId'] ?? '',
          ),
          initialCityId: int.tryParse(
            state.uri.queryParameters['cityId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: RoutePaths.localAds,
        name: RouteNames.localAds,
        builder: (context, state) => const LocalAdsScreen(),
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
        path: RoutePaths.localPerson,
        name: RouteNames.localPerson,
        builder: (context, state) =>
            PersonProfileScreen(personId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: RoutePaths.localJobDetails,
        name: RouteNames.localJobDetails,
        builder: (context, state) => JobDetailsScreen(
          jobId: state.pathParameters['id']!,
          initialJob: state.extra is JobPost ? state.extra as JobPost : null,
        ),
      ),
      GoRoute(
        path: RoutePaths.classifiedDetails,
        name: RouteNames.classifiedDetails,
        builder: (context, state) => ClassifiedDetailsScreen(
          adId: state.pathParameters['id']!,
          initialAd: state.extra is ClassifiedAd
              ? state.extra as ClassifiedAd
              : null,
        ),
      ),
      GoRoute(
        path: RoutePaths.localAdCreate,
        name: RouteNames.localAdCreate,
        builder: (context, state) => const CreateLocalAdScreen(),
      ),
      GoRoute(
        path: RoutePaths.localAdEdit,
        name: RouteNames.localAdEdit,
        builder: (context, state) => CreateLocalAdScreen(
          adId: state.pathParameters['id']!,
          initialAd: state.extra is ClassifiedAd
              ? state.extra as ClassifiedAd
              : null,
        ),
      ),
      GoRoute(
        path: RoutePaths.myJobs,
        name: RouteNames.myJobs,
        builder: (context, state) => const MyJobsScreen(),
      ),
      GoRoute(
        path: RoutePaths.employerCreateJob,
        name: RouteNames.employerCreateJob,
        builder: (context, state) => const JobFormScreen(),
      ),
      GoRoute(
        path: RoutePaths.employerEditJob,
        name: RouteNames.employerEditJob,
        builder: (context, state) => JobFormScreen(
          jobId: state.pathParameters['id'],
          initialJob: state.extra is JobPost ? state.extra as JobPost : null,
        ),
      ),
    ],
  );
});
