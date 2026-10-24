import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/applications_repository.dart';
import '../models/application_filters.dart';
import '../models/application_model.dart';

final applicationsControllerProvider = NotifierProvider<ApplicationsController, ApplicationsState>(
  ApplicationsController.new,
);

final applicationDetailsProvider = FutureProvider.family<Application?, String>((ref, id) async {
  final repository = ref.watch(applicationsRepositoryProvider);
  return repository.fetchApplicationById(id);
});

class ApplicationsState extends Equatable {
  final List<Application> applications;
  final bool isLoading;
  final String? error;
  final ApplicationFilters filters;

  const ApplicationsState({
    this.applications = const [],
    this.isLoading = false,
    this.error,
    this.filters = const ApplicationFilters(),
  });

  ApplicationsState copyWith({
    List<Application>? applications,
    bool? isLoading,
    String? error,
    ApplicationFilters? filters,
  }) {
    return ApplicationsState(
      applications: applications ?? this.applications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => [applications, isLoading, error, filters];
}

class ApplicationsController extends Notifier<ApplicationsState> {
  @override
  ApplicationsState build() {
    return const ApplicationsState();
  }

  Future<void> loadApplications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(applicationsRepositoryProvider);
      final applications = await repository.fetchApplications(
        statusFilter: state.filters.statusFilter,
      );

      // Sort applications based on filters
      final sortedApplications = _sortApplications(applications, state.filters.sortBy);

      state = state.copyWith(applications: sortedApplications, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> filterByStatus(String? status) async {
    final nextFilters = state.filters.copyWith(
      statusFilter: status,
    );
    state = state.copyWith(filters: nextFilters);
    await loadApplications();
  }

  Future<void> clearFilters() async {
    state = state.copyWith(filters: const ApplicationFilters());
    await loadApplications();
  }

  List<Application> _sortApplications(List<Application> applications, String sortBy) {
    final sorted = [...applications];
    if (sortBy == 'recent') {
      sorted.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    } else {
      sorted.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
    }
    return sorted;
  }
}
