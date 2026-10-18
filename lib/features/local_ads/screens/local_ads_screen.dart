import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../local_discovery/models/local_job.dart';
import '../../local_discovery/providers/local_jobs_provider.dart';
import '../models/local_ad.dart';
import '../providers/local_ads_provider.dart';
import '../widgets/local_ad_card.dart';

class LocalAdsScreen extends ConsumerStatefulWidget {
  const LocalAdsScreen({super.key});
  @override
  ConsumerState<LocalAdsScreen> createState() => _LocalAdsScreenState();
}

class _LocalAdsScreenState extends ConsumerState<LocalAdsScreen> {
  static const _categories = [
    'All',
    'Jobs / Work',
    'Services',
    'Business',
    'Sale',
    'Tuition',
    'House',
    'Vehicle',
    'Other',
  ];
  String _category = 'All';

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(localAdsProvider);
    final jobs = ref.watch(localJobsProvider);
    final adItems = ads.map((ad) => _ClassifiedItem(ad: ad));
    final jobItems = jobs.map((job) => _ClassifiedItem(job: job));
    final all = [...adItems, ...jobItems];
    final filtered = all
        .where((item) => _category == 'All' || item.category == _category)
        .toList();
    final featured = filtered
        .where((item) => item.ad?.featured ?? false)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Local Classifieds')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.localAdCreate),
        icon: const Icon(Icons.add),
        label: const Text('Post an Ad'),
      ),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              const Text(
                'A nearby noticeboard for work, services and local finds.',
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final category in _categories)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                      ),
                  ],
                ),
              ),
              if (featured.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'FEATURED',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: .6,
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
                'LATEST NEAR YOU',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 8),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 42,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nothing posted here yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Try another category or add the first local listing.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.pushNamed(RouteNames.localAdCreate),
                        icon: const Icon(Icons.add),
                        label: const Text('Post an Ad'),
                      ),
                    ],
                  ),
                ),
              for (final item in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _card(context, item),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, _ClassifiedItem item) => LocalAdCard(
    ad: item.toAd(),
    onView: () {
      if (item.job != null) {
        context.pushNamed(
          RouteNames.localJobDetails,
          pathParameters: {'id': item.job!.id},
        );
      } else {
        context.pushNamed(
          RouteNames.classifiedDetails,
          pathParameters: {'id': item.ad!.id},
        );
      }
    },
    onContact: () => ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact action is a mock for now.')),
    ),
  );

  Widget _featuredCard(BuildContext context, _ClassifiedItem item) {
    final ad = item.toAd();
    return Card(
      child: InkWell(
        onTap: () => _openItem(context, item),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.category.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                ad.title.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '${ad.location} · ${ad.postedAt}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 6),
              Text(
                ad.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _openItem(context, item),
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openItem(BuildContext context, _ClassifiedItem item) {
    if (item.job != null) {
      context.pushNamed(
        RouteNames.localJobDetails,
        pathParameters: {'id': item.job!.id},
      );
    } else {
      context.pushNamed(
        RouteNames.classifiedDetails,
        pathParameters: {'id': item.ad!.id},
      );
    }
  }
}

class _ClassifiedItem {
  final LocalAd? ad;
  final LocalJob? job;
  const _ClassifiedItem({this.ad, this.job});

  String get category => ad?.category ?? 'Jobs / Work';

  LocalAd toAd() =>
      ad ??
      LocalAd(
        id: job!.id,
        publisher: job!.employer,
        location: job!.location,
        type: 'Work opportunity',
        title: job!.title,
        description: job!.description,
        postedAt: job!.postedAt,
        contact: job!.contact,
        price: job!.pay,
      );
}
