import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../models/job_model.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  const JobCard({super.key, required this.job, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (job.isFeatured)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Featured',
                        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.onPrimaryContainer),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(job.company, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16),
                  const SizedBox(width: 4),
                  Expanded(child: Text(job.location, style: theme.textTheme.bodySmall)),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: job.category),
                  _InfoChip(label: job.employmentType),
                  _InfoChip(label: job.experienceLevel),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(job.salary, style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
                  Text(job.postedAt, style: theme.textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}
