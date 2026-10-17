import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/applications_repository.dart';
import '../models/application_filters.dart';
import '../models/application_model.dart';
import '../models/application_status.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jobs/models/job_model.dart';

final applicationsControllerProvider =
    NotifierProvider<ApplicationsController, ApplicationsState>(
      ApplicationsController.new,
    );

final applicationDetailsProvider = FutureProvider.family<Application?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(applicationsRepositoryProvider);
  return repository.fetchApplicationById(id);
});

class ApplicationsState extends Equatable {
  final List<Application> applications;
  final List<Application> allApplications;
  final bool isLoading;
  final String? error;
  final ApplicationFilters filters;
  final bool isSubmitting;
  final String? submitError;

  const ApplicationsState({
    this.applications = const [],
    this.allApplications = const [],
    this.isLoading = false,
    this.error,
    this.filters = const ApplicationFilters(),
    this.isSubmitting = false,
    this.submitError,
  });

  ApplicationsState copyWith({
    List<Application>? applications,
    List<Application>? allApplications,
    bool? isLoading,
    String? error,
    ApplicationFilters? filters,
    bool? isSubmitting,
    String? submitError,
  }) {
    return ApplicationsState(
      applications: applications ?? this.applications,
      allApplications: allApplications ?? this.allApplications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: submitError,
    );
  }

  @override
  List<Object?> get props => [
    applications,
    allApplications,
    isLoading,
    error,
    filters,
    isSubmitting,
    submitError,
  ];
}

class ApplicationsController extends Notifier<ApplicationsState> {
  @override
  ApplicationsState build() {
    Future.microtask(loadApplications);
    return const ApplicationsState();
  }

  Future<void> loadApplications() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(applicationsRepositoryProvider);
      final applications = await repository.fetchApplications();
      final allApplications = applications;
      final visibleApplications = state.filters.statusFilter == null
          ? applications
          : applications
                .where(
                  (app) =>
                      app.status.label.toLowerCase() ==
                      state.filters.statusFilter!.toLowerCase(),
                )
                .toList();

      // Sort applications based on filters
      final sortedApplications = _sortApplications(
        visibleApplications,
        state.filters.sortBy,
      );

      state = state.copyWith(
        applications: sortedApplications,
        allApplications: allApplications,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Application? applicationForJob(String jobId) {
    final auth = ref.read(authStateProvider);
    final userId = auth is Authenticated ? auth.user.id : 'local-user';
    for (final application in state.allApplications) {
      if (application.job.id == jobId && application.userId == userId) {
        return application;
      }
    }
    return null;
  }

  Future<Application> submitApplication({
    required Job job,
    required String fullName,
    required String email,
    required String phone,
    required String resumeName,
    required String coverLetter,
    required String additionalInformation,
  }) async {
    final auth = ref.read(authStateProvider);
    final userId = auth is Authenticated ? auth.user.id : 'local-user';
    final existing = applicationForJob(job.id);
    if (existing != null) return existing;

    state = state.copyWith(isSubmitting: true, submitError: null);
    try {
      final application = Application(
        id: 'local-app-${DateTime.now().microsecondsSinceEpoch}',
        job: job,
        userId: userId,
        status: ApplicationStatus.applied,
        appliedAt: DateTime.now().toIso8601String(),
        coverLetter: [
          coverLetter,
          if (additionalInformation.trim().isNotEmpty)
            additionalInformation.trim(),
        ].where((value) => value.trim().isNotEmpty).join('\n\n'),
        applicantName: fullName.trim(),
        applicantEmail: email.trim(),
        applicantPhone: phone.trim(),
        resumeName: resumeName,
      );
      final created = await ref
          .read(applicationsRepositoryProvider)
          .createApplication(application);
      state = state.copyWith(
        applications: [
          created,
          ...state.applications.where((item) => item.id != created.id),
        ],
        allApplications: [
          created,
          ...state.allApplications.where((item) => item.id != created.id),
        ],
        isSubmitting: false,
        submitError: null,
        filters: const ApplicationFilters(),
      );
      return created;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        submitError: error.toString(),
      );
      rethrow;
    }
  }

  Future<void> filterByStatus(String? status) async {
    final nextFilters = state.filters.copyWith(statusFilter: status);
    state = state.copyWith(filters: nextFilters);
    await loadApplications();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const ApplicationFilters());
    await loadApplications();
  }

  List<Application> _sortApplications(
    List<Application> applications,
    String sortBy,
  ) {
    final sorted = [...applications];
    if (sortBy == 'recent') {
      sorted.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    } else {
      sorted.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
    }
    return sorted;
  }
}
