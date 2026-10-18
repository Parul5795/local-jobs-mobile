import 'package:flutter/material.dart';
import '../models/local_ad.dart';

class LocalAdCard extends StatelessWidget {
  final LocalAd ad;
  final VoidCallback onView;
  final VoidCallback onContact;

  const LocalAdCard({
    super.key,
    required this.ad,
    required this.onView,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onView,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.publisher,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                ad.title.toUpperCase(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${ad.location} · ${ad.postedAt}',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              Text(ad.description),
              if (ad.price.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(ad.price, style: theme.textTheme.titleSmall),
              ],
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(ad.category),
                    visualDensity: VisualDensity.compact,
                  ),
                  TextButton(onPressed: onView, child: const Text('View')),
                  FilledButton.tonal(
                    onPressed: onContact,
                    child: const Text('Contact'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
