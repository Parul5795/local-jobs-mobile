import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/local_navigation_bar.dart';
import '../providers/local_discovery_provider.dart';

class PersonProfileScreen extends ConsumerWidget {
  final String personId;
  const PersonProfileScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref
        .watch(localPeopleProvider)
        .where((p) => p.id == personId)
        .firstOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Worker profile')),
      bottomNavigationBar: const LocalNavigationBar(selectedIndex: 1),
      body: person == null
          ? const Center(child: Text('This profile is no longer available.'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primaryContainer,
                      child: Text(
                        person.name[0],
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      person.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      person.primaryWork,
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
                            subtitle: Text(
                              '${person.location} · ${person.distanceKm.toStringAsFixed(1)} km',
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.star_outline),
                            title: const Text('Experience'),
                            subtitle: Text(person.experience),
                          ),
                          ListTile(
                            leading: const Icon(Icons.schedule_outlined),
                            title: const Text('Availability'),
                            subtitle: Text(person.availability),
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('About'),
                            subtitle: Text(person.about),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _Chips(values: person.skills),
                    const SizedBox(height: 16),
                    Text(
                      'Interested in',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _Chips(values: person.interests),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              _contact(context, ref, personId, 'Call'),
                          icon: const Icon(Icons.call_outlined),
                          label: const Text('Call'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _contact(context, ref, personId, 'WhatsApp'),
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('WhatsApp'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '${person.contactCount} people contacted this profile',
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _contact(BuildContext context, WidgetRef ref, String id, String method) {
    ref.read(localPeopleProvider.notifier).recordContact(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$method action recorded for this demo.')),
    );
  }
}

class _Chips extends StatelessWidget {
  final List<String> values;
  const _Chips({required this.values});
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [for (final value in values) Chip(label: Text(value))],
  );
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
