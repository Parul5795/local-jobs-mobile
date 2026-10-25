import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/update_user_request.dart';
import '../providers/user_account_provider.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  static const routeName = 'edit-account';
  const EditAccountScreen({super.key});

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userAccountProvider);
    final user = userState.asData?.value;
    if (user != null && !_initialized) {
      _name.text = user.fullName;
      _email.text = user.email;
      _phone.text = user.phone;
      _initialized = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit account details')),
      body: userState.isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : userState.hasError && user == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load your account details.'),
                  TextButton(
                    onPressed: () =>
                        ref.read(userAccountProvider.notifier).load(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      AppTextField(
                        label: 'Name',
                        controller: _name,
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Phone number',
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: user == null || _saving ? null : _save,
                        child: _saving
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Save account details'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(userAccountProvider.notifier)
          .save(
            UpdateUserRequest(
              name: _name.text,
              email: _email.text,
              phoneNumber: _phone.text,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account details updated.')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        final message = error is ApiException
            ? error.message
            : 'Could not update account details. Please try again.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
