import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/local_category_strip.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/local_discovery_provider.dart';
import '../providers/local_jobs_provider.dart';
import '../widgets/local_job_card.dart';
import '../widgets/local_person_card.dart';
import '../widgets/location_picker.dart';

class LocalSearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const LocalSearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<LocalSearchScreen> createState() => _LocalSearchScreenState();
}

class _LocalSearchScreenState extends ConsumerState<LocalSearchScreen> {
  late final TextEditingController _query;
  String _area = 'Kalyani Nagar';
  double? _radius = 5;
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

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isEmployer =
        auth is Authenticated &&
        auth.user.role.toLowerCase().contains('employer');
    final people = ref
        .watch(localPeopleProvider)
        .where(
          (person) =>
              person.matches(_query.text) &&
              _nearby(person.distanceKm, person.location),
        )
        .toList();
    final jobs = ref
        .watch(localJobsProvider)
        .where(
          (job) =>
              job.matches(_query.text) && _nearby(job.distanceKm, job.location),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                isEmployer ? 'Find people' : 'Find work',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: isEmployer
                      ? 'Driver, plumber, tutor…'
                      : 'Driver, shop helper, tutor…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _query.clear();
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
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
              const SizedBox(height: 18),
              Text('Popular', style: Theme.of(context).textTheme.titleMedium),
              LocalCategoryStrip(
                categories: _categories,
                onSelected: (value) {
                  _query.text = value;
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              Text(
                isEmployer ? 'People near you' : 'Work near you',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (isEmployer && people.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No people found nearby. Try another category or distance.',
                  ),
                ),
              if (isEmployer)
                for (final person in people)
                  LocalPersonCard(
                    person: person,
                    onTap: () => context.pushNamed(
                      RouteNames.localPerson,
                      pathParameters: {'id': person.id},
                    ),
                    onCall: () => _contact(context, person.id, 'Call'),
                    onWhatsApp: () => _contact(context, person.id, 'WhatsApp'),
                  ),
              if (!isEmployer && jobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No local work matches yet. Try another category or distance.',
                  ),
                ),
              if (!isEmployer)
                for (final job in jobs)
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

  void _contact(BuildContext context, String id, String method) {
    ref.read(localPeopleProvider.notifier).recordContact(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$method contact is a demo action.')),
    );
  }
}
