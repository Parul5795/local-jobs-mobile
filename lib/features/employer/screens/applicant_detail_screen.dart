import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../applications/models/application_status.dart';
import '../../applications/widgets/application_status_badge.dart';
import '../models/applicant_model.dart';
import '../providers/employer_provider.dart';

class ApplicantDetailScreen extends ConsumerWidget {
  static const String routeName = 'employer-applicant-detail';
  final String applicantId;

  const ApplicantDetailScreen({super.key, required this.applicantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(applicantDetailProvider(applicantId));

    return Scaffold(
      appBar: AppBar(title: const Text('Applicant Profile')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ApplicantMessage(
          title: 'Could not load applicant',
          message: e.toString(),
          onRetry: () => ref.invalidate(applicantDetailProvider(applicantId)),
        ),
        data: (applicant) {
          if (applicant == null) {
            return const _ApplicantMessage(
              title: 'Applicant not found',
              message: 'This applicant may have been removed.',
            );
          }
          return _ApplicantBody(applicant: applicant);
        },
      ),
    );
  }
}

class _ApplicantBody extends ConsumerStatefulWidget {
  final Applicant applicant;

  const _ApplicantBody({required this.applicant});

  @override
  ConsumerState<_ApplicantBody> createState() => _ApplicantBodyState();
}

class _ApplicantBodyState extends ConsumerState<_ApplicantBody> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final applicant = widget.applicant;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile header ──────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryContainer,
                  child: Text(
                    applicant.applicantName.isNotEmpty
                        ? applicant.applicantName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  applicant.applicantName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  applicant.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  applicant.phone,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ApplicationStatusBadge(status: applicant.status, isLarge: true),
              ],
            ),
          ),
          const Divider(height: 32),

          // ── Experience ──────────────────────────────────────────
          _Section(
            title: 'Experience',
            child: Text(
              applicant.experienceSummary,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),

          // ── Skills ──────────────────────────────────────────────
          _Section(
            title: 'Skills',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: applicant.skills.map((s) {
                return Chip(label: Text(s));
              }).toList(),
            ),
          ),

          // ── Cover letter ────────────────────────────────────────
          if (applicant.coverLetter != null &&
              applicant.coverLetter!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _Section(
              title: 'Cover Letter',
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  applicant.coverLetter!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],

          // ── Applied date ────────────────────────────────────────
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16),
              const SizedBox(width: 8),
              Text(
                'Applied ${applicant.appliedAt}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Actions ─────────────────────────────────────────────
          Text(
            'Update Status',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _ActionButton(
            label: 'Shortlist',
            icon: Icons.star_outline,
            color: Colors.orange,
            disabled: applicant.status == ApplicationStatus.shortlisted,
            onTap: () => _updateStatus(ApplicationStatus.shortlisted),
            isLoading: _isUpdating,
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Hire',
            icon: Icons.check_circle_outline,
            color: AppColors.tertiary,
            disabled: applicant.status == ApplicationStatus.hired,
            onTap: () => _updateStatus(ApplicationStatus.hired),
            isLoading: _isUpdating,
          ),
          const SizedBox(height: 10),
          _ActionButton(
            label: 'Reject',
            icon: Icons.cancel_outlined,
            color: AppColors.error,
            disabled: applicant.status == ApplicationStatus.rejected,
            onTap: () => _updateStatus(ApplicationStatus.rejected),
            isLoading: _isUpdating,
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(ApplicationStatus status) async {
    if (_isUpdating) return;
    if (status == ApplicationStatus.rejected ||
        status == ApplicationStatus.hired) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('${status.label} applicant?'),
          content: Text(
            'Update this applicant status to ${status.label.toLowerCase()}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(status.label),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    final applicant = widget.applicant;
    setState(() => _isUpdating = true);
    try {
      await ref
          .read(applicantsProvider(applicant.jobId).notifier)
          .updateStatus(applicant.id, status);
      // Refresh detail
      ref.invalidate(applicantDetailProvider(applicant.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${status.label}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool disabled;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.disabled = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: disabled ? null : color,
          side: BorderSide(color: disabled ? Colors.grey : color),
        ),
        onPressed: disabled || isLoading ? null : onTap,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(isLoading ? 'Updating…' : label),
      ),
    );
  }
}

class _ApplicantMessage extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _ApplicantMessage({
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
          const Icon(Icons.person_search_outlined, size: 48),
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
