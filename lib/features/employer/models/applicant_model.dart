import 'package:equatable/equatable.dart';
import '../../applications/models/application_status.dart';

class Applicant extends Equatable {
  final String id;
  final String jobId;
  final String applicantName;
  final String email;
  final String phone;
  final String appliedAt;
  final ApplicationStatus status;
  final String? resumeUrl;
  final String? coverLetter;
  final List<String> skills;
  final String experienceSummary;

  const Applicant({
    required this.id,
    required this.jobId,
    required this.applicantName,
    required this.email,
    required this.phone,
    required this.appliedAt,
    required this.status,
    this.resumeUrl,
    this.coverLetter,
    required this.skills,
    required this.experienceSummary,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id']?.toString() ?? '',
      jobId: json['jobId']?.toString() ?? '',
      applicantName: json['applicantName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      appliedAt: json['appliedAt']?.toString() ?? '',
      status: _parseStatus(json['status']),
      resumeUrl: json['resumeUrl']?.toString(),
      coverLetter: json['coverLetter']?.toString(),
      skills: List<String>.from(json['skills'] ?? const []),
      experienceSummary: json['experienceSummary']?.toString() ?? '',
    );
  }

  Applicant copyWith({ApplicationStatus? status}) => Applicant(
    id: id,
    jobId: jobId,
    applicantName: applicantName,
    email: email,
    phone: phone,
    appliedAt: appliedAt,
    status: status ?? this.status,
    resumeUrl: resumeUrl,
    coverLetter: coverLetter,
    skills: skills,
    experienceSummary: experienceSummary,
  );

  @override
  List<Object?> get props => [
    id,
    jobId,
    applicantName,
    email,
    phone,
    appliedAt,
    status,
    resumeUrl,
    coverLetter,
    skills,
    experienceSummary,
  ];
}

ApplicationStatus _parseStatus(dynamic v) {
  switch (v?.toString().toLowerCase()) {
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
