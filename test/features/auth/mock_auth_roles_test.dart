import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_api_service.dart';
import 'package:local_jobs_mobile/features/auth/data/auth_repository.dart';
import 'package:local_jobs_mobile/features/auth/models/login_request.dart';
import 'package:local_jobs_mobile/features/auth/models/register_request.dart';

void main() {
  group('mock authentication roles', () {
    final service = AuthApiServiceImpl();

    test('job seeker demo credentials authenticate as JobSeeker', () async {
      final response = await service.login(
        const LoginRequest(
          email: 'jobseeker@test.com',
          password: 'password',
          role: 'JobSeeker',
        ),
      );

      expect(response.success, isTrue);
      expect(response.data?.user.role, 'JobSeeker');
    });

    test('employer demo credentials authenticate as Employer', () async {
      final response = await service.login(
        const LoginRequest(
          email: 'employer@test.com',
          password: 'password',
          role: 'Employer',
        ),
      );

      expect(response.success, isTrue);
      expect(response.data?.user.role, 'Employer');
    });

    test(
      'credentials cannot authenticate under the other selected role',
      () async {
        final response = await service.login(
          const LoginRequest(
            email: 'jobseeker@test.com',
            password: 'password',
            role: 'Employer',
          ),
        );

        expect(response.success, isFalse);
      },
    );

    test('registration retains the selected role', () async {
      final seeker = await service.register(
        const RegisterRequest(
          fullName: 'Alex Seeker',
          email: 'alex@example.com',
          phone: '1234567890',
          password: 'password',
          role: 'JobSeeker',
        ),
      );
      final employer = await service.register(
        const RegisterRequest(
          fullName: 'Sam Employer',
          email: 'sam@example.com',
          phone: '1234567890',
          password: 'password',
          role: 'Employer',
        ),
      );

      expect(seeker.data?.user.role, 'JobSeeker');
      expect(employer.data?.user.role, 'Employer');
    });

    test('repository keeps and clears the mock session in memory', () async {
      final repository = AuthRepositoryImpl(service);
      final user = await repository.login(
        const LoginRequest(
          email: 'employer@test.com',
          password: 'password',
          role: 'Employer',
        ),
      );

      expect(user.role, 'Employer');
      expect(await repository.hasSession(), isTrue);
      expect((await repository.getCurrentUser()).role, 'Employer');

      await repository.logout();
      expect(await repository.hasSession(), isFalse);
    });
  });
}
