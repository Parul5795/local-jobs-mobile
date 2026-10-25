import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/core/network/api_exceptions.dart';
import 'package:local_jobs_mobile/features/auth/models/auth_state.dart';
import 'package:local_jobs_mobile/features/auth/models/user_model.dart';
import 'package:local_jobs_mobile/features/auth/providers/auth_provider.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_api_service.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_repository.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_models.dart';
import 'package:local_jobs_mobile/features/profile/data/profile_api_service.dart';
import 'package:local_jobs_mobile/features/profile/data/profile_repository.dart';
import 'package:local_jobs_mobile/features/profile/data/user_account_api_service.dart';
import 'package:local_jobs_mobile/features/profile/data/user_account_repository.dart';
import 'package:local_jobs_mobile/features/profile/models/profile_model.dart';
import 'package:local_jobs_mobile/features/profile/providers/profile_provider.dart';
import 'package:local_jobs_mobile/features/profile/screens/profile_screen.dart';

void main() {
  final user = UserModel(
    id: 'worker-1',
    email: 'worker@example.test',
    fullName: 'Test Worker',
    phone: '1234567890',
    role: 'JobSeeker',
    createdAt: DateTime.utc(2026),
  );

  test('200 worker profile is mapped as an existing profile', () async {
    final worker = _workerProfile();
    final service = ProfileApiServiceImpl(_ProfileLocalJobsRepository(worker));

    final result = await service.getProfile(user);

    expect(result?.id, user.id);
    expect(result?.workCategory, 'Driver');
  });

  test('404 worker profile is represented as first-use null state', () async {
    final dio = Dio()
      ..httpClientAdapter = _StatusAdapter(
        404,
        '{"title":"Worker profile not found"}',
      );
    final result = await LocalJobsApiService(dio).getMyWorkerProfile();

    expect(result, isNull);
    final service = ProfileApiServiceImpl(_ProfileLocalJobsRepository(null));
    expect(await service.getProfile(user), isNull);
  });

  testWidgets('missing worker profile shows the create-profile state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _AuthenticatedNotifier(user)),
          profileRepositoryProvider.overrideWithValue(_ProfileRepository()),
          userAccountRepositoryProvider.overrideWithValue(
            _TestUserAccountRepository(user),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create your worker profile'), findsOneWidget);
    expect(find.text('Create worker profile'), findsOneWidget);
    expect(find.text('Couldnâ€™t load your profile'), findsNothing);
  });

  test('non-404 worker profile failure remains an error', () async {
    final error = ApiException('Server unavailable', 500);
    final service = ProfileApiServiceImpl(
      _ProfileLocalJobsRepository(null, error: error),
    );

    await expectLater(service.getProfile(user), throwsA(same(error)));
  });

  testWidgets('non-404 profile error keeps the retry state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _AuthenticatedNotifier(user)),
          profileRepositoryProvider.overrideWithValue(
            _ProfileRepository(
              getError: ApiException('Server unavailable', 500),
            ),
          ),
          userAccountRepositoryProvider.overrideWithValue(
            _TestUserAccountRepository(user),
          ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Check your connection and try again.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('Create worker profile'), findsNothing);
  });

  test(
    'successful first PUT reloads and exposes the created profile',
    () async {
      final repository = _ProfileRepository();
      final container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith(() => _AuthenticatedNotifier(user)),
          profileRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      expect(await container.read(profileProvider.future), isNull);
      final draft = ProfileModel.fromUser(
        user,
      ).copyWith(categoryId: 1, cityId: 2, workCategory: 'Driver');

      await container.read(profileProvider.notifier).save(draft);
      final created = await container.read(profileProvider.future);

      expect(repository.updateCount, 1);
      expect(repository.readCount, 2);
      expect(created?.workCategory, 'Driver');
      expect(created?.categoryId, 1);
    },
  );
}

WorkerProfile _workerProfile() => WorkerProfile(
  userId: 'worker-1',
  name: 'Test Worker',
  categoryId: 1,
  categoryName: 'Driver',
  cityId: 2,
  cityName: 'Pune',
  cityState: 'Maharashtra',
  isFresher: false,
  experienceYears: 3,
  experienceDetails: 'Delivery driving',
  skills: 'Navigation',
  interests: 'Driving',
  availability: 'Immediate',
  about: 'Reliable driver',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026),
);

class _ProfileLocalJobsRepository extends LocalJobsRepository {
  _ProfileLocalJobsRepository(this.response, {this.error})
    : super(LocalJobsApiService(Dio()));

  final WorkerProfile? response;
  final Object? error;

  @override
  Future<WorkerProfile?> getMyWorkerProfile() async {
    if (error case final Object error) throw error;
    return response;
  }
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

class _AuthenticatedNotifier extends AuthNotifier {
  _AuthenticatedNotifier(this.user);

  final UserModel user;

  @override
  AuthState build() => Authenticated(user);
}

class _ProfileRepository implements ProfileRepository {
  _ProfileRepository({this.getError});

  final Object? getError;
  int readCount = 0;
  int updateCount = 0;
  ProfileModel? saved;

  @override
  Future<ProfileModel?> getProfile(UserModel user) async {
    readCount++;
    if (getError case final Object error) throw error;
    return saved;
  }

  @override
  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    updateCount++;
    saved = profile;
    return profile;
  }
}

class _TestUserAccountRepository extends UserAccountRepository {
  _TestUserAccountRepository(this.user) : super(UserAccountApiService(Dio()));

  final UserModel user;

  @override
  Future<UserModel> getMe() async => user;
}
