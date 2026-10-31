import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spinnerColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSecondaryContainer,
      AppButtonVariant.outline || AppButtonVariant.text => colorScheme.primary,
    };
    final Widget content = isLoading
        ? SizedBox.square(
            dimension: 19,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
            ),
          )
        : Text(text);

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
      AppButtonVariant.secondary => FilledButton.tonal(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        child: content,
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
