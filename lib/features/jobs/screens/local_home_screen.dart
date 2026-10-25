import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../features/auth/models/auth_state.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/localjobs/models/localjobs_models.dart';
import '../../../features/localjobs/providers/localjobs_providers.dart';
import '../../../features/local_discovery/models/local_person.dart';
import '../../../features/local_discovery/widgets/local_person_card.dart';
import '../../../features/contacts/contact_actions.dart';
import '../../../shared/widgets/local_navigation_bar.dart';

class LocalHomeScreen extends ConsumerWidget {
  const LocalHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final employer = auth is Authenticated && auth.user.role == 'Employer';
    final categories = ref.watch(categoriesProvider);
    final jobs = ref.watch(localJobsFeedProvider);
    final mine = employer ? ref.watch(myJobsApiProvider) : null;
    final people = ref.watch(homeWorkerPreviewProvider(employer));
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalJobs'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.goNamed(RouteNames.localSearch),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 0),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(localJobsFeedProvider);
          if (employer) ref.invalidate(myJobsApiProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              employer ? 'Find people nearby' : 'Find work nearby',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              employer
                  ? 'Connect with local workers or post a work requirement.'
                  : 'Explore local jobs that fit your skills and availability.',
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              onTap: () => context.goNamed(RouteNames.localSearch),
              decoration: InputDecoration(
                hintText: employer ? 'Search workers' : 'Search local work',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            if (employer) ...[
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    context.pushNamed(RouteNames.employerCreateJob),
                icon: const Icon(Icons.add),
                label: const Text('Post a Job'),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              'Popular categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            categories.when(
              data: (items) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in items)
                    ActionChip(
                      label: Text(item.name),
                      onPressed: () => context.goNamed(
                        RouteNames.localSearch,
                        queryParameters: {'categoryId': '${item.id}'},
                      ),
                    ),
                ],
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Categories could not be loaded.'),
            ),
            const SizedBox(height: 20),
            Text(
              employer ? 'Your Posted Jobs' : 'Work near you',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (employer && mine!.isLoading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (employer && mine!.hasError)
              TextButton(
                onPressed: () => ref.invalidate(myJobsApiProvider),
                child: const Text('Could not load your jobs. Retry'),
              ),
            if (employer && mine!.asData?.value.items.isEmpty == true)
              const Text('You have not posted any jobs yet.'),
            if (employer)
              for (final job
                  in mine!.asData?.value.items.take(3) ?? const <JobPost>[])
                _jobTile(context, job),
            if (employer)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.pushNamed(RouteNames.myJobs),
                  child: const Text('View all posted jobs'),
                ),
              ),
            if (employer) ...[
              const SizedBox(height: 18),
              Text(
                'People near you',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (people.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (people.hasError)
                TextButton(
                  onPressed: () =>
                      ref.invalidate(homeWorkerPreviewProvider(employer)),
                  child: const Text('Could not load workers. Retry'),
                ),
              if (people.asData?.value.items.isEmpty == true)
                const Text('No worker profiles are available yet.'),
              for (final item
                  in people.asData?.value.items ?? const <WorkerSearchResult>[])
                LocalPersonCard(
                  person: LocalPerson.fromWorker(item.profile),
                  onTap: () => context.pushNamed(
                    RouteNames.localPerson,
                    pathParameters: {'id': item.profile.userId},
                  ),
                  onCall: () => startWorkerContact(
                    context,
                    ref,
                    item.profile.userId,
                    'Call',
                  ),
                  onWhatsApp: () => startWorkerContact(
                    context,
                    ref,
                    item.profile.userId,
                    'WhatsApp',
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => context.goNamed(RouteNames.localSearch),
                  child: const Text('Search all workers'),
                ),
              ),
            ],
            if (!employer && jobs.isLoading && jobs.items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!employer && jobs.error != null && jobs.items.isEmpty)
              TextButton(
                onPressed: () =>
                    ref.read(localJobsFeedProvider.notifier).load(),
                child: Text('${jobs.error}  Retry'),
              ),
            if (!employer &&
                jobs.items.isEmpty &&
                !jobs.isLoading &&
                jobs.error == null)
              const Text('No active local jobs are available yet.'),
            if (!employer)
              for (final job in jobs.items.take(5)) _jobTile(context, job),
            if (jobs.hasMore && !employer)
              Center(
                child: TextButton(
                  onPressed: jobs.isLoadingMore
                      ? null
                      : () =>
                            ref.read(localJobsFeedProvider.notifier).loadMore(),
                  child: const Text('Load more jobs'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _jobTile(BuildContext context, JobPost job) => Card(
    child: ListTile(
      title: Text(job.title),
      subtitle: Text(
        '${job.categoryName} · ${job.location} · ${job.salaryLabel}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.pushNamed(
        RouteNames.localJobDetails,
        pathParameters: {'id': job.id},
      ),
    ),
  );
}
