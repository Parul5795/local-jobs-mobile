import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/application_status.dart';
import '../providers/applications_provider.dart';
import '../widgets/application_status_badge.dart';

class ApplicationDetailsScreen extends ConsumerWidget {
  static const String routeName = 'application-details';

  final String applicationId;

  const ApplicationDetailsScreen({super.key, required this.applicationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationAsync = ref.watch(
      applicationDetailsProvider(applicationId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Details'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: applicationAsync.when(
        data: (application) {
          if (application == null) {
            return const Center(child: Text('Application not found'));
          }

          final job = application.job;
          final theme = Theme.of(context);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Header
                Text(job.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  job.company,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(job.location)),
                  ],
                ),
                const SizedBox(height: 20),

                // Status Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Application Status',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ApplicationStatusBadge(
                        status: application.status,
                        isLarge: true,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Applied on ${_formatDate(application.appliedAt)}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (application.reviewedAt != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last reviewed on ${_formatDate(application.reviewedAt!)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Job Details
                Text('About this role', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(job.description),
                const SizedBox(height: 20),

                // Job Info
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoCard(
                      icon: Icons.business_center_outlined,
                      label: 'Employment Type',
                      value: job.employmentType,
                    ),
                    _InfoCard(
                      icon: Icons.trending_up_outlined,
                      label: 'Experience Level',
                      value: job.experienceLevel,
                    ),
                    _InfoCard(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: job.category,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Salary
                Text('Salary', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  job.salary,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),

                // Required Skills
                Text('Required skills', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ...job.skills.map(
                  (skill) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, size: 18),
                        const SizedBox(width: 12),
                        Expanded(child: Text(skill)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Requirements
                Text('Requirements', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ...job.requirements.map(
                  (requirement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_right),
                        const SizedBox(width: 8),
                        Expanded(child: Text(requirement)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Cover Letter (if exists)
                if (application.coverLetter != null &&
                    application.coverLetter!.isNotEmpty) ...[
                  Text('Your cover letter', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(application.coverLetter!),
                  ),
                  const SizedBox(height: 20),
                ],
                if (application.applicantName != null ||
                    application.resumeName != null) ...[
                  Text('Submitted with', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (application.applicantName != null)
                    Text('Applicant: ${application.applicantName}'),
                  if (application.applicantEmail != null)
                    Text('Email: ${application.applicantEmail}'),
                  if (application.applicantPhone != null)
                    Text('Phone: ${application.applicantPhone}'),
                  if (application.resumeName != null)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.picture_as_pdf_outlined),
                      title: Text(application.resumeName!),
                      subtitle: const Text('Selected resume'),
                    ),
                  const SizedBox(height: 20),
                ],

                // Action Button
                if (application.status != ApplicationStatus.hired &&
                    application.status != ApplicationStatus.rejected)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        // TODO: Implement withdraw application
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Application withdrawn'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Withdraw Application'),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            const Center(child: Text('Failed to load application details')),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return dateString;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
