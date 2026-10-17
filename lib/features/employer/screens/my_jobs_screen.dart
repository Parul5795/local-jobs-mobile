import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../jobs/widgets/empty_state.dart';
import '../providers/employer_provider.dart';
import '../widgets/employer_job_card.dart';

class MyJobsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'employer-my-jobs';

  const MyJobsScreen({super.key});

  @override
  ConsumerState<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends ConsumerState<MyJobsScreen> {
  late final TextEditingController _searchCtrl;

  static const _statusOptions = ['All', 'Active', 'Closed'];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employerJobsProvider);
    final notifier = ref.read(employerJobsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Jobs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('employer-create-job'),
        icon: const Icon(Icons.add),
        label: const Text('Post a Job'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.load(),
          child: CustomScrollView(
            slivers: [
              // ── Search + filter ───────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Search jobs',
                        controller: _searchCtrl,
                        prefixIcon: const Icon(Icons.search),
                        onSubmitted: (q) => notifier.applyFilter(query: q),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _statusOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final opt = _statusOptions[i];
                            final selected = state.statusFilter == opt;
                            return ChoiceChip(
                              label: Text(opt),
                              selected: selected,
                              onSelected: (_) =>
                                  notifier.applyFilter(status: opt),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Job list ──────────────────────────────────────────
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: _JobsMessage(
                    title: 'Could not load jobs',
                    message: state.error!,
                    onRetry: notifier.load,
                  ),
                )
              else if (state.jobs.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.work_off_outlined,
                    title: 'No jobs found',
                    message: 'Adjust filters or post a new job.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final job = state.jobs[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EmployerJobCard(
                          job: job,
                          showActions: true,
                          onTap: () => context.pushNamed(
                            'employer-job-detail',
                            pathParameters: {'id': job.id},
                          ),
                          onEdit: () => context.pushNamed(
                            'employer-edit-job',
                            pathParameters: {'id': job.id},
                          ),
                        ),
                      );
                    }, childCount: state.jobs.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobsMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _JobsMessage({
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
