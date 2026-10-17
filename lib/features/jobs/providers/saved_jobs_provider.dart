import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/saved_jobs_repository.dart';
import '../models/job_model.dart';

final savedJobsProvider = NotifierProvider<SavedJobsNotifier, SavedJobsState>(
  SavedJobsNotifier.new,
);

class SavedJobsState extends Equatable {
  final List<Job> jobs;
  final bool isLoading;
  final String? error;
  final Set<String> updatingJobIds;

  const SavedJobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.updatingJobIds = const {},
  });

  SavedJobsState copyWith({
    List<Job>? jobs,
    bool? isLoading,
    String? error,
    Set<String>? updatingJobIds,
  }) => SavedJobsState(
    jobs: jobs ?? this.jobs,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    updatingJobIds: updatingJobIds ?? this.updatingJobIds,
  );

  bool contains(String jobId) => jobs.any((job) => job.id == jobId);

  @override
  List<Object?> get props => [jobs, isLoading, error, updatingJobIds];
}

class SavedJobsNotifier extends Notifier<SavedJobsState> {
  String _userId = 'guest';

  @override
  SavedJobsState build() {
    final authState = ref.watch(authStateProvider);
    _userId = authState is Authenticated ? authState.user.id : 'guest';
    Future.microtask(load);
    return const SavedJobsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final jobs = await ref
          .read(savedJobsRepositoryProvider)
          .loadSavedJobs(_userId);
      state = state.copyWith(jobs: jobs, isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> toggle(Job job) async {
    if (state.updatingJobIds.contains(job.id)) return;

    final previousJobs = state.jobs;
    final wasSaved = state.contains(job.id);
    final nextJobs = wasSaved
        ? previousJobs.where((savedJob) => savedJob.id != job.id).toList()
        : [...previousJobs, job];
    final pendingIds = {...state.updatingJobIds, job.id};
    state = state.copyWith(
      jobs: nextJobs,
      updatingJobIds: pendingIds,
      error: null,
    );

    try {
      await ref
          .read(savedJobsRepositoryProvider)
          .saveJobIds(
            _userId,
            nextJobs.map((savedJob) => savedJob.id).toList(),
          );
    } catch (error) {
      state = state.copyWith(jobs: previousJobs, error: error.toString());
      rethrow;
    } finally {
      state = state.copyWith(
        updatingJobIds: {...state.updatingJobIds}..remove(job.id),
      );
    }
  }
}

final savedJobCountProvider = Provider<int>(
  (ref) => ref.watch(savedJobsProvider).jobs.length,
);
