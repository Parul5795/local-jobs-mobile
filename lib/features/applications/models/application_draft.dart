import '../../jobs/models/job_model.dart';

class ApplicationDraft {
  final Job job;
  final String fullName;
  final String email;
  final String phone;
  final String resumeName;
  final String coverLetter;
  final String additionalInformation;

  const ApplicationDraft({
    required this.job,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.resumeName,
    required this.coverLetter,
    required this.additionalInformation,
  });
}
