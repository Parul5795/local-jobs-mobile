import 'package:dio/dio.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_api_service.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_models.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_requests.dart';

class FakeLocalJobsRepository extends LocalJobsRepository {
  FakeLocalJobsRepository() : super(LocalJobsApiService(Dio()));
  JobPost job = JobPost(
    id: 'job-1',
    title: 'Family Driver Needed',
    description: 'Local driving work',
    salary: 20000,
    categoryId: 1,
    categoryName: 'Driver',
    cityId: 1,
    cityName: 'Pune',
    cityState: 'Maharashtra',
    userId: 'test-',
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
  final List<JobPost> ownJobs = [];
  JobWriteRequest? lastJobUpdateRequest;
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
        job.isActive &&
        (keyword == null ||
            keyword.isEmpty ||
            job.title.toLowerCase().contains(keyword.toLowerCase()));
    return PagedResult(
      items: matched ? [job] : [],
      page: page,
      pageSize: pageSize,
      totalCount: matched ? 1 : 0,
      totalPages: matched ? 1 : 0,
    );
  }

  @override
  Future<JobPost> getJob(String id) async {
    if (job.id == id && job.isActive) return job;
    throw StateError('Job not found');
  }

  @override
  Future<PagedResult<JobPost>> getMyJobs({
    int page = 1,
    int pageSize = 20,
  }) async => PagedResult(
    items: ownJobs,
    page: page,
    pageSize: pageSize,
    totalCount: ownJobs.length,
    totalPages: ownJobs.isEmpty ? 0 : 1,
  );

  @override
  Future<JobPost> updateJob(String id, JobWriteRequest request) async {
    lastJobUpdateRequest = request;
    final current = ownJobs.where((item) => item.id == id).firstOrNull ?? job;
    final updated = JobPost(
      id: current.id,
      title: request.title,
      description: request.description,
      salary: request.salary,
      categoryId: request.categoryId,
      categoryName: current.categoryName,
      cityId: request.cityId,
      cityName: current.cityName,
      cityState: current.cityState,
      userId: current.userId,
      userName: current.userName,
      isActive: request.isActive ?? current.isActive,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
      workType: request.workType,
      experienceRequirement: request.experienceRequirement,
      paymentPeriod: request.paymentPeriod,
      startDate: request.startDate,
      status: request.isActive == true ? 'Active' : 'Inactive',
      area: request.area,
    );
    if (job.id == id) job = updated;
    final index = ownJobs.indexWhere((item) => item.id == id);
    if (index >= 0) ownJobs[index] = updated;
    return updated;
  }

  @override
  Future<void> deactivateJob(String id) async {
    final current = ownJobs.where((item) => item.id == id).firstOrNull ?? job;
    await updateJob(
      id,
      JobWriteRequest(
        title: current.title,
        description: current.description,
        salary: current.salary,
        categoryId: current.categoryId,
        cityId: current.cityId,
        area: current.area,
        workType: current.workType,
        experienceRequirement: current.experienceRequirement,
        paymentPeriod: current.paymentPeriod,
        startDate: current.startDate,
        isActive: false,
      ),
    );
  }

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
