import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../local_discovery/widgets/location_picker.dart';
import '../models/local_ad.dart';
import '../widgets/local_ad_card.dart';

class LocalAdsScreen extends ConsumerStatefulWidget {
  const LocalAdsScreen({super.key});
  @override
  ConsumerState<LocalAdsScreen> createState() => _LocalAdsScreenState();
}

class _LocalAdsScreenState extends ConsumerState<LocalAdsScreen> {
  final _query = TextEditingController();
  int? _categoryId, _cityId;
  double? _radiusKm = 5;
  String _area = '';
  bool _showMyAds = false;
  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() => ref
      .read(localAdsFeedProvider.notifier)
      .search(
        keyword: _query.text,
        cityId: _cityId,
        categoryId: _categoryId,
        area: _area,
      );

  @override
  Widget build(BuildContext context) {
    final categories =
        ref.watch(adCategoriesProvider).asData?.value ?? const <LookupItem>[];
    final citiesAsync = ref.watch(citiesProvider);
    final feed = _showMyAds ? null : ref.watch(localAdsFeedProvider);
    final mine = _showMyAds ? ref.watch(myAdsProvider) : null;
    final ads = _showMyAds
        ? (mine!.asData?.value.items ?? const <ClassifiedAd>[])
        : (feed?.items ?? const <ClassifiedAd>[]);
    final isLoading = _showMyAds ? mine!.isLoading : feed!.isLoading;
    final error = _showMyAds ? mine!.hasError : feed!.error != null;
    final items = ads.map(LocalAd.fromBackend).toList();
    final featured = items.where((item) => item.featured).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(_showMyAds ? 'My Ads' : 'Local Classifieds'),
        actions: [
          IconButton(
            tooltip: _showMyAds ? 'Browse ads' : 'My ads',
            onPressed: () => setState(() {
              _showMyAds = !_showMyAds;
              if (_showMyAds) ref.invalidate(myAdsProvider);
            }),
            icon: Icon(
              _showMyAds ? Icons.campaign_outlined : Icons.person_outline,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.localAdCreate),
        icon: const Icon(Icons.add),
        label: const Text('Post an Ad'),
      ),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: RefreshIndicator(
            onRefresh: () async {
              if (_showMyAds) {
                ref.invalidate(myAdsProvider);
              } else {
                await ref.read(localAdsFeedProvider.notifier).load();
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                if (!_showMyAds) ...[
                  const Text(
                    'A nearby noticeboard for work, services and local finds.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _query,
                    decoration: InputDecoration(
                      hintText: 'Search local ads',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                  const SizedBox(height: 10),
                  citiesAsync.when(
                    data: (cities) => DropdownButtonFormField<int?>(
                      initialValue: _cityId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'City'),
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
                      onChanged: (id) {
                        setState(() => _cityId = id);
                        _search();
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, _) => const Text('Cities are unavailable.'),
                  ),
                  const SizedBox(height: 10),
                  LocationPickerButton(
                    area: _area,
                    radiusKm: _radiusKm,
                    onChanged: (choice) {
                      setState(() {
                        _area = choice.area;
                        _radiusKm = choice.radiusKm;
                      });
                      _search();
                    },
                  ),
                  Text(
                    'Ads can be filtered by city and area. Distance filtering is not available yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _categoryId == null,
                            onSelected: (_) {
                              setState(() => _categoryId = null);
                              _search();
                            },
                          ),
                        ),
                        for (final category in categories)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category.name),
                              selected: _categoryId == category.id,
                              onSelected: (_) {
                                setState(() {
                                  _categoryId = _categoryId == category.id
                                      ? null
                                      : category.id;
                                });
                                _search();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if (isLoading && ads.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (error && ads.isEmpty)
                  _error(
                    context,
                    _showMyAds
                        ? 'Could not load your ads.'
                        : 'Could not load classified ads.',
                    () {
                      if (_showMyAds) {
                        ref.invalidate(myAdsProvider);
                      } else {
                        _search();
                      }
                    },
                  )
                else if (ads.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Text(
                      _showMyAds
                          ? 'You have not posted any ads yet.'
                          : 'Nothing posted here yet. Try another category or add the first local listing.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  if (!_showMyAds && featured.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'FEATURED',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 218,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => SizedBox(
                          width: (MediaQuery.sizeOf(context).width - 40)
                              .clamp(220, 310)
                              .toDouble(),
                          child: _featuredCard(context, featured[index]),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    _showMyAds ? 'YOUR ADS' : 'LATEST NEAR YOU',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: LocalAdCard(
                        ad: item,
                        onView: () => context.pushNamed(
                          RouteNames.classifiedDetails,
                          pathParameters: {'id': item.id},
                          extra: ads.firstWhere((ad) => ad.id == item.id),
                        ),
                        onContact: () => _contactUnavailable(context),
                        onEdit: _showMyAds
                            ? () => context.pushNamed(
                                RouteNames.localAdEdit,
                                pathParameters: {'id': item.id},
                                extra: ads.firstWhere((ad) => ad.id == item.id),
                              )
                            : null,
                        onDeactivate: _showMyAds && item.isActive
                            ? () => _deactivate(context, item.id)
                            : null,
                      ),
                    ),
                  if (!_showMyAds && feed!.error != null) Text(feed.error!),
                  if (!_showMyAds && feed!.hasMore)
                    Center(
                      child: TextButton(
                        onPressed: feed.isLoadingMore
                            ? null
                            : () => ref
                                  .read(localAdsFeedProvider.notifier)
                                  .loadMore(),
                        child: feed.isLoadingMore
                            ? const CircularProgressIndicator()
                            : const Text('Load more'),
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

  Widget _featuredCard(BuildContext context, LocalAd ad) => Card(
    child: InkWell(
      onTap: () => context.pushNamed(
        RouteNames.classifiedDetails,
        pathParameters: {'id': ad.id},
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ad.category.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Text(
              ad.title.toUpperCase(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(ad.location, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(ad.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            const Align(alignment: Alignment.centerRight, child: Text('View')),
          ],
        ),
      ),
    ),
  );
  Widget _error(BuildContext context, String message, VoidCallback retry) =>
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(message),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: retry, child: const Text('Try again')),
          ],
        ),
      );
  Future<void> _deactivate(BuildContext context, String id) async {
    try {
      await ref.read(localJobsRepositoryProvider).deactivateAd(id);
      ref.invalidate(myAdsProvider);
      ref.invalidate(localAdsFeedProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not deactivate this ad. Please try again.'),
          ),
        );
      }
    }
  }

  void _contactUnavailable(BuildContext context) =>
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact details are not available for ads yet.'),
        ),
      );
}
