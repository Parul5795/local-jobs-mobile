import 'package:equatable/equatable.dart';

enum NotificationType {
  applicationSubmitted,
  applicationStatus,
  shortlisted,
  rejected,
  hired,
  newApplicant,
  jobUpdate,
  newJob,
  general,
}

enum NotificationTarget {
  none,
  jobs,
  applications,
  applicationDetails,
  employerDashboard,
  employerJobDetails,
  employerApplicants,
  employerApplicantDetails,
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final NotificationTarget target;
  final String? targetId;
  final String? relatedJobId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.target = NotificationTarget.none,
    this.targetId,
    this.relatedJobId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    message: message,
    createdAt: createdAt,
    type: type,
    isRead: isRead ?? this.isRead,
    target: target,
    targetId: targetId,
    relatedJobId: relatedJobId,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    createdAt,
    type,
    isRead,
    target,
    targetId,
    relatedJobId,
  ];
}

extension NotificationTypeX on NotificationType {
  String get label => switch (this) {
    NotificationType.applicationSubmitted => 'Application',
    NotificationType.applicationStatus => 'Application update',
    NotificationType.shortlisted => 'Shortlisted',
    NotificationType.rejected => 'Application update',
    NotificationType.hired => 'Congratulations',
    NotificationType.newApplicant => 'New applicant',
    NotificationType.jobUpdate => 'Job update',
    NotificationType.newJob => 'Job match',
    NotificationType.general => 'General',
  };

  String get iconName => switch (this) {
    NotificationType.applicationSubmitted => 'send',
    NotificationType.applicationStatus => 'description',
    NotificationType.shortlisted => 'star',
    NotificationType.rejected => 'cancel',
    NotificationType.hired => 'celebration',
    NotificationType.newApplicant => 'person_add',
    NotificationType.jobUpdate => 'work',
    NotificationType.newJob => 'work',
    NotificationType.general => 'notifications',
  };
}
