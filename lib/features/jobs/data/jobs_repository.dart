import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_model.dart';
import 'jobs_api_service.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  final apiService = ref.watch(jobsApiServiceProvider);
  return JobsRepositoryImpl(apiService);
});

abstract class JobsRepository {
  Future<List<Job>> fetchJobs({String query = '', String category = 'All', String city = 'All'});
  Future<Job?> fetchJobById(String id);
}

class JobsRepositoryImpl implements JobsRepository {
  final JobsApiService _apiService;

  JobsRepositoryImpl(this._apiService);

  @override
  Future<List<Job>> fetchJobs({String query = '', String category = 'All', String city = 'All'}) {
    return _apiService.fetchJobs(query: query, category: category, city: city);
  }

  @override
  Future<Job?> fetchJobById(String id) {
    return _apiService.fetchJobById(id);
  }
}
