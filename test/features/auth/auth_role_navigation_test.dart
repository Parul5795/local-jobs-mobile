import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/app/app.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_localjobs_repository.dart';

void main() {
  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
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
