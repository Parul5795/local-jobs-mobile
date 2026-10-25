import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../providers/user_account_provider.dart';
import 'edit_profile_screen.dart';
import 'edit_account_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = 'profile';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final auth = ref.watch(authStateProvider);
    final accountState = ref.watch(userAccountProvider);
    final account =
        accountState.asData?.value ??
        (auth is Authenticated ? auth.user : null);
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
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 3),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ProfileMessage(
          icon: Icons.cloud_off_outlined,
          title: 'Couldn’t load your profile',
          detail: 'Check your connection and try again.',
          action: AppButton(
            text: 'Try again',
            fullWidth: false,
            onPressed: () => ref.read(profileProvider.notifier).load(),
          ),
        ),
        data: (user) => user == null
            ? _FirstTimeWorkerProfile(
                account: account,
                accountHasError: accountState.hasError,
                onCreate: () => context.pushNamed(EditProfileScreen.routeName),
                onEditAccount: () =>
                    context.pushNamed(EditAccountScreen.routeName),
                onRetryAccount: () =>
                    ref.read(userAccountProvider.notifier).load(),
              )
            : _ProfileContent(
                profile: user,
                account: account,
                accountHasError: accountState.hasError,
                onEditAccount: () =>
                    context.pushNamed(EditAccountScreen.routeName),
                onRetryAccount: () =>
                    ref.read(userAccountProvider.notifier).load(),
              ),
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

class _FirstTimeWorkerProfile extends StatelessWidget {
  final UserModel? account;
  final bool accountHasError;
  final VoidCallback onCreate;
  final VoidCallback onEditAccount;
  final VoidCallback onRetryAccount;
  const _FirstTimeWorkerProfile({
    required this.account,
    required this.accountHasError,
    required this.onCreate,
    required this.onEditAccount,
    required this.onRetryAccount,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileMessage(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Create your worker profile',
            detail:
                'Add your work category, city, experience, skills and availability so local employers can find you.',
            action: AppButton(
              text: 'Create worker profile',
              fullWidth: false,
              onPressed: onCreate,
            ),
          ),
          if (account != null) ...[
            const SizedBox(height: 16),
            _AccountDetailsCard(
              account: account!,
              hasError: accountHasError,
              onEdit: onEditAccount,
              onRetry: onRetryAccount,
            ),
          ],
        ],
      ),
    ),
  );
}

class _ProfileContent extends StatelessWidget {
  final ProfileModel profile;
  final UserModel? account;
  final bool accountHasError;
  final VoidCallback onEditAccount;
  final VoidCallback onRetryAccount;
  const _ProfileContent({
    required this.profile,
    required this.account,
    required this.accountHasError,
    required this.onEditAccount,
    required this.onRetryAccount,
  });

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
                      account?.fullName ?? profile.fullName,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.isEmployer ? 'Local employer' : 'Local worker',
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
                    if (!profile.isEmployer) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile.workCategory,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(profile.experience),
                      if (profile.availability.isNotEmpty)
                        Text('Available: ${profile.availability}'),
                      const SizedBox(height: 8),
                      Text(
                        '${profile.contactCount} people contacted this profile',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 20),
                    if (!profile.isEmployer)
                      OutlinedButton.icon(
                        onPressed: () =>
                            context.pushNamed(EditProfileScreen.routeName),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit worker profile'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (account != null)
              _AccountDetailsCard(
                account: account!,
                hasError: accountHasError,
                onEdit: onEditAccount,
                onRetry: onRetryAccount,
              )
            else
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
                  ],
                ),
              ),
            if (profile.location.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: profile.location,
                    ),
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
            ] else if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: _InfoTile(
                  icon: Icons.notes_outlined,
                  label: 'About',
                  value: profile.bio,
                ),
              ),
            ],
            if (!profile.isEmployer && profile.skills.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Skills', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final skill in profile.skills) Chip(label: Text(skill)),
                ],
              ),
            ],
            if (!profile.isEmployer && profile.interests.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Interested in', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final item in profile.interests) Chip(label: Text(item)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountDetailsCard extends StatelessWidget {
  final UserModel account;
  final bool hasError;
  final VoidCallback onEdit;
  final VoidCallback onRetry;
  const _AccountDetailsCard({
    required this.account,
    required this.hasError,
    required this.onEdit,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        _InfoTile(
          icon: Icons.person_outline,
          label: 'Name',
          value: account.fullName,
        ),
        const Divider(height: 1, indent: 56),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'Email',
          value: account.email,
        ),
        const Divider(height: 1, indent: 56),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'Phone',
          value: account.phone.isEmpty ? 'Not provided' : account.phone,
        ),
        if (hasError)
          TextButton(
            onPressed: onRetry,
            child: const Text('Could not refresh account details. Retry'),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit account details'),
            ),
          ),
        ),
      ],
    ),
  );
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
