import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/job_model.dart';

final jobsApiServiceProvider = Provider<JobsApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JobsApiServiceImpl(apiClient.dio);
});

abstract class JobsApiService {
  Future<List<Job>> fetchJobs({String query = '', String category = 'All', String city = 'All'});
  Future<Job?> fetchJobById(String id);
}

class JobsApiServiceImpl implements JobsApiService {
  final Dio _dio;

  JobsApiServiceImpl(this._dio);

  @override
  Future<List<Job>> fetchJobs({String query = '', String category = 'All', String city = 'All'}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final _ = _dio.options.baseUrl;
    final jobs = _mockJobs.map(Job.fromJson).toList();
    final normalizedQuery = query.trim().toLowerCase();
    final normalizedCategory = category.trim().toLowerCase();
    final normalizedCity = city.trim().toLowerCase();

    return jobs.where((job) {
      final matchesQuery = normalizedQuery.isEmpty ||
          job.title.toLowerCase().contains(normalizedQuery) ||
          job.company.toLowerCase().contains(normalizedQuery) ||
          job.description.toLowerCase().contains(normalizedQuery);
      final matchesCategory = normalizedCategory.isEmpty ||
          normalizedCategory == 'all' ||
          job.category.toLowerCase() == normalizedCategory;
      final matchesCity = normalizedCity.isEmpty ||
          normalizedCity == 'all' ||
          job.city.toLowerCase() == normalizedCity;

      return matchesQuery && matchesCategory && matchesCity;
    }).toList();
  }

  @override
  Future<Job?> fetchJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockJobs.map(Job.fromJson).where((job) => job.id == id).firstOrNull;
  }

  static const List<Map<String, dynamic>> _mockJobs = [
    {
      'id': 'job-1',
      'title': 'Senior Flutter Developer',
      'company': 'Northstar Labs',
      'location': 'Berlin, Germany',
      'city': 'Berlin',
      'category': 'Engineering',
      'description': 'Build polished mobile experiences for a fast-growing AI startup.',
      'employmentType': 'Full-time',
      'experienceLevel': 'Senior',
      'salary': '€85k - €110k',
      'postedAt': '2 hours ago',
      'isFeatured': true,
      'skills': ['Flutter', 'Dart', 'Riverpod', 'Material 3'],
      'requirements': ['5+ years in mobile', 'Production Flutter experience', 'Strong UI craft'],
    },
    {
      'id': 'job-2',
      'title': 'Product Designer',
      'company': 'Beacon Studio',
      'location': 'Munich, Germany',
      'city': 'Munich',
      'category': 'Design',
      'description': 'Shape customer journeys and design systems for a marketplace platform.',
      'employmentType': 'Full-time',
      'experienceLevel': 'Mid',
      'salary': '€65k - €85k',
      'postedAt': '5 hours ago',
      'isFeatured': true,
      'skills': ['Figma', 'Design Systems', 'User Research'],
      'requirements': ['Strong portfolio', 'Product design experience', 'Cross-functional collaboration'],
    },
    {
      'id': 'job-3',
      'title': 'Growth Marketing Manager',
      'company': 'LocalLoop',
      'location': 'Hamburg, Germany',
      'city': 'Hamburg',
      'category': 'Marketing',
      'description': 'Drive user acquisition and lifecycle campaigns across web and mobile.',
      'employmentType': 'Full-time',
      'experienceLevel': 'Mid',
      'salary': '€60k - €78k',
      'postedAt': '1 day ago',
      'isFeatured': false,
      'skills': ['Growth', 'Analytics', 'CRM'],
      'requirements': ['Campaign management', 'Performance marketing', 'Data-driven decisions'],
    },
    {
      'id': 'job-4',
      'title': 'Operations Coordinator',
      'company': 'UrbanWork',
      'location': 'Remote',
      'city': 'Remote',
      'category': 'Operations',
      'description': 'Coordinate delivery operations and support local hiring partners.',
      'employmentType': 'Contract',
      'experienceLevel': 'Entry',
      'salary': '€45k - €55k',
      'postedAt': '3 days ago',
      'isFeatured': false,
      'skills': ['Operations', 'Excel', 'Customer Success'],
      'requirements': ['Organized mindset', 'Strong communication', 'Comfort with ambiguity'],
    },
  ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
