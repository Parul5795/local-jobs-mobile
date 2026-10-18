import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/local_ad.dart';
import '../providers/local_ads_provider.dart';

class CreateLocalAdScreen extends ConsumerStatefulWidget {
  const CreateLocalAdScreen({super.key});
  @override
  ConsumerState<CreateLocalAdScreen> createState() =>
      _CreateLocalAdScreenState();
}

class _CreateLocalAdScreenState extends ConsumerState<CreateLocalAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _contact = TextEditingController();
  String _type = 'Business';
  static const _types = [
    'Jobs / Work',
    'Services',
    'Business',
    'Sale',
    'Tuition',
    'House',
    'Vehicle',
    'Announcement',
    'Other',
  ];

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create an advertisement')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Category'),
                items: [
                  for (final type in _types)
                    DropdownMenuItem(value: type, child: Text(type)),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Title',
                controller: _title,
                validator: _required,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: _description,
                maxLines: 4,
                validator: _required,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Location',
                controller: _location,
                validator: _required,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image selection will be added later.'),
                  ),
                ),
                icon: const Icon(Icons.image_outlined),
                label: const Text('Add an image (optional)'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Contact information',
                controller: _contact,
                keyboardType: TextInputType.phone,
                validator: _required,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _post,
                child: const Text('Post advertisement'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  void _post() {
    if (!_formKey.currentState!.validate()) return;
    final auth = ref.read(authStateProvider);
    final publisher = auth is Authenticated
        ? auth.user.fullName
        : 'Local neighbour';
    ref
        .read(localAdsProvider.notifier)
        .add(
          LocalAd(
            id: 'ad-${DateTime.now().microsecondsSinceEpoch}',
            publisher: publisher,
            location: _location.text.trim(),
            type: switch (_type) {
              'Jobs / Work' => 'Work opportunity',
              'Services' => 'Service',
              'Sale' => 'Product',
              _ => _type,
            },
            title: _title.text.trim(),
            description: _description.text.trim(),
            postedAt: 'Just now',
            contact: _contact.text.trim(),
          ),
        );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Advertisement posted.')));
    context.pop();
  }
}
