import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../applications/models/application_status.dart';
import '../models/applicant_model.dart';
import '../models/employer_dashboard_stats.dart';
import '../models/employer_job_model.dart';
import '../models/job_form_data.dart';

final employerApiServiceProvider = Provider<EmployerApiService>((ref) {
  return EmployerApiServiceImpl();
});

abstract class EmployerApiService {
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

class EmployerApiServiceImpl implements EmployerApiService {
  // ── Mutable in-memory store ──────────────────────────────────────────────
  final List<Map<String, dynamic>> _jobs = List.from(_mockJobs);
  final List<Map<String, dynamic>> _applicants = List.from(_mockApplicants);

  @override
  Future<EmployerDashboardStats> fetchDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final jobs = _jobs.map(EmployerJob.fromJson).toList();
    final active = jobs
        .where((j) => j.status == EmployerJobStatus.active)
        .length;
    final total = _applicants.length;
    final shortlisted = _applicants
        .where((a) => a['status'] == 'shortlisted')
        .length;
    final hired = _applicants.where((a) => a['status'] == 'hired').length;
    return EmployerDashboardStats(
      activeJobs: active,
      totalApplications: total,
      shortlisted: shortlisted,
      hired: hired,
    );
  }

  @override
  Future<List<EmployerJob>> fetchMyJobs({
    String? statusFilter,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var jobs = _jobs.map(EmployerJob.fromJson).toList();

    if (statusFilter != null && statusFilter != 'All') {
      final closed = statusFilter.toLowerCase() == 'closed';
      jobs = jobs.where((j) {
        return closed
            ? j.status == EmployerJobStatus.closed
            : j.status == EmployerJobStatus.active;
      }).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      jobs = jobs
          .where(
            (j) =>
                j.title.toLowerCase().contains(q) ||
                j.location.toLowerCase().contains(q),
          )
          .toList();
    }
    return jobs;
  }

  @override
  Future<EmployerJob?> fetchJobById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final raw = _jobs.where((j) => j['id'] == id).firstOrNull;
    return raw == null ? null : EmployerJob.fromJson(raw);
  }

  @override
  Future<EmployerJob> createJob(JobFormData data) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final id = 'ej-${DateTime.now().millisecondsSinceEpoch}';
    final raw = {
      'id': id,
      'title': data.title,
      'companyName': data.companyName,
      'category': data.category,
      'location': data.location,
      'jobType': data.jobType,
      'description': data.description,
      'salaryMin': int.tryParse(data.salaryMin) ?? 0,
      'salaryMax': int.tryParse(data.salaryMax) ?? 0,
      'experienceRequired': data.experienceRequired,
      'skills': data.skills,
      'applicationDeadline': data.applicationDeadline,
      'status': 'active',
      'applicationCount': 0,
      'postedAt': 'Just now',
    };
    _jobs.insert(0, raw);
    return EmployerJob.fromJson(raw);
  }

  @override
  Future<EmployerJob> updateJob(String id, JobFormData data) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final idx = _jobs.indexWhere((j) => j['id'] == id);
    if (idx == -1) throw Exception('Job not found');
    final existing = _jobs[idx];
    final updated = {
      ...existing,
      'title': data.title,
      'companyName': data.companyName,
      'category': data.category,
      'location': data.location,
      'jobType': data.jobType,
      'description': data.description,
      'salaryMin': int.tryParse(data.salaryMin) ?? 0,
      'salaryMax': int.tryParse(data.salaryMax) ?? 0,
      'experienceRequired': data.experienceRequired,
      'skills': data.skills,
      'applicationDeadline': data.applicationDeadline,
    };
    _jobs[idx] = updated;
    return EmployerJob.fromJson(updated);
  }

  @override
  Future<void> closeJob(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _jobs.indexWhere((j) => j['id'] == id);
    if (idx != -1) _jobs[idx] = {..._jobs[idx], 'status': 'closed'};
  }

  @override
  Future<void> deleteJob(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _jobs.removeWhere((j) => j['id'] == id);
    _applicants.removeWhere((a) => a['jobId'] == id);
  }

  @override
  Future<List<Applicant>> fetchApplicants(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _applicants
        .where((a) => a['jobId'] == jobId)
        .map(Applicant.fromJson)
        .toList();
  }

  @override
  Future<Applicant?> fetchApplicantById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final raw = _applicants.where((a) => a['id'] == id).firstOrNull;
    return raw == null ? null : Applicant.fromJson(raw);
  }

  @override
  Future<Applicant> updateApplicantStatus(
    String applicantId,
    ApplicationStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _applicants.indexWhere((a) => a['id'] == applicantId);
    if (idx == -1) throw Exception('Applicant not found');
    _applicants[idx] = {..._applicants[idx], 'status': status.name};
    return Applicant.fromJson(_applicants[idx]);
  }

  // ── Mock data ────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _mockJobs = [
    {
      'id': 'ej-1',
      'title': 'Flutter Developer',
      'companyName': 'TechNova GmbH',
      'category': 'Engineering',
      'location': 'Berlin, Germany',
      'jobType': 'Full-time',
      'description':
          'We are looking for a skilled Flutter Developer to join our growing mobile team. You will own the full lifecycle of our consumer-facing app.',
      'salaryMin': 70000,
      'salaryMax': 95000,
      'experienceRequired': 'Mid (2-4 years)',
      'skills': ['Flutter', 'Dart', 'REST APIs', 'Riverpod'],
      'applicationDeadline': '2026-11-30',
      'status': 'active',
      'applicationCount': 12,
      'postedAt': '3 days ago',
    },
    {
      'id': 'ej-2',
      'title': 'Product Manager',
      'companyName': 'TechNova GmbH',
      'category': 'Product',
      'location': 'Munich, Germany',
      'jobType': 'Full-time',
      'description':
          'Drive the roadmap and execution of our B2B product suite. Work closely with engineering, design, and sales.',
      'salaryMin': 80000,
      'salaryMax': 105000,
      'experienceRequired': 'Senior (5+ years)',
      'skills': ['Roadmapping', 'Agile', 'Stakeholder Management'],
      'applicationDeadline': '2026-11-15',
      'status': 'active',
      'applicationCount': 7,
      'postedAt': '1 week ago',
    },
    {
      'id': 'ej-3',
      'title': 'UX Researcher',
      'companyName': 'TechNova GmbH',
      'category': 'Design',
      'location': 'Remote',
      'jobType': 'Contract',
      'description':
          'Conduct user interviews, usability tests, and synthesize insights to inform product decisions.',
      'salaryMin': 55000,
      'salaryMax': 70000,
      'experienceRequired': 'Mid (2-4 years)',
      'skills': ['User Research', 'Usability Testing', 'Figma'],
      'applicationDeadline': '2026-10-31',
      'status': 'closed',
      'applicationCount': 23,
      'postedAt': '3 weeks ago',
    },
  ];

  static const List<Map<String, dynamic>> _mockApplicants = [
    {
      'id': 'ap-1',
      'jobId': 'ej-1',
      'applicantName': 'Sarah Chen',
      'email': 'sarah.chen@email.com',
      'phone': '+49 151 1234567',
      'appliedAt': '2026-10-14',
      'status': 'applied',
      'coverLetter':
          'I am very excited about this Flutter role. With 3 years of production Flutter experience across two consumer apps, I believe I can make an immediate impact.',
      'skills': [
        'Flutter',
        'Dart',
        'Riverpod',
        'Firebase',
        'Clean Architecture',
      ],
      'experienceSummary':
          '3 years of Flutter development. Previously built a fintech super-app and a logistics tracking platform.',
    },
    {
      'id': 'ap-2',
      'jobId': 'ej-1',
      'applicantName': 'Marcus Klein',
      'email': 'm.klein@email.com',
      'phone': '+49 160 9876543',
      'appliedAt': '2026-10-13',
      'status': 'shortlisted',
      'coverLetter':
          'Flutter is my primary technology stack for the past 4 years. I am passionate about performance and pixel-perfect UIs.',
      'skills': ['Flutter', 'Dart', 'Bloc', 'GraphQL', 'CI/CD'],
      'experienceSummary':
          '4 years of Flutter. Led mobile engineering at a Series-B startup with 200k+ users.',
    },
    {
      'id': 'ap-3',
      'jobId': 'ej-1',
      'applicantName': 'Priya Sharma',
      'email': 'priya.s@email.com',
      'phone': '+49 176 5554433',
      'appliedAt': '2026-10-12',
      'status': 'reviewing',
      'coverLetter': null,
      'skills': ['Flutter', 'Dart', 'GetX', 'REST APIs'],
      'experienceSummary':
          '2 years Flutter, formerly an Android developer. Strong understanding of native integrations.',
    },
    {
      'id': 'ap-4',
      'jobId': 'ej-2',
      'applicantName': 'Jonas Weber',
      'email': 'j.weber@email.com',
      'phone': '+49 151 7778899',
      'appliedAt': '2026-10-10',
      'status': 'hired',
      'coverLetter': 'Excited to join TechNova as PM.',
      'skills': [
        'Agile',
        'Jira',
        'OKRs',
        'Stakeholder Management',
        'Data Analysis',
      ],
      'experienceSummary':
          '6 years in product management. Previously at a FAANG company and two early-stage startups.',
    },
    {
      'id': 'ap-5',
      'jobId': 'ej-2',
      'applicantName': 'Lea Müller',
      'email': 'lea.m@email.com',
      'phone': '+49 162 3332211',
      'appliedAt': '2026-10-09',
      'status': 'rejected',
      'coverLetter': null,
      'skills': ['Scrum', 'User Stories', 'Roadmapping'],
      'experienceSummary':
          '3 years as a junior PM. Looking to step up to a senior role.',
    },
  ];
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
