import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/local_category_strip.dart';
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
  double? _radius = 5;
  int? _cityId, _categoryId;
  bool? _isFresher;
  String? _workType, _experienceRequirement, _paymentPeriod;

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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isEmployer = auth is Authenticated && auth.user.role == 'Employer';
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? const <LookupItem>[];
    final citiesAsync = ref.watch(citiesProvider);
    final workers = isEmployer ? ref.watch(workerSearchProvider) : null;
    final jobs = isEmployer ? null : ref.watch(localJobsFeedProvider);
    final cityList = citiesAsync.asData?.value ?? const <CityItem>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                isEmployer ? 'Find people' : 'Find work',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _query,
                decoration: InputDecoration(
                  hintText: isEmployer
                      ? 'Driver, plumber, tutor…'
                      : 'Driver, shop helper, tutor…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      _query.clear();
                      _scheduleSearch(isEmployer);
                    },
                    icon: const Icon(Icons.clear),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => _scheduleSearch(isEmployer),
              ),
              const SizedBox(height: 12),
              if (citiesAsync.isLoading)
                const LinearProgressIndicator()
              else if (citiesAsync.hasError)
                TextButton(
                  onPressed: () => ref.invalidate(citiesProvider),
                  child: const Text('Could not load cities. Retry'),
                )
              else
                DropdownButtonFormField<int?>(
                  initialValue: _cityId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All cities'),
                    ),
                    for (final city in cityList)
                      DropdownMenuItem<int?>(
                        value: city.id,
                        child: Text(city.label),
                      ),
                  ],
                  onChanged: (id) {
                    setState(() => _cityId = id);
                    _scheduleSearch(isEmployer);
                  },
                ),
              const SizedBox(height: 10),
              LocationPickerButton(
                area: _area,
                radiusKm: _radius,
                onChanged: (choice) {
                  setState(() {
                    _area = choice.area;
                    _radius = choice.radiusKm;
                  });
                  _scheduleSearch(isEmployer);
                },
              ),
              Text(
                'Results use city and area. Distance filtering is not available yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 14),
              Text('Popular', style: Theme.of(context).textTheme.titleMedium),
              if (ref.watch(categoriesProvider).isLoading)
                const LinearProgressIndicator()
              else if (categories.isEmpty)
                const SizedBox.shrink()
              else
                LocalCategoryStrip(
                  categories: ['All', ...categories.map((c) => c.name)],
                  onSelected: (name) {
                    final item = categories
                        .where((c) => c.name == name)
                        .firstOrNull;
                    setState(() => _categoryId = item?.id);
                    _scheduleSearch(isEmployer);
                  },
                ),
              if (isEmployer) ...[
                const SizedBox(height: 6),
                FilterChip(
                  label: const Text('Fresher only'),
                  selected: _isFresher == true,
                  onSelected: (value) {
                    setState(() => _isFresher = value ? true : null);
                    _scheduleSearch(true);
                  },
                ),
              ],
              if (!isEmployer) ...[
                const SizedBox(height: 10),
                _filterDropdown(
                  'Work type',
                  _workType,
                  const ['Full-time', 'Part-time', 'One-time', 'Flexible'],
                  (value) {
                    setState(() => _workType = value);
                    _scheduleSearch(false);
                  },
                ),
                const SizedBox(height: 8),
                _filterDropdown(
                  'Experience',
                  _experienceRequirement,
                  const [
                    'Any experience',
                    'Fresher welcome',
                    'Experienced preferred',
                  ],
                  (value) {
                    setState(() => _experienceRequirement = value);
                    _scheduleSearch(false);
                  },
                ),
                const SizedBox(height: 8),
                _filterDropdown(
                  'Payment period',
                  _paymentPeriod,
                  const ['Monthly', 'Daily', 'Hourly', 'Fixed'],
                  (value) {
                    setState(() => _paymentPeriod = value);
                    _scheduleSearch(false);
                  },
                ),
              ],
              const SizedBox(height: 12),
              Text(
                isEmployer ? 'People near you' : 'Work near you',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (isEmployer) _workerResults(workers!) else _jobResults(jobs!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workerResults(PagedItemsState<WorkerSearchResult> state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return _retry(state.error!, _searchWorkers);
    }
    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No people found. Try another category or area.'),
      );
    }
    final people = state.items
        .map((result) => LocalPerson.fromWorker(result.profile))
        .toList();
    return Column(
      children: [
        for (var i = 0; i < people.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LocalPersonCard(
              person: people[i],
              onTap: () => context.pushNamed(
                RouteNames.localPerson,
                pathParameters: {'id': people[i].id},
              ),
              onCall: () =>
                  startWorkerContact(context, ref, people[i].id, 'Call'),
              onWhatsApp: () =>
                  startWorkerContact(context, ref, people[i].id, 'WhatsApp'),
            ),
          ),
        if (state.error != null) Text(state.error!),
        if (state.hasMore)
          OutlinedButton(
            onPressed: state.isLoadingMore
                ? null
                : () => ref.read(workerSearchProvider.notifier).loadMore(),
            child: state.isLoadingMore
                ? const CircularProgressIndicator()
                : const Text('Load more'),
          ),
      ],
    );
  }

  Widget _jobResults(PagedItemsState<JobPost> state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return _retry(state.error!, _searchJobs);
    }
    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No local work matches yet. Try another category or area.'),
      );
    }
    final localJobs = state.items.map(LocalJob.fromPost).toList();
    return Column(
      children: [
        for (final job in localJobs)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LocalJobCard(
              job: job,
              onTap: () => context.pushNamed(
                RouteNames.localJobDetails,
                pathParameters: {'id': job.id},
              ),
            ),
          ),
        if (state.error != null) Text(state.error!),
        if (state.hasMore)
          OutlinedButton(
            onPressed: state.isLoadingMore
                ? null
                : () => ref.read(localJobsFeedProvider.notifier).loadMore(),
            child: state.isLoadingMore
                ? const CircularProgressIndicator()
                : const Text('Load more'),
          ),
      ],
    );
  }

  Widget _retry(String message, VoidCallback retry) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: retry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
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
      border: const OutlineInputBorder(),
    ),
    items: [
      DropdownMenuItem<String?>(
        value: null,
        child: Text('Any $label'.toLowerCase()),
      ),
      for (final choice in choices)
        DropdownMenuItem<String?>(value: choice, child: Text(choice)),
    ],
    onChanged: onChanged,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
