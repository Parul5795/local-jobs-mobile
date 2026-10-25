import 'package:equatable/equatable.dart';
import '../../localjobs/models/localjobs_models.dart';

class Job extends Equatable {
  final String id,
      title,
      company,
      location,
      city,
      category,
      description,
      employmentType,
      experienceLevel,
      salary,
      postedAt;
  final bool isFeatured;
  final List<String> skills, requirements;
  final int categoryId, cityId;
  final String userId, paymentPeriod, workType, experienceRequirement, status;
  final double? salaryAmount;
  final DateTime createdAt, updatedAt;
  final DateTime? startDate;
  final bool isActive;
  final String? area;
  Job({
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
    this.categoryId = 0,
    this.cityId = 0,
    this.userId = '',
    this.paymentPeriod = 'Monthly',
    this.workType = '',
    this.experienceRequirement = '',
    this.status = 'Active',
    this.salaryAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.startDate,
    this.isActive = true,
    this.area,
  }) : createdAt =
           createdAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
       updatedAt =
           updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  factory Job.fromJson(Map<String, dynamic> json) =>
      Job.fromPost(JobPost.fromJson(json));
  factory Job.fromPost(JobPost post) => Job(
    id: post.id,
    title: post.title,
    company: post.userName,
    location: post.location,
    city: post.cityName,
    category: post.categoryName,
    description: post.description,
    employmentType: post.workType,
    experienceLevel: post.experienceRequirement,
    salary: post.salaryLabel,
    postedAt: post.postedAt,
    isFeatured: false,
    skills: const [],
    requirements: const [],
    categoryId: post.categoryId,
    cityId: post.cityId,
    userId: post.userId,
    paymentPeriod: post.paymentPeriod,
    workType: post.workType,
    experienceRequirement: post.experienceRequirement,
    status: post.status,
    salaryAmount: post.salary,
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
    startDate: post.startDate,
    isActive: post.isActive,
    area: post.area,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'salary': salaryAmount,
    'categoryId': categoryId,
    'categoryName': category,
    'cityId': cityId,
    'cityName': city,
    'cityState': '',
    'userId': userId,
    'userName': company,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'workType': workType,
    'experienceRequirement': experienceRequirement,
    'paymentPeriod': paymentPeriod,
    'startDate': startDate?.toIso8601String(),
    'status': status,
    'area': area,
  };
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
    categoryId,
    cityId,
    userId,
    paymentPeriod,
    workType,
    experienceRequirement,
    status,
    salaryAmount,
    createdAt,
    updatedAt,
    startDate,
    isActive,
    area,
  ];
}
