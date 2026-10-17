import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../providers/applications_provider.dart';
import '../widgets/application_status_badge.dart';

class ApplicationSuccessScreen extends ConsumerWidget {
  static const routeName = 'application-success';
  final String applicationId;

  const ApplicationSuccessScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(
      applicationDetailsProvider(applicationId),
    );
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Application sent'),
      ),
      body: applicationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _SuccessState(
          onRetry: () =>
              ref.invalidate(applicationDetailsProvider(applicationId)),
        ),
        data: (application) {
          if (application == null) {
            return _SuccessState(
              onRetry: () =>
                  ref.invalidate(applicationDetailsProvider(applicationId)),
            );
          }
          final theme = Theme.of(context);
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Application submitted',
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your application was sent to ${application.job.company}. Good luck!',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.work_outline),
                          title: Text(application.job.title),
                          subtitle: Text(
                            '${application.job.company} · ${application.job.location}',
                          ),
                          trailing: ApplicationStatusBadge(
                            status: application.status,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.pushNamed(
                            RouteNames.applicationDetails,
                            pathParameters: {'id': application.id},
                          ),
                          child: const Text('View application'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => context.goNamed(RouteNames.jobs),
                          icon: const Icon(Icons.search),
                          label: const Text('Browse more jobs'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final VoidCallback onRetry;

  const _SuccessState({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, size: 64),
          const SizedBox(height: 16),
          Text(
            'Application submitted',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your application has been saved. You can find it in My Applications.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.goNamed(RouteNames.myApplications),
            child: const Text('My applications'),
          ),
          TextButton(onPressed: onRetry, child: const Text('Refresh details')),
        ],
      ),
    ),
  );
}
