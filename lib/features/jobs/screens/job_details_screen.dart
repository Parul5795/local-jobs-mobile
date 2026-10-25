import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../../localjobs/models/localjobs_models.dart';

class JobDetailsScreen extends ConsumerWidget {
  static const String routeName = 'job-details';
  final String jobId;
  final JobPost? initialJob;
  const JobDetailsScreen({super.key, required this.jobId, this.initialJob});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = initialJob == null
        ? ref.watch(jobDetailsApiProvider(jobId))
        : AsyncData(initialJob!);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: job.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Could not load this job.'),
              TextButton(
                onPressed: () => ref.invalidate(jobDetailsApiProvider(jobId)),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
        data: (item) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Posted by ${item.userName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item.location)),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DetailChip(label: item.categoryName),
                    _DetailChip(label: item.workType),
                    _DetailChip(label: item.experienceRequirement),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'About this work',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(item.description),
                const SizedBox(height: 18),
                Text('Payment', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(item.salaryLabel),
                if (item.startDate != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Start date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.startDate!.day}/${item.startDate!.month}/${item.startDate!.year}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;
  const _DetailChip({required this.label});
  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}
