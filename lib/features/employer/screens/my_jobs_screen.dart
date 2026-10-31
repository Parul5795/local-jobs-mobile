import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../../../app/router/route_names.dart';
import '../../jobs/widgets/job_status_badge.dart';
import '../widgets/job_management_controls.dart';

class MyJobsScreen extends ConsumerWidget {
  static const String routeName = 'my-jobs';
  const MyJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(myJobsApiProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Posted Jobs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.employerCreateJob),
        icon: const Icon(Icons.add),
        label: const Text('Post a Job'),
      ),
      body: jobs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load your jobs.'),
              TextButton(
                onPressed: () => ref.invalidate(myJobsApiProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (page) => page.items.isEmpty
            ? const Center(child: Text('You have not posted any jobs yet.'))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(myJobsApiProvider),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                  children: [for (final job in page.items) _job(context, job)],
                ),
              ),
      ),
    );
  }

  Widget _job(BuildContext context, JobPost job) => Card(
    child: Column(
      children: [
        ListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(width: 8),
              JobStatusBadge(isActive: job.isActive),
            ],
          ),
          subtitle: Text(
            '${job.categoryName} · ${job.location} · ${job.salaryLabel} · ${job.workType}',
          ),
          onTap: () => context.pushNamed(
            RouteNames.localJobDetails,
            pathParameters: {'id': job.id},
            extra: job,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: JobManagementControls(job: job, compact: true),
        ),
      ],
    ),
  );
}
