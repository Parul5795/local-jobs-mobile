class LocalJob {
  final String id;
  final String title;
  final String category;
  final String location;
  final double distanceKm;
  final String pay;
  final String workType;
  final String experience;
  final String availability;
  final String description;
  final String requirements;
  final String employer;
  final String? employerId;
  final String contact;
  final String postedAt;

  const LocalJob({
    required this.id,
    required this.title,
    required this.category,
    required this.location,
    required this.distanceKm,
    required this.pay,
    required this.workType,
    required this.experience,
    required this.availability,
    required this.description,
    required this.requirements,
    required this.employer,
    this.employerId,
    required this.contact,
    required this.postedAt,
  });

  bool matches(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return '$title $category $description $requirements $experience $availability'
        .toLowerCase()
        .contains(term);
  }
}
