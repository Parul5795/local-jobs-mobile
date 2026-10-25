import 'package:dio/dio.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_api_service.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_models.dart';

class FakeLocalJobsRepository extends LocalJobsRepository {
  FakeLocalJobsRepository() : super(LocalJobsApiService(Dio()));
  final job = JobPost(
    id: 'job-1',
    title: 'Family Driver Needed',
    description: 'Local driving work',
    salary: 20000,
    categoryId: 1,
    categoryName: 'Driver',
    cityId: 1,
    cityName: 'Pune',
    cityState: 'Maharashtra',
    userId: 'employer-1',
    userName: 'Local family',
    isActive: true,
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
    workType: 'Full-time',
    experienceRequirement: 'Any experience',
    paymentPeriod: 'Monthly',
    startDate: null,
    status: 'Active',
  );
  final worker = WorkerProfile(
    userId: 'worker-1',
    name: 'Rajesh Kumar',
    categoryId: 1,
    categoryName: 'Driver',
    cityId: 1,
    cityName: 'Pune',
    cityState: 'Maharashtra',
    isFresher: false,
    experienceYears: 5,
    experienceDetails: 'Local driving',
    skills: 'City routes',
    interests: 'Personal driver',
    availability: 'Available',
    about: 'Experienced local driver',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 1),
    contactCount: 24,
  );
  @override
  Future<List<LookupItem>> getCategories() async => const [
    LookupItem(id: 1, name: 'Driver'),
    LookupItem(id: 2, name: 'Maid'),
  ];
  @override
  Future<List<CityItem>> getCities() async => const [
    CityItem(id: 1, name: 'Pune', state: 'Maharashtra'),
  ];
  @override
  Future<List<LookupItem>> getAdCategories() async => const [
    LookupItem(id: 1, name: 'Jobs/Work'),
    LookupItem(id: 2, name: 'Services'),
  ];
  @override
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
  }) async {
    final matched =
        keyword == null ||
        keyword.isEmpty ||
        job.title.toLowerCase().contains(keyword.toLowerCase());
    return PagedResult(
      items: matched ? [job] : [],
      page: page,
      pageSize: pageSize,
      totalCount: matched ? 1 : 0,
      totalPages: matched ? 1 : 0,
    );
  }

  @override
  Future<PagedResult<JobPost>> getMyJobs({
    int page = 1,
    int pageSize = 20,
  }) async => PagedResult(
    items: const [],
    page: page,
    pageSize: pageSize,
    totalCount: 0,
    totalPages: 0,
  );
  @override
  Future<PagedResult<WorkerSearchResult>> searchWorkers({
    int? categoryId,
    int? cityId,
    String? area,
    bool? isFresher,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async => PagedResult(
    items: [WorkerSearchResult(worker)],
    page: page,
    pageSize: pageSize,
    totalCount: 1,
    totalPages: 1,
  );
  @override
  Future<PagedResult<ClassifiedAd>> getAds({
    int? cityId,
    int? adCategoryId,
    String? area,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async => PagedResult(
    items: const [],
    page: page,
    pageSize: pageSize,
    totalCount: 0,
    totalPages: 0,
  );
  @override
  Future<PagedResult<ClassifiedAd>> getMyAds({
    int page = 1,
    int pageSize = 20,
  }) async => PagedResult(
    items: const [],
    page: page,
    pageSize: pageSize,
    totalCount: 0,
    totalPages: 0,
  );
  @override
  Future<WorkerProfile?> getMyWorkerProfile() async => null;
}
