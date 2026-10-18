import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_person.dart';

final localPeopleProvider =
    NotifierProvider<LocalPeopleNotifier, List<LocalPerson>>(
      LocalPeopleNotifier.new,
    );

class LocalPeopleNotifier extends Notifier<List<LocalPerson>> {
  @override
  List<LocalPerson> build() => const [
    LocalPerson(
      id: 'person-rajesh',
      name: 'Rajesh Kumar',
      primaryWork: 'Driver',
      location: 'Kalyani Nagar, Pune',
      distanceKm: 2.3,
      experience: '5 years experience',
      skills: ['City routes', 'Long distance', 'Family driver'],
      interests: ['Personal driver', 'Local trips'],
      availability: 'Available now',
      about: 'Reliable local driver who knows Pune and nearby routes.',
      contactCount: 24,
      phone: '+919876543210',
    ),
    LocalPerson(
      id: 'person-sunita',
      name: 'Sunita Pawar',
      primaryWork: 'House Help',
      location: 'Viman Nagar, Pune',
      distanceKm: 3.1,
      experience: '3 years experience',
      skills: ['Cleaning', 'Cooking', 'Child care'],
      interests: ['House help', 'Cook'],
      availability: 'Available this week',
      about: 'Friendly and experienced household helper.',
      contactCount: 18,
      phone: '+919876543211',
    ),
    LocalPerson(
      id: 'person-aman',
      name: 'Aman Sharma',
      primaryWork: 'Fresher',
      location: 'Viman Nagar, Pune',
      distanceKm: 3.2,
      experience: 'Fresher',
      skills: ['Delivery', 'Packing', 'Teamwork'],
      interests: ['Shop Helper', 'Delivery', 'Warehouse'],
      availability: 'Available now',
      about: 'Looking for a first local job and ready to learn.',
      contactCount: 7,
      phone: '+919876543212',
    ),
    LocalPerson(
      id: 'person-imran',
      name: 'Imran Shaikh',
      primaryWork: 'Plumber',
      location: 'Koregaon Park, Pune',
      distanceKm: 2.4,
      experience: '8 years experience',
      skills: ['Pipe fitting', 'Repairs', 'Water heaters'],
      interests: ['Plumbing', 'Home repairs'],
      availability: 'Available today',
      about: 'Independent plumber for home repairs and installations.',
      contactCount: 31,
      phone: '+919876543213',
    ),
    LocalPerson(
      id: 'person-meena',
      name: 'Meena Joshi',
      primaryWork: 'Tutor',
      location: 'Kalyani Nagar, Pune',
      distanceKm: 1.7,
      experience: '6 years experience',
      skills: ['Maths', 'Science', 'Classes 6–10'],
      interests: ['Home tuition', 'Evening classes'],
      availability: 'Evenings',
      about: 'Patient home tutor for middle and secondary school students.',
      contactCount: 15,
      phone: '+919876543214',
    ),
  ];

  LocalPerson? findById(String id) =>
      state.where((person) => person.id == id).firstOrNull;

  void recordContact(String id) {
    state = [
      for (final person in state)
        if (person.id == id)
          person.copyWith(contactCount: person.contactCount + 1)
        else
          person,
    ];
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
