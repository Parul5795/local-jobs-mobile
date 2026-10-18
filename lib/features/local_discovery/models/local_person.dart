class LocalPerson {
  final String id;
  final String name;
  final String primaryWork;
  final String location;
  final double distanceKm;
  final String experience;
  final List<String> skills;
  final List<String> interests;
  final String availability;
  final String about;
  final int contactCount;
  final String? photoUrl;
  final String phone;

  const LocalPerson({
    required this.id,
    required this.name,
    required this.primaryWork,
    required this.location,
    required this.distanceKm,
    required this.experience,
    required this.skills,
    required this.interests,
    required this.availability,
    required this.about,
    required this.contactCount,
    required this.phone,
    this.photoUrl,
  });

  LocalPerson copyWith({int? contactCount}) => LocalPerson(
    id: id,
    name: name,
    primaryWork: primaryWork,
    location: location,
    distanceKm: distanceKm,
    experience: experience,
    skills: skills,
    interests: interests,
    availability: availability,
    about: about,
    contactCount: contactCount ?? this.contactCount,
    phone: phone,
    photoUrl: photoUrl,
  );

  bool matches(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    final searchable = [
      name,
      primaryWork,
      location,
      experience,
      availability,
      about,
      ...skills,
      ...interests,
    ].join(' ').toLowerCase();
    return searchable.contains(term);
  }
}
