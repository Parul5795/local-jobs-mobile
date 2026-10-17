import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/application_status.dart';

class ApplicationStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool isLarge;

  const ApplicationStatusBadge({
    super.key,
    required this.status,
    this.isLarge = false,
  });

  Color _getStatusColor() {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.primary;
      case ApplicationStatus.reviewing:
        return Colors.orange;
      case ApplicationStatus.shortlisted:
        return Colors.green;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.hired:
        return Colors.green;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.primaryContainer;
      case ApplicationStatus.reviewing:
        return Colors.orange.withValues(alpha: 0.1);
      case ApplicationStatus.shortlisted:
        return Colors.green.withValues(alpha: 0.1);
      case ApplicationStatus.rejected:
        return AppColors.errorContainer;
      case ApplicationStatus.hired:
        return Colors.green.withValues(alpha: 0.1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getStatusBackgroundColor();
    final textColor = _getStatusColor();

    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status.label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor),
      ),
    );
  }
}
