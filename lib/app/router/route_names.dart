class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String home = 'home';
  static const String jobs = 'job-list';
  static const String jobDetails = 'job-details';
  static const String myApplications = 'my-applications';
  static const String applicationDetails = 'application-details';
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String settings = 'settings';
  static const String employerDashboard = 'employer-dashboard';
  static const String employerMyJobs = 'employer-my-jobs';
  static const String employerJobDetails = 'employer-job-detail';
  static const String employerCreateJob = 'employer-create-job';
  static const String employerEditJob = 'employer-edit-job';
  static const String employerApplicants = 'employer-applicants';
  static const String employerApplicantDetails = 'employer-applicant-detail';
  static const String notifications = 'notifications';
  static const String notificationDetails = 'notification-details';
  static const String savedJobs = 'saved-jobs';
  static const String applicationForm = 'application-form';
  static const String applicationReview = 'application-review';
  static const String applicationSuccess = 'application-success';
}

class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String jobDetails = '/jobs/:id';
  static const String myApplications = '/applications';
  static const String applicationDetails = '/applications/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String employerDashboard = '/employer';
  static const String employerMyJobs = '/employer/jobs';
  static const String employerJobDetails = '/employer/jobs/:id';
  static const String employerCreateJob = '/employer/jobs/create';
  static const String employerEditJob = '/employer/jobs/:id/edit';
  static const String employerApplicants = '/employer/jobs/:jobId/applicants';
  static const String employerApplicantDetails = '/employer/applicants/:id';
  static const String notifications = '/notifications';
  static const String notificationDetails = '/notifications/:id';
  static const String savedJobs = '/saved-jobs';
  static const String applicationForm = '/jobs/:id/apply';
  static const String applicationReview = '/applications/review';
  static const String applicationSuccess = '/applications/success/:id';
}
