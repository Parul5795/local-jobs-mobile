import 'package:equatable/equatable.dart';

enum EmployerJobStatus { active, closed }

extension EmployerJobStatusX on EmployerJobStatus {
  String get label => switch (this) {
    EmployerJobStatus.active => 'Active',
    EmployerJobStatus.closed => 'Closed',
  };

  String get value => name[0].toUpperCase() + name.substring(1);
}

class EmployerJob extends Equatable {
  final String id;
  final String title;
  final String companyName;
  final String category;
  final String location;
  final String jobType;
  final String description;
  final int salaryMin;
  final int salaryMax;
  final String experienceRequired;
  final List<String> skills;
  final String applicationDeadline;
  final EmployerJobStatus status;
  final int applicationCount;
  final String postedAt;

  const EmployerJob({
    required this.id,
    required this.title,
    required this.companyName,
    required this.category,
    required this.location,
    required this.jobType,
    required this.description,
    required this.salaryMin,
    required this.salaryMax,
    required this.experienceRequired,
    required this.skills,
    required this.applicationDeadline,
    required this.status,
    required this.applicationCount,
    required this.postedAt,
  });

  factory EmployerJob.fromJson(Map<String, dynamic> json) {
    return EmployerJob(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      jobType: json['jobType']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      salaryMin: (json['salaryMin'] as num?)?.toInt() ?? 0,
      salaryMax: (json['salaryMax'] as num?)?.toInt() ?? 0,
      experienceRequired: json['experienceRequired']?.toString() ?? '',
      skills: List<String>.from(json['skills'] ?? const []),
      applicationDeadline: json['applicationDeadline']?.toString() ?? '',
      status: json['status']?.toString().toLowerCase() == 'closed'
          ? EmployerJobStatus.closed
          : EmployerJobStatus.active,
      applicationCount: (json['applicationCount'] as num?)?.toInt() ?? 0,
      postedAt: json['postedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'companyName': companyName,
    'category': category,
    'location': location,
    'jobType': jobType,
    'description': description,
    'salaryMin': salaryMin,
    'salaryMax': salaryMax,
    'experienceRequired': experienceRequired,
    'skills': skills,
    'applicationDeadline': applicationDeadline,
    'status': status.value,
    'applicationCount': applicationCount,
    'postedAt': postedAt,
  };

  EmployerJob copyWith({
    String? id,
    String? title,
    String? companyName,
    String? category,
    String? location,
    String? jobType,
    String? description,
    int? salaryMin,
    int? salaryMax,
    String? experienceRequired,
    List<String>? skills,
    String? applicationDeadline,
    EmployerJobStatus? status,
    int? applicationCount,
    String? postedAt,
  }) {
    return EmployerJob(
      id: id ?? this.id,
      title: title ?? this.title,
      companyName: companyName ?? this.companyName,
      category: category ?? this.category,
      location: location ?? this.location,
      jobType: jobType ?? this.jobType,
      description: description ?? this.description,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      experienceRequired: experienceRequired ?? this.experienceRequired,
      skills: skills ?? this.skills,
      applicationDeadline: applicationDeadline ?? this.applicationDeadline,
      status: status ?? this.status,
      applicationCount: applicationCount ?? this.applicationCount,
      postedAt: postedAt ?? this.postedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    companyName,
    category,
    location,
    jobType,
    description,
    salaryMin,
    salaryMax,
    experienceRequired,
    skills,
    applicationDeadline,
    status,
    applicationCount,
    postedAt,
  ];
}
