import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/profile/data/user_account_api_service.dart';
import 'package:local_jobs_mobile/features/profile/models/update_user_request.dart';

void main() {
  test('GET and PUT use the backend user/me contract', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5064'));
    final requests = <RequestOptions>[];
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'userId': 'user-1',
                'name': 'Updated User',
                'email': 'updated@example.test',
                'phoneNumber': '5551234567',
                'accountType': 'JobSeeker',
              },
            ),
          );
        },
      ),
    );
    final api = UserAccountApiService(dio);

    final loaded = await api.getMe();
    final updated = await api.updateMe(
      const UpdateUserRequest(
        name: 'Updated User',
        email: 'updated@example.test',
        phoneNumber: '5551234567',
      ),
    );

    expect(requests[0].method, 'GET');
    expect(requests[0].path, '/api/users/me');
    expect(requests[1].method, 'PUT');
    expect(requests[1].path, '/api/users/me');
    expect(requests[1].data, {
      'name': 'Updated User',
      'email': 'updated@example.test',
      'phoneNumber': '5551234567',
    });
    expect(loaded.fullName, 'Updated User');
    expect(loaded.email, 'updated@example.test');
    expect(loaded.phone, '5551234567');
    expect(updated.role, 'JobSeeker');
  });
}
