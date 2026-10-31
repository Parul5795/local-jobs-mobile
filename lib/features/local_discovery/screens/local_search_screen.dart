import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../contacts/contact_actions.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../models/local_job.dart';
import '../models/local_person.dart';
import '../widgets/local_job_card.dart';
import '../widgets/local_person_card.dart';
import '../widgets/location_picker.dart';

class LocalSearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  final int? initialCategoryId;
  final int? initialCityId;

  const LocalSearchScreen({
    super.key,
    this.initialQuery = '',
    this.initialCategoryId,
    this.initialCityId,
  });

  @override
  ConsumerState<LocalSearchScreen> createState() => _LocalSearchScreenState();
}

class _LocalSearchScreenState extends ConsumerState<LocalSearchScreen> {
  late final TextEditingController _query;
  Timer? _debounce;
  String _area = '';
  int? _cityId;
  int? _categoryId;
  bool? _isFresher;
  String? _workType;
  String? _experienceRequirement;
  String? _paymentPeriod;

  @override
  void initState() {
    super.initState();
    _query = TextEditingController(text: widget.initialQuery);
    _categoryId = widget.initialCategoryId;
    _cityId = widget.initialCityId;
    Future.microtask(() {
      final auth = ref.read(authStateProvider);
      if (auth is Authenticated && auth.user.role == 'Employer') {
        _searchWorkers();
      } else {
        _searchJobs();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _searchWorkers() => ref
      .read(workerSearchProvider.notifier)
      .search(
        keyword: _query.text,
        categoryId: _categoryId,
        cityId: _cityId,
        area: _area,
        isFresher: _isFresher,
      );

  void _searchJobs() => ref
      .read(localJobsFeedProvider.notifier)
      .search(
        keyword: _query.text,
        categoryId: _categoryId,
        cityId: _cityId,
        area: _area,
        workType: _workType,
        experienceRequirement: _experienceRequirement,
        paymentPeriod: _paymentPeriod,
      );

  void _scheduleSearch(bool employer) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      employer ? _searchWorkers : _searchJobs,
    );
  }

  List<String> _activeFilterLabels(bool employer) => [
    if (_area.isNotEmpty) _area,
    if (employer && _isFresher == true) 'Fresher',
    if (!employer && _workType != null) _workType!,
    if (!employer && _experienceRequirement != null) _experienceRequirement!,
    if (!employer && _paymentPeriod != null) _paymentPeriod!,
  ];

  Future<void> _showFilters({required bool employer}) async {
    var draftCityId = _cityId;
    var draftArea = _area;
    var draftIsFresher = _isFresher == true;
    var draftWorkType = _workType;
    var draftExperience = _experienceRequirement;
    var draftPaymentPeriod = _paymentPeriod;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (sheetContext, sheetRef, _) {
          final citiesAsync = sheetRef.watch(citiesProvider);
          return StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              final cities = citiesAsync.asData?.value ?? const <CityItem>[];
              return SizedBox(
                height: MediaQuery.sizeOf(sheetContext).height * 0.82,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Location & filters',
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close filters',
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location',
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            if (citiesAsync.isLoading)
                              const LinearProgressIndicator()
                            else if (citiesAsync.hasError)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      sheetRef.invalidate(citiesProvider),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry loading cities'),
                                ),
                              )
                            else
                              DropdownButtonFormField<int?>(
                                initialValue: draftCityId,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: Icon(
                                    Icons.location_city_outlined,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text('All cities'),
                                  ),
                                  for (final city in cities)
                                    DropdownMenuItem<int?>(
                                      value: city.id,
                                      child: Text(city.label),
                                    ),
                                ],
                                onChanged: (value) =>
                                    setSheetState(() => draftCityId = value),
                              ),
                            const SizedBox(height: AppSpacing.x4),
                            Text(
                              'Area',
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleSmall,
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            Wrap(
                              spacing: AppSpacing.x2,
                              runSpacing: AppSpacing.x2,
                              children: [
                                ChoiceChip(
                                  label: const Text('Any area'),
                                  selected: draftArea.isEmpty,
                                  onSelected: (_) =>
                                      setSheetState(() => draftArea = ''),
                                ),
                                for (final area in localAreas)
                                  ChoiceChip(
                                    label: Text(area),
                                    selected: draftArea == area,
                                    onSelected: (_) => setSheetState(
                                      () => draftArea = draftArea == area
                                          ? ''
                                          : area,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.x6),
                            const Divider(),
                            const SizedBox(height: AppSpacing.x4),
                            Text(
                              employer ? 'Worker filters' : 'Work filters',
                              style: Theme.of(
                                sheetContext,
                              ).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.x3),
                            if (employer)
                              FilterChip(
                                avatar: const Icon(
                                  Icons.school_outlined,
                                  size: 18,
                                ),
                                label: const Text('Fresher only'),
                                selected: draftIsFresher,
                                onSelected: (value) =>
                                    setSheetState(() => draftIsFresher = value),
                              )
                            else ...[
                              _filterDropdown(
                                'Work type',
                                draftWorkType,
                                const [
                                  'Full-time',
                                  'Part-time',
                                  'One-time',
                                  'Flexible',
                                ],
                                (value) =>
                                    setSheetState(() => draftWorkType = value),
                              ),
                              const SizedBox(height: AppSpacing.x3),
                              _filterDropdown(
                                'Experience',
                                draftExperience,
                                const [
                                  'Any experience',
                                  'Fresher welcome',
                                  'Experienced preferred',
                                ],
                                (value) => setSheetState(
                                  () => draftExperience = value,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.x3),
                              _filterDropdown(
                                'Payment period',
                                draftPaymentPeriod,
                                const ['Monthly', 'Daily', 'Hourly', 'Fixed'],
                                (value) => setSheetState(
                                  () => draftPaymentPeriod = value,
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.x5),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => setSheetState(() {
                              draftCityId = null;
                              draftArea = '';
                              draftIsFresher = false;
                              draftWorkType = null;
                              draftExperience = null;
                              draftPaymentPeriod = null;
                            }),
                            child: const Text('Reset'),
                          ),
                          const SizedBox(width: AppSpacing.x3),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _cityId = draftCityId;
                                  _area = draftArea;
                                  _isFresher = employer && draftIsFresher
                                      ? true
                                      : null;
                                  _workType = employer ? null : draftWorkType;
                                  _experienceRequirement = employer
                                      ? null
                                      : draftExperience;
                                  _paymentPeriod = employer
                                      ? null
                                      : draftPaymentPeriod;
                                });
                                Navigator.of(sheetContext).pop();
                                _debounce?.cancel();
                                if (employer) {
                                  _searchWorkers();
                                } else {
                                  _searchJobs();
                                }
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Apply filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _clearAll(bool employer) {
    _query.clear();
    setState(() {
      _cityId = null;
      _area = '';
      _categoryId = null;
      _isFresher = null;
      _workType = null;
      _experienceRequirement = null;
      _paymentPeriod = null;
    });
    _debounce?.cancel();
    if (employer) {
      _searchWorkers();
    } else {
      _searchJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isEmployer = auth is Authenticated && auth.user.role == 'Employer';
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? const <LookupItem>[];
    final citiesAsync = ref.watch(citiesProvider);
    final cityList = citiesAsync.asData?.value ?? const <CityItem>[];
    final selectedCity = cityList
        .where((city) => city.id == _cityId)
        .firstOrNull;
    final locationLabel = [
      if (_area.isNotEmpty) _area,
      selectedCity?.label ?? (_cityId == null ? 'All cities' : 'Selected city'),
    ].where((part) => part.isNotEmpty).join(' · ');
    final activeFilters = _activeFilterLabels(isEmployer);
    final workers = isEmployer ? ref.watch(workerSearchProvider) : null;
    final jobs = isEmployer ? null : ref.watch(localJobsFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.background,
      ),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Text(
                isEmployer ? 'Find someone' : 'Find work',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.x4),
              AppSearchField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: isEmployer
                      ? 'Driver, house help, plumber...'
                      : 'Driver, shop helper, tutor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _query.clear();
                            setState(() {});
                            _scheduleSearch(isEmployer);
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) {
                  setState(() {});
                  _scheduleSearch(isEmployer);
                },
                onSubmitted: (_) => _scheduleSearch(isEmployer),
              ),
              const SizedBox(height: AppSpacing.x3),
              const SizedBox(height: AppSpacing.x6),
              Text(
                'Popular categories',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.x2),
              if (ref.watch(categoriesProvider).isLoading)
                const LinearProgressIndicator()
              else if (categories.isNotEmpty)
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _categoryChip(
                        context,
                        name: 'All',
                        icon: Icons.grid_view_rounded,
                        selected: _categoryId == null,
                        onSelected: () {
                          setState(() => _categoryId = null);
                          _scheduleSearch(isEmployer);
                        },
                      ),
                      for (final category in categories)
                        _categoryChip(
                          context,
                          name: category.name,
                          icon: _categoryIcon(category.name),
                          selected: category.id == _categoryId,
                          onSelected: () {
                            setState(() => _categoryId = category.id);
                            _scheduleSearch(isEmployer);
                          },
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFilters(employer: isEmployer),
                      icon: const Icon(Icons.location_on_outlined),
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  FilledButton.tonalIcon(
                    onPressed: () => _showFilters(employer: isEmployer),
                    icon: const Icon(Icons.tune),
                    label: Text(
                      activeFilters.isEmpty
                          ? 'Filters'
                          : 'Filters ${activeFilters.length}',
                    ),
                  ),
                ],
              ),
              if (activeFilters.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.x2),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: activeFilters.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.x2),
                    itemBuilder: (context, index) => Chip(
                      avatar: const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(activeFilters[index]),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.x6),
              _resultsHeader(
                context,
                isEmployer ? 'People near you' : 'Work near you',
                isEmployer ? workers!.totalCount : jobs!.totalCount,
              ),
              const SizedBox(height: AppSpacing.x3),
              if (isEmployer) _workerResults(workers!) else _jobResults(jobs!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryChip(
    BuildContext context, {
    required String name,
    required IconData icon,
    required bool selected,
    required VoidCallback onSelected,
  }) => Padding(
    padding: const EdgeInsets.only(right: AppSpacing.x2),
    child: ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : AppColors.primary,
      ),
      label: Text(name),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: selected ? Colors.white : AppColors.onSurface,
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );

  Widget _resultsHeader(BuildContext context, String title, int count) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (count > 0)
        Text(
          count == 1 ? '1 result' : '$count results',
          style: Theme.of(context).textTheme.bodySmall,
        ),
    ],
  );

  Widget _workerResults(PagedItemsState<WorkerSearchResult> state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return _retry(state.error!, _searchWorkers);
    }
    if (state.items.isEmpty) {
      return _emptyResults(
        title: 'No people found nearby',
        message: 'Try another category or location.',
        actionLabel: 'Clear filters',
        onAction: () => _clearAll(true),
      );
    }
    final people = state.items
        .map((result) => LocalPerson.fromWorker(result.profile))
        .toList();
    return Column(
      children: [
        for (final person in people)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x3),
            child: LocalPersonCard(
              person: person,
              onTap: () => context.pushNamed(
                RouteNames.localPerson,
                pathParameters: {'id': person.id},
              ),
              onCall: () => startWorkerContact(context, ref, person.id, 'Call'),
              onWhatsApp: () =>
                  startWorkerContact(context, ref, person.id, 'WhatsApp'),
            ),
          ),
        if (state.error != null) _inlineError(state.error!),
        if (state.hasMore)
          OutlinedButton(
            onPressed: state.isLoadingMore
                ? null
                : () => ref.read(workerSearchProvider.notifier).loadMore(),
            child: state.isLoadingMore
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load more people'),
          ),
      ],
    );
  }

  Widget _jobResults(PagedItemsState<JobPost> state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return _retry(state.error!, _searchJobs);
    }
    if (state.items.isEmpty) {
      return _emptyResults(
        title: 'No work found nearby',
        message: 'Try another category or location.',
        actionLabel: 'Browse all jobs',
        onAction: () => _clearAll(false),
      );
    }
    final localJobs = state.items.map(LocalJob.fromPost).toList();
    return Column(
      children: [
        for (final job in localJobs)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x3),
            child: LocalJobCard(
              job: job,
              onTap: () => context.pushNamed(
                RouteNames.localJobDetails,
                pathParameters: {'id': job.id},
              ),
            ),
          ),
        if (state.error != null) _inlineError(state.error!),
        if (state.hasMore)
          OutlinedButton(
            onPressed: state.isLoadingMore
                ? null
                : () => ref.read(localJobsFeedProvider.notifier).loadMore(),
            child: state.isLoadingMore
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Load more jobs'),
          ),
      ],
    );
  }

  Widget _emptyResults({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.x1),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.x3),
          FilledButton.tonal(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );

  Widget _retry(String message, VoidCallback retry) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.x5),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.x3),
          OutlinedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );

  Widget _inlineError(String message) => Padding(
    padding: const EdgeInsets.all(AppSpacing.x2),
    child: Text(
      message,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AppColors.error),
    ),
  );

  Widget _filterDropdown(
    String label,
    String? value,
    List<String> choices,
    ValueChanged<String?> onChanged,
  ) => DropdownButtonFormField<String?>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(_filterIcon(label)),
    ),
    items: [
      DropdownMenuItem<String?>(value: null, child: Text('Any $label')),
      for (final choice in choices)
        DropdownMenuItem<String?>(value: choice, child: Text(choice)),
    ],
    onChanged: onChanged,
  );

  IconData _filterIcon(String label) => switch (label) {
    'Work type' => Icons.work_outline,
    'Experience' => Icons.stars_outlined,
    'Payment period' => Icons.payments_outlined,
    _ => Icons.tune,
  };

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
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
