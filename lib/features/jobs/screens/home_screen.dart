import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../employer/screens/employer_dashboard_screen.dart';
import 'job_list_screen.dart';
import '../../applications/screens/my_applications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  static const String routeName = 'home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final isEmployer =
        auth is Authenticated &&
        auth.user.role.toLowerCase().contains('employer');
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalJobs'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(JobListScreen.routeName),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.pushNamed(ProfileScreen.routeName),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Discover jobs that match your next move.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (isEmployer) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(EmployerDashboardScreen.routeName),
                      icon: const Icon(Icons.business_center_outlined),
                      label: const Text('Employer Dashboard'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.pushNamed(JobListScreen.routeName),
                    icon: const Icon(Icons.work_outline),
                    label: const Text('Browse jobs'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.pushNamed(MyApplicationsScreen.routeName),
                    icon: const Icon(Icons.assignment_outlined),
                    label: const Text('My applications'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        context.pushNamed(SettingsScreen.routeName),
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Settings'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
