import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_jobs_mobile/features/jobs/data/jobs_repository.dart';
import 'package:local_jobs_mobile/features/jobs/models/job_model.dart';

void main() {
  test('fetchJobs returns jobs from the mock data source', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(jobsRepositoryProvider);
    final jobs = await repository.fetchJobs();

    expect(jobs, isNotEmpty);
    expect(jobs.first, isA<Job>());
    expect(jobs.first.title, isNotEmpty);
  });
}
