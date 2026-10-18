import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_job.dart';

final localJobsProvider = NotifierProvider<LocalJobsNotifier, List<LocalJob>>(
  LocalJobsNotifier.new,
);

class LocalJobsNotifier extends Notifier<List<LocalJob>> {
  @override
  List<LocalJob> build() => const [
    LocalJob(
      id: 'local-driver',
      title: 'Family Driver Needed',
      category: 'Driver',
      location: 'Kalyani Nagar',
      distanceKm: 2.5,
      pay: '₹18,000–₹22,000',
      workType: 'Full-time',
      experience: 'Experienced preferred',
      availability: 'Immediate',
      description:
          'Family looking for a careful driver for local trips and school pickup.',
      requirements: 'Valid driving licence and familiarity with Pune routes.',
      employer: 'Kulkarni Family',
      contact: '+919876540005',
      postedAt: 'Today',
    ),
    LocalJob(
      id: 'local-shop-helper',
      title: 'Shop Helper Wanted',
      category: 'Shop Helper',
      location: 'Viman Nagar',
      distanceKm: 3.2,
      pay: '₹12,000–₹15,000',
      workType: 'Full-time',
      experience: 'Fresher welcome',
      availability: 'This week',
      description:
          'Help with stocking shelves and serving customers at a neighbourhood shop.',
      requirements: 'Friendly and punctual. Training provided.',
      employer: 'Fresh Mart',
      contact: '+919876540001',
      postedAt: 'Today',
    ),
    LocalJob(
      id: 'local-plumber',
      title: 'Plumber for Home Repairs',
      category: 'Plumber',
      location: 'Koregaon Park',
      distanceKm: 2.4,
      pay: '₹700–₹1,200 per visit',
      workType: 'Part-time',
      experience: 'Experienced',
      availability: 'Flexible',
      description:
          'Need a local plumber for regular household maintenance and small repairs.',
      requirements: 'Bring basic plumbing tools.',
      employer: 'A nearby homeowner',
      contact: '+919876540006',
      postedAt: 'Yesterday',
    ),
    LocalJob(
      id: 'local-tutor',
      title: 'Evening Maths Tutor',
      category: 'Tutor',
      location: 'Yerwada',
      distanceKm: 4.1,
      pay: '₹500 per class',
      workType: 'Part-time',
      experience: 'Any experience',
      availability: 'Evenings',
      description: 'Looking for friendly maths help for a student in class 8.',
      requirements: 'Comfortable teaching middle-school maths.',
      employer: 'A local family',
      contact: '+919876540007',
      postedAt: '2 days ago',
    ),
  ];

  void add(LocalJob job) => state = [job, ...state];

  LocalJob? findById(String id) =>
      state.where((job) => job.id == id).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
