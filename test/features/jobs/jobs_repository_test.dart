import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/jobs/models/job_model.dart';
import '../../helpers/fake_localjobs_repository.dart';

void main() {
  test('job repository contract maps the backend job DTO', () async {
    final repository = FakeLocalJobsRepository();
    final page = await repository.getJobs();
    final jobs = page.items.map(Job.fromPost).toList();

    expect(jobs, isNotEmpty);
    expect(jobs.first, isA<Job>());
    expect(jobs.first.title, isNotEmpty);
  });
}
