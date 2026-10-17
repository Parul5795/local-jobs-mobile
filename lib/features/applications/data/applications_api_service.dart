import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/application_model.dart';
import '../models/application_status.dart';

final applicationsApiServiceProvider = Provider<ApplicationsApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ApplicationsApiServiceImpl(apiClient.dio);
});

abstract class ApplicationsApiService {
  Future<List<Application>> fetchApplications({String? statusFilter});
  Future<Application?> fetchApplicationById(String id);
  Future<void> applyForJob(String jobId);
  Future<Application> createApplication(Application application);
  Future<void> withdrawApplication(String applicationId);
}

class ApplicationsApiServiceImpl implements ApplicationsApiService {
  final Dio _dio;
  static final List<Application> _localApplications = [];
  static final Set<String> _withdrawnApplicationIds = {};

  ApplicationsApiServiceImpl(this._dio);

  @override
  Future<List<Application>> fetchApplications({String? statusFilter}) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final _ = _dio.options.baseUrl;
    final applications = [
      ..._mockApplications
          .map(Application.fromJson)
          .where(
            (application) => !_withdrawnApplicationIds.contains(application.id),
          ),
      ..._localApplications,
    ];

    if (statusFilter != null &&
        statusFilter.isNotEmpty &&
        statusFilter.toLowerCase() != 'all') {
      return applications
          .where(
            (app) =>
                app.status.label.toLowerCase() == statusFilter.toLowerCase(),
          )
          .toList();
    }

    return applications;
  }

  @override
  Future<Application?> fetchApplicationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
          ..._mockApplications.map(Application.fromJson),
          ..._localApplications,
        ]
        .where((app) => app.id == id && !_withdrawnApplicationIds.contains(id))
        .firstOrNull;
  }

  @override
  Future<void> applyForJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock implementation - in real app, would call API endpoint
  }

  @override
  Future<Application> createApplication(Application application) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final duplicate = _localApplications.any(
      (item) =>
          item.userId == application.userId &&
          item.job.id == application.job.id,
    );
    if (duplicate) {
      throw StateError('An application for this job already exists.');
    }
    _localApplications.insert(0, application);
    return application;
  }

  @override
  Future<void> withdrawApplication(String applicationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _localApplications.removeWhere(
      (application) => application.id == applicationId,
    );
    _withdrawnApplicationIds.add(applicationId);
  }

  static const List<Map<String, dynamic>> _mockApplications = [
    {
      'id': 'app-1',
      'job': {
        'id': 'job-1',
        'title': 'Senior Flutter Developer',
        'company': 'Northstar Labs',
        'location': 'Berlin, Germany',
        'city': 'Berlin',
        'category': 'Engineering',
        'description':
            'Build polished mobile experiences for a fast-growing AI startup.',
        'employmentType': 'Full-time',
        'experienceLevel': 'Senior',
        'salary': '€85k - €110k',
        'postedAt': '2 hours ago',
        'isFeatured': true,
        'skills': ['Flutter', 'Dart', 'Riverpod', 'Material 3'],
        'requirements': [
          '5+ years in mobile',
          'Production Flutter experience',
          'Strong UI craft',
        ],
      },
      'userId': 'user-123',
      'status': 'Shortlisted',
      'appliedAt': '2024-07-05T10:30:00Z',
      'reviewedAt': '2024-07-06T14:20:00Z',
      'coverLetter': 'I am very interested in this position...',
    },
    {
      'id': 'app-2',
      'job': {
        'id': 'job-2',
        'title': 'Product Designer',
        'company': 'Beacon Studio',
        'location': 'Munich, Germany',
        'city': 'Munich',
        'category': 'Design',
        'description':
            'Shape customer journeys and design systems for a marketplace platform.',
        'employmentType': 'Full-time',
        'experienceLevel': 'Mid',
        'salary': '€65k - €85k',
        'postedAt': '5 hours ago',
        'isFeatured': true,
        'skills': ['Figma', 'Design Systems', 'User Research'],
        'requirements': [
          'Strong portfolio',
          'Product design experience',
          'Cross-functional collaboration',
        ],
      },
      'userId': 'user-123',
      'status': 'Reviewing',
      'appliedAt': '2024-07-08T09:15:00Z',
      'reviewedAt': null,
      'coverLetter': null,
    },
    {
      'id': 'app-3',
      'job': {
        'id': 'job-3',
        'title': 'Growth Marketing Manager',
        'company': 'LocalLoop',
        'location': 'Hamburg, Germany',
        'city': 'Hamburg',
        'category': 'Marketing',
        'description':
            'Drive user acquisition and lifecycle campaigns across web and mobile.',
        'employmentType': 'Full-time',
        'experienceLevel': 'Mid',
        'salary': '€60k - €78k',
        'postedAt': '1 day ago',
        'isFeatured': false,
        'skills': ['Growth', 'Analytics', 'CRM'],
        'requirements': [
          'Campaign management',
          'Performance marketing',
          'Data-driven decisions',
        ],
      },
      'userId': 'user-123',
      'status': 'Applied',
      'appliedAt': '2024-07-10T11:45:00Z',
      'reviewedAt': null,
      'coverLetter': null,
    },
    {
      'id': 'app-4',
      'job': {
        'id': 'job-4',
        'title': 'Operations Coordinator',
        'company': 'UrbanWork',
        'location': 'Remote',
        'city': 'Remote',
        'category': 'Operations',
        'description':
            'Coordinate delivery operations and support local hiring partners.',
        'employmentType': 'Contract',
        'experienceLevel': 'Entry',
        'salary': '€45k - €55k',
        'postedAt': '3 days ago',
        'isFeatured': false,
        'skills': ['Operations', 'Excel', 'Customer Success'],
        'requirements': [
          'Organized mindset',
          'Strong communication',
          'Comfort with ambiguity',
        ],
      },
      'userId': 'user-123',
      'status': 'Rejected',
      'appliedAt': '2024-07-01T14:20:00Z',
      'reviewedAt': '2024-07-03T10:15:00Z',
      'coverLetter': null,
    },
    {
      'id': 'app-5',
      'job': {
        'id': 'job-1',
        'title': 'Senior Flutter Developer',
        'company': 'Northstar Labs',
        'location': 'Berlin, Germany',
        'city': 'Berlin',
        'category': 'Engineering',
        'description':
            'Build polished mobile experiences for a fast-growing AI startup.',
        'employmentType': 'Full-time',
        'experienceLevel': 'Senior',
        'salary': '€85k - €110k',
        'postedAt': '2 hours ago',
        'isFeatured': true,
        'skills': ['Flutter', 'Dart', 'Riverpod', 'Material 3'],
        'requirements': [
          '5+ years in mobile',
          'Production Flutter experience',
          'Strong UI craft',
        ],
      },
      'userId': 'user-123',
      'status': 'Hired',
      'appliedAt': '2024-06-20T08:00:00Z',
      'reviewedAt': '2024-07-09T16:45:00Z',
      'coverLetter': 'Very excited about this opportunity...',
    },
  ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
