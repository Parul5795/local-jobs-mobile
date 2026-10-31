import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../models/local_job.dart';

class LocalJobCard extends StatelessWidget {
  final LocalJob job;
  final VoidCallback onTap;
  const LocalJobCard({super.key, required this.job, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.x2),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: [
              Chip(
                label: Text(job.category),
                visualDensity: VisualDensity.compact,
                backgroundColor: AppColors.primaryLight,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            [
              job.location,
              if (job.distanceKm != null)
                '${job.distanceKm!.toStringAsFixed(1)} km',
            ].join(' · '),
          ),
          const SizedBox(height: 6),
          Text(
            job.pay,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            [
              job.workType,
              job.experience,
            ].where((v) => v.isNotEmpty).join(' · '),
          ),
          const SizedBox(height: 4),
          Text(
            'Posted ${job.postedAt}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: onTap, child: const Text('View')),
          ),
        ],
      ),
    ),
  );
}
