import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/app/app.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_models.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_localjobs_repository.dart';

void main() {
  Future<void> startApp(
    WidgetTester tester,
    FakeLocalJobsRepository repository,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          localJobsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const LocalJobsApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> login(WidgetTester tester, String email) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
  }

  Future<void> openMyJobs(WidgetTester tester) async {
    await tester.dragUntilVisible(
      find.text('View all'),
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.tap(find.text('View all'));
    await tester.pumpAndSettle();
  }

  testWidgets('own jobs show status badges and both status actions', (
    tester,
  ) async {
    final repository = FakeLocalJobsRepository();
    repository.ownJobs.addAll([
      repository.job,
      _withStatus(
        repository.job,
        isActive: false,
        title: 'Inactive Driver Job',
      ),
    ]);
    await startApp(tester, repository);
    await login(tester, 'employer@example.test');
    await tester.dragUntilVisible(
      find.text('Your posted jobs'),
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    await openMyJobs(tester);

    expect(find.text('Family Driver Needed'), findsOneWidget);
    expect(find.text('Inactive Driver Job'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Edit'), findsNWidgets(2));
    expect(find.text('Deactivate'), findsOneWidget);
    expect(find.text('Reactivate'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'inactive employer home job opens details without public lookup',
    (tester) async {
      final repository = FakeLocalJobsRepository();
      repository.job = _withStatus(
        repository.job,
        isActive: false,
        title: 'Inactive Driver Job',
      );
      repository.ownJobs.add(repository.job);
      await startApp(tester, repository);
      await login(tester, 'employer@example.test');
      await tester.dragUntilVisible(
        find.text('Your posted jobs'),
        find.byType(ListView).first,
        const Offset(0, -500),
      );
      await tester.tap(find.text('Inactive Driver Job'));
      await tester.pumpAndSettle();

      expect(find.text('Inactive'), findsOneWidget);
      expect(find.text('Reactivate Job'), findsOneWidget);
      expect(find.text('Could not load this job.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('employer can deactivate and reactivate from job details', (
    tester,
  ) async {
    final repository = FakeLocalJobsRepository()..ownJobs.addAll([]);
    repository.ownJobs.add(repository.job);
    await startApp(tester, repository);
    await login(tester, 'employer@example.test');
    await openMyJobs(tester);
    await tester.tap(find.text('Family Driver Needed'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Edit Job'), findsOneWidget);
    expect(find.text('Deactivate Job'), findsOneWidget);
    expect(find.text('Reactivate Job'), findsNothing);

    await tester.tap(find.text('Deactivate Job'));
    await tester.pumpAndSettle();
    expect(find.text('Deactivate this job?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Deactivate'));
    await tester.pumpAndSettle();
    expect(find.text('Inactive'), findsOneWidget);
    expect(find.text('Reactivate Job'), findsOneWidget);

    await tester.tap(find.text('Reactivate Job'));
    await tester.pumpAndSettle();
    expect(find.text('Reactivate this job?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Reactivate'));
    await tester.pumpAndSettle();
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Deactivate Job'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reactivating a past-dated job clears the expired date with notice',
    (tester) async {
      final repository = FakeLocalJobsRepository();
      repository.job = _withStatus(
        repository.job,
        isActive: false,
        startDate: DateTime.utc(2025, 1, 1),
      );
      repository.ownJobs.add(repository.job);
      await startApp(tester, repository);
      await login(tester, 'employer@example.test');
      await openMyJobs(tester);

      await tester.tap(find.text('Reactivate'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('past start date will be cleared'),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Reactivate').last);
      await tester.pumpAndSettle();

      expect(repository.lastJobUpdateRequest?.isActive, isTrue);
      expect(repository.lastJobUpdateRequest?.startDate, isNull);
      expect(find.text('Active'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('JobSeeker sees no employer management actions', (tester) async {
    final repository = FakeLocalJobsRepository();
    await startApp(tester, repository);
    await login(tester, 'jobseeker@example.test');
    await tester.dragUntilVisible(
      find.text('Family Driver Needed'),
      find.byType(ListView).first,
      const Offset(0, -500),
    );
    await tester.tap(find.text('Family Driver Needed'));
    await tester.pumpAndSettle();

    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Edit Job'), findsNothing);
    expect(find.text('Deactivate Job'), findsNothing);
    expect(find.text('Reactivate Job'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('inactive jobs are excluded from public and Jobs/Work feeds', (
    tester,
  ) async {
    final repository = FakeLocalJobsRepository();
    repository.job = _withStatus(repository.job, isActive: false);
    await startApp(tester, repository);
    await login(tester, 'jobseeker@example.test');

    expect(find.text('Family Driver Needed'), findsNothing);
    await tester.tap(find.text('Ads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jobs/Work'));
    await tester.pumpAndSettle();
    expect(find.text('Family Driver Needed'), findsNothing);
    expect(find.text('JOB POSTS'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

JobPost _withStatus(
  JobPost job, {
  required bool isActive,
  String? title,
  DateTime? startDate,
}) => JobPost(
  id: job.id,
  title: title ?? job.title,
  description: job.description,
  salary: job.salary,
  categoryId: job.categoryId,
  categoryName: job.categoryName,
  cityId: job.cityId,
  cityName: job.cityName,
  cityState: job.cityState,
  userId: job.userId,
  userName: job.userName,
  isActive: isActive,
  createdAt: job.createdAt,
  updatedAt: job.updatedAt,
  workType: job.workType,
  experienceRequirement: job.experienceRequirement,
  paymentPeriod: job.paymentPeriod,
  startDate: startDate ?? job.startDate,
  status: isActive ? 'Active' : 'Inactive',
  area: job.area,
);
