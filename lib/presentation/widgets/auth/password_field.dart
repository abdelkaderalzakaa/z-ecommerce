import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import 'auth_text_field.dart';

class PasswordField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.validator,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      label: widget.label,
      hintText: widget.hintText,
      prefixIcon: Icons.lock_outline,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      suffixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textMuted,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          splashRadius: 20,
        ),
      ),
    );
  }
}
