import 'package:flutter/material.dart';

class LocationChoice {
  final String area;
  final double? radiusKm;
  const LocationChoice({required this.area, required this.radiusKm});
}

const localAreas = [
  'Kalyani Nagar',
  'Viman Nagar',
  'Koregaon Park',
  'Yerwada',
  'Hadapsar',
];

Future<LocationChoice?> showLocationPicker(
  BuildContext context, {
  required String selectedArea,
  required double? selectedRadius,
}) => showModalBottomSheet<LocationChoice>(
  context: context,
  isScrollControlled: true,
  builder: (context) => _LocationPickerSheet(
    selectedArea: selectedArea,
    selectedRadius: selectedRadius,
  ),
);

class _LocationPickerSheet extends StatefulWidget {
  final String selectedArea;
  final double? selectedRadius;
  const _LocationPickerSheet({
    required this.selectedArea,
    required this.selectedRadius,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late String _area = widget.selectedArea;
  late double? _radius = widget.selectedRadius;
  late bool _nearMe = widget.selectedArea == 'Kalyani Nagar';

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.my_location_outlined),
              title: const Text('Near me'),
              trailing: _nearMe ? const Icon(Icons.check) : null,
              selected: _nearMe,
              onTap: () => setState(() {
                _area = 'Kalyani Nagar';
                _nearMe = true;
              }),
            ),
            const Text('Choose area'),
            Wrap(
              spacing: 8,
              children: [
                for (final area in localAreas)
                  ChoiceChip(
                    label: Text(area),
                    selected: _area == area,
                    onSelected: (_) => setState(() {
                      _area = area;
                      _nearMe = false;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Distance'),
            Wrap(
              spacing: 8,
              children: [
                for (final radius in <double?>[2, 5, 10, 25, null])
                  ChoiceChip(
                    label: Text(
                      radius == null ? 'Any distance' : '${radius.toInt()} km',
                    ),
                    selected: _radius == radius,
                    onSelected: (_) => setState(() => _radius = radius),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  LocationChoice(
                    area: _area == 'Near me' ? 'Kalyani Nagar' : _area,
                    radiusKm: _radius,
                  ),
                ),
                child: const Text('Show results'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LocationPickerButton extends StatelessWidget {
  final String area;
  final double? radiusKm;
  final ValueChanged<LocationChoice> onChanged;

  const LocationPickerButton({
    super.key,
    required this.area,
    required this.radiusKm,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: () async {
      final choice = await showLocationPicker(
        context,
        selectedArea: area,
        selectedRadius: radiusKm,
      );
      if (choice != null) onChanged(choice);
    },
    icon: const Icon(Icons.location_on_outlined),
    label: Text(
      '$area · ${radiusKm == null ? 'Any distance' : '${radiusKm!.toInt()} km'}',
    ),
  );
}
