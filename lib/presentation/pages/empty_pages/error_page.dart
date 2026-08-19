import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';

import '../../global/locale_provider.dart';
 
class ErrorPage extends StatelessWidget {
  final Exception? error;
  final String? errorMessage;

  const ErrorPage({super.key, this.error, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final isAr = context.read<LocaleProvider>().locale.languageCode == 'ar';
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animated or Stylish Icon Container
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.sentiment_dissatisfied_rounded,
                  size: 100,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 40),

              // Error Title
              Text(
                isAr ? 'عذراً! حدث خطأ ما' : 'Oops! Something went wrong',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Error Description
              Text(
                errorMessage ??
                    (isAr
                        ? 'الصفحة التي تحاول الوصول إليها غير موجودة أو تم نقلها.'
                        : 'The page you are looking for does not exist or has been moved.'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Return Home Button
              ButtonApp(
                onPressed: () {
                  // If they are inside a company context, maybe go to that company's home.
                  // But usually safest to just clear stack and go to entry
                  changeScreenReplacement(context, const BusinessEntry());
                },
                icon: Icons.home_rounded,
                label: isAr ? 'العودة للصفحة الرئيسية' : 'Return to Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
