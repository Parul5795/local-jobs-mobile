import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/route_names.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/models/localjobs_requests.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class JobManagementControls extends ConsumerStatefulWidget {
  final JobPost job;
  final bool compact;
  final ValueChanged<JobPost>? onJobChanged;

  const JobManagementControls({
    super.key,
    required this.job,
    this.compact = false,
    this.onJobChanged,
  });

  @override
  ConsumerState<JobManagementControls> createState() =>
      _JobManagementControlsState();
}

class _JobManagementControlsState extends ConsumerState<JobManagementControls> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final isOwner =
        auth is Authenticated &&
        auth.user.role == 'Employer' &&
        auth.user.id == widget.job.userId;
    if (!isOwner) return const SizedBox.shrink();

    final editLabel = widget.compact ? 'Edit' : 'Edit Job';
    final statusLabel = widget.job.isActive
        ? (widget.compact ? 'Deactivate' : 'Deactivate Job')
        : (widget.compact ? 'Reactivate' : 'Reactivate Job');
    final statusIcon = widget.job.isActive
        ? Icons.pause_circle_outline
        : Icons.play_circle_outline;

    return Wrap(
      alignment: widget.compact ? WrapAlignment.end : WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : _edit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(editLabel),
        ),
        widget.job.isActive
            ? OutlinedButton.icon(
                onPressed: _busy ? null : () => _changeStatus(false),
                icon: const Icon(Icons.pause_circle_outline),
                label: Text(statusLabel),
              )
            : FilledButton.icon(
                onPressed: _busy ? null : () => _changeStatus(true),
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(statusIcon),
                label: Text(statusLabel),
              ),
      ],
    );
  }

  Future<void> _edit() async {
    final result = await context.pushNamed(
      RouteNames.employerEditJob,
      pathParameters: {'id': widget.job.id},
      extra: widget.job,
    );
    ref.invalidate(myJobsApiProvider);
    ref.invalidate(localJobsFeedProvider);
    ref.invalidate(jobDetailsApiProvider(widget.job.id));
    ref.invalidate(jobsWorkAdsProvider);
    if (result is JobPost && mounted) widget.onJobChanged?.call(result);
  }

  Future<void> _changeStatus(bool activate) async {
    final clearExpiredStartDate =
        activate &&
        widget.job.startDate != null &&
        DateUtils.dateOnly(
          widget.job.startDate!.toUtc(),
        ).isBefore(DateUtils.dateOnly(DateTime.now().toUtc()));
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(activate ? 'Reactivate this job?' : 'Deactivate this job?'),
        content: Text(
          clearExpiredStartDate
              ? 'This job will appear in active listings again. Its past start date will be cleared.'
              : activate
              ? 'This job will appear in active job listings again.'
              : 'This job will no longer appear in active job listings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(activate ? 'Reactivate' : 'Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final job = widget.job;
      final repository = ref.read(localJobsRepositoryProvider);
      late final JobPost updated;
      if (activate) {
        updated = await repository.updateJob(
          job.id,
          JobWriteRequest(
            title: job.title,
            description: job.description,
            salary: job.salary,
            categoryId: job.categoryId,
            cityId: job.cityId,
            area: job.area,
            workType: job.workType,
            experienceRequirement: job.experienceRequirement,
            paymentPeriod: job.paymentPeriod,
            startDate: clearExpiredStartDate ? null : job.startDate,
            isActive: true,
          ),
        );
      } else {
        await repository.deactivateJob(job.id);
        updated = _withActiveState(job, false);
      }
      ref.invalidate(myJobsApiProvider);
      ref.invalidate(localJobsFeedProvider);
      ref.invalidate(jobDetailsApiProvider(job.id));
      ref.invalidate(jobsWorkAdsProvider);
      widget.onJobChanged?.call(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              clearExpiredStartDate
                  ? 'Job reactivated. The past start date was cleared.'
                  : activate
                  ? 'Job reactivated.'
                  : 'Job deactivated.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              activate
                  ? 'Could not reactivate the job. Please try again.'
                  : 'Could not deactivate the job. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

JobPost _withActiveState(JobPost job, bool isActive) => JobPost(
  id: job.id,
  title: job.title,
  description: job.description,
  salary: job.salary,
  categoryId: job.categoryId,
  categoryName: job.categoryName,
  cityId: job.cityId,
  cityName: job.cityName,
  cityState: job.cityState,
  userId: job.userId,
  userName: job.userName,
  isActive: isActive,
  createdAt: job.createdAt,
  updatedAt: DateTime.now().toUtc(),
  workType: job.workType,
  experienceRequirement: job.experienceRequirement,
  paymentPeriod: job.paymentPeriod,
  startDate: job.startDate,
  status: isActive ? 'Active' : 'Inactive',
  area: job.area,
);
