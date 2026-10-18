import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/local_navigation_bar.dart';
import '../../local_discovery/providers/local_jobs_provider.dart';

class JobDetailsScreen extends ConsumerWidget {
  static const String routeName = 'local-job-details';
  final String jobId;
  const JobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref
        .watch(localJobsProvider)
        .where((item) => item.id == jobId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Work details')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
      body: job == null
          ? const Center(child: Text('This work post is no longer available.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${job.location} · ${job.distanceKm.toStringAsFixed(1)} km',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.pay,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${job.workType} · ${job.availability} · ${job.experience}',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(job.description),
                    const SizedBox(height: 16),
                    Text(
                      'Requirements',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.requirements.isEmpty
                          ? 'No additional requirements listed.'
                          : job.requirements,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Posted by',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(job.employer),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => _contact(context, 'Call'),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Call'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _contact(context, 'WhatsApp'),
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('WhatsApp'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _contact(BuildContext context, String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$method contact is a demo action.')),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
