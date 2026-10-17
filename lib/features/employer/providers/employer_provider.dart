import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../applications/models/application_status.dart';
import '../data/employer_repository.dart';
import '../models/applicant_model.dart';
import '../models/employer_dashboard_stats.dart';
import '../models/employer_job_model.dart';
import '../models/job_form_data.dart';

// ── Dashboard ────────────────────────────────────────────────────────────────

final employerDashboardProvider =
    NotifierProvider<EmployerDashboardNotifier, EmployerDashboardState>(
      EmployerDashboardNotifier.new,
    );

class EmployerDashboardState extends Equatable {
  final EmployerDashboardStats? stats;
  final List<EmployerJob> recentJobs;
  final bool isLoading;
  final String? error;

  const EmployerDashboardState({
    this.stats,
    this.recentJobs = const [],
    this.isLoading = false,
    this.error,
  });

  EmployerDashboardState copyWith({
    EmployerDashboardStats? stats,
    List<EmployerJob>? recentJobs,
    bool? isLoading,
    String? error,
  }) => EmployerDashboardState(
    stats: stats ?? this.stats,
    recentJobs: recentJobs ?? this.recentJobs,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  @override
  List<Object?> get props => [stats, recentJobs, isLoading, error];
}

class EmployerDashboardNotifier extends Notifier<EmployerDashboardState> {
  @override
  EmployerDashboardState build() {
    Future.microtask(load);
    return const EmployerDashboardState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(employerRepositoryProvider);
      final stats = await repo.fetchDashboardStats();
      final jobs = await repo.fetchMyJobs();
      state = state.copyWith(
        stats: stats,
        recentJobs: jobs.take(3).toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ── My Jobs ──────────────────────────────────────────────────────────────────

final employerJobsProvider =
    NotifierProvider<EmployerJobsNotifier, EmployerJobsState>(
      EmployerJobsNotifier.new,
    );

class EmployerJobsState extends Equatable {
  final List<EmployerJob> jobs;
  final bool isLoading;
  final String? error;
  final String statusFilter;
  final String query;

  const EmployerJobsState({
    this.jobs = const [],
    this.isLoading = false,
    this.error,
    this.statusFilter = 'All',
    this.query = '',
  });

  EmployerJobsState copyWith({
    List<EmployerJob>? jobs,
    bool? isLoading,
    String? error,
    String? statusFilter,
    String? query,
  }) => EmployerJobsState(
    jobs: jobs ?? this.jobs,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    statusFilter: statusFilter ?? this.statusFilter,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => [jobs, isLoading, error, statusFilter, query];
}

class EmployerJobsNotifier extends Notifier<EmployerJobsState> {
  @override
  EmployerJobsState build() {
    Future.microtask(load);
    return const EmployerJobsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final jobs = await ref
          .read(employerRepositoryProvider)
          .fetchMyJobs(statusFilter: state.statusFilter, query: state.query);
      state = state.copyWith(jobs: jobs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> applyFilter({String? status, String? query}) async {
    state = state.copyWith(
      statusFilter: status ?? state.statusFilter,
      query: query ?? state.query,
    );
    await load();
  }

  Future<void> createJob(JobFormData data) async {
    await ref.read(employerRepositoryProvider).createJob(data);
    // Reload dashboard too
    ref.invalidate(employerDashboardProvider);
    await load();
  }

  Future<void> updateJob(String id, JobFormData data) async {
    await ref.read(employerRepositoryProvider).updateJob(id, data);
    ref.invalidate(employerJobDetailProvider(id));
    await load();
  }

  Future<void> closeJob(String id) async {
    await ref.read(employerRepositoryProvider).closeJob(id);
    ref.invalidate(employerDashboardProvider);
    ref.invalidate(employerJobDetailProvider(id));
    await load();
  }

  Future<void> deleteJob(String id) async {
    await ref.read(employerRepositoryProvider).deleteJob(id);
    ref.invalidate(employerDashboardProvider);
    ref.invalidate(employerJobDetailProvider(id));
    await load();
  }
}

// ── Job Detail (employer view) ───────────────────────────────────────────────

final employerJobDetailProvider = FutureProvider.family<EmployerJob?, String>((
  ref,
  id,
) {
  return ref.watch(employerRepositoryProvider).fetchJobById(id);
});

// ── Applicants ───────────────────────────────────────────────────────────────

final applicantsProvider =
    NotifierProvider.family<ApplicantsNotifier, ApplicantsState, String>(
      (jobId) => ApplicantsNotifier(jobId),
    );

class ApplicantsState extends Equatable {
  final List<Applicant> applicants;
  final bool isLoading;
  final bool isUpdatingStatus;
  final String? error;

  const ApplicantsState({
    this.applicants = const [],
    this.isLoading = false,
    this.isUpdatingStatus = false,
    this.error,
  });

  ApplicantsState copyWith({
    List<Applicant>? applicants,
    bool? isLoading,
    bool? isUpdatingStatus,
    String? error,
  }) => ApplicantsState(
    applicants: applicants ?? this.applicants,
    isLoading: isLoading ?? this.isLoading,
    isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
    error: error,
  );

  @override
  List<Object?> get props => [applicants, isLoading, isUpdatingStatus, error];
}

class ApplicantsNotifier extends Notifier<ApplicantsState> {
  final String jobId;

  ApplicantsNotifier(this.jobId);

  @override
  ApplicantsState build() {
    Future.microtask(load);
    return const ApplicantsState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await ref
          .read(employerRepositoryProvider)
          .fetchApplicants(jobId);
      state = state.copyWith(applicants: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStatus(
    String applicantId,
    ApplicationStatus status,
  ) async {
    state = state.copyWith(isUpdatingStatus: true, error: null);
    try {
      final updated = await ref
          .read(employerRepositoryProvider)
          .updateApplicantStatus(applicantId, status);
      final next = state.applicants
          .map((a) => a.id == applicantId ? updated : a)
          .toList();
      state = state.copyWith(applicants: next, isUpdatingStatus: false);
      ref.invalidate(employerDashboardProvider);
    } catch (error) {
      state = state.copyWith(isUpdatingStatus: false, error: error.toString());
      rethrow;
    }
  }
}

// ── Applicant Detail ─────────────────────────────────────────────────────────

final applicantDetailProvider = FutureProvider.family<Applicant?, String>((
  ref,
  id,
) {
  return ref.watch(employerRepositoryProvider).fetchApplicantById(id);
});
