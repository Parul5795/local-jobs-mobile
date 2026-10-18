import 'package:flutter/material.dart';

class LocalCategoryStrip extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String> onSelected;

  const LocalCategoryStrip({
    super.key,
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        for (final category in categories.take(5))
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(category),
              onPressed: () => onSelected(category),
            ),
          ),
        TextButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final category in categories)
                    ListTile(
                      title: Text(category),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelected(category);
                      },
                    ),
                ],
              ),
            ),
          ),
          child: const Text('More'),
        ),
      ],
    ),
  );
}
