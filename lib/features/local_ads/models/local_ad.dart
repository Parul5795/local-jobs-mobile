class LocalAd {
  final String id;
  final String publisher;
  final String location;
  final String type;
  final String title;
  final String description;
  final String postedAt;
  final String contact;
  final String price;
  final bool featured;

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
  });

  String get category => switch (type.toLowerCase()) {
    'work opportunity' || 'job' => 'Jobs / Work',
    'business' => 'Business',
    'product' || 'sale' => 'Sale',
    'tuition' => 'Tuition',
    'house' => 'House',
    'vehicle' => 'Vehicle',
    'service' when title.toLowerCase().contains('tuition') => 'Tuition',
    'service' => 'Services',
    _ => 'Other',
  };
}
