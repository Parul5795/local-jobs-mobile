import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../../../app/router/route_names.dart';

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
                  children: [
                    for (final job in page.items) _job(context, ref, job),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _job(BuildContext context, WidgetRef ref, JobPost job) => Card(
    child: Column(
      children: [
        ListTile(
          title: Text(job.title),
          subtitle: Text(
            '${job.location} · ${job.salaryLabel} · ${job.status}',
          ),
          onTap: () => context.pushNamed(
            RouteNames.localJobDetails,
            pathParameters: {'id': job.id},
            extra: job,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => context.pushNamed(
                  RouteNames.employerEditJob,
                  pathParameters: {'id': job.id},
                  extra: job,
                ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
              ),
              if (job.isActive)
                TextButton.icon(
                  onPressed: () => _deactivate(context, ref, job),
                  icon: const Icon(Icons.pause_circle_outline),
                  label: const Text('Deactivate'),
                ),
            ],
          ),
        ),
      ],
    ),
  );
  Future<void> _deactivate(
    BuildContext context,
    WidgetRef ref,
    JobPost job,
  ) async {
    try {
      await ref.read(localJobsRepositoryProvider).deactivateJob(job.id);
      ref.invalidate(myJobsApiProvider);
      ref.invalidate(localJobsFeedProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Job deactivated.')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not deactivate the job. Please try again.'),
          ),
        );
      }
    }
  }
}
