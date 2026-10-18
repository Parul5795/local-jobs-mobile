import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../local_discovery/models/local_job.dart';
import '../../local_discovery/providers/local_jobs_provider.dart';
import '../../local_discovery/widgets/location_picker.dart';

/// Reuses the existing Employer job form entry point for simple local work posts.
class JobFormScreen extends ConsumerStatefulWidget {
  static const String createRouteName = 'employer-create-job';
  static const String editRouteName = 'employer-edit-job';
  const JobFormScreen({super.key});

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _pay = TextEditingController();
  final _description = TextEditingController();
  final _requirements = TextEditingController();
  final _contact = TextEditingController();
  String _category = 'Driver';
  String _location = 'Kalyani Nagar';
  String _workType = 'Full-time';
  String _experience = 'Any experience';
  String _availability = 'Immediate';

  static const _categories = [
    'Driver',
    'House Help',
    'Carpenter',
    'Plumber',
    'Electrician',
    'Mechanic',
    'Cleaner',
    'Cook',
    'Shop Helper',
    'Labourer',
    'Tutor',
    'Delivery',
  ];
  static const _workTypes = ['Full-time', 'Part-time', 'One-time', 'Flexible'];
  static const _experiences = [
    'Any experience',
    'Fresher welcome',
    'Experienced preferred',
  ];
  static const _availabilityOptions = [
    'Immediate',
    'This week',
    'Flexible',
    'Evenings',
  ];

  @override
  void dispose() {
    _title.dispose();
    _pay.dispose();
    _description.dispose();
    _requirements.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Post a local job')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _dropdown(
                'Category',
                _category,
                _categories,
                (value) => _category = value,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'What help do you need?',
                controller: _title,
                hint: 'e.g. Family driver needed',
                validator: _required,
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: LocationPickerButton(
                  area: _location,
                  radiusKm: 5,
                  onChanged: (choice) =>
                      setState(() => _location = choice.area),
                ),
              ),
              const SizedBox(height: 14),
              _dropdown(
                'Work type',
                _workType,
                _workTypes,
                (value) => _workType = value,
              ),
              const SizedBox(height: 14),
              _dropdown(
                'Experience',
                _experience,
                _experiences,
                (value) => _experience = value,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Pay or payment range (optional)',
                controller: _pay,
                hint: 'e.g. ₹18,000–₹22,000 or negotiable',
              ),
              const SizedBox(height: 14),
              _dropdown(
                'Availability',
                _availability,
                _availabilityOptions,
                (value) => _availability = value,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Describe the work',
                controller: _description,
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Anything else? (optional)',
                controller: _requirements,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Your contact number',
                controller: _contact,
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _publish, child: const Text('Post job')),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final option in options)
        DropdownMenuItem(value: option, child: Text(option)),
    ],
    onChanged: (next) => setState(() => onChanged(next ?? value)),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  void _publish() {
    if (!_form.currentState!.validate()) return;
    final auth = ref.read(authStateProvider);
    final employer = auth is Authenticated
        ? auth.user.fullName
        : 'Local employer';
    final job = LocalJob(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      category: _category,
      location: _location,
      distanceKm: 1.8,
      pay: _pay.text.trim(),
      workType: _workType,
      experience: _experience,
      availability: _availability,
      description: _description.text.trim(),
      requirements: _requirements.text.trim(),
      employer: employer,
      employerId: auth is Authenticated ? auth.user.id : null,
      contact: _contact.text.trim(),
      postedAt: 'Just now',
    );
    ref.read(localJobsProvider.notifier).add(job);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your job is now visible in local search.')),
    );
    context.pop();
  }
}
