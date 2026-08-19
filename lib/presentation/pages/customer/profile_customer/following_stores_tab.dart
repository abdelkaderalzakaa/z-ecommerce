import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import '../../../../data/providers/follower_provider.dart';
import '../../../../data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/pages/customer/business_entry.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import '../../../global/locale_provider.dart';

class FollowingStoresTab extends StatelessWidget {
  const FollowingStoresTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isAr = context.watch<LocaleProvider>().locale.languageCode == 'ar';
    final followerProvider = context.watch<FollowerProvider>();
    final userFollowingIds = followerProvider.userFollowing.map((f) => f.businessId).toList();
    final allBusinesses = context.watch<BusinessProvider>().businesses;
    final businesses = allBusinesses.where((b) => userFollowingIds.contains(b.id)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isAr ? 'المتاجر التي أتابعها' : 'Stores I Follow',
          style: AppTextStyles.heroTitle(context, isMobile).copyWith(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isAr ? 'المتاجر التي قمت بمتابعتها' : 'Stores you have followed',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        const SizedBox(height: 32),
        
        businesses.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 60),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Column(
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'لا توجد متاجر تتابعها بعد' : 'No followed stores yet',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? 'اضغط على متابعة في صفحة المتجر' : 'Tap follow on the store page',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: businesses.length,
                itemBuilder: (context, index) {
                  return CardBusiness(business: businesses[index]);
                },
              ),
      ],
    );
  }
}
