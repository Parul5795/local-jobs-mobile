import 'package:flutter/material.dart';
import '../models/local_ad.dart';

class LocalAdCard extends StatelessWidget {
  final LocalAd ad;
  final VoidCallback onView, onContact;
  final VoidCallback? onEdit, onDeactivate;
  const LocalAdCard({
    super.key,
    required this.ad,
    required this.onView,
    required this.onContact,
    this.onEdit,
    this.onDeactivate,
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
              if (ad.imageUrls.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ad.imageUrls.first,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 80,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
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
                [
                  ad.location,
                  ad.postedAt,
                ].where((s) => s.isNotEmpty).join(' · '),
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
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                  if (onDeactivate != null)
                    TextButton.icon(
                      onPressed: onDeactivate,
                      icon: const Icon(Icons.visibility_off_outlined, size: 16),
                      label: const Text('Deactivate'),
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
