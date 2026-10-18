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

  testWidgets('Job Seeker login opens local work Home', (tester) async {
    await startApp(tester);
    await submitLogin(tester, email: 'jobseeker', employer: false);

    expect(find.text('Find work nearby'), findsOneWidget);
    expect(find.text('Employer Dashboard'), findsNothing);
    expect(find.text('LOCAL ADVERTISEMENTS'), findsNothing);
  });

  testWidgets('Employer login opens local people Home', (tester) async {
    await startApp(tester);
    await submitLogin(tester, email: 'employer', employer: true);

    expect(find.text('Find people nearby'), findsOneWidget);
    expect(find.text('Post a Job'), findsOneWidget);
  });

  testWidgets('Employer can find a worker and record a mock contact', (
    tester,
  ) async {
    await startApp(tester);
    await submitLogin(tester, email: 'employer', employer: true);
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Driver');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rajesh Kumar').first);
    await tester.pumpAndSettle();

    expect(find.text('Worker profile'), findsOneWidget);
    expect(find.text('24 people contacted this profile'), findsOneWidget);
    await tester.tap(find.text('Call'));
    await tester.pumpAndSettle();
    expect(find.text('25 people contacted this profile'), findsOneWidget);
  });

  testWidgets('Job Seeker can search local work and open its details', (
    tester,
  ) async {
    await startApp(tester);
    await submitLogin(tester, email: 'jobseeker', employer: false);
    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Driver');
    await tester.pumpAndSettle();
    expect(find.text('Family Driver Needed'), findsOneWidget);
    await tester.tap(find.text('View').first);
    await tester.pumpAndSettle();

    expect(find.text('Work details'), findsOneWidget);
    expect(find.text('Apply Now'), findsNothing);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
  });

  testWidgets('Both roles can post and view a classified', (tester) async {
    await startApp(tester);
    await submitLogin(tester, email: 'jobseeker', employer: false);
    await tester.tap(find.text('Ads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post an Ad'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Fresh vegetable stall');
    await tester.enterText(
      fields.at(1),
      'Fresh vegetables available every morning.',
    );
    await tester.enterText(fields.at(2), 'Hadapsar');
    await tester.enterText(fields.at(3), '9876543210');
    await tester.ensureVisible(find.text('Post advertisement'));
    await tester.tap(find.text('Post advertisement'));
    await tester.pumpAndSettle();
    expect(find.text('FRESH VEGETABLE STALL'), findsOneWidget);
    await tester.tap(find.text('View').first);
    await tester.pumpAndSettle();
    expect(find.text('Classified details'), findsOneWidget);
  });

  testWidgets('Employer job post appears in seeker search and classifieds', (
    tester,
  ) async {
    await startApp(tester);
    await submitLogin(tester, email: 'employer', employer: true);
    await tester.tap(find.text('Post a Job'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Night Guard Needed');
    await tester.enterText(fields.at(1), '₹16,000 per month');
    await tester.enterText(
      fields.at(2),
      'Night shift security for a small apartment building.',
    );
    await tester.enterText(fields.at(3), 'Responsible and punctual.');
    await tester.enterText(fields.at(4), '9876543210');
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Post job'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    await submitLogin(tester, email: 'jobseeker', employer: false);

    await tester.tap(find.text('Search').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Night Guard');
    await tester.pumpAndSettle();
    expect(find.text('Night Guard Needed'), findsOneWidget);

    await tester.tap(find.text('Ads').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Jobs / Work'));
    await tester.pumpAndSettle();
    expect(find.text('NIGHT GUARD NEEDED'), findsOneWidget);
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
        expect(find.text('Find people nearby'), findsOneWidget);
        expect(find.text('Post a Job'), findsOneWidget);
      } else {
        expect(find.text('Find work nearby'), findsOneWidget);
        expect(find.text('Employer Dashboard'), findsNothing);
      }
    });
  }
}
