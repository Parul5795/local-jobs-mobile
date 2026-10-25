import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exceptions.dart';
import '../data/jobs_repository.dart';
import '../models/job_filters.dart';
import '../models/job_model.dart';
import '../../localjobs/data/localjobs_repository.dart';

final jobsControllerProvider = NotifierProvider<JobsController, JobsState>(
  JobsController.new,
);
final jobDetailsProvider = FutureProvider.family<Job?, String>(
  (ref, id) => ref.watch(jobsRepositoryProvider).fetchJobById(id),
);

class JobsState extends Equatable {
  final List<Job> jobs;
  final bool isLoading, isLoadingMore;
  final String? error;
  final JobFilters filters;
  final int page, totalCount, totalPages;
  const JobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filters = const JobFilters(),
    this.page = 0,
    this.totalCount = 0,
    this.totalPages = 0,
  });
  bool get hasMore => page < totalPages;
  JobsState copyWith({
    List<Job>? jobs,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    JobFilters? filters,
    int? page,
    int? totalCount,
    int? totalPages,
  }) => JobsState(
    jobs: jobs ?? this.jobs,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
    filters: filters ?? this.filters,
    page: page ?? this.page,
    totalCount: totalCount ?? this.totalCount,
    totalPages: totalPages ?? this.totalPages,
  );
  @override
  List<Object?> get props => [
    jobs,
    isLoading,
    isLoadingMore,
    error,
    filters,
    page,
    totalCount,
    totalPages,
  ];
}

class JobsController extends Notifier<JobsState> {
  @override
  JobsState build() => const JobsState();
  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: state.jobs.isEmpty, error: null);
    try {
      final page = await ref
          .read(jobsRepositoryProvider)
          .fetchJobsPage(
            query: state.filters.query,
            categoryId: state.filters.categoryId,
            cityId: state.filters.cityId,
            area: state.filters.area,
            page: 1,
          );
      state = JobsState(
        jobs: page.items.map(Job.fromPost).toList(),
        filters: state.filters,
        page: page.page,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: _errorMessage(error));
    }
  }

  Future<void> applyFilters({
    String? query,
    String? category,
    String? city,
    int? categoryId,
    int? cityId,
    String? area,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearArea = false,
  }) async {
    if (category != null) {
      final values = await ref
          .read(localJobsRepositoryProvider)
          .getCategories();
      categoryId = values
          .where((item) => item.name == category)
          .firstOrNull
          ?.id;
      clearCategory = category == 'All' || categoryId == null;
    }
    if (city != null) {
      final values = await ref.read(localJobsRepositoryProvider).getCities();
      cityId = values
          .where(
            (item) =>
                '${item.name}, ${item.state}' == city || item.name == city,
          )
          .firstOrNull
          ?.id;
      clearCity = city == 'All' || cityId == null;
    }
    state = state.copyWith(
      filters: state.filters.copyWith(
        query: query,
        category: category,
        city: city,
        categoryId: categoryId,
        cityId: cityId,
        area: area,
        clearCategory: clearCategory,
        clearCity: clearCity,
        clearArea: clearArea,
      ),
    );
    state = JobsState(filters: state.filters, isLoading: true);
    await loadJobs();
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await ref
          .read(jobsRepositoryProvider)
          .fetchJobsPage(
            query: state.filters.query,
            categoryId: state.filters.categoryId,
            cityId: state.filters.cityId,
            area: state.filters.area,
            page: state.page + 1,
          );
      state = JobsState(
        jobs: [...state.jobs, ...page.items.map(Job.fromPost)],
        filters: state.filters,
        page: page.page,
        totalCount: page.totalCount,
        totalPages: page.totalPages,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: _errorMessage(error));
    }
  }

  Future<void> clearFilters() => applyFilters(
    query: '',
    clearCategory: true,
    clearCity: true,
    clearArea: true,
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

String _errorMessage(Object error) => error is ApiException
    ? error.message
    : 'Could not load jobs. Please try again.';
