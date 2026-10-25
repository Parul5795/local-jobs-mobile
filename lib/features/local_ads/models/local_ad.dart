import '../../localjobs/models/localjobs_models.dart';

class LocalAd {
  final String id,
      publisher,
      location,
      type,
      title,
      description,
      postedAt,
      contact,
      price;
  final bool featured, isActive;
  final String? area, ownerId;
  final int? categoryId, cityId;
  final List<String> imageUrls;
  const LocalAd({
    required this.id,
    required this.publisher,
    required this.location,
    required this.type,
    required this.title,
    required this.description,
    required this.postedAt,
    required this.contact,
    this.price = '',
    this.featured = false,
    this.isActive = true,
    this.area,
    this.ownerId,
    this.categoryId,
    this.cityId,
    this.imageUrls = const [],
  });
  factory LocalAd.fromBackend(ClassifiedAd ad) => LocalAd(
    id: ad.id,
    publisher: ad.userName,
    location: ad.location,
    area: ad.area,
    type: ad.categoryName,
    title: ad.title,
    description: ad.description,
    postedAt: ad.postedAt,
    contact: '',
    price: ad.priceLabel,
    featured: ad.isFeatured,
    isActive: ad.isActive,
    ownerId: ad.userId,
    categoryId: ad.categoryId,
    cityId: ad.cityId,
    imageUrls: ad.imageUrls,
  );
  String get category => switch (type.toLowerCase()) {
    'jobs/work' || 'jobs / work' => 'Jobs/Work',
    'services' => 'Services',
    'business/shop' || 'business' => 'Business/Shop',
    'products for sale' || 'sale' || 'product' => 'Products for Sale',
    'tuition' => 'Tuition',
    'house/room' || 'house' => 'House/Room',
    'vehicle' => 'Vehicle',
    'local announcement' || 'announcement' => 'Local Announcement',
    _ => 'Other',
  };
}
