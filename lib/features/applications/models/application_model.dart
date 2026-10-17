import 'package:equatable/equatable.dart';
import '../../jobs/models/job_model.dart';
import 'application_status.dart';

class Application extends Equatable {
  final String id;
  final Job job;
  final String userId;
  final ApplicationStatus status;
  final String appliedAt;
  final String? reviewedAt;
  final String? coverLetter;
  final String? applicantName;
  final String? applicantEmail;
  final String? applicantPhone;
  final String? resumeName;

  const Application({
    required this.id,
    required this.job,
    required this.userId,
    required this.status,
    required this.appliedAt,
    this.reviewedAt,
    this.coverLetter,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhone,
    this.resumeName,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      job: Job.fromJson(json['job'] ?? {}),
      userId: json['userId']?.toString() ?? '',
      status: _parseStatus(json['status']),
      appliedAt: json['appliedAt']?.toString() ?? '',
      reviewedAt: json['reviewedAt']?.toString(),
      coverLetter: json['coverLetter']?.toString(),
      applicantName: json['applicantName']?.toString(),
      applicantEmail: json['applicantEmail']?.toString(),
      applicantPhone: json['applicantPhone']?.toString(),
      resumeName: json['resumeName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job': job.toJson(),
      'userId': userId,
      'status': status.value,
      'appliedAt': appliedAt,
      'reviewedAt': reviewedAt,
      'coverLetter': coverLetter,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhone': applicantPhone,
      'resumeName': resumeName,
    };
  }

  Application copyWith({
    String? id,
    Job? job,
    String? userId,
    ApplicationStatus? status,
    String? appliedAt,
    String? reviewedAt,
    String? coverLetter,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhone,
    String? resumeName,
  }) {
    return Application(
      id: id ?? this.id,
      job: job ?? this.job,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      coverLetter: coverLetter ?? this.coverLetter,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      resumeName: resumeName ?? this.resumeName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    job,
    userId,
    status,
    appliedAt,
    reviewedAt,
    coverLetter,
    applicantName,
    applicantEmail,
    applicantPhone,
    resumeName,
  ];
}

ApplicationStatus _parseStatus(dynamic statusValue) {
  if (statusValue is ApplicationStatus) {
    return statusValue;
  }

  final statusString = statusValue?.toString().toLowerCase() ?? '';

  switch (statusString) {
    case 'applied':
      return ApplicationStatus.applied;
    case 'reviewing':
      return ApplicationStatus.reviewing;
    case 'shortlisted':
      return ApplicationStatus.shortlisted;
    case 'rejected':
      return ApplicationStatus.rejected;
    case 'hired':
      return ApplicationStatus.hired;
    default:
      return ApplicationStatus.applied;
  }
}
