import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../models/job_model.dart';
import 'jobs_api_service.dart';

final jobsRepositoryProvider = Provider<JobsRepository>(
  (ref) => JobsRepositoryImpl(ref.watch(jobsApiServiceProvider)),
);

abstract class JobsRepository {
  Future<List<Job>> fetchJobs({
    String query = '',
    int? categoryId,
    int? cityId,
    String? area,
  });
  Future<PagedResult<JobPost>> fetchJobsPage({
    String query = '',
    int? categoryId,
    int? cityId,
    String? area,
    int page = 1,
    int pageSize = 20,
  });
  Future<Job?> fetchJobById(String id);
}

class JobsRepositoryImpl implements JobsRepository {
  final JobsApiService _apiService;
  const JobsRepositoryImpl(this._apiService);
  @override
  Future<List<Job>> fetchJobs({
    String query = '',
    int? categoryId,
    int? cityId,
    String? area,
  }) async => (await fetchJobsPage(
    query: query,
    categoryId: categoryId,
    cityId: cityId,
    area: area,
  )).items.map(Job.fromPost).toList();
  @override
  Future<PagedResult<JobPost>> fetchJobsPage({
    String query = '',
    int? categoryId,
    int? cityId,
    String? area,
    int page = 1,
    int pageSize = 20,
  }) => _apiService.fetchJobsPage(
    query: query,
    categoryId: categoryId,
    cityId: cityId,
    area: area,
    page: page,
    pageSize: pageSize,
  );
  @override
  Future<Job?> fetchJobById(String id) => _apiService.fetchJobById(id);
}
