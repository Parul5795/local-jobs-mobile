import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../models/employer_job_model.dart';
import '../providers/employer_provider.dart';

class EmployerJobDetailScreen extends ConsumerWidget {
  static const String routeName = 'employer-job-detail';
  final String jobId;

  const EmployerJobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(employerJobDetailProvider(jobId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.pushNamed(
              'employer-edit-job',
              pathParameters: {'id': jobId},
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _DetailMessage(
          title: 'Could not load this job',
          message: e.toString(),
          onRetry: () => ref.invalidate(employerJobDetailProvider(jobId)),
        ),
        data: (job) {
          if (job == null) {
            return const _DetailMessage(
              title: 'Job not found',
              message: 'This job may have been removed.',
            );
          }
          return _JobDetailBody(job: job);
        },
      ),
    );
  }
}

class _JobDetailBody extends ConsumerStatefulWidget {
  final EmployerJob job;

  const _JobDetailBody({required this.job});

  @override
  ConsumerState<_JobDetailBody> createState() => _JobDetailBodyState();
}

class _JobDetailBodyState extends ConsumerState<_JobDetailBody> {
  String? _operation;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);
    final isActive = job.status == EmployerJobStatus.active;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.tertiaryContainer
                      : AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  job.status.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isActive
                        ? AppColors.onTertiaryContainer
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            job.companyName,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          // ── Meta row ─────────────────────────────────────────────
          _MetaRow(icon: Icons.location_on_outlined, label: job.location),
          const SizedBox(height: 6),
          _MetaRow(icon: Icons.work_outline, label: job.jobType),
          const SizedBox(height: 6),
          _MetaRow(icon: Icons.school_outlined, label: job.experienceRequired),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.euro_outlined,
            label:
                '€${job.salaryMin.toString()} – €${job.salaryMax.toString()}',
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: 'Deadline: ${job.applicationDeadline}',
          ),
          const SizedBox(height: 6),
          _MetaRow(
            icon: Icons.people_outline,
            label: '${job.applicationCount} applicants',
          ),
          const Divider(height: 32),

          // ── Description ──────────────────────────────────────────
          Text(
            'Description',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(job.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),

          // ── Skills ───────────────────────────────────────────────
          Text(
            'Skills',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.skills.map((s) {
              return Chip(label: Text(s));
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ── Actions ──────────────────────────────────────────────
          FilledButton.icon(
            onPressed: () => context.pushNamed(
              'employer-applicants',
              pathParameters: {'jobId': job.id},
            ),
            icon: const Icon(Icons.people_outline),
            label: Text('View Applicants (${job.applicationCount})'),
          ),
          const SizedBox(height: 12),
          if (isActive)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _operation == null ? _confirmClose : null,
                icon: const Icon(Icons.close_outlined),
                label: _operation == 'close'
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Close this Job'),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: _operation == null ? _confirmDelete : null,
              icon: const Icon(Icons.delete_outline),
              label: _operation == 'delete'
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Delete Job'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClose() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Close Job'),
        content: const Text(
          'This will stop accepting new applications. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close Job'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _runOperation('close');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Job'),
        content: const Text(
          'This action cannot be undone. All applicant data will also be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _runOperation('delete');
    }
  }

  Future<void> _runOperation(String operation) async {
    setState(() => _operation = operation);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final notifier = ref.read(employerJobsProvider.notifier);
      if (operation == 'close') {
        await notifier.closeJob(widget.job.id);
      } else {
        await notifier.deleteJob(widget.job.id);
      }
      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(operation == 'close' ? 'Job closed.' : 'Job deleted.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _operation = null);
      messenger.showSnackBar(
        SnackBar(content: Text('Could not $operation job: $error')),
      );
    }
  }
}

class _DetailMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _DetailMessage({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_off_outlined, size: 48),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
