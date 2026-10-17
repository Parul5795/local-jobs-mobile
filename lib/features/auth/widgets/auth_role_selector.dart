import 'package:flutter/material.dart';

class AuthRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const AuthRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Continue as', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'JobSeeker', label: Text('Job Seeker')),
          ButtonSegment(value: 'Employer', label: Text('Employer')),
        ],
        selected: {selectedRole},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    ],
  );
}
