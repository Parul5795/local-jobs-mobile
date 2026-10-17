import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/app/app.dart';

void main() {
  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const ProviderScope(child: LocalJobsApp()));
    await tester.pumpAndSettle();
  }

  Future<void> submitLogin(
    WidgetTester tester, {
    required String email,
    required bool employer,
  }) async {
    if (employer) {
      await tester.tap(find.text('Employer').first);
      await tester.pumpAndSettle();
    }
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.pump();
  }

  testWidgets('Job Seeker login opens Job Seeker Home', (tester) async {
    await startApp(tester);
    await submitLogin(tester, email: 'jobseeker@test.com', employer: false);

    expect(find.text('LocalJobs'), findsOneWidget);
    expect(find.text('Employer Dashboard'), findsNothing);
  });

  testWidgets('Employer login opens Employer Dashboard', (tester) async {
    await startApp(tester);
    await submitLogin(tester, email: 'employer@test.com', employer: true);

    expect(find.text('Employer Dashboard'), findsOneWidget);
  });

  for (final role in ['JobSeeker', 'Employer']) {
    testWidgets('Registration as $role opens the correct destination', (
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
      await tester.enterText(fields.at(0), 'Taylor Applicant');
      await tester.enterText(fields.at(1), 'taylor@example.com');
      await tester.enterText(fields.at(2), '1234567890');
      await tester.enterText(fields.at(3), 'password');
      await tester.enterText(fields.at(4), 'password');
      await tester.ensureVisible(find.text('Sign Up').first);
      await tester.tap(find.text('Sign Up').first);
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tester.pump();

      if (role == 'Employer') {
        expect(find.text('Employer Dashboard'), findsOneWidget);
      } else {
        expect(find.text('LocalJobs'), findsOneWidget);
        expect(find.text('Employer Dashboard'), findsNothing);
      }
    });
  }
}
