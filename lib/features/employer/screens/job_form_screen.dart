import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/employer_job_model.dart';
import '../models/job_form_data.dart';
import '../providers/employer_provider.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _categories = [
  'Engineering',
  'Design',
  'Product',
  'Marketing',
  'Operations',
  'Sales',
  'HR',
  'Finance',
  'Other',
];

const _jobTypes = [
  'Full-time',
  'Part-time',
  'Contract',
  'Freelance',
  'Internship',
];

const _experienceLevels = [
  'Entry (0-1 years)',
  'Junior (1-2 years)',
  'Mid (2-4 years)',
  'Senior (5+ years)',
  'Lead / Principal',
];

// ── Screen ────────────────────────────────────────────────────────────────────

/// Handles both Create and Edit. When [jobId] is null → Create mode.
class JobFormScreen extends ConsumerStatefulWidget {
  static const String createRouteName = 'employer-create-job';
  static const String editRouteName = 'employer-edit-job';

  final String? jobId;

  const JobFormScreen({super.key, this.jobId});

  bool get isEditMode => jobId != null;

  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _salaryMinCtrl;
  late final TextEditingController _salaryMaxCtrl;
  late final TextEditingController _deadlineCtrl;
  late final TextEditingController _skillInputCtrl;

  String _category = _categories[0];
  String _jobType = _jobTypes[0];
  String _experience = _experienceLevels[2];
  final List<String> _skills = [];

  bool _isLoading = false;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _companyCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _salaryMinCtrl = TextEditingController();
    _salaryMaxCtrl = TextEditingController();
    _deadlineCtrl = TextEditingController();
    _skillInputCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _deadlineCtrl.dispose();
    _skillInputCtrl.dispose();
    super.dispose();
  }

  void _prefill(EmployerJob job) {
    if (_prefilled) return;
    _prefilled = true;
    _titleCtrl.text = job.title;
    _descCtrl.text = job.description;
    _companyCtrl.text = job.companyName;
    _locationCtrl.text = job.location;
    _salaryMinCtrl.text = job.salaryMin.toString();
    _salaryMaxCtrl.text = job.salaryMax.toString();
    _deadlineCtrl.text = job.applicationDeadline;
    _category = _categories.contains(job.category)
        ? job.category
        : _categories[0];
    _jobType = _jobTypes.contains(job.jobType) ? job.jobType : _jobTypes[0];
    _experience = _experienceLevels.contains(job.experienceRequired)
        ? job.experienceRequired
        : _experienceLevels[2];
    _skills
      ..clear()
      ..addAll(job.skills);
    setState(() {});
  }

  void _addSkill() {
    final skill = _skillInputCtrl.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() => _skills.add(skill));
    _skillInputCtrl.clear();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one skill.')));
      return;
    }

    setState(() => _isLoading = true);

    final data = JobFormData(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      companyName: _companyCtrl.text.trim(),
      category: _category,
      location: _locationCtrl.text.trim(),
      salaryMin: _salaryMinCtrl.text.trim(),
      salaryMax: _salaryMaxCtrl.text.trim(),
      jobType: _jobType,
      experienceRequired: _experience,
      skills: List.from(_skills),
      applicationDeadline: _deadlineCtrl.text.trim(),
    );

    try {
      final notifier = ref.read(employerJobsProvider.notifier);
      if (widget.isEditMode) {
        await notifier.updateJob(widget.jobId!, data);
      } else {
        await notifier.createJob(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditMode
                ? 'Job updated successfully.'
                : 'Job posted successfully.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      _deadlineCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = widget.isEditMode
        ? ref.watch(employerJobDetailProvider(widget.jobId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Job' : 'Post a Job'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionLabel('Job Information'),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Job Title',
                      controller: _titleCtrl,
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Company Name',
                      controller: _companyCtrl,
                      prefixIcon: const Icon(Icons.business_outlined),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Location',
                      controller: _locationCtrl,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 14),
                    // Description — multiline
                    TextFormField(
                      controller: _descCtrl,
                      minLines: 4,
                      maxLines: 8,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('Details'),
                    const SizedBox(height: 12),
                    _DropdownField(
                      label: 'Category',
                      value: _category,
                      items: _categories,
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 14),
                    _DropdownField(
                      label: 'Job Type',
                      value: _jobType,
                      items: _jobTypes,
                      onChanged: (v) => setState(() => _jobType = v!),
                    ),
                    const SizedBox(height: 14),
                    _DropdownField(
                      label: 'Experience Required',
                      value: _experience,
                      items: _experienceLevels,
                      onChanged: (v) => setState(() => _experience = v!),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('Salary Range (Annual €)'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMinCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                                _validateSalary(value, isMinimum: true),
                            decoration: const InputDecoration(
                              labelText: 'Min',
                              prefixText: '€ ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMaxCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) =>
                                _validateSalary(value, isMinimum: false),
                            decoration: const InputDecoration(
                              labelText: 'Max',
                              prefixText: '€ ',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _deadlineCtrl,
                      readOnly: true,
                      onTap: _pickDeadline,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Deadline is required'
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Application Deadline',
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionLabel('Skills'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _skillInputCtrl,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _addSkill(),
                            decoration: const InputDecoration(
                              labelText: 'Add a skill',
                              hintText: 'e.g. Flutter',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          onPressed: _addSkill,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _skills.map((s) {
                          return Chip(
                            label: Text(s),
                            onDeleted: () => setState(() => _skills.remove(s)),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 32),
                    AppButton(
                      text: widget.isEditMode ? 'Save Changes' : 'Post Job',
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                    if (widget.isEditMode) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (jobAsync != null)
            Positioned.fill(
              child: jobAsync.when(
                loading: () => const _FormStatePanel(
                  icon: Icons.hourglass_empty,
                  title: 'Loading job',
                  message: 'Please wait while the job details load.',
                  loading: true,
                ),
                error: (error, _) => _FormStatePanel(
                  icon: Icons.error_outline,
                  title: 'Could not load job',
                  message: error.toString(),
                  action: OutlinedButton.icon(
                    onPressed: () => ref.invalidate(
                      employerJobDetailProvider(widget.jobId!),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try again'),
                  ),
                ),
                data: (job) {
                  if (job == null) {
                    return const _FormStatePanel(
                      icon: Icons.work_off_outlined,
                      title: 'Job not found',
                      message: 'This job may have been removed.',
                    );
                  }
                  if (!_prefilled) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_prefilled) _prefill(job);
                    });
                    return const _FormStatePanel(
                      icon: Icons.hourglass_empty,
                      title: 'Preparing form',
                      message: 'Loading the current job details.',
                      loading: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  String? _validateSalary(String? value, {required bool isMinimum}) {
    if (value == null || value.trim().isEmpty) return null;
    final entered = int.tryParse(value.trim());
    if (entered == null) return 'Enter a valid amount';
    final otherText = (isMinimum ? _salaryMaxCtrl : _salaryMinCtrl).text.trim();
    final other = int.tryParse(otherText);
    if (other == null) return null;
    if (isMinimum && entered > other) return 'Minimum cannot exceed maximum';
    if (!isMinimum && entered < other) {
      return 'Maximum must be at least minimum';
    }
    return null;
  }
}

// ── Private helpers ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _FormStatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool loading;

  const _FormStatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator()
            else
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    ),
  );
}
