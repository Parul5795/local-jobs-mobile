import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/job_model.dart';
import '../providers/saved_jobs_provider.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';

class SavedJobsScreen extends ConsumerWidget {
  static const String routeName = 'saved-jobs';

  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedJobsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Jobs'),
        bottom: state.jobs.isNotEmpty
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.jobs.length} ${state.jobs.length == 1 ? 'job' : 'jobs'} saved',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: state.isLoading && state.jobs.isEmpty
          ? const _SavedJobsLoading()
          : state.error != null && state.jobs.isEmpty
          ? _SavedJobsError(
              onRetry: () => ref.read(savedJobsProvider.notifier).load(),
            )
          : state.jobs.isEmpty
          ? _SavedJobsEmpty(onBrowse: () => context.pushNamed(RouteNames.jobs))
          : RefreshIndicator(
              onRefresh: () => ref.read(savedJobsProvider.notifier).load(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                    itemCount: state.jobs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = state.jobs[index];
                      return JobCard(
                        job: job,
                        isSaved: true,
                        isUpdatingSavedState: state.updatingJobIds.contains(
                          job.id,
                        ),
                        onToggleSaved: () => _removeSavedJob(context, ref, job),
                        onTap: () => context.pushNamed(
                          JobDetailsScreen.routeName,
                          pathParameters: {'id': job.id},
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _removeSavedJob(
    BuildContext context,
    WidgetRef ref,
    Job job,
  ) async {
    try {
      await ref.read(savedJobsProvider.notifier).toggle(job);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${job.title} removed from saved jobs.'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => ref.read(savedJobsProvider.notifier).toggle(job),
          ),
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update saved jobs: $error')),
        );
      }
    }
  }
}

class _SavedJobsLoading extends StatelessWidget {
  const _SavedJobsLoading();

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 760),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => const Card(
          child: SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    ),
  );
}

class _SavedJobsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _SavedJobsError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Saved jobs unavailable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('We couldn’t load your saved jobs. Please try again.'),
          const SizedBox(height: 20),
          AppButton(text: 'Try again', fullWidth: false, onPressed: onRetry),
        ],
      ),
    ),
  );
}

class _SavedJobsEmpty extends StatelessWidget {
  final VoidCallback onBrowse;

  const _SavedJobsEmpty({required this.onBrowse});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No saved jobs yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark roles that interest you and come back to them here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          AppButton(text: 'Browse jobs', fullWidth: false, onPressed: onBrowse),
        ],
      ),
    ),
  );
}
