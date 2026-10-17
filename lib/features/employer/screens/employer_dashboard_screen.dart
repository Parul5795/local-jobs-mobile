import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/employer_provider.dart';
import '../widgets/employer_job_card.dart';
import '../widgets/stat_card.dart';
import '../../jobs/widgets/empty_state.dart';
import '../../notifications/providers/notifications_provider.dart';

class EmployerDashboardScreen extends ConsumerWidget {
  static const String routeName = 'employer-dashboard';

  const EmployerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employerDashboardProvider);
    final theme = Theme.of(context);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Dashboard'),
        actions: [
          IconButton(
            tooltip:
                'Notifications${unreadCount > 0 ? ', $unreadCount unread' : ''}',
            onPressed: () => context.pushNamed('notifications'),
            icon: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Profile',
            onPressed: () => context.pushNamed('profile'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed('employer-create-job'),
        icon: const Icon(Icons.add),
        label: const Text('Post a Job'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(employerDashboardProvider.notifier).load(),
          child: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: theme.textTheme.bodyLarge),
                      Text(
                        'Employer',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here\'s a snapshot of your hiring activity.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Stats grid ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: state.isLoading && state.stats == null
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : state.stats == null
                      ? const SizedBox.shrink()
                      : GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                          children: [
                            StatCard(
                              label: 'Active Jobs',
                              value: '${state.stats!.activeJobs}',
                              icon: Icons.work_outline,
                              color: AppColors.primary,
                            ),
                            StatCard(
                              label: 'Total Applications',
                              value: '${state.stats!.totalApplications}',
                              icon: Icons.people_outline,
                              color: AppColors.secondary,
                            ),
                            StatCard(
                              label: 'Shortlisted',
                              value: '${state.stats!.shortlisted}',
                              icon: Icons.star_outline,
                              color: Colors.orange,
                            ),
                            StatCard(
                              label: 'Hired',
                              value: '${state.stats!.hired}',
                              icon: Icons.check_circle_outline,
                              color: AppColors.tertiary,
                            ),
                          ],
                        ),
                ),
              ),

              // ── Recent job postings ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Recent postings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pushNamed('employer-my-jobs'),
                        child: const Text('View all'),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.isLoading && state.recentJobs.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EmptyState(
                        icon: Icons.error_outline,
                        title: 'Could not load dashboard',
                        message: state.error!,
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            ref.read(employerDashboardProvider.notifier).load(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                )
              else if (state.recentJobs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyState(
                      icon: Icons.work_off_outlined,
                      title: 'No jobs posted yet',
                      message: 'Tap "Post a Job" to create your first listing.',
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, i) {
                      final job = state.recentJobs[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EmployerJobCard(
                          job: job,
                          onTap: () => context.pushNamed(
                            'employer-job-detail',
                            pathParameters: {'id': job.id},
                          ),
                        ),
                      );
                    }, childCount: state.recentJobs.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
