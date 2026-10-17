import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../jobs/widgets/empty_state.dart';
import '../providers/employer_provider.dart';
import '../widgets/applicant_card.dart';

class ApplicantsScreen extends ConsumerWidget {
  static const String routeName = 'employer-applicants';
  final String jobId;

  const ApplicantsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(applicantsProvider(jobId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(applicantsProvider(jobId).notifier).load(),
          child: Builder(
            builder: (ctx) {
              if (state.isLoading) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(ctx).height * 0.7,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ],
                );
              }
              if (state.error != null) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(ctx).height * 0.7,
                      child: _ApplicantsMessage(
                        title: 'Could not load applicants',
                        message: state.error!,
                        onRetry: () =>
                            ref.read(applicantsProvider(jobId).notifier).load(),
                      ),
                    ),
                  ],
                );
              }
              if (state.applicants.isEmpty) {
                return ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 420,
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        title: 'No applicants yet',
                        message:
                            'Share your job listing to attract candidates.',
                      ),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: state.applicants.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final a = state.applicants[i];
                  return ApplicantCard(
                    applicant: a,
                    onTap: () => context.pushNamed(
                      'employer-applicant-detail',
                      pathParameters: {'id': a.id},
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ApplicantsMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _ApplicantsMessage({
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}
