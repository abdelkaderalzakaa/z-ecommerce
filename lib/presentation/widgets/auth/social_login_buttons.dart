import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onGooglePressed;

  const SocialLoginButtons({
    super.key,
    this.onGooglePressed,
  });

  @override
  Widget build(BuildContext context) {
    // Auth UI is strictly Light Mode only
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onGooglePressed ?? () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G Logo
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
