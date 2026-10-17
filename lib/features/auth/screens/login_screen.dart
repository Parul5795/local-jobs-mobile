import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../app/router/route_names.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_role_selector.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _selectedRole = 'JobSeeker';

  @override
  void initState() {
    super.initState();
    _emailController.text = 'jobseeker';
    _passwordController.text = 'password';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(authStateProvider.notifier)
          .login(
            _emailController.text.trim(),
            _passwordController.text,
            _selectedRole,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState is AuthLoading;

    // Listen for errors to show snackbar
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 48),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AuthRoleSelector(
                      selectedRole: _selectedRole,
                      onChanged: (role) => setState(() {
                        _selectedRole = role;
                        _emailController.text = role == 'Employer'
                            ? 'employer'
                            : 'jobseeker';
                        _passwordController.text = 'password';
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Demo ID: ${_selectedRole == 'Employer' ? 'employer' : 'jobseeker'} · Password: password',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Email or ID',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final id = _selectedRole == 'Employer'
                            ? 'employer'
                            : 'jobseeker';
                        if (value?.trim().toLowerCase() == id) return null;
                        return Validators.validateEmail(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      suffixIcon: TextButton(
                        onPressed: () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                        child: Text(_obscurePassword ? 'Show' : 'Hide'),
                      ),
                      validator: Validators.validatePassword,
                      onSubmitted: (_) => _login(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            context.pushNamed(RouteNames.forgotPassword),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(text: 'Login', onPressed: _login),
                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () =>
                              context.pushNamed(RouteNames.register),
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
