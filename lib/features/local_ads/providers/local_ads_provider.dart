import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_ad.dart';

final localAdsProvider = NotifierProvider<LocalAdsNotifier, List<LocalAd>>(
  LocalAdsNotifier.new,
);

class LocalAdsNotifier extends Notifier<List<LocalAd>> {
  @override
  List<LocalAd> build() => const [
    LocalAd(
      id: 'ad-fresh-mart',
      publisher: 'Fresh Mart',
      location: 'Kalyani Nagar, Pune',
      type: 'Business',
      title: 'New shop opening',
      description:
          'Fresh Mart is now open. Visit us for groceries and daily essentials.',
      postedAt: 'Today',
      contact: '+919876540001',
      featured: true,
    ),
    LocalAd(
      id: 'ad-ac-repair',
      publisher: 'Cool Home Services',
      location: 'Viman Nagar, Pune',
      type: 'Service',
      title: 'AC repair in your area',
      description: 'Home AC servicing and repairs with same-day visits nearby.',
      postedAt: 'Yesterday',
      contact: '+919876540002',
      featured: true,
    ),
    LocalAd(
      id: 'ad-tuition',
      publisher: 'Meena Joshi',
      location: 'Kalyani Nagar, Pune',
      type: 'Service',
      title: 'Math tuition for classes 6–10',
      description:
          'Small evening batches and one-to-one home tuition available.',
      postedAt: '2 days ago',
      contact: '+919876540003',
    ),
    LocalAd(
      id: 'ad-delivery',
      publisher: 'Green Basket',
      location: 'Koregaon Park, Pune',
      type: 'Work opportunity',
      title: 'Looking for a delivery helper',
      description:
          'Local morning delivery work. Fresher candidates are welcome.',
      postedAt: '3 days ago',
      contact: '+919876540004',
    ),
    LocalAd(
      id: 'ad-driver',
      publisher: 'Kulkarni Family',
      location: 'Kalyani Nagar, Pune',
      type: 'Work opportunity',
      title: 'Looking for a family driver',
      description:
          'Daytime local driving. A calm, experienced driver is preferred.',
      postedAt: '4 days ago',
      contact: '+919876540005',
    ),
    LocalAd(
      id: 'ad-shop-helper',
      publisher: 'Fresh Mart',
      location: 'Kalyani Nagar, Pune',
      type: 'Work opportunity',
      title: 'Shop helper wanted',
      description: 'Help with stocking and customers. Freshers are welcome.',
      postedAt: '4 days ago',
      contact: '+919876540001',
    ),
    LocalAd(
      id: 'ad-plumber-available',
      publisher: 'Imran Shaikh',
      location: 'Viman Nagar, Pune',
      type: 'Service',
      title: 'Plumber available',
      description:
          'Experienced plumber available for home repairs and installations.',
      postedAt: 'Today',
      contact: '+919876543213',
    ),
    LocalAd(
      id: 'ad-home-rent',
      publisher: 'Neighbourhood Homes',
      location: 'Hadapsar, Pune',
      type: 'House',
      title: '1 BHK home for rent',
      description:
          'Bright one-bedroom home close to local shops and bus routes.',
      postedAt: 'Yesterday',
      contact: '+919876540008',
    ),
    LocalAd(
      id: 'ad-bicycle-sale',
      publisher: 'Local resident',
      location: 'Yerwada, Pune',
      type: 'Product',
      title: 'Bicycle for sale',
      description: 'Well-kept city bicycle available for pickup nearby.',
      postedAt: '2 days ago',
      contact: '+919876540009',
    ),
  ];

  void add(LocalAd ad) => state = [ad, ...state];
}
