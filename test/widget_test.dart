import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_jobs_mobile/app/app.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('LocalJobs app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const LocalJobsApp(),
      ),
    );

    expect(find.text('LocalJobs'), findsOneWidget);
  });
}
