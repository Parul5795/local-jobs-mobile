import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';

final notificationsApiServiceProvider = Provider<NotificationsApiService>(
  (ref) => NotificationsApiServiceImpl(),
);

abstract class NotificationsApiService {
  Future<List<AppNotification>> fetchNotifications(String role);
  Future<List<AppNotification>> markAsRead(String role, String id);
  Future<List<AppNotification>> markAllAsRead(String role);
}

class NotificationsApiServiceImpl implements NotificationsApiService {
  List<AppNotification>? _jobSeekerNotifications;
  List<AppNotification>? _employerNotifications;

  @override
  Future<List<AppNotification>> fetchNotifications(String role) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final isEmployer = role.toLowerCase().contains('employer');
    final notifications = isEmployer
        ? (_employerNotifications ??= _employerMockData())
        : (_jobSeekerNotifications ??= _jobSeekerMockData());
    return List.unmodifiable(notifications);
  }

  @override
  Future<List<AppNotification>> markAsRead(String role, String id) async {
    final list = _listFor(role);
    final index = list.indexWhere((item) => item.id == id);
    if (index >= 0) list[index] = list[index].copyWith(isRead: true);
    return List.unmodifiable(list);
  }

  @override
  Future<List<AppNotification>> markAllAsRead(String role) async {
    final list = _listFor(role);
    for (var index = 0; index < list.length; index++) {
      list[index] = list[index].copyWith(isRead: true);
    }
    return List.unmodifiable(list);
  }

  List<AppNotification> _listFor(String role) =>
      role.toLowerCase().contains('employer')
      ? _employerNotifications ??= _employerMockData()
      : _jobSeekerNotifications ??= _jobSeekerMockData();

  List<AppNotification> _jobSeekerMockData() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'js-submitted',
        title: 'Application submitted',
        message:
            'Your application for Senior Flutter Developer at Northstar Labs was submitted successfully.',
        createdAt: now.subtract(const Duration(minutes: 8)),
        type: NotificationType.applicationSubmitted,
        target: NotificationTarget.applicationDetails,
        targetId: 'app-1',
        relatedJobId: 'job-1',
      ),
      AppNotification(
        id: 'js-review',
        title: 'Your application is under review',
        message:
            'The hiring team at Beacon Studio is reviewing your Product Designer application.',
        createdAt: now.subtract(const Duration(hours: 3)),
        type: NotificationType.applicationStatus,
        target: NotificationTarget.applicationDetails,
        targetId: 'app-2',
        relatedJobId: 'job-2',
      ),
      AppNotification(
        id: 'js-shortlisted',
        title: 'You have been shortlisted',
        message:
            'Northstar Labs would like to move forward with your application for Senior Flutter Developer.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.shortlisted,
        target: NotificationTarget.applicationDetails,
        targetId: 'app-1',
        relatedJobId: 'job-1',
      ),
      AppNotification(
        id: 'js-rejected',
        title: 'Application update',
        message:
            'The team at Greenline Market has decided to pursue other candidates for the Store Associate role.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.rejected,
        target: NotificationTarget.applicationDetails,
        targetId: 'app-3',
      ),
      AppNotification(
        id: 'js-hired',
        title: 'Congratulations — you got the job!',
        message:
            'Beacon Studio has marked your Product Designer application as hired. Check your application for next steps.',
        createdAt: now.subtract(const Duration(days: 3)),
        type: NotificationType.hired,
        target: NotificationTarget.applicationDetails,
        targetId: 'app-2',
        relatedJobId: 'job-2',
      ),
      AppNotification(
        id: 'js-new-job',
        title: 'A new job matches your interests',
        message:
            'A new Flutter Engineer role in Berlin matches your engineering and mobile development interests.',
        createdAt: now.subtract(const Duration(days: 4)),
        type: NotificationType.newJob,
        target: NotificationTarget.jobs,
      ),
    ];
  }

  List<AppNotification> _employerMockData() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'em-new-applicant',
        title: 'New applicant for Flutter Developer',
        message:
            'Sarah Chen applied for your Flutter Developer role. Review their profile and application.',
        createdAt: now.subtract(const Duration(minutes: 12)),
        type: NotificationType.newApplicant,
        target: NotificationTarget.employerApplicantDetails,
        targetId: 'ap-1',
        relatedJobId: 'ej-1',
      ),
      AppNotification(
        id: 'em-shortlisted',
        title: 'Applicant shortlisted',
        message:
            'Marcus Klein is currently shortlisted for Flutter Developer. Review the applicant pipeline.',
        createdAt: now.subtract(const Duration(hours: 2)),
        type: NotificationType.shortlisted,
        target: NotificationTarget.employerApplicants,
        relatedJobId: 'ej-1',
      ),
      AppNotification(
        id: 'em-rejected',
        title: 'Applicant status updated',
        message:
            'Lea Müller was declined for Product Manager. Your applicant list has been updated.',
        createdAt: now.subtract(const Duration(days: 1)),
        type: NotificationType.rejected,
        target: NotificationTarget.employerApplicants,
        relatedJobId: 'ej-2',
      ),
      AppNotification(
        id: 'em-hired',
        title: 'Hiring milestone reached',
        message:
            'Jonas Weber was hired for Product Manager. View the job to review the updated hiring activity.',
        createdAt: now.subtract(const Duration(days: 2)),
        type: NotificationType.hired,
        target: NotificationTarget.employerJobDetails,
        targetId: 'ej-2',
      ),
      AppNotification(
        id: 'em-job-update',
        title: 'Your job is getting noticed',
        message:
            'Your Flutter Developer listing has received new views. Check the latest applicant activity.',
        createdAt: now.subtract(const Duration(days: 3)),
        type: NotificationType.jobUpdate,
        target: NotificationTarget.employerJobDetails,
        targetId: 'ej-1',
      ),
    ];
  }
}
