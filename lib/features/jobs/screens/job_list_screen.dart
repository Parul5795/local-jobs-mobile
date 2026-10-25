import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/jobs_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/job_card.dart';
import 'job_details_screen.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class JobListScreen extends ConsumerStatefulWidget {
  static const String routeName = 'job-list';

  const JobListScreen({super.key});

  @override
  ConsumerState<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends ConsumerState<JobListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(
      () => ref.read(jobsControllerProvider.notifier).loadJobs(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsControllerProvider);
    final filters = state.filters;
    final categoryItems =
        ref.watch(categoriesProvider).asData?.value ?? const [];
    final cityItems = ref.watch(citiesProvider).asData?.value ?? const [];
    final categories = ['All', ...categoryItems.map((item) => item.name)];
    final cities = ['All', ...cityItems.map((item) => item.label)];

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(jobsControllerProvider.notifier).loadJobs(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find your next opportunity',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search by role, company, or location.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Search jobs',
                        hint: 'Developer, designer, manager',
                        controller: _searchController,
                        prefixIcon: const Icon(Icons.search),
                        onSubmitted: (value) async {
                          await ref
                              .read(jobsControllerProvider.notifier)
                              .applyFilters(query: value);
                        },
                      ),
                      const SizedBox(height: 16),
                      FilterChipRow(
                        title: 'Category',
                        options: categories,
                        selectedValue: filters.category,
                        onSelected: (value) async {
                          await ref
                              .read(jobsControllerProvider.notifier)
                              .applyFilters(category: value);
                        },
                      ),
                      const SizedBox(height: 12),
                      FilterChipRow(
                        title: 'City',
                        options: cities,
                        selectedValue: filters.city,
                        onSelected: (value) async {
                          await ref
                              .read(jobsControllerProvider.notifier)
                              .applyFilters(city: value);
                        },
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
              else if (state.jobs.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.work_outline,
                    title: 'No jobs found',
                    message: 'Try adjusting your filters or search query.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final job = state.jobs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          job: job,
                          onTap: () {
                            context.pushNamed(
                              JobDetailsScreen.routeName,
                              pathParameters: {'id': job.id},
                            );
                          },
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
