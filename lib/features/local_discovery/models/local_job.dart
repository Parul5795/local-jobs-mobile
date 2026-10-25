import '../../localjobs/models/localjobs_models.dart';

class LocalJob {
  final String id,
      title,
      category,
      location,
      pay,
      workType,
      experience,
      availability,
      description,
      requirements,
      employer,
      postedAt;
  final double? distanceKm;
  final String? employerId;
  final String contact;
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
  factory LocalJob.fromPost(JobPost job) => LocalJob(
    id: job.id,
    title: job.title,
    category: job.categoryName,
    location: job.location,
    distanceKm: null,
    pay: job.salaryLabel,
    workType: job.workType,
    experience: job.experienceRequirement,
    availability: job.startDate == null
        ? ''
        : 'Starts ${job.startDate!.day}/${job.startDate!.month}/${job.startDate!.year}',
    description: job.description,
    requirements: '',
    employer: job.userName,
    employerId: job.userId,
    contact: '',
    postedAt: job.postedAt,
  );
  bool matches(String query) {
    final term = query.trim().toLowerCase();
    return term.isEmpty ||
        '$title $category $description $requirements $experience $availability'
            .toLowerCase()
            .contains(term);
  }
}
