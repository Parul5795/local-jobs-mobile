import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class JobStatusBadge extends StatelessWidget {
  final bool isActive;
  const JobStatusBadge({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final foreground = isActive
        ? AppColors.onTertiaryContainer
        : AppColors.onSurfaceVariant;
    final background = isActive
        ? AppColors.tertiaryContainer
        : AppColors.secondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.pause_circle_outline,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
