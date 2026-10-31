import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../data/localjobs_repository.dart';
import '../models/localjobs_models.dart';

final categoriesProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(localJobsRepositoryProvider).getCategories(),
);
final citiesProvider = FutureProvider<List<CityItem>>(
  (ref) => ref.watch(localJobsRepositoryProvider).getCities(),
);
final adCategoriesProvider = FutureProvider<List<LookupItem>>(
  (ref) => ref.watch(localJobsRepositoryProvider).getAdCategories(),
);
final myWorkerProfileProvider = FutureProvider<WorkerProfile?>(
  (ref) => ref.watch(localJobsRepositoryProvider).getMyWorkerProfile(),
);
final publicWorkerProfileProvider =
    FutureProvider.family<WorkerProfile, String>(
      (ref, id) => ref.watch(localJobsRepositoryProvider).getWorkerProfile(id),
    );
final homeWorkerPreviewProvider =
    FutureProvider.family<PagedResult<WorkerSearchResult>, bool>(
      (ref, employer) => employer
          ? ref.watch(localJobsRepositoryProvider).searchWorkers(pageSize: 5)
          : const PagedResult(
              items: [],
              page: 1,
              pageSize: 5,
              totalCount: 0,
              totalPages: 0,
            ),
    );
final jobDetailsApiProvider = FutureProvider.family<JobPost, String>(
  (ref, id) => ref.watch(localJobsRepositoryProvider).getJob(id),
);
final adDetailsProvider = FutureProvider.family<ClassifiedAd, String>(
  (ref, id) => ref.watch(localJobsRepositoryProvider).getAd(id),
);
final myJobsApiProvider = FutureProvider<PagedResult<JobPost>>(
  (ref) => ref.watch(localJobsRepositoryProvider).getMyJobs(pageSize: 100),
);
typedef JobsWorkAdsQuery = ({String keyword, int? cityId, String area});

final jobsWorkAdsProvider = FutureProvider.autoDispose
    .family<PagedResult<JobPost>, JobsWorkAdsQuery>((ref, query) {
      return ref
          .watch(localJobsRepositoryProvider)
          .getJobs(
            keyword: query.keyword,
            cityId: query.cityId,
            area: query.area,
            pageSize: 100,
          );
    });
final myAdsProvider = FutureProvider<PagedResult<ClassifiedAd>>(
  (ref) => ref.watch(localJobsRepositoryProvider).getMyAds(pageSize: 100),
);

class PagedItemsState<T> {
  final List<T> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page, pageSize, totalCount, totalPages;
  const PagedItemsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 0,
    this.pageSize = 20,
    this.totalCount = 0,
    this.totalPages = 0,
  });
  bool get hasMore => page < totalPages;
  PagedItemsState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? totalCount,
    int? totalPages,
  }) => PagedItemsState<T>(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
    page: page ?? this.page,
    pageSize: pageSize,
    totalCount: totalCount ?? this.totalCount,
    totalPages: totalPages ?? this.totalPages,
  );
}

final localJobsFeedProvider =
    NotifierProvider<LocalJobsFeedNotifier, PagedItemsState<JobPost>>(
      LocalJobsFeedNotifier.new,
    );

class LocalJobsFeedNotifier extends Notifier<PagedItemsState<JobPost>> {
  String _keyword = '',
      _area = '',
      _workType = '',
      _experience = '',
      _paymentPeriod = '';
  int? _categoryId, _cityId;
  @override
  PagedItemsState<JobPost> build() {
    Future.microtask(load);
    return const PagedItemsState(isLoading: true);
  }

  Future<void> search({
    String? keyword,
    int? categoryId,
    int? cityId,
    String? area,
    String? workType,
    String? experienceRequirement,
    String? paymentPeriod,
  }) async {
    _keyword = keyword ?? _keyword;
    _categoryId = categoryId;
    _cityId = cityId;
    _area = area ?? '';
    _workType = workType ?? '';
    _experience = experienceRequirement ?? '';
    _paymentPeriod = paymentPeriod ?? '';
    state = const PagedItemsState(isLoading: true);
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: state.items.isEmpty, error: null);
    try {
      final page = await ref
          .read(localJobsRepositoryProvider)
          .getJobs(
            keyword: _keyword,
            categoryId: _categoryId,
            cityId: _cityId,
            area: _area,
            workType: _workType,
            experienceRequirement: _experience,
            paymentPeriod: _paymentPeriod,
            page: 1,
          );
      state = PagedItemsState(
        items: page.items,
        page: page.page,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _message(error));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final result = await ref
          .read(localJobsRepositoryProvider)
          .getJobs(
            keyword: _keyword,
            categoryId: _categoryId,
            cityId: _cityId,
            area: _area,
            workType: _workType,
            experienceRequirement: _experience,
            paymentPeriod: _paymentPeriod,
            page: state.page + 1,
          );
      state = PagedItemsState(
        items: [...state.items, ...result.items],
        page: result.page,
        pageSize: result.pageSize,
        totalCount: result.totalCount,
        totalPages: result.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: _message(error));
    }
  }
}

final workerSearchProvider =
    NotifierProvider<WorkerSearchNotifier, PagedItemsState<WorkerSearchResult>>(
      WorkerSearchNotifier.new,
    );

class WorkerSearchNotifier
    extends Notifier<PagedItemsState<WorkerSearchResult>> {
  String _keyword = '', _area = '';
  int? _categoryId, _cityId;
  bool? _isFresher;
  @override
  PagedItemsState<WorkerSearchResult> build() => const PagedItemsState();
  Future<void> search({
    String? keyword,
    int? categoryId,
    int? cityId,
    String? area,
    bool? isFresher,
  }) async {
    _keyword = keyword ?? '';
    _categoryId = categoryId;
    _cityId = cityId;
    _area = area ?? '';
    _isFresher = isFresher;
    state = const PagedItemsState(isLoading: true);
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: state.items.isEmpty, error: null);
    try {
      final page = await ref
          .read(localJobsRepositoryProvider)
          .searchWorkers(
            keyword: _keyword,
            categoryId: _categoryId,
            cityId: _cityId,
            area: _area,
            isFresher: _isFresher,
          );
      state = PagedItemsState(
        items: page.items,
        page: page.page,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _message(error));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await ref
          .read(localJobsRepositoryProvider)
          .searchWorkers(
            keyword: _keyword,
            categoryId: _categoryId,
            cityId: _cityId,
            area: _area,
            isFresher: _isFresher,
            page: state.page + 1,
          );
      state = PagedItemsState(
        items: [...state.items, ...page.items],
        page: page.page,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: _message(error));
    }
  }
}

final localAdsFeedProvider =
    NotifierProvider<LocalAdsFeedNotifier, PagedItemsState<ClassifiedAd>>(
      LocalAdsFeedNotifier.new,
    );

class LocalAdsFeedNotifier extends Notifier<PagedItemsState<ClassifiedAd>> {
  String _keyword = '', _area = '';
  int? _cityId, _categoryId;
  @override
  PagedItemsState<ClassifiedAd> build() {
    Future.microtask(load);
    return const PagedItemsState(isLoading: true);
  }

  Future<void> search({
    String? keyword,
    int? cityId,
    int? categoryId,
    String? area,
  }) async {
    _keyword = keyword ?? '';
    _cityId = cityId;
    _categoryId = categoryId;
    _area = area ?? '';
    state = const PagedItemsState(isLoading: true);
    await load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: state.items.isEmpty, error: null);
    try {
      final page = await ref
          .read(localJobsRepositoryProvider)
          .getAds(
            keyword: _keyword,
            cityId: _cityId,
            adCategoryId: _categoryId,
            area: _area,
          );
      state = PagedItemsState(
        items: page.items,
        page: page.page,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _message(error));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await ref
          .read(localJobsRepositoryProvider)
          .getAds(
            keyword: _keyword,
            cityId: _cityId,
            adCategoryId: _categoryId,
            area: _area,
            page: state.page + 1,
          );
      state = PagedItemsState(
        items: [...state.items, ...page.items],
        page: page.page,
        pageSize: page.pageSize,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: _message(error));
    }
  }
}

String _message(Object error) => error is ApiException
    ? error.message
    : error is FormatException
    ? 'The server returned an unexpected response.'
    : 'Something went wrong. Please try again.';
