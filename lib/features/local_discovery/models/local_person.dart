import '../../localjobs/models/localjobs_models.dart';

class LocalPerson {
  final String id, name, primaryWork, location, experience, availability, about;
  final List<String> skills, interests;
  final int contactCount;
  final double? distanceKm;
  final String? photoUrl, phone;
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
    this.phone,
    this.photoUrl,
  });
  factory LocalPerson.fromWorker(WorkerProfile worker) => LocalPerson(
    id: worker.userId,
    name: worker.name,
    primaryWork: worker.categoryName,
    location: worker.location,
    distanceKm: null,
    experience: worker.experienceLabel,
    skills: worker.skills
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(),
    interests: worker.interests
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(),
    availability: worker.availability,
    about: worker.about,
    contactCount: worker.contactCount,
    photoUrl: worker.profileImageUrl,
  );
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
    return [
      name,
      primaryWork,
      location,
      experience,
      availability,
      about,
      ...skills,
      ...interests,
    ].join(' ').toLowerCase().contains(term);
  }
}
