import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'edit-profile';
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _area = TextEditingController(),
      _years = TextEditingController(),
      _details = TextEditingController(),
      _skills = TextEditingController(),
      _interests = TextEditingController(),
      _availability = TextEditingController(),
      _about = TextEditingController(),
      _image = TextEditingController();
  int? _categoryId, _cityId;
  bool _fresher = true, _saving = false, _initialized = false;
  @override
  void dispose() {
    _area.dispose();
    _years.dispose();
    _details.dispose();
    _skills.dispose();
    _interests.dispose();
    _availability.dispose();
    _about.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final categories =
        ref.watch(categoriesProvider).asData?.value ?? const <LookupItem>[];
    final cities =
        ref.watch(citiesProvider).asData?.value ?? const <CityItem>[];
    final savedProfile = profileState.asData?.value;
    final profileDoesNotExist =
        profileState.asData != null && savedProfile == null;
    final auth = ref.watch(authStateProvider);
    final profile =
        savedProfile ??
        (profileDoesNotExist &&
                auth is Authenticated &&
                auth.user.role.toLowerCase() == 'jobseeker'
            ? ProfileModel.fromUser(auth.user)
            : null);
    if (profile != null && !_initialized) {
      _categoryId = profile.categoryId;
      _cityId = profile.cityId;
      _fresher = profile.isFresher;
      _area.text = profile.area;
      _years.text = profile.experienceYears?.toString() ?? '';
      _details.text = profile.experience;
      _skills.text = profile.skills.join(', ');
      _interests.text = profile.interests.join(', ');
      _availability.text = profile.availability;
      _about.text = profile.bio;
      _image.text = profile.profileImageUrl ?? '';
      _initialized = true;
    }
    if (categories.isNotEmpty && _categoryId == null) {
      _categoryId = categories.first.id;
    }
    if (cities.isNotEmpty && _cityId == null) _cityId = cities.first.id;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit worker profile')),
      body: profileState.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : profileState.hasError && profile == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load your profile.'),
                  TextButton(
                    onPressed: () => ref.invalidate(profileProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _form,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (profile == null)
                        const Text('Sign in to edit your profile.'),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Main type of work',
                        ),
                        items: [
                          for (final category in categories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                        validator: (v) =>
                            v == null ? 'Choose a work category' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _cityId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'City'),
                        items: [
                          for (final city in cities)
                            DropdownMenuItem(
                              value: city.id,
                              child: Text(city.label),
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
                      SwitchListTile(
                        title: const Text('I am a fresher'),
                        value: _fresher,
                        onChanged: (v) => setState(() => _fresher = v),
                      ),
                      if (!_fresher) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _years,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Experience in years',
                          ),
                          validator: (v) {
                            final years = double.tryParse(v ?? '');
                            return years == null || years < 0
                                ? 'Enter valid experience years'
                                : null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _details,
                          decoration: const InputDecoration(
                            labelText: 'Experience details',
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _skills,
                        decoration: const InputDecoration(
                          labelText: 'Skills (comma separated)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _interests,
                        decoration: const InputDecoration(
                          labelText: 'Interests (comma separated)',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _availability,
                        decoration: const InputDecoration(
                          labelText: 'Availability',
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _about,
                        maxLines: 4,
                        decoration: const InputDecoration(labelText: 'About'),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _image,
                        decoration: const InputDecoration(
                          labelText: 'Profile photo URL (optional)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed:
                            _saving ||
                                categories.isEmpty ||
                                cities.isEmpty ||
                                profile == null
                            ? null
                            : _save,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Save profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final profileState = ref.read(profileProvider);
    final savedProfile = profileState.asData?.value;
    final auth = ref.read(authStateProvider);
    final current =
        savedProfile ??
        (profileState.asData != null &&
                savedProfile == null &&
                auth is Authenticated &&
                auth.user.role.toLowerCase() == 'jobseeker'
            ? ProfileModel.fromUser(auth.user)
            : null);
    if (current == null || _categoryId == null || _cityId == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .save(
            current.copyWith(
              categoryId: _categoryId,
              cityId: _cityId,
              area: _area.text.trim(),
              isFresher: _fresher,
              experienceYears: _fresher ? null : double.tryParse(_years.text),
              experience: _fresher ? '' : _details.text.trim(),
              skills: _split(_skills.text),
              interests: _split(_interests.text),
              availability: _availability.text.trim(),
              bio: _about.text.trim(),
              profileImageUrl: _image.text.trim().isEmpty
                  ? null
                  : _image.text.trim(),
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Worker profile saved.')));
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save profile. Check the fields and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _split(String value) => value
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
