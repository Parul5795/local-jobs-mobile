import 'package:equatable/equatable.dart';

int _intValue(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;
double? _doubleValue(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse('$value');
String _stringValue(dynamic value, [String fallback = '']) =>
    value?.toString() ?? fallback;
DateTime _dateValue(dynamic value) =>
    DateTime.tryParse(_stringValue(value))?.toUtc() ??
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
DateTime? _nullableDate(dynamic value) =>
    value == null ? null : DateTime.tryParse(_stringValue(value))?.toUtc();

class LookupItem extends Equatable {
  final int id;
  final String name;
  const LookupItem({required this.id, required this.name});
  factory LookupItem.fromJson(Map<String, dynamic> json) =>
      LookupItem(id: _intValue(json['id']), name: _stringValue(json['name']));
  @override
  List<Object?> get props => [id, name];
}

class CityItem extends Equatable {
  final int id;
  final String name;
  final String state;
  const CityItem({required this.id, required this.name, required this.state});
  factory CityItem.fromJson(Map<String, dynamic> json) => CityItem(
    id: _intValue(json['id']),
    name: _stringValue(json['name']),
    state: _stringValue(json['state']),
  );
  String get label => '$name, $state';
  @override
  List<Object?> get props => [id, name, state];
}

class PagedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });
  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) => PagedResult<T>(
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => parse(Map<String, dynamic>.from(item)))
        .toList(),
    page: _intValue(json['page']),
    pageSize: _intValue(json['pageSize']),
    totalCount: _intValue(json['totalCount']),
    totalPages: _intValue(json['totalPages']),
  );
  bool get hasMore => page < totalPages;
}

class JobPost extends Equatable {
  final String id,
      title,
      description,
      categoryName,
      cityName,
      cityState,
      userId,
      userName,
      workType,
      experienceRequirement,
      paymentPeriod,
      status;
  final int categoryId, cityId;
  final double? salary;
  final bool isActive;
  final DateTime createdAt, updatedAt;
  final DateTime? startDate;
  final String? area;
  const JobPost({
    required this.id,
    required this.title,
    required this.description,
    required this.salary,
    required this.categoryId,
    required this.categoryName,
    required this.cityId,
    required this.cityName,
    required this.cityState,
    required this.userId,
    required this.userName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.workType,
    required this.experienceRequirement,
    required this.paymentPeriod,
    required this.startDate,
    required this.status,
    this.area,
  });
  factory JobPost.fromJson(Map<String, dynamic> json) => JobPost(
    id: _stringValue(json['id']),
    title: _stringValue(json['title']),
    description: _stringValue(json['description']),
    salary: _doubleValue(json['salary']),
    categoryId: _intValue(json['categoryId']),
    categoryName: _stringValue(json['categoryName']),
    cityId: _intValue(json['cityId']),
    cityName: _stringValue(json['cityName']),
    cityState: _stringValue(json['cityState']),
    userId: _stringValue(json['userId']),
    userName: _stringValue(json['userName']),
    isActive: json['isActive'] as bool? ?? false,
    createdAt: _dateValue(json['createdAt']),
    updatedAt: _dateValue(json['updatedAt']),
    workType: _stringValue(json['workType']),
    experienceRequirement: _stringValue(json['experienceRequirement']),
    paymentPeriod: _stringValue(json['paymentPeriod'], 'Monthly'),
    startDate: _nullableDate(json['startDate']),
    status: _stringValue(json['status'], 'Active'),
    area: json['area'] as String?,
  );
  String get location => [
    if (area?.isNotEmpty ?? false) area!,
    cityName,
    cityState,
  ].where((part) => part.isNotEmpty).join(', ');
  String get salaryLabel => salary == null
      ? 'Payment negotiable'
      : '₹${salary!.toStringAsFixed(salary! % 1 == 0 ? 0 : 2)} / ${paymentPeriod.toLowerCase()}';
  String get postedAt => _relativeDate(createdAt);
  String get company => userName;
  String get category => categoryName;
  String get employmentType => workType;
  String get experienceLevel => experienceRequirement;
  bool get isFeatured => false;
  List<String> get skills => const [];
  List<String> get requirements => const [];
  Map<String, dynamic> toWriteJson({required bool includeStatus}) => {
    'title': title,
    'description': description,
    'salary': salary,
    'categoryId': categoryId,
    'cityId': cityId,
    'area': area,
    'workType': workType,
    'experienceRequirement': experienceRequirement,
    'paymentPeriod': paymentPeriod,
    'startDate': startDate?.toUtc().toIso8601String(),
    if (includeStatus) 'isActive': isActive,
  };
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    salary,
    categoryId,
    categoryName,
    cityId,
    cityName,
    cityState,
    userId,
    userName,
    isActive,
    createdAt,
    updatedAt,
    workType,
    experienceRequirement,
    paymentPeriod,
    startDate,
    status,
    area,
  ];
}

class WorkerProfile extends Equatable {
  final String userId,
      name,
      categoryName,
      cityName,
      cityState,
      experienceDetails,
      skills,
      interests,
      availability,
      about;
  final int categoryId, cityId, contactCount;
  final bool isFresher;
  final double? experienceYears;
  final DateTime createdAt, updatedAt;
  final String? area, profileImageUrl;
  const WorkerProfile({
    required this.userId,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.cityId,
    required this.cityName,
    required this.cityState,
    required this.isFresher,
    required this.experienceYears,
    required this.experienceDetails,
    required this.skills,
    required this.interests,
    required this.availability,
    required this.about,
    required this.createdAt,
    required this.updatedAt,
    this.area,
    this.profileImageUrl,
    this.contactCount = 0,
  });
  factory WorkerProfile.fromJson(Map<String, dynamic> json) => WorkerProfile(
    userId: _stringValue(json['userId']),
    name: _stringValue(json['name']),
    categoryId: _intValue(json['categoryId']),
    categoryName: _stringValue(json['categoryName']),
    cityId: _intValue(json['cityId']),
    cityName: _stringValue(json['cityName']),
    cityState: _stringValue(json['cityState']),
    isFresher: json['isFresher'] as bool? ?? false,
    experienceYears: _doubleValue(json['experienceYears']),
    experienceDetails: _stringValue(json['experienceDetails']),
    skills: _stringValue(json['skills']),
    interests: _stringValue(json['interests']),
    availability: _stringValue(json['availability']),
    about: _stringValue(json['about']),
    createdAt: _dateValue(json['createdAt']),
    updatedAt: _dateValue(json['updatedAt']),
    area: json['area'] as String?,
    profileImageUrl: json['profileImageUrl'] as String?,
    contactCount: _intValue(json['contactCount']),
  );
  String get location => [
    if (area?.isNotEmpty ?? false) area!,
    cityName,
    cityState,
  ].where((part) => part.isNotEmpty).join(', ');
  String get experienceLabel => isFresher
      ? 'Fresher'
      : [
          if (experienceYears != null)
            '${experienceYears!.toStringAsFixed(experienceYears! % 1 == 0 ? 0 : 1)} years',
          experienceDetails,
        ].where((part) => part.isNotEmpty).join(' · ');
  @override
  List<Object?> get props => [
    userId,
    name,
    categoryId,
    categoryName,
    cityId,
    cityName,
    cityState,
    isFresher,
    experienceYears,
    experienceDetails,
    skills,
    interests,
    availability,
    about,
    createdAt,
    updatedAt,
    area,
    profileImageUrl,
    contactCount,
  ];
}

class WorkerSearchResult extends Equatable {
  final WorkerProfile profile;
  const WorkerSearchResult(this.profile);
  factory WorkerSearchResult.fromJson(Map<String, dynamic> json) =>
      WorkerSearchResult(WorkerProfile.fromJson(json));
  @override
  List<Object?> get props => [profile];
}

class ClassifiedAd extends Equatable {
  final String id,
      title,
      description,
      categoryName,
      cityName,
      cityState,
      userId,
      userName;
  final int categoryId, cityId;
  final double? price;
  final bool isActive;
  final DateTime createdAt, updatedAt;
  final String? area;
  final List<String> imageUrls;
  const ClassifiedAd({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.cityId,
    required this.cityName,
    required this.cityState,
    required this.price,
    required this.userId,
    required this.userName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.area,
    this.imageUrls = const [],
  });
  factory ClassifiedAd.fromJson(Map<String, dynamic> json) => ClassifiedAd(
    id: _stringValue(json['id']),
    title: _stringValue(json['title']),
    description: _stringValue(json['description']),
    categoryId: _intValue(json['adCategoryId']),
    categoryName: _stringValue(json['adCategoryName']),
    cityId: _intValue(json['cityId']),
    cityName: _stringValue(json['cityName']),
    cityState: _stringValue(json['cityState']),
    price: _doubleValue(json['price']),
    userId: _stringValue(json['userId']),
    userName: _stringValue(json['userName']),
    isActive: json['isActive'] as bool? ?? false,
    createdAt: _dateValue(json['createdAt']),
    updatedAt: _dateValue(json['updatedAt']),
    area: json['area'] as String?,
    imageUrls: (json['imageUrls'] as List? ?? const [])
        .whereType<String>()
        .toList(),
  );
  String get location => [
    if (area?.isNotEmpty ?? false) area!,
    cityName,
    cityState,
  ].where((part) => part.isNotEmpty).join(', ');
  String get priceLabel => price == null
      ? ''
      : '₹${price!.toStringAsFixed(price! % 1 == 0 ? 0 : 2)}';
  String get postedAt => _relativeDate(createdAt);
  bool get isFeatured => false;
  @override
  List<Object?> get props => [
    id,
    title,
    description,
    categoryId,
    categoryName,
    cityId,
    cityName,
    cityState,
    price,
    userId,
    userName,
    isActive,
    createdAt,
    updatedAt,
    area,
    imageUrls,
  ];
}

class ContactResult {
  final String workerUserId, method, phoneNumber;
  final int contactCount;
  const ContactResult({
    required this.workerUserId,
    required this.method,
    required this.phoneNumber,
    required this.contactCount,
  });
  factory ContactResult.fromJson(Map<String, dynamic> json) => ContactResult(
    workerUserId: _stringValue(json['workerUserId']),
    method: _stringValue(json['method']),
    phoneNumber: _stringValue(json['phoneNumber']),
    contactCount: _intValue(json['contactCount']),
  );
}

String _relativeDate(DateTime date) {
  final difference = DateTime.now().toUtc().difference(date.toUtc());
  if (difference.inMinutes < 60) {
    return difference.inMinutes <= 1
        ? 'Just now'
        : '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 7) return '${difference.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
