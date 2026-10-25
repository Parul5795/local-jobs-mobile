import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exceptions.dart';
import '../models/localjobs_models.dart';
import '../models/localjobs_requests.dart';

final localJobsApiServiceProvider = Provider<LocalJobsApiService>(
  (ref) => LocalJobsApiService(ref.watch(apiClientProvider).dio),
);

class LocalJobsApiService {
  final Dio _dio;
  const LocalJobsApiService(this._dio);

  Future<List<LookupItem>> getCategories() async =>
      _list('/api/categories', LookupItem.fromJson);
  Future<List<CityItem>> getCities() async =>
      _list('/api/cities', CityItem.fromJson);
  Future<List<LookupItem>> getAdCategories() async =>
      _list('/api/ad-categories', LookupItem.fromJson);

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
    final query = _query({
      'keyword': keyword,
      'categoryId': categoryId,
      'cityId': cityId,
      'area': area,
      'workType': workType,
      'experienceRequirement': experienceRequirement,
      'paymentPeriod': paymentPeriod,
      'page': page,
      'pageSize': pageSize,
    });
    final path = query.keys.any((key) => !{'page', 'pageSize'}.contains(key))
        ? '/api/jobs/search'
        : '/api/jobs';
    return _paged(await _get(path, query: query), JobPost.fromJson);
  }

  Future<JobPost> getJob(String id) async =>
      JobPost.fromJson(_map(await _get('/api/jobs/$id')));
  Future<PagedResult<JobPost>> getMyJobs({
    int page = 1,
    int pageSize = 20,
  }) async => _paged(
    await _get('/api/jobs/me', query: {'page': page, 'pageSize': pageSize}),
    JobPost.fromJson,
  );
  Future<JobPost> createJob(JobWriteRequest request) async =>
      JobPost.fromJson(_map(await _post('/api/jobs', request.toJson())));
  Future<JobPost> updateJob(String id, JobWriteRequest request) async =>
      JobPost.fromJson(_map(await _put('/api/jobs/$id', request.toJson())));
  Future<void> deactivateJob(String id) async {
    await _put('/api/jobs/$id/deactivate', null);
  }

  Future<WorkerProfile?> getMyWorkerProfile() async {
    try {
      return WorkerProfile.fromJson(
        _map(await _get('/api/worker-profiles/me')),
      );
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      _rethrow(error);
    }
  }

  Future<WorkerProfile> saveMyWorkerProfile(
    WorkerProfileWriteRequest request,
  ) async => WorkerProfile.fromJson(
    _map(await _put('/api/worker-profiles/me', request.toJson())),
  );
  Future<WorkerProfile> getWorkerProfile(String userId) async =>
      WorkerProfile.fromJson(_map(await _get('/api/worker-profiles/$userId')));
  Future<PagedResult<WorkerSearchResult>> searchWorkers({
    int? categoryId,
    int? cityId,
    String? area,
    bool? isFresher,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = _query({
      'categoryId': categoryId,
      'cityId': cityId,
      'area': area,
      'isFresher': isFresher,
      'keyword': keyword,
      'page': page,
      'pageSize': pageSize,
    });
    return _paged(
      await _get('/api/worker-profiles/search', query: query),
      WorkerSearchResult.fromJson,
    );
  }

  Future<PagedResult<ClassifiedAd>> getAds({
    int? cityId,
    int? adCategoryId,
    String? area,
    String? keyword,
    int page = 1,
    int pageSize = 20,
  }) async {
    final query = _query({
      'cityId': cityId,
      'adCategoryId': adCategoryId,
      'area': area,
      'keyword': keyword,
      'page': page,
      'pageSize': pageSize,
    });
    final path = query.keys.any((key) => !{'page', 'pageSize'}.contains(key))
        ? '/api/ads/search'
        : '/api/ads';
    return _paged(await _get(path, query: query), ClassifiedAd.fromJson);
  }

  Future<ClassifiedAd> getAd(String id) async =>
      ClassifiedAd.fromJson(_map(await _get('/api/ads/$id')));
  Future<PagedResult<ClassifiedAd>> getMyAds({
    int page = 1,
    int pageSize = 20,
  }) async => _paged(
    await _get('/api/ads/me', query: {'page': page, 'pageSize': pageSize}),
    ClassifiedAd.fromJson,
  );
  Future<ClassifiedAd> createAd(AdWriteRequest request) async =>
      ClassifiedAd.fromJson(
        _map(await _post('/api/ads/new', request.toJson())),
      );
  Future<ClassifiedAd> updateAd(String id, AdWriteRequest request) async =>
      ClassifiedAd.fromJson(_map(await _put('/api/ads/$id', request.toJson())));
  Future<void> deactivateAd(String id) async {
    await _put('/api/ads/$id/deactivate', null);
  }

  Future<ContactResult> contactWorker(
    String workerUserId,
    String contactType,
  ) async => ContactResult.fromJson(
    _map(
      await _post(
        '/api/contacts',
        ContactWriteRequest(
          workerUserId: workerUserId,
          method: contactType,
        ).toJson(),
      ),
    ),
  );

  Future<List<T>> _list<T>(
    String path,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final data = await _get(path);
    if (data is! List) {
      throw const FormatException(
        'The server returned an invalid list response.',
      );
    }
    return data
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<dynamic> _get(String path, {Map<String, dynamic>? query}) async {
    try {
      return (await _dio.get<dynamic>(path, queryParameters: query)).data;
    } on DioException catch (error) {
      _rethrow(error);
    }
  }

  Future<dynamic> _post(String path, Object body) async {
    try {
      return (await _dio.post<dynamic>(path, data: body)).data;
    } on DioException catch (error) {
      _rethrow(error);
    }
  }

  Future<dynamic> _put(String path, Object? body) async {
    try {
      return (await _dio.put<dynamic>(path, data: body)).data;
    } on DioException catch (error) {
      _rethrow(error);
    }
  }

  Never _rethrow(DioException error) {
    if (error.error is ApiException) throw error.error! as ApiException;
    throw ApiException(
      'The request could not be completed. Please try again.',
      error.response?.statusCode,
    );
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is! Map) {
      throw const FormatException('The server returned an invalid response.');
    }
    return Map<String, dynamic>.from(data);
  }

  PagedResult<T> _paged<T>(
    dynamic data,
    T Function(Map<String, dynamic>) parse,
  ) => PagedResult<T>.fromJson(_map(data), parse);
  Map<String, dynamic> _query(Map<String, dynamic> values) => {
    for (final entry in values.entries)
      if (entry.value != null && entry.value != '' && entry.value != 0)
        entry.key: entry.value,
  };
}
