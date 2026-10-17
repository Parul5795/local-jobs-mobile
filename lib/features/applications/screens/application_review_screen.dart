import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/app_button.dart';
import '../models/application_draft.dart';
import '../providers/applications_provider.dart';

class ApplicationReviewScreen extends ConsumerWidget {
  static const routeName = 'application-review';
  final ApplicationDraft? draft;

  const ApplicationReviewScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = this.draft;
    if (draft == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review application')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Application details unavailable',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Return to the job and start your application again.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.goNamed(RouteNames.jobs),
                  child: const Text('Browse jobs'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final state = ref.watch(applicationsControllerProvider);
    final job = draft.job;
    return Scaffold(
      appBar: AppBar(title: const Text('Review application')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Almost there',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Check your details before sending your application.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _ReviewCard(
                  title: 'Position',
                  children: [
                    _ReviewRow(label: 'Job', value: job.title),
                    _ReviewRow(label: 'Company', value: job.company),
                    _ReviewRow(label: 'Location', value: job.location),
                    _ReviewRow(label: 'Job type', value: job.employmentType),
                  ],
                ),
                const SizedBox(height: 12),
                _ReviewCard(
                  title: 'Your information',
                  children: [
                    _ReviewRow(label: 'Name', value: draft.fullName),
                    _ReviewRow(label: 'Email', value: draft.email),
                    _ReviewRow(label: 'Phone', value: draft.phone),
                  ],
                ),
                const SizedBox(height: 12),
                _ReviewCard(
                  title: 'Resume and message',
                  children: [
                    _ReviewRow(label: 'Resume', value: draft.resumeName),
                    _ReviewRow(label: 'Cover letter', value: draft.coverLetter),
                    if (draft.additionalInformation.isNotEmpty)
                      _ReviewRow(
                        label: 'Additional information',
                        value: draft.additionalInformation,
                      ),
                  ],
                ),
                if (state.submitError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Your application could not be submitted. Please try again.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  text: 'Submit application',
                  isLoading: state.isSubmitting,
                  onPressed: state.isSubmitting
                      ? null
                      : () async {
                          try {
                            final application = await ref
                                .read(applicationsControllerProvider.notifier)
                                .submitApplication(
                                  job: job,
                                  fullName: draft.fullName,
                                  email: draft.email,
                                  phone: draft.phone,
                                  resumeName: draft.resumeName,
                                  coverLetter: draft.coverLetter,
                                  additionalInformation:
                                      draft.additionalInformation,
                                );
                            if (context.mounted) {
                              context.pushReplacementNamed(
                                RouteNames.applicationSuccess,
                                pathParameters: {'id': application.id},
                              );
                            }
                          } catch (_) {
                            // The provider retains the error for inline feedback.
                          }
                        },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: state.isSubmitting ? null : () => context.pop(),
                  child: const Text('Edit application'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ReviewCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: child,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelMedium),
      const SizedBox(height: 3),
      Text(value, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}
