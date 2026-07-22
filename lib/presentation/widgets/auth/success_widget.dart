import 'package:flutter/material.dart';
import '../../global/core/constants/app_constants.dart';
import 'primary_auth_button.dart';
import 'auth_card.dart';

class SuccessWidget extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const SuccessWidget({
    super.key,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      subtitle: message,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle,
                color: AppColors.green,
                size: 64,
              ),
            ),
          ),
        ),
        const SizedBox(height: 48),
        PrimaryAuthButton(
          label: buttonLabel,
          onPressed: onPressed,
        ),
      ],
    );
  }
}
