import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/localjobs_models.dart';
import '../models/localjobs_requests.dart';
import 'localjobs_api_service.dart';

final localJobsRepositoryProvider = Provider<LocalJobsRepository>(
  (ref) => LocalJobsRepository(ref.watch(localJobsApiServiceProvider)),
);

class LocalJobsRepository {
  final LocalJobsApiService _service;
  final Map<String, String> _contactPhones = {};
  LocalJobsRepository(this._service);
  Future<List<LookupItem>> getCategories() => _service.getCategories();
  Future<List<CityItem>> getCities() => _service.getCities();
  Future<List<LookupItem>> getAdCategories() => _service.getAdCategories();
  Future<PagedResult<JobPost>> getJobs({
    String? keyword,
    int? categoryId,
    int? cityId,
    String? area,
    String? workType,
    String? experienceRequirement,
    String? paymentPeriod,
    int page = 1,
    int pageSize = 20,
  }) => _service.getJobs(
    keyword: keyword,
    categoryId: categoryId,
    cityId: cityId,
    area: area,
    workType: workType,
    experienceRequirement: experienceRequirement,
    paymentPeriod: paymentPeriod,
    page: page,
    pageSize: pageSize,
  );
  Future<JobPost> getJob(String id) => _service.getJob(id);
  Future<PagedResult<JobPost>> getMyJobs({int page = 1, int pageSize = 20}) =>
      _service.getMyJobs(page: page, pageSize: pageSize);
  Future<JobPost> createJob(JobWriteRequest request) =>
      _service.createJob(request);
  Future<JobPost> updateJob(String id, JobWriteRequest request) =>
      _service.updateJob(id, request);
  Future<void> deactivateJob(String id) => _service.deactivateJob(id);
  Future<WorkerProfile?> getMyWorkerProfile() => _service.getMyWorkerProfile();
  Future<WorkerProfile> saveMyWorkerProfile(
    WorkerProfileWriteRequest request,
  ) => _service.saveMyWorkerProfile(request);
  Future<WorkerProfile> getWorkerProfile(String id) =>
      _service.getWorkerProfile(id);
  Future<PagedResult<WorkerSearchResult>> searchWorkers({
    int? categoryId,
    int? cityId,
    String? area,
    bool? isFresher,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) => _service.searchWorkers(
    categoryId: categoryId,
    cityId: cityId,
    area: area,
    isFresher: isFresher,
    keyword: keyword,
    page: page,
    pageSize: pageSize,
  );
  Future<PagedResult<ClassifiedAd>> getAds({
    int? cityId,
    int? adCategoryId,
    String? area,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) => _service.getAds(
    cityId: cityId,
    adCategoryId: adCategoryId,
    area: area,
    keyword: keyword,
    page: page,
    pageSize: pageSize,
  );
  Future<ClassifiedAd> getAd(String id) => _service.getAd(id);
  Future<PagedResult<ClassifiedAd>> getMyAds({
    int page = 1,
    int pageSize = 20,
  }) => _service.getMyAds(page: page, pageSize: pageSize);
  Future<ClassifiedAd> createAd(AdWriteRequest request) =>
      _service.createAd(request);
  Future<ClassifiedAd> updateAd(String id, AdWriteRequest request) =>
      _service.updateAd(id, request);
  Future<void> deactivateAd(String id) => _service.deactivateAd(id);
  Future<ContactResult> contactWorker(String workerUserId, String type) async {
    final result = await _service.contactWorker(workerUserId, type);
    if (result.phoneNumber.isNotEmpty) {
      _contactPhones[workerUserId] = result.phoneNumber;
    }
    return result;
  }

  String? cachedPhoneForWorker(String workerUserId) =>
      _contactPhones[workerUserId];
}
