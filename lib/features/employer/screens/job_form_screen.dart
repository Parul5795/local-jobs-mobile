import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../localjobs/data/localjobs_repository.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/models/localjobs_requests.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class JobFormScreen extends ConsumerStatefulWidget {
  static const String createRouteName = 'employer-create-job';
  static const String editRouteName = 'employer-edit-job';
  final String? jobId;
  final JobPost? initialJob;
  const JobFormScreen({super.key, this.jobId, this.initialJob});
  @override
  ConsumerState<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends ConsumerState<JobFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(),
      _description = TextEditingController(),
      _area = TextEditingController(),
      _salary = TextEditingController(),
      _workType = TextEditingController(text: 'Full-time'),
      _experience = TextEditingController(text: 'Any experience');
  int? _categoryId, _cityId;
  String _period = 'Monthly';
  DateTime? _startDate;
  bool _loading = false, _saving = false, _initialized = false;
  bool _isActive = true;
  @override
  void initState() {
    super.initState();
    if (widget.jobId != null && widget.initialJob != null) {
      final job = widget.initialJob!;
      _title.text = job.title;
      _description.text = job.description;
      _area.text = job.area ?? '';
      _salary.text = job.salary?.toString() ?? '';
      _workType.text = job.workType;
      _experience.text = job.experienceRequirement;
      _categoryId = job.categoryId;
      _cityId = job.cityId;
      _period = job.paymentPeriod;
      _startDate = job.startDate;
      _isActive = job.isActive;
      _initialized = true;
    } else if (widget.jobId != null) {
      Future.microtask(_load);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _area.dispose();
    _salary.dispose();
    _workType.dispose();
    _experience.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final job = await ref
          .read(localJobsRepositoryProvider)
          .getJob(widget.jobId!);
      _title.text = job.title;
      _description.text = job.description;
      _area.text = job.area ?? '';
      _salary.text = job.salary?.toString() ?? '';
      _workType.text = job.workType;
      _experience.text = job.experienceRequirement;
      _categoryId = job.categoryId;
      _cityId = job.cityId;
      _period = job.paymentPeriod;
      _startDate = job.startDate;
      _isActive = job.isActive;
      _initialized = true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load this job.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoriesProvider),
        cityState = ref.watch(citiesProvider);
    final categories = categoryState.asData?.value ?? const <LookupItem>[];
    final cities = cityState.asData?.value ?? const <CityItem>[];
    if (!_initialized && widget.jobId == null) {
      if (_categoryId == null && categories.isNotEmpty) {
        _categoryId = categories.first.id;
      }
      if (_cityId == null && cities.isNotEmpty) _cityId = cities.first.id;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.jobId == null ? 'Post a local job' : 'Edit job'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _form,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (categoryState.hasError || cityState.hasError)
                        const Text('Could not load categories or cities.'),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: [
                          for (final item in categories)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: (v) =>
                            v == null ? 'Choose a category' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _cityId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: [
                          for (final item in cities)
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(item.label),
                            ),
                        ],
                        onChanged: (v) => setState(() => _cityId = v),
                        validator: (v) => v == null ? 'Choose a city' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _area,
                        decoration: const InputDecoration(
                          labelText: 'Area / locality (optional)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _title,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          labelText: 'Job title',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _description,
                        maxLines: 4,
                        maxLength: 5000,
                        decoration: const InputDecoration(
                          labelText: 'Describe the work',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _workType,
                        decoration: const InputDecoration(
                          labelText: 'Work type',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _experience,
                        decoration: const InputDecoration(
                          labelText: 'Experience requirement',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _salary,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Payment amount (optional)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final n = double.tryParse(v);
                          return n == null || n < 0
                              ? 'Enter a non-negative amount'
                              : null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _period,
                        decoration: const InputDecoration(
                          labelText: 'Payment period',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Monthly',
                            child: Text('Monthly'),
                          ),
                          DropdownMenuItem(
                            value: 'Daily',
                            child: Text('Daily'),
                          ),
                          DropdownMenuItem(
                            value: 'Hourly',
                            child: Text('Hourly'),
                          ),
                          DropdownMenuItem(
                            value: 'Fixed',
                            child: Text('Fixed'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _period = v ?? 'Monthly'),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          _startDate == null
                              ? 'Start date (optional)'
                              : 'Starts ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        ),
                        trailing: IconButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 3650),
                              ),
                            );
                            if (date != null) setState(() => _startDate = date);
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      if (_startDate != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _startDate = null),
                            child: const Text('Clear date'),
                          ),
                        ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed:
                            _saving || categories.isEmpty || cities.isEmpty
                            ? null
                            : _save,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                widget.jobId == null
                                    ? 'Post Job'
                                    : 'Save changes',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'This field is required' : null;
  Future<void> _save() async {
    if (!_form.currentState!.validate() ||
        _categoryId == null ||
        _cityId == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final request = JobWriteRequest(
        title: _title.text,
        description: _description.text,
        categoryId: _categoryId!,
        cityId: _cityId!,
        workType: _workType.text,
        experienceRequirement: _experience.text,
        paymentPeriod: _period,
        salary: _salary.text.trim().isEmpty
            ? null
            : double.parse(_salary.text.trim()),
        startDate: _startDate,
        area: _area.text,
        isActive: widget.jobId == null ? null : _isActive,
      );
      final repo = ref.read(localJobsRepositoryProvider);
      if (widget.jobId == null) {
        await repo.createJob(request);
      } else {
        await repo.updateJob(widget.jobId!, request);
        ref.invalidate(jobDetailsApiProvider(widget.jobId!));
      }
      ref.invalidate(myJobsApiProvider);
      ref.invalidate(localJobsFeedProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.jobId == null ? 'Job posted.' : 'Job updated.',
            ),
          ),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save the job. Check the details and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
