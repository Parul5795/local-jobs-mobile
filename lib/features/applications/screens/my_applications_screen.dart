import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/application_status.dart';
import '../providers/applications_provider.dart';
import '../widgets/application_card.dart';
import '../../jobs/widgets/empty_state.dart';
import 'application_details_screen.dart';

class MyApplicationsScreen extends ConsumerStatefulWidget {
  static const String routeName = 'my-applications';

  const MyApplicationsScreen({super.key});

  @override
  ConsumerState<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends ConsumerState<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(applicationsControllerProvider.notifier).loadApplications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(applicationsControllerProvider);
    final statuses = [
      'All',
      ...ApplicationStatus.values.map((s) => s.label),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(applicationsControllerProvider.notifier).loadApplications(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Track your applications',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'See the status of all jobs you\'ve applied for.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: statuses.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final status = statuses[index];
                            final isSelected = state.filters.statusFilter == null && status == 'All' ||
                                state.filters.statusFilter == status;
                            return ChoiceChip(
                              label: Text(status),
                              selected: isSelected,
                              onSelected: (_) {
                                final filterValue = status == 'All' ? null : status;
                                ref
                                    .read(applicationsControllerProvider.notifier)
                                    .filterByStatus(filterValue);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Something went wrong',
                    message: state.error ?? 'Please try again.',
                  ),
                )
              else if (state.applications.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.assignment_outlined,
                    title: 'No applications yet',
                    message: 'Start exploring jobs and apply to positions that interest you.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final application = state.applications[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ApplicationCard(
                            application: application,
                            onTap: () {
                              context.pushNamed(
                                ApplicationDetailsScreen.routeName,
                                pathParameters: {'id': application.id},
                              );
                            },
                          ),
                        );
                      },
                      childCount: state.applications.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
