import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/local_navigation_bar.dart';
import '../../contacts/contact_actions.dart';
import '../../localjobs/models/localjobs_models.dart';
import '../../localjobs/providers/localjobs_providers.dart';

class PersonProfileScreen extends ConsumerWidget {
  final String personId;
  const PersonProfileScreen({super.key, required this.personId});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Worker profile')),
    bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
    body: ref
        .watch(publicWorkerProfileProvider(personId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _message(
            context,
            'Could not load this worker profile.',
            () => ref.invalidate(publicWorkerProfileProvider(personId)),
          ),
          data: (profile) => _profile(context, ref, profile),
        ),
  );
  Widget _profile(BuildContext context, WidgetRef ref, WorkerProfile profile) {
    final skills = profile.skills
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    final interests = profile.interests
        .split(',')
        .map((v) => v.trim())
        .where((v) => v.isNotEmpty)
        .toList();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: profile.profileImageUrl == null
                  ? null
                  : NetworkImage(profile.profileImageUrl!),
              child: profile.profileImageUrl == null
                  ? Text(
                      profile.name.isEmpty ? '?' : profile.name[0],
                      style: Theme.of(context).textTheme.headlineLarge,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              profile.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              profile.categoryName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Location'),
                    subtitle: Text(profile.location),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: const Text('Experience'),
                    subtitle: Text(profile.experienceLabel),
                  ),
                  if (profile.availability.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.schedule_outlined),
                      title: const Text('Availability'),
                      subtitle: Text(profile.availability),
                    ),
                  if (profile.about.isNotEmpty)
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      subtitle: Text(profile.about),
                    ),
                ],
              ),
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Skills', style: Theme.of(context).textTheme.titleMedium),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in skills) Chip(label: Text(value)),
                ],
              ),
            ],
            if (interests.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Interested in',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Wrap(
                spacing: 8,
                children: [
                  for (final value in interests) Chip(label: Text(value)),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      startWorkerContact(context, ref, personId, 'Call'),
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call'),
                ),
                OutlinedButton.icon(
                  onPressed: () =>
                      startWorkerContact(context, ref, personId, 'WhatsApp'),
                  icon: const Icon(Icons.chat_outlined),
                  label: const Text('WhatsApp'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '${profile.contactCount} people contacted this profile',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _message(BuildContext context, String text, VoidCallback retry) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: retry, child: const Text('Try again')),
            ],
          ),
        ),
      );
}
