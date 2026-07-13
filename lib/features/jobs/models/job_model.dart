import 'package:equatable/equatable.dart';

class Job extends Equatable {
  final String id;
  final String title;
  final String company;
  final String location;
  final String city;
  final String category;
  final String description;
  final String employmentType;
  final String experienceLevel;
  final String salary;
  final String postedAt;
  final bool isFeatured;
  final List<String> skills;
  final List<String> requirements;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.city,
    required this.category,
    required this.description,
    required this.employmentType,
    required this.experienceLevel,
    required this.salary,
    required this.postedAt,
    required this.isFeatured,
    required this.skills,
    required this.requirements,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      employmentType: json['employmentType']?.toString() ?? '',
      experienceLevel: json['experienceLevel']?.toString() ?? '',
      salary: json['salary']?.toString() ?? '',
      postedAt: json['postedAt']?.toString() ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      skills: List<String>.from(json['skills'] ?? const []),
      requirements: List<String>.from(json['requirements'] ?? const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'city': city,
      'category': category,
      'description': description,
      'employmentType': employmentType,
      'experienceLevel': experienceLevel,
      'salary': salary,
      'postedAt': postedAt,
      'isFeatured': isFeatured,
      'skills': skills,
      'requirements': requirements,
    };
  }

  Job copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? city,
    String? category,
    String? description,
    String? employmentType,
    String? experienceLevel,
    String? salary,
    String? postedAt,
    bool? isFeatured,
    List<String>? skills,
    List<String>? requirements,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      city: city ?? this.city,
      category: category ?? this.category,
      description: description ?? this.description,
      employmentType: employmentType ?? this.employmentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      salary: salary ?? this.salary,
      postedAt: postedAt ?? this.postedAt,
      isFeatured: isFeatured ?? this.isFeatured,
      skills: skills ?? this.skills,
      requirements: requirements ?? this.requirements,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        company,
        location,
        city,
        category,
        description,
        employmentType,
        experienceLevel,
        salary,
        postedAt,
        isFeatured,
        skills,
        requirements,
      ];
}
