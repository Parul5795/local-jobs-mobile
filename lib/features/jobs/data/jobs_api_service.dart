import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../models/job_model.dart';

final jobsApiServiceProvider = Provider<JobsApiService>(
  (ref) => JobsApiServiceImpl(ref.watch(localJobsRepositoryProvider)),
);

abstract class JobsApiService {
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

class JobsApiServiceImpl implements JobsApiService {
  final LocalJobsRepository _repository;
  const JobsApiServiceImpl(this._repository);
  @override
  Future<PagedResult<JobPost>> fetchJobsPage({
    String query = '',
    int? categoryId,
    int? cityId,
    String? area,
    int page = 1,
    int pageSize = 20,
  }) => _repository.getJobs(
    keyword: query,
    categoryId: categoryId,
    cityId: cityId,
    area: area,
    page: page,
    pageSize: pageSize,
  );
  @override
  Future<Job?> fetchJobById(String id) async {
    try {
      return Job.fromPost(await _repository.getJob(id));
    } catch (_) {
      return null;
    }
  }
}
