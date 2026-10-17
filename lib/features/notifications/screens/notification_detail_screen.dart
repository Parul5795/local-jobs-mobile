import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/app_button.dart';
import '../../jobs/widgets/empty_state.dart';
import '../models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationDetailScreen extends ConsumerWidget {
  static const routeName = 'notification-details';

  final String notificationId;

  const NotificationDetailScreen({super.key, required this.notificationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _LoadError(
          onRetry: () => ref.read(notificationsProvider.notifier).refresh(),
        ),
        data: (items) {
          AppNotification? notification;
          for (final item in items) {
            if (item.id == notificationId) {
              notification = item;
              break;
            }
          }
          if (notification == null) {
            return const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'Notification not found',
              message: 'This notification may no longer be available.',
            );
          }
          return _NotificationDetail(notification: notification);
        },
      ),
    );
  }
}

class _NotificationDetail extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationDetail({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: Icon(_typeIcon(notification.type), size: 28),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      notification.title,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(_typeIcon(notification.type), size: 18),
                          label: Text(notification.type.label),
                        ),
                        Chip(
                          avatar: Icon(
                            notification.isRead
                                ? Icons.mark_email_read_outlined
                                : Icons.mark_email_unread_outlined,
                            size: 18,
                          ),
                          label: Text(notification.isRead ? 'Read' : 'Unread'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (!notification.isRead) ...[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => _markAsRead(context, ref),
                        icon: const Icon(Icons.done),
                        label: const Text('Mark as read'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_actionLabel(notification.target) case final label?) ...[
              const SizedBox(height: 16),
              AppButton(
                text: label,
                onPressed: () => _openAction(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _markAsRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(notificationsProvider.notifier)
          .markAsRead(notification.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification marked as read.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update notification: $error')),
        );
      }
    }
  }

  Future<void> _openAction(BuildContext context, WidgetRef ref) async {
    try {
      if (!notification.isRead) {
        await ref
            .read(notificationsProvider.notifier)
            .markAsRead(notification.id);
      }
      if (!context.mounted) return;
      switch (notification.target) {
        case NotificationTarget.jobs:
          context.pushNamed(RouteNames.jobs);
        case NotificationTarget.applications:
          context.pushNamed(RouteNames.myApplications);
        case NotificationTarget.applicationDetails:
          context.pushNamed(
            RouteNames.applicationDetails,
            pathParameters: {'id': notification.targetId!},
          );
        case NotificationTarget.employerDashboard:
          context.pushNamed(RouteNames.employerDashboard);
        case NotificationTarget.employerJobDetails:
          context.pushNamed(
            RouteNames.employerJobDetails,
            pathParameters: {'id': notification.targetId!},
          );
        case NotificationTarget.employerApplicants:
          context.pushNamed(
            RouteNames.employerApplicants,
            pathParameters: {'jobId': notification.relatedJobId!},
          );
        case NotificationTarget.employerApplicantDetails:
          context.pushNamed(
            RouteNames.employerApplicantDetails,
            pathParameters: {'id': notification.targetId!},
          );
        case NotificationTarget.none:
          break;
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open this action: $error')),
        );
      }
    }
  }
}

class _LoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 16),
          Text(
            'Notification unavailable',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('We couldn’t load this notification. Try again.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

String? _actionLabel(NotificationTarget target) => switch (target) {
  NotificationTarget.none => null,
  NotificationTarget.jobs => 'Browse jobs',
  NotificationTarget.applications => 'View applications',
  NotificationTarget.applicationDetails => 'View application',
  NotificationTarget.employerDashboard => 'Open employer dashboard',
  NotificationTarget.employerJobDetails => 'View job',
  NotificationTarget.employerApplicants => 'View applicants',
  NotificationTarget.employerApplicantDetails => 'View applicant',
};

IconData _typeIcon(NotificationType type) => switch (type) {
  NotificationType.applicationSubmitted => Icons.outgoing_mail,
  NotificationType.applicationStatus => Icons.description_outlined,
  NotificationType.shortlisted => Icons.star_outline,
  NotificationType.rejected => Icons.cancel_outlined,
  NotificationType.hired => Icons.celebration_outlined,
  NotificationType.newApplicant => Icons.person_add_alt_1_outlined,
  NotificationType.jobUpdate => Icons.work_outline,
  NotificationType.newJob => Icons.work_outline,
  NotificationType.general => Icons.notifications_outlined,
};

String _formatTimestamp(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final meridiem = local.hour < 12 ? 'AM' : 'PM';
  return '${months[local.month - 1]} ${local.day}, ${local.year} at $hour:$minute $meridiem';
}
