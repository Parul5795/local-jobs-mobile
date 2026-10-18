import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../providers/local_ads_provider.dart';

class ClassifiedDetailsScreen extends ConsumerWidget {
  final String adId;
  const ClassifiedDetailsScreen({super.key, required this.adId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ad = ref
        .watch(localAdsProvider)
        .where((item) => item.id == adId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Classified details')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 2),
      body: ad == null
          ? const Center(child: Text('This classified is no longer available.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      ad.title.toUpperCase(),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text('${ad.location} · ${ad.postedAt}'),
                    const SizedBox(height: 14),
                    Chip(
                      label: Text(ad.category),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (ad.price.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        ad.price,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      ad.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Posted by ${ad.publisher}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Contact action is a mock for now.',
                              ),
                            ),
                          ),
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Contact'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
