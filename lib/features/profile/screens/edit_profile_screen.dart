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
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _bio.dispose();
    _location.dispose();
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
                        child: Stack(
                          clipBehavior: Clip.none,
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
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: CircleAvatar(
                                radius: 16,
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 17,
                                ),
                              ),
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
                      const SizedBox(height: 16),
                      AppTextField(
                        label: profile.isEmployer
                            ? 'About your organization'
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
}
