import 'package:flutter_test/flutter_test.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_models.dart';
import 'package:local_jobs_mobile/features/localjobs/models/localjobs_requests.dart';

void main() {
  test(
    'job response parses nullable salary, date, location and owner fields',
    () {
      final job = JobPost.fromJson({
        'id': 'job-id',
        'title': 'Driver needed',
        'description': 'Local trips',
        'salary': null,
        'categoryId': 1,
        'categoryName': 'Driver',
        'cityId': 2,
        'cityName': 'Pune',
        'cityState': 'Maharashtra',
        'userId': 'employer-id',
        'userName': 'Local family',
        'isActive': true,
        'createdAt': '2026-10-01T00:00:00Z',
        'updatedAt': '2026-10-02T00:00:00Z',
        'workType': 'Part-time',
        'experienceRequirement': 'Fresher welcome',
        'paymentPeriod': 'Daily',
        'startDate': null,
        'status': 'Active',
        'area': 'Koregaon Park',
      });
      expect(job.location, 'Koregaon Park, Pune, Maharashtra');
      expect(job.salary, isNull);
      expect(job.startDate, isNull);
      expect(job.paymentPeriod, 'Daily');
      expect(job.userId, 'employer-id');
    },
  );

  test('worker profile parses media/contact count without a phone field', () {
    final profile = WorkerProfile.fromJson({
      'userId': 'worker-id',
      'name': 'Sam',
      'categoryId': 1,
      'categoryName': 'Driver',
      'cityId': 1,
      'cityName': 'Pune',
      'cityState': 'Maharashtra',
      'isFresher': false,
      'experienceYears': 2,
      'experienceDetails': 'Delivery work',
      'skills': 'Driving',
      'interests': 'Local work',
      'availability': 'Today',
      'about': 'Available',
      'createdAt': '2026-10-01T00:00:00Z',
      'updatedAt': '2026-10-01T00:00:00Z',
      'area': 'Kalyani Nagar',
      'profileImageUrl': 'https://example.test/photo.jpg',
      'contactCount': 4,
    });
    expect(profile.profileImageUrl, 'https://example.test/photo.jpg');
    expect(profile.contactCount, 4);
    expect(profile.experienceYears, 2);
  });

  test('classified ad response parses category, price and image URLs', () {
    final ad = ClassifiedAd.fromJson({
      'id': 'ad-id',
      'title': 'Plumber available',
      'description': 'Local repairs',
      'adCategoryId': 2,
      'adCategoryName': 'Services',
      'cityId': 1,
      'cityName': 'Pune',
      'cityState': 'Maharashtra',
      'price': 500,
      'userId': 'owner-id',
      'userName': 'Sam',
      'isActive': true,
      'createdAt': '2026-10-01T00:00:00Z',
      'updatedAt': '2026-10-01T00:00:00Z',
      'area': 'Camp',
      'imageUrls': ['https://example.test/ad.jpg'],
    });
    expect(ad.categoryName, 'Services');
    expect(ad.price, 500);
    expect(ad.imageUrls, ['https://example.test/ad.jpg']);
  });

  test('write request JSON uses backend field names', () {
    final job = JobWriteRequest(
      title: 'Cook needed',
      description: 'Evening work',
      categoryId: 3,
      cityId: 1,
      workType: 'Part-time',
      experienceRequirement: 'Any',
      paymentPeriod: 'Hourly',
      salary: 300,
      area: 'Camp',
      isActive: true,
    );
    expect(job.toJson(), containsPair('categoryId', 3));
    expect(job.toJson(), containsPair('paymentPeriod', 'Hourly'));
    expect(job.toJson(), containsPair('isActive', true));
    final worker = WorkerProfileWriteRequest(
      categoryId: 1,
      cityId: 1,
      isFresher: true,
      skills: 'Driving',
      area: 'Camp',
      profileImageUrl: 'https://example.test/photo.jpg',
    );
    expect(
      worker.toJson(),
      containsPair('profileImageUrl', 'https://example.test/photo.jpg'),
    );
    expect(worker.toJson(), containsPair('isFresher', true));
    final ad = AdWriteRequest(
      title: 'Shop open',
      description: 'Visit us',
      adCategoryId: 3,
      cityId: 1,
      imageUrls: const ['https://example.test/ad.jpg'],
    );
    expect(ad.toJson(), containsPair('adCategoryId', 3));
    expect(ad.toJson(), contains('imageUrls'));
    expect(
      const ContactWriteRequest(
        workerUserId: 'worker-id',
        method: 'Call',
      ).toJson(),
      {'workerUserId': 'worker-id', 'method': 'Call'},
    );
    expect(
      const ContactWriteRequest(
        workerUserId: 'worker-id',
        method: 'WhatsApp',
      ).toJson()['method'],
      'WhatsApp',
    );
  });

  test('pagination response maps page metadata', () {
    final result = PagedResult<JobPost>.fromJson({
      'items': [],
      'page': 2,
      'pageSize': 20,
      'totalCount': 41,
      'totalPages': 3,
    }, JobPost.fromJson);
    expect(result.page, 2);
    expect(result.totalPages, 3);
    expect(result.hasMore, isTrue);
  });
}
