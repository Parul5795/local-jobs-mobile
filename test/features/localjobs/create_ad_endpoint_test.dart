import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_api_service.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_requests.dart';

void main() {
  test('create ad posts to the backend new-ad endpoint', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:5064'));
    RequestOptions? capturedRequest;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequest = options;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'id': 'ad-id',
                'title': 'Local service',
                'description': 'Available nearby',
                'adCategoryId': 2,
                'adCategoryName': 'Services',
                'cityId': 1,
                'cityName': 'Pune',
                'cityState': 'Maharashtra',
                'userId': 'user-id',
                'userName': 'Local user',
                'isActive': true,
                'createdAt': '2026-10-25T00:00:00Z',
                'updatedAt': '2026-10-25T00:00:00Z',
              },
            ),
          );
        },
      ),
    );

    final ad = await LocalJobsApiService(dio).createAd(
      const AdWriteRequest(
        title: 'Local service',
        description: 'Available nearby',
        adCategoryId: 2,
        cityId: 1,
      ),
    );

    expect(capturedRequest?.method, 'POST');
    expect(capturedRequest?.path, '/api/ads/new');
    expect(capturedRequest?.data['adCategoryId'], 2);
    expect(ad.id, 'ad-id');
  });
}
