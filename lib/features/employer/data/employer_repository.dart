import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../applications/models/application_status.dart';
import '../models/applicant_model.dart';
import '../models/employer_dashboard_stats.dart';
import '../models/employer_job_model.dart';
import '../models/job_form_data.dart';
import 'employer_api_service.dart';

final employerRepositoryProvider = Provider<EmployerRepository>((ref) {
  final api = ref.watch(employerApiServiceProvider);
  return EmployerRepositoryImpl(api);
});

abstract class EmployerRepository {
  Future<EmployerDashboardStats> fetchDashboardStats();
  Future<List<EmployerJob>> fetchMyJobs({String? statusFilter, String? query});
  Future<EmployerJob?> fetchJobById(String id);
  Future<EmployerJob> createJob(JobFormData data);
  Future<EmployerJob> updateJob(String id, JobFormData data);
  Future<void> closeJob(String id);
  Future<void> deleteJob(String id);
  Future<List<Applicant>> fetchApplicants(String jobId);
  Future<Applicant?> fetchApplicantById(String id);
  Future<Applicant> updateApplicantStatus(
    String applicantId,
    ApplicationStatus status,
  );
}

class EmployerRepositoryImpl implements EmployerRepository {
  final EmployerApiService _api;

  EmployerRepositoryImpl(this._api);

  @override
  Future<EmployerDashboardStats> fetchDashboardStats() =>
      _api.fetchDashboardStats();

  @override
  Future<List<EmployerJob>> fetchMyJobs({
    String? statusFilter,
    String? query,
  }) => _api.fetchMyJobs(statusFilter: statusFilter, query: query);

  @override
  Future<EmployerJob?> fetchJobById(String id) => _api.fetchJobById(id);

  @override
  Future<EmployerJob> createJob(JobFormData data) => _api.createJob(data);

  @override
  Future<EmployerJob> updateJob(String id, JobFormData data) =>
      _api.updateJob(id, data);

  @override
  Future<void> closeJob(String id) => _api.closeJob(id);

  @override
  Future<void> deleteJob(String id) => _api.deleteJob(id);

  @override
  Future<List<Applicant>> fetchApplicants(String jobId) =>
      _api.fetchApplicants(jobId);

  @override
  Future<Applicant?> fetchApplicantById(String id) =>
      _api.fetchApplicantById(id);

  @override
  Future<Applicant> updateApplicantStatus(
    String applicantId,
    ApplicationStatus status,
  ) => _api.updateApplicantStatus(applicantId, status);
}
