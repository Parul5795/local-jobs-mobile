import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/jobs_repository.dart';
import '../models/job_filters.dart';
import '../models/job_model.dart';

final jobsControllerProvider = NotifierProvider<JobsController, JobsState>(JobsController.new);

final jobDetailsProvider = FutureProvider.family<Job?, String>((ref, id) async {
  final repository = ref.watch(jobsRepositoryProvider);
  return repository.fetchJobById(id);
});

class JobsState extends Equatable {
  final List<Job> jobs;
  final bool isLoading;
  final String? error;
  final JobFilters filters;

  const JobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.filters = const JobFilters(),
  });

  JobsState copyWith({
    List<Job>? jobs,
    bool? isLoading,
    String? error,
    JobFilters? filters,
  }) {
    return JobsState(
      jobs: jobs ?? this.jobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [jobs, isLoading, error, filters];
}

class JobsController extends Notifier<JobsState> {
  @override
  JobsState build() {
    return const JobsState();
  }

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(jobsRepositoryProvider);
      final jobs = await repository.fetchJobs(
        query: state.filters.query,
        category: state.filters.category,
        city: state.filters.city,
      );
      state = state.copyWith(jobs: jobs, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> applyFilters({String? query, String? category, String? city}) async {
    final nextFilters = state.filters.copyWith(
      query: query,
      category: category,
      city: city,
    );
    state = state.copyWith(filters: nextFilters);
    await loadJobs();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const JobFilters());
    await loadJobs();
  }
}
