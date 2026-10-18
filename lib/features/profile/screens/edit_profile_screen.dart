import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'edit-profile';
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _bio = TextEditingController();
  final _location = TextEditingController();
  final _workCategory = TextEditingController();
  final _experience = TextEditingController();
  final _skills = TextEditingController();
  final _interests = TextEditingController();
  final _availability = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    _location.dispose();
    _workCategory.dispose();
    _experience.dispose();
    _skills.dispose();
    _interests.dispose();
    _availability.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.asData?.value;
    if (profile != null && !_initialized) {
      _name.text = profile.fullName;
      _email.text = profile.email;
      _phone.text = profile.phone;
      _bio.text = profile.bio;
      _location.text = profile.location;
      _workCategory.text = profile.workCategory;
      _experience.text = profile.experience;
      _skills.text = profile.skills.join(', ');
      _interests.text = profile.interests.join(', ');
      _availability.text = profile.availability;
      _initialized = true;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: profileState.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : profileState.hasError && profile == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Couldn’t load your profile'),
                    const SizedBox(height: 12),
                    AppButton(
                      text: 'Try again',
                      onPressed: () =>
                          ref.read(profileProvider.notifier).load(),
                      fullWidth: false,
                    ),
                  ],
                ),
              ),
            )
          : profile == null
          ? const Center(child: Text('No profile information available.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.person_outline,
                                size: 42,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Profile photo can be added later',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Full name',
                        controller: _name,
                        prefixIcon: const Icon(Icons.person_outline),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your full name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        enabled: false,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone number',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Location',
                        controller: _location,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      if (!profile.isEmployer) ...[
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Main type of work',
                          controller: _workCategory,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Experience (or Fresher)',
                          controller: _experience,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Skills (separate with commas)',
                          controller: _skills,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Interested in (separate with commas)',
                          controller: _interests,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Availability',
                          controller: _availability,
                        ),
                      ],
                      const SizedBox(height: 16),
                      AppTextField(
                        label: profile.isEmployer
                            ? 'About you or your business'
                            : 'About you',
                        controller: _bio,
                        prefixIcon: const Icon(Icons.notes_outlined),
                        textInputAction: TextInputAction.newline,
                      ),
                      if (profile.isEmployer) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: profile.companyName ?? '',
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Company name',
                            prefixIcon: Icon(Icons.business_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        text: 'Save changes',
                        isLoading: _saving,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final current = ref.read(profileProvider).asData?.value;
    if (current == null) return;
    setState(() => _saving = true);
    Object? saveError;
    try {
      await ref
          .read(profileProvider.notifier)
          .save(
            current.copyWith(
              fullName: _name.text.trim(),
              phone: _phone.text.trim(),
              bio: _bio.text.trim(),
              location: _location.text.trim(),
              workCategory: _workCategory.text.trim(),
              experience: _experience.text.trim(),
              skills: _parseList(_skills.text),
              interests: _parseList(_interests.text),
              availability: _availability.text.trim(),
            ),
          );
    } catch (error) {
      saveError = error;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save profile: $saveError')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  List<String> _parseList(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
