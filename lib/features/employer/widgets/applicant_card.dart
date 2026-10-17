import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../applications/widgets/application_status_badge.dart';
import '../models/applicant_model.dart';

class ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final VoidCallback? onTap;

  const ApplicantCard({super.key, required this.applicant, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  applicant.applicantName.isNotEmpty
                      ? applicant.applicantName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.applicantName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Applied ${applicant.appliedAt}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: applicant.skills.take(3).map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(s, style: theme.textTheme.labelSmall),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  ApplicationStatusBadge(status: applicant.status),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
