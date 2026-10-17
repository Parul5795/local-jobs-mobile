import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../jobs/providers/jobs_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/application_draft.dart';
import '../providers/applications_provider.dart';
import 'application_details_screen.dart';

class ApplicationFormScreen extends ConsumerStatefulWidget {
  static const routeName = 'application-form';
  final String jobId;

  const ApplicationFormScreen({super.key, required this.jobId});

  @override
  ConsumerState<ApplicationFormScreen> createState() =>
      _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends ConsumerState<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _cover = TextEditingController();
  final _additional = TextEditingController();
  String? _resumeName;
  String? _prefilledProfileId;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _cover.dispose();
    _additional.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailsProvider(widget.jobId));
    final profileAsync = ref.watch(profileProvider);
    final applications = ref.watch(applicationsControllerProvider);
    final profile = profileAsync.asData?.value;
    if (profile != null && _prefilledProfileId != profile.id) {
      _name.text = profile.fullName;
      _email.text = profile.email;
      _phone.text = profile.phone;
      _prefilledProfileId = profile.id;
    }
    final existing = ref
        .read(applicationsControllerProvider.notifier)
        .applicationForJob(widget.jobId);

    return Scaffold(
      appBar: AppBar(title: const Text('Apply for this job')),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, retry) => _StateMessage(
          icon: Icons.error_outline,
          title: 'Could not load this job',
          message: 'Check your connection and try again.',
          action: TextButton(
            onPressed: () => ref.invalidate(jobDetailsProvider(widget.jobId)),
            child: const Text('Retry'),
          ),
        ),
        data: (job) {
          if (job == null) {
            return const _StateMessage(
              icon: Icons.work_off_outlined,
              title: 'Job unavailable',
              message: 'This job could not be found.',
            );
          }
          if (applications.isLoading && applications.applications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (applications.error != null && applications.applications.isEmpty) {
            return _StateMessage(
              icon: Icons.wifi_off_outlined,
              title: 'Could not check your applications',
              message: 'Retry to make sure you have not already applied.',
              action: FilledButton.icon(
                onPressed: () => ref
                    .read(applicationsControllerProvider.notifier)
                    .loadApplications(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }
          if (existing != null) {
            return _StateMessage(
              icon: Icons.check_circle_outline,
              title: 'Already applied',
              message: 'You have already applied for ${job.title}.',
              action: FilledButton(
                onPressed: () => context.pushNamed(
                  ApplicationDetailsScreen.routeName,
                  pathParameters: {'id': existing.id},
                ),
                child: const Text('View application'),
              ),
            );
          }
          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${job.company} · ${job.location}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Your information',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Full name',
                        controller: _name,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Email address',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter your email address';
                          }
                          return RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(value.trim())
                              ? null
                              : 'Enter a valid email address';
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Phone number',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: (value) {
                          final digits =
                              value?.replaceAll(RegExp(r'\D'), '') ?? '';
                          if (digits.isEmpty) return 'Enter your phone number';
                          return digits.length >= 7 && digits.length <= 15
                              ? null
                              : 'Enter a valid phone number';
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Resume',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                _resumeName == null
                                    ? Icons.description_outlined
                                    : Icons.picture_as_pdf_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _resumeName ??
                                      'Add a resume to support your application',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_resumeName == null)
                                TextButton.icon(
                                  onPressed: () => setState(
                                    () => _resumeName =
                                        'Ankit_Chourey_Resume.pdf',
                                  ),
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Select'),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => setState(
                                        () =>
                                            _resumeName = 'Updated_Resume.pdf',
                                      ),
                                      icon: const Icon(
                                        Icons.drive_file_rename_outline,
                                      ),
                                      label: const Text('Replace'),
                                    ),
                                    IconButton(
                                      tooltip: 'Remove resume',
                                      onPressed: () =>
                                          setState(() => _resumeName = null),
                                      icon: const Icon(Icons.close),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_resumeName == null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 6),
                          child: Text(
                            'Select a resume to continue.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text(
                        'Message to the employer',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cover,
                        minLines: 4,
                        maxLines: 7,
                        maxLength: 1500,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Cover letter',
                          hintText: 'Tell the employer why you are a good fit.',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Add a short message to the employer'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _additional,
                        minLines: 2,
                        maxLines: 5,
                        maxLength: 500,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Additional information (optional)',
                          hintText: 'Anything else you would like to share?',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (!_formKey.currentState!.validate()) return;
                          if (_resumeName == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please select a resume to continue.',
                                ),
                              ),
                            );
                            return;
                          }
                          context.pushNamed(
                            RouteNames.applicationReview,
                            extra: ApplicationDraft(
                              job: job,
                              fullName: _name.text.trim(),
                              email: _email.text.trim(),
                              phone: _phone.text.trim(),
                              resumeName: _resumeName!,
                              coverLetter: _cover.text.trim(),
                              additionalInformation: _additional.text.trim(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Review application'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    ),
  );
}
