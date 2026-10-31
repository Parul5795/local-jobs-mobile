import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/app/app.dart';
import 'package:local_jobs_mobile/app/theme/app_colors.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_localjobs_repository.dart';

void main() {
  Future<void> startApp(
    WidgetTester tester, {
    Size viewport = const Size(400, 900),
  }) async {
    tester.view.physicalSize = viewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          localJobsRepositoryProvider.overrideWithValue(
            FakeLocalJobsRepository(),
          ),
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

  testWidgets('JobSeeker routes to local work home', (tester) async {
    await startApp(tester);
    await login(tester, 'jobseeker@example.test');
    expect(find.text('Find work nearby'), findsOneWidget);
    expect(find.text('Employer Dashboard'), findsNothing);
    expect(find.text('Apply Now'), findsNothing);
  });

  testWidgets('Employer routes to local worker and job home', (tester) async {
    await startApp(tester);
    await login(tester, 'employer@example.test');
    expect(find.text('Find people nearby'), findsOneWidget);
    expect(find.text('Post a Job'), findsWidgets);
    expect(find.text('Rajesh Kumar'), findsOneWidget);
    expect(find.text('Applications'), findsNothing);
  });

  testWidgets('Employer Post a Job opens the structured job form', (
    tester,
  ) async {
    await startApp(tester);
    await login(tester, 'employer@example.test');
    final postButton = find.widgetWithText(FilledButton, 'Post a Job');
    await tester.ensureVisible(postButton);
    await tester.tap(postButton);
    await tester.pumpAndSettle();

    expect(find.text('Post a local job'), findsOneWidget);
    expect(find.text('Job Details'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Jobs/Work Ads shows structured Jobs separately', (tester) async {
    await startApp(tester);
    await login(tester, 'jobseeker@example.test');
    await tester.tap(find.text('Ads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jobs/Work'));
    await tester.pumpAndSettle();

    expect(find.text('JOB POSTS'), findsOneWidget);
    expect(find.text('Family Driver Needed'), findsOneWidget);
    expect(find.text('CLASSIFIED ADS'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('new ad route opens the create form, not ad details', (
    tester,
  ) async {
    await startApp(tester);
    await login(tester, 'jobseeker@example.test');
    await tester.tap(find.text('Ads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create an advertisement'), findsOneWidget);
    expect(find.text('Classified details'), findsNothing);
  });

  testWidgets(
    'JobSeeker search keeps filters compact and applies them at mobile width',
    (tester) async {
      await startApp(tester, viewport: const Size(320, 720));
      await login(tester, 'jobseeker@example.test');
      await tester.tap(find.text('Search').last);
      await tester.pumpAndSettle();

      expect(find.text('Find work'), findsOneWidget);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold).last).backgroundColor,
        AppColors.background,
      );
      expect(find.text('Work type'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Location & filters'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Work type'), findsOneWidget);
      expect(find.text('Experience'), findsOneWidget);
      expect(find.text('Payment period'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(
        find
            .byWidgetPredicate((widget) => widget is DropdownButtonFormField)
            .at(1),
      );
      await tester.tap(
        find
            .byWidgetPredicate((widget) => widget is DropdownButtonFormField)
            .at(1),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Part-time').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply filters'));
      await tester.pumpAndSettle();

      expect(find.text('Filters 1'), findsOneWidget);
      expect(find.text('Part-time'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Employer search uses the same compact filter sheet', (
    tester,
  ) async {
    await startApp(tester);
    await login(tester, 'employer@example.test');
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();

    expect(find.text('Find someone'), findsOneWidget);
    expect(find.text('Fresher only'), findsNothing);

    await tester.tap(find.text('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('City'), findsOneWidget);
    expect(find.text('Area'), findsOneWidget);
    expect(find.text('Fresher only'), findsOneWidget);
    expect(find.text('Work type'), findsNothing);

    await tester.tap(find.text('Fresher only'));
    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();

    expect(find.text('Filters 1'), findsOneWidget);
    expect(find.text('Fresher'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final role in ['JobSeeker', 'Employer']) {
    testWidgets('Registration as $role routes to the role-aware home', (
      tester,
    ) async {
      await startApp(tester);
      await tester.ensureVisible(find.text('Sign Up').first);
      await tester.tap(find.text('Sign Up').first);
      await tester.pumpAndSettle();
      if (role == 'Employer') {
        await tester.tap(find.text('Employer').first);
        await tester.pumpAndSettle();
      }
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Taylor Worker');
      await tester.enterText(fields.at(1), 'taylor@example.com');
      await tester.enterText(fields.at(2), '1234567890');
      await tester.enterText(fields.at(3), 'password');
      await tester.enterText(fields.at(4), 'password');
      await tester.ensureVisible(find.text('Sign Up').first);
      await tester.tap(find.text('Sign Up').first);
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pumpAndSettle();
      expect(
        find.text(
          role == 'Employer' ? 'Find people nearby' : 'Find work nearby',
        ),
        findsOneWidget,
      );
    });
  }
}
