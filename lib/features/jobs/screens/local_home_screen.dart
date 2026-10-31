import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../features/auth/models/auth_state.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/localjobs/models/localjobs_models.dart';
import '../../../features/localjobs/providers/localjobs_providers.dart';
import '../../../features/local_discovery/models/local_person.dart';
import '../../../features/local_discovery/widgets/local_person_card.dart';
import '../../../features/contacts/contact_actions.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../widgets/job_status_badge.dart';

class LocalHomeScreen extends ConsumerWidget {
  const LocalHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final employer = auth is Authenticated && auth.user.role == 'Employer';
    final categories = ref.watch(categoriesProvider);
    final jobs = ref.watch(localJobsFeedProvider);
    final mine = employer ? ref.watch(myJobsApiProvider) : null;
    final myJobItems = mine?.asData?.value.items ?? const <JobPost>[];
    final people = ref.watch(homeWorkerPreviewProvider(employer));

    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalJobs'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => context.goNamed(RouteNames.localSearch),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 0),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(localJobsFeedProvider);
              if (employer) ref.invalidate(myJobsApiProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _hero(context, employer),
                const SizedBox(height: AppSpacing.x4),
                AppSearchField(
                  readOnly: true,
                  onTap: () => context.goNamed(RouteNames.localSearch),
                  hintText: employer
                      ? 'Search local workers'
                      : 'Driver, shop helper, tutor...',
                ),
                if (employer) ...[
                  const SizedBox(height: AppSpacing.x3),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.pushNamed(RouteNames.employerCreateJob),
                      icon: const Icon(Icons.add),
                      label: const Text('Post a Job'),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.x6),
                _sectionHeading(context, 'Popular categories'),
                const SizedBox(height: AppSpacing.x3),
                categories.when(
                  data: (items) => SizedBox(
                    height: 112,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.x3),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return _categoryTile(
                          context,
                          item.name,
                          _categoryIcon(item.name),
                          () => context.goNamed(
                            RouteNames.localSearch,
                            queryParameters: {'categoryId': '${item.id}'},
                          ),
                        );
                      },
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) =>
                      const Text('Categories could not be loaded.'),
                ),
                const SizedBox(height: AppSpacing.x6),
                if (employer) ...[
                  _sectionHeading(
                    context,
                    'People near you',
                    actionLabel: 'Find workers',
                    onAction: () => context.goNamed(RouteNames.localSearch),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  if (people.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (people.hasError)
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(homeWorkerPreviewProvider(employer)),
                      child: const Text('Could not load workers. Retry'),
                    ),
                  if (people.asData?.value.items.isEmpty == true)
                    _emptyState(
                      context,
                      Icons.people_outline,
                      'No worker profiles yet',
                      'Check back soon or search another category.',
                    ),
                  for (final item
                      in people.asData?.value.items ??
                          const <WorkerSearchResult>[])
                    LocalPersonCard(
                      person: LocalPerson.fromWorker(item.profile),
                      onTap: () => context.pushNamed(
                        RouteNames.localPerson,
                        pathParameters: {'id': item.profile.userId},
                      ),
                      onCall: () => startWorkerContact(
                        context,
                        ref,
                        item.profile.userId,
                        'Call',
                      ),
                      onWhatsApp: () => startWorkerContact(
                        context,
                        ref,
                        item.profile.userId,
                        'WhatsApp',
                      ),
                    ),
                  _sectionHeading(
                    context,
                    'Your posted jobs',
                    actionLabel: 'View all',
                    onAction: () => context.pushNamed(RouteNames.myJobs),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  if (mine?.isLoading == true)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (mine?.hasError == true)
                    TextButton(
                      onPressed: () => ref.invalidate(myJobsApiProvider),
                      child: const Text('Could not load your jobs. Retry'),
                    ),
                  if (mine?.asData != null && myJobItems.isEmpty)
                    _emptyState(
                      context,
                      Icons.work_outline,
                      'Your job posts will show here',
                      'Post a local work requirement to get started.',
                    ),
                  for (final job in myJobItems.take(3))
                    _jobTile(context, job, showStatus: true),
                  const SizedBox(height: AppSpacing.x6),
                ] else ...[
                  _sectionHeading(
                    context,
                    'Work near you',
                    actionLabel: 'See all',
                    onAction: () => context.goNamed(RouteNames.localSearch),
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  if (jobs.isLoading && jobs.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (jobs.error != null && jobs.items.isEmpty)
                    TextButton(
                      onPressed: () =>
                          ref.read(localJobsFeedProvider.notifier).load(),
                      child: Text('${jobs.error}  Retry'),
                    ),
                  if (jobs.items.isEmpty &&
                      !jobs.isLoading &&
                      jobs.error == null)
                    _emptyState(
                      context,
                      Icons.search_off_outlined,
                      'No active jobs nearby yet',
                      'Try a different category or check again later.',
                    ),
                  for (final job in jobs.items.take(5)) _jobTile(context, job),
                  if (jobs.hasMore)
                    Center(
                      child: TextButton(
                        onPressed: jobs.isLoadingMore
                            ? null
                            : () => ref
                                  .read(localJobsFeedProvider.notifier)
                                  .loadMore(),
                        child: jobs.isLoadingMore
                            ? const CircularProgressIndicator()
                            : const Text('Load more jobs'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _hero(BuildContext context, bool employer) => Container(
    padding: const EdgeInsets.all(AppSpacing.x5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withAlpha(30),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(34),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'LOCAL WORK · LOCAL PEOPLE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              Text(
                employer ? 'Find people nearby' : 'Find work nearby',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                employer
                    ? 'Connect with local workers or post a work requirement.'
                    : 'Explore local jobs that fit your skills and availability.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withAlpha(235),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.x3),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(32),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            employer ? Icons.people_alt_outlined : Icons.work_outline,
            color: Colors.white,
            size: 34,
          ),
        ),
      ],
    ),
  );

  Widget _sectionHeading(
    BuildContext context,
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (actionLabel != null && onAction != null)
        TextButton(onPressed: onAction, child: Text(actionLabel)),
    ],
  );

  Widget _categoryTile(
    BuildContext context,
    String name,
    IconData icon,
    VoidCallback onTap,
  ) => SizedBox(
    width: 88,
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.x2,
            vertical: AppSpacing.x3,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _emptyState(
    BuildContext context,
    IconData icon,
    String title,
    String message,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.x1),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  IconData _categoryIcon(String name) {
    final value = name.toLowerCase();
    if (value.contains('driver') || value.contains('vehicle')) {
      return Icons.directions_car_outlined;
    }
    if (value.contains('plumb')) return Icons.plumbing_outlined;
    if (value.contains('cook') || value.contains('food')) {
      return Icons.restaurant_outlined;
    }
    if (value.contains('clean') || value.contains('house')) {
      return Icons.home_outlined;
    }
    if (value.contains('tutor') || value.contains('teach')) {
      return Icons.menu_book_outlined;
    }
    if (value.contains('shop') || value.contains('sales')) {
      return Icons.storefront_outlined;
    }
    if (value.contains('electric')) return Icons.bolt_outlined;
    if (value.contains('carpent')) return Icons.handyman_outlined;
    return Icons.work_outline;
  }

  Widget _jobTile(
    BuildContext context,
    JobPost job, {
    bool showStatus = false,
  }) => Card(
    child: InkWell(
      onTap: () => context.pushNamed(
        RouteNames.localJobDetails,
        pathParameters: {'id': job.id},
        extra: showStatus ? job : null,
      ),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (showStatus) ...[
                  const SizedBox(width: AppSpacing.x2),
                  JobStatusBadge(isActive: job.isActive),
                ] else ...[
                  const SizedBox(width: AppSpacing.x2),
                  Icon(
                    Icons.arrow_outward_rounded,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            Wrap(
              spacing: AppSpacing.x2,
              runSpacing: AppSpacing.x2,
              children: [
                _jobTag(context, job.categoryName, AppColors.primaryLight),
                if (job.workType.isNotEmpty)
                  _jobTag(
                    context,
                    job.workType,
                    Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 17,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.x1),
                Expanded(
                  child: Text(
                    job.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    job.salaryLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (job.experienceRequirement.isNotEmpty)
                  Flexible(
                    child: Text(
                      job.experienceRequirement,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'Posted ${job.postedAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _jobTag(BuildContext context, String text, Color background) =>
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
