import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_logo.dart';
// Note: Navigation logic is handled by GoRouter's redirect based on AuthState,
// so Splash Screen just needs to display the logo while AuthNotifier initializes.

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: AppLogo(size: 120),
      ),
    );
  }
}
