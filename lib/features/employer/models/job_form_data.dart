import 'package:equatable/equatable.dart';

class JobFormData extends Equatable {
  final String title;
  final String description;
  final String companyName;
  final String category;
  final String location;
  final String salaryMin;
  final String salaryMax;
  final String jobType;
  final String experienceRequired;
  final List<String> skills;
  final String applicationDeadline;

  const JobFormData({
    this.title = '',
    this.description = '',
    this.companyName = '',
    this.category = '',
    this.location = '',
    this.salaryMin = '',
    this.salaryMax = '',
    this.jobType = '',
    this.experienceRequired = '',
    this.skills = const [],
    this.applicationDeadline = '',
  });

  JobFormData copyWith({
    String? title,
    String? description,
    String? companyName,
    String? category,
    String? location,
    String? salaryMin,
    String? salaryMax,
    String? jobType,
    String? experienceRequired,
    List<String>? skills,
    String? applicationDeadline,
  }) {
    return JobFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      companyName: companyName ?? this.companyName,
      category: category ?? this.category,
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      jobType: jobType ?? this.jobType,
      experienceRequired: experienceRequired ?? this.experienceRequired,
      skills: skills ?? this.skills,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
    );
  }

  @override
  List<Object?> get props => [
    title,
    description,
    companyName,
    category,
    location,
    salaryMin,
    salaryMax,
    jobType,
    experienceRequired,
    skills,
    applicationDeadline,
  ];
}
