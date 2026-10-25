class JobWriteRequest {
  final String title,
      description,
      workType,
      experienceRequirement,
      paymentPeriod;
  final double? salary;
  final int categoryId, cityId;
  final DateTime? startDate;
  final String? area;
  final bool? isActive;
  const JobWriteRequest({
    required this.title,
    required this.description,
    required this.categoryId,
    required this.cityId,
    required this.workType,
    required this.experienceRequirement,
    required this.paymentPeriod,
    this.salary,
    this.startDate,
    this.area,
    this.isActive,
  });
  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'description': description.trim(),
    'salary': salary,
    'categoryId': categoryId,
    'cityId': cityId,
    'workType': workType,
    'experienceRequirement': experienceRequirement,
    'paymentPeriod': paymentPeriod,
    'startDate': startDate?.toUtc().toIso8601String(),
    'area': area?.trim(),
    if (isActive != null) 'isActive': isActive,
  };
}

class WorkerProfileWriteRequest {
  final int categoryId, cityId;
  final bool isFresher;
  final double? experienceYears;
  final String? experienceDetails,
      skills,
      interests,
      availability,
      about,
      area,
      profileImageUrl;
  const WorkerProfileWriteRequest({
    required this.categoryId,
    required this.cityId,
    required this.isFresher,
    this.experienceYears,
    this.experienceDetails,
    this.skills,
    this.interests,
    this.availability,
    this.about,
    this.area,
    this.profileImageUrl,
  });
  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'cityId': cityId,
    'isFresher': isFresher,
    'experienceYears': experienceYears,
    'experienceDetails': experienceDetails,
    'skills': skills,
    'interests': interests,
    'availability': availability,
    'about': about,
    'area': area,
    'profileImageUrl': profileImageUrl,
  };
}

class AdWriteRequest {
  final String title, description;
  final int adCategoryId, cityId;
  final double? price;
  final String? area;
  final List<String> imageUrls;
  final bool? isActive;
  const AdWriteRequest({
    required this.title,
    required this.description,
    required this.adCategoryId,
    required this.cityId,
    this.price,
    this.area,
    this.imageUrls = const [],
    this.isActive,
  });
  Map<String, dynamic> toJson() => {
    'title': title.trim(),
    'description': description.trim(),
    'adCategoryId': adCategoryId,
    'cityId': cityId,
    'price': price,
    'area': area?.trim(),
    'imageUrls': imageUrls,
    if (isActive != null) 'isActive': isActive,
  };
}

class ContactWriteRequest {
  final String workerUserId;
  final String method;
  const ContactWriteRequest({required this.workerUserId, required this.method});
  Map<String, dynamic> toJson() => {
    'workerUserId': workerUserId,
    'method': method,
  };
}
