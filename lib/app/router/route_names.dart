class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
  static const String home = 'home';
  static const String jobs = 'job-list';
  static const String jobDetails = 'job-details';
  static const String localSearch = 'local-search';
  static const String localAds = 'local-ads';
  static const String profile = 'profile';
  static const String localPerson = 'local-person';
  static const String localJobDetails = 'local-job-details';
  static const String localAdCreate = 'local-ad-create';
  static const String localAdEdit = 'local-ad-edit';
  static const String classifiedDetails = 'classified-details';
  static const String myJobs = 'my-jobs';
  static const String employerCreateJob = 'employer-create-job';
  static const String employerEditJob = 'employer-edit-job';
  static const String editProfile = 'edit-profile';
  static const String editAccount = 'edit-account';
  // Legacy screens remain compiled for compatibility, but these paths are not
  // registered in the redesigned LocalJobs router.
  static const String applicationReview = 'application-review';
  static const String applicationSuccess = 'application-success';
  static const String applicationDetails = 'application-details';
  static const String myApplications = 'my-applications';
  static const String employerDashboard = 'employer-dashboard';
  static const String employerJobDetails = 'employer-job-detail';
  static const String employerApplicants = 'employer-applicants';
  static const String employerApplicantDetails = 'employer-applicant-detail';
}

class RoutePaths {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String jobDetails = '/jobs/:id';
  static const String localSearch = '/search';
  static const String localAds = '/ads';
  static const String profile = '/profile';
  static const String localPerson = '/workers/:id';
  static const String localJobDetails = '/local-jobs/:id';
  static const String localAdCreate = '/ads/new';
  static const String localAdEdit = '/ads/:id/edit';
  static const String classifiedDetails = '/ads/:id';
  static const String myJobs = '/my-jobs';
  static const String employerCreateJob = '/jobs/new';
  static const String employerEditJob = '/jobs/:id/edit';
  static const String editProfile = '/profile/edit';
  static const String editAccount = '/profile/account/edit';
}
