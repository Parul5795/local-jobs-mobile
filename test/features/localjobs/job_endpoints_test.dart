import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/localjobs/data/localjobs_api_service.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_requests.dart';

void main() {
  test(
    'job create, own-list, update and deactivate use Jobs endpoints',
    () async {
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
                data: options.path == '/api/jobs/me'
                    ? {
                        'items': [_jobJson],
                        'page': 1,
                        'pageSize': 20,
                        'totalCount': 1,
                        'totalPages': 1,
                      }
                    : options.path.endsWith('/deactivate')
                    ? <String, dynamic>{}
                    : _jobJson,
              ),
            );
          },
        ),
      );
      final service = LocalJobsApiService(dio);
      const request = JobWriteRequest(
        title: 'Driver needed',
        description: 'Local trips',
        categoryId: 3,
        cityId: 4,
        workType: 'Full-time',
        experienceRequirement: 'Any',
        paymentPeriod: 'Monthly',
        salary: 20000,
      );

      await service.createJob(request);
      final ownJobs = await service.getMyJobs();
      await service.updateJob(
        'job-1',
        const JobWriteRequest(
          title: 'Driver needed',
          description: 'Local trips',
          categoryId: 3,
          cityId: 4,
          workType: 'Full-time',
          experienceRequirement: 'Any',
          paymentPeriod: 'Monthly',
          salary: 20000,
          isActive: true,
        ),
      );
      await service.deactivateJob('job-1');

      expect(requests.map((request) => '${request.method} ${request.path}'), [
        'POST /api/jobs',
        'GET /api/jobs/me',
        'PUT /api/jobs/job-1',
        'PUT /api/jobs/job-1/deactivate',
      ]);
      final body = Map<String, dynamic>.from(requests.first.data as Map);
      final updateBody = Map<String, dynamic>.from(requests[2].data as Map);
      expect(updateBody['isActive'], isTrue);
      expect(body['title'], 'Driver needed');
      expect(body['categoryId'], 3);
      expect(body['cityId'], 4);
      expect(body.containsKey('userId'), isFalse);
      expect(body.containsKey('employerId'), isFalse);
      expect(ownJobs.items.single.id, 'job-1');
    },
  );
}

final _jobJson = <String, dynamic>{
  'id': 'job-1',
  'title': 'Driver needed',
  'description': 'Local trips',
  'salary': 20000,
  'categoryId': 3,
  'categoryName': 'Driver',
  'cityId': 4,
  'cityName': 'Pune',
  'cityState': 'Maharashtra',
  'userId': 'employer-1',
  'userName': 'Local family',
  'isActive': true,
  'createdAt': '2026-10-31T00:00:00Z',
  'updatedAt': '2026-10-31T00:00:00Z',
  'workType': 'Full-time',
  'experienceRequirement': 'Any',
  'paymentPeriod': 'Monthly',
  'startDate': null,
  'status': 'Active',
};
