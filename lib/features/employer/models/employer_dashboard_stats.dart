import 'package:equatable/equatable.dart';

class EmployerDashboardStats extends Equatable {
  final int activeJobs;
  final int totalApplications;
  final int shortlisted;
  final int hired;

  const EmployerDashboardStats({
    required this.activeJobs,
    required this.totalApplications,
    required this.shortlisted,
    required this.hired,
  });

  @override
  List<Object?> get props => [
    activeJobs,
    totalApplications,
    shortlisted,
    hired,
  ];
}
