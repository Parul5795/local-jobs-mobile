import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_model.dart';
import 'applications_api_service.dart';

final applicationsRepositoryProvider = Provider<ApplicationsRepository>((ref) {
  final apiService = ref.watch(applicationsApiServiceProvider);
  return ApplicationsRepositoryImpl(apiService);
});

abstract class ApplicationsRepository {
  Future<List<Application>> fetchApplications({String? statusFilter});
  Future<Application?> fetchApplicationById(String id);
  Future<void> applyForJob(String jobId);
  Future<Application> createApplication(Application application);
  Future<void> withdrawApplication(String applicationId);
}

class ApplicationsRepositoryImpl implements ApplicationsRepository {
  final ApplicationsApiService _apiService;

  ApplicationsRepositoryImpl(this._apiService);

  @override
  Future<List<Application>> fetchApplications({String? statusFilter}) {
    return _apiService.fetchApplications(statusFilter: statusFilter);
  }

  @override
  Future<Application?> fetchApplicationById(String id) {
    return _apiService.fetchApplicationById(id);
  }

  @override
  Future<void> applyForJob(String jobId) {
    return _apiService.applyForJob(jobId);
  }

  @override
  Future<void> withdrawApplication(String applicationId) {
    return _apiService.withdrawApplication(applicationId);
  }

  @override
  Future<Application> createApplication(Application application) =>
      _apiService.createApplication(application);
}
