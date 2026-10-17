import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../../applications/screens/my_applications_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = 'profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => _confirmLogout(context, ref),
            child: const Text('Log out'),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.pushNamed(SettingsScreen.routeName),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProfileMessage(
          icon: Icons.cloud_off_outlined,
          title: 'Couldn’t load your profile',
          detail: error.toString(),
          action: AppButton(
            text: 'Try again',
            fullWidth: false,
            onPressed: () => ref.read(profileProvider.notifier).load(),
          ),
        ),
        data: (user) => user == null
            ? const _ProfileMessage(
                icon: Icons.person_off_outlined,
                title: 'Profile unavailable',
                detail: 'Sign in to view your profile.',
              )
            : _ProfileContent(profile: user),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (shouldLogout != true || !context.mounted) return;
    await ref.read(authStateProvider.notifier).logout();
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileModel profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: profile.profileImageUrl == null
                          ? null
                          : NetworkImage(profile.profileImageUrl!),
                      child: profile.profileImageUrl == null
                          ? Icon(
                              Icons.person_outline,
                              size: 42,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.fullName,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.isEmployer ? 'Employer' : 'Job seeker',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (profile.isEmployer &&
                        (profile.companyName?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.companyName!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.pushNamed(EditProfileScreen.routeName),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Edit profile'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: profile.email,
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value: profile.phone.isEmpty
                        ? 'Not provided'
                        : profile.phone,
                  ),
                  if (profile.location.isNotEmpty) ...[
                    const Divider(height: 1, indent: 56),
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: profile.location,
                    ),
                  ],
                  if (profile.bio.isNotEmpty) ...[
                    const Divider(height: 1, indent: 56),
                    _InfoTile(
                      icon: Icons.notes_outlined,
                      label: 'About',
                      value: profile.bio,
                    ),
                  ],
                ],
              ),
            ),
            if (!profile.isEmployer) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: const Text('My applications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      context.pushNamed(MyApplicationsScreen.routeName),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label, style: Theme.of(context).textTheme.bodySmall),
    subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
  );
}

class _ProfileMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final Widget? action;
  const _ProfileMessage({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(detail, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    ),
  );
}
