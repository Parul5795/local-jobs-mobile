import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  final String? hintText;
  final InputDecoration? decoration;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? suffixIcon;
  final bool readOnly;

  const AppSearchField({
    super.key,
    this.hintText,
    this.decoration,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.suffixIcon,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    onTap: onTap,
    readOnly: readOnly,
    textInputAction: TextInputAction.search,
    decoration:
        decoration ??
        InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
  );
}
