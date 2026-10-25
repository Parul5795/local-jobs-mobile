import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class ClassifiedDetailsScreen extends ConsumerWidget {
  final String adId;
  final ClassifiedAd? initialAd;
  const ClassifiedDetailsScreen({
    super.key,
    required this.adId,
    this.initialAd,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Classified details')),
    bottomNavigationBar: const LocalNavigationBar(selectedIndex: 2),
    body:
        (initialAd == null
                ? ref.watch(adDetailsProvider(adId))
                : AsyncData(initialAd!))
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This classified could not be loaded.'),
                    TextButton(
                      onPressed: () => ref.invalidate(adDetailsProvider(adId)),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
              data: (ad) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (ad.imageUrls.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ad.imageUrls.first,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              height: 160,
                              child: Center(
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                          ),
                        ),
                      Text(
                        ad.title.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text('${ad.location} · ${ad.postedAt}'),
                      const SizedBox(height: 14),
                      Chip(
                        label: Text(ad.categoryName),
                        visualDensity: VisualDensity.compact,
                      ),
                      if (ad.price != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          ad.priceLabel,
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
                        'Posted by ${ad.userName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (ad.imageUrls.length > 1) ...[
                        const SizedBox(height: 16),
                        for (final url in ad.imageUrls.skip(1))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                url,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        'Contact details are not available for classified ads yet.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
  );
}
