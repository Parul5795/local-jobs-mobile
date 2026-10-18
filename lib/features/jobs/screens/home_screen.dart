import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/local_category_strip.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../local_discovery/providers/local_discovery_provider.dart';
import '../../local_discovery/providers/local_jobs_provider.dart';
import '../../local_discovery/widgets/local_job_card.dart';
import '../../local_discovery/widgets/local_person_card.dart';
import '../../local_discovery/widgets/location_picker.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const String routeName = 'home';
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _categories = [
    'Driver',
    'Shop Helper',
    'House Help',
    'Plumber',
    'Tutor',
    'Delivery',
    'Carpenter',
    'Electrician',
    'Mechanic',
    'Cleaner',
    'Cook',
    'Labourer',
  ];
  String _area = 'Kalyani Nagar';
  double? _radius = 5;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isEmployer =
        auth is Authenticated &&
        auth.user.role.toLowerCase().contains('employer');
    final firstName =
        auth is Authenticated && auth.user.fullName.trim().isNotEmpty
        ? auth.user.fullName.trim().split(RegExp(r'\s+')).first
        : '';
    final currentEmployerId = auth is Authenticated ? auth.user.id : null;
    final people = ref
        .watch(localPeopleProvider)
        .where((person) => _nearby(person.distanceKm, person.location))
        .toList();
    final allJobs = ref.watch(localJobsProvider);
    final jobs = allJobs
        .where((job) => _nearby(job.distanceKm, job.location))
        .toList();
    final myJobs = allJobs
        .where((job) => job.employerId == currentEmployerId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('LocalJobs')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                firstName.isEmpty
                    ? 'Good morning 👋'
                    : 'Good morning, $firstName 👋',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isEmployer ? 'Find people nearby' : 'Find work nearby',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => context.pushNamed(RouteNames.localSearch),
                borderRadius: BorderRadius.circular(16),
                child: IgnorePointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: isEmployer
                          ? 'Driver, house help, plumber…'
                          : 'Driver, shop helper, tutor…',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              LocationPickerButton(
                area: _area,
                radiusKm: _radius,
                onChanged: (choice) => setState(() {
                  _area = choice.area;
                  _radius = choice.radiusKm;
                }),
              ),
              if (isEmployer) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.pushNamed(RouteNames.localJobCreate),
                  icon: const Icon(Icons.add),
                  label: const Text('Post a Job'),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                isEmployer ? 'Popular' : 'Popular work',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              LocalCategoryStrip(
                categories: _categories,
                onSelected: (category) => context.pushNamed(
                  RouteNames.localSearch,
                  queryParameters: {'q': category},
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEmployer ? 'People near you' : 'Work near you',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pushNamed(RouteNames.localSearch),
                    child: const Text('See all'),
                  ),
                ],
              ),
              if (isEmployer && people.isEmpty)
                _NearbyEmptyState(
                  icon: Icons.people_outline,
                  title: 'No workers nearby yet',
                  message: 'Try another area or widen your search distance.',
                  actionLabel: 'Search workers',
                  onPressed: () => context.pushNamed(RouteNames.localSearch),
                ),
              if (isEmployer)
                for (final person in people.take(3))
                  LocalPersonCard(
                    person: person,
                    onTap: () => context.pushNamed(
                      RouteNames.localPerson,
                      pathParameters: {'id': person.id},
                    ),
                    onCall: () => _contactPerson(context, person.id, 'Call'),
                    onWhatsApp: () =>
                        _contactPerson(context, person.id, 'WhatsApp'),
                  ),
              if (isEmployer) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your Posted Jobs',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                if (myJobs.isEmpty)
                  _NearbyEmptyState(
                    icon: Icons.work_outline,
                    title: "You haven't posted any jobs yet.",
                    message: 'Post a local job so nearby workers can find it.',
                    actionLabel: 'Post a Job',
                    onPressed: () =>
                        context.pushNamed(RouteNames.localJobCreate),
                  ),
                for (final job in myJobs)
                  LocalJobCard(
                    job: job,
                    onTap: () => context.pushNamed(
                      RouteNames.localJobDetails,
                      pathParameters: {'id': job.id},
                    ),
                  ),
              ],
              if (!isEmployer && jobs.isEmpty)
                _NearbyEmptyState(
                  icon: Icons.work_outline,
                  title: 'No work posts nearby yet',
                  message: 'Try another area or check again later.',
                  actionLabel: 'Search for work',
                  onPressed: () => context.pushNamed(RouteNames.localSearch),
                ),
              if (!isEmployer)
                for (final job in jobs.take(4))
                  LocalJobCard(
                    job: job,
                    onTap: () => context.pushNamed(
                      RouteNames.localJobDetails,
                      pathParameters: {'id': job.id},
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  bool _nearby(double distance, String location) =>
      (_area == 'Kalyani Nagar' || location.contains(_area)) &&
      (_radius == null || distance <= _radius!);

  void _contactPerson(BuildContext context, String id, String method) {
    ref.read(localPeopleProvider.notifier).recordContact(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$method contact is a demo action.')),
    );
  }
}

class _NearbyEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  const _NearbyEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          TextButton(onPressed: onPressed, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}
