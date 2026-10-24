import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_provider.dart';

class JobDetailsScreen extends ConsumerWidget {
  static const String routeName = 'job-details';

  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailsProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: jobAsync.when(
        data: (job) {
          if (job == null) {
            return const Center(child: Text('Job not found'));
          }

          final theme = Theme.of(context);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(job.company, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(job.location),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _DetailChip(label: job.category),
                    _DetailChip(label: job.employmentType),
                    _DetailChip(label: job.experienceLevel),
                  ],
                ),
                const SizedBox(height: 16),
                Text('About this role', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(job.description),
                const SizedBox(height: 16),
                Text('Salary', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(job.salary),
                const SizedBox(height: 16),
                Text('Required skills', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...job.skills.map((skill) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(skill)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Text('Requirements', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ...job.requirements.map((requirement) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right),
                          const SizedBox(width: 8),
                          Expanded(child: Text(requirement)),
                        ],
                      ),
                    )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(child: Text('Failed to load job details')),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final String label;

  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
