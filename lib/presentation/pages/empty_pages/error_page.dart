import 'package:flutter/material.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:provider/provider.dart';

import '../../global/locale_provider.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry_page.dart';

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
              ElevatedButton.icon(
                onPressed: () {
                  // If they are inside a company context, maybe go to that company's home.
                  // But usually safest to just clear stack and go to entry
                  changeScreenReplacement(context, const BusinessEntryPage());
                },
                icon: const Icon(Icons.home_rounded),
                label: Text(
                  isAr ? 'العودة للصفحة الرئيسية' : 'Return to Home',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  shadowColor: primaryColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
