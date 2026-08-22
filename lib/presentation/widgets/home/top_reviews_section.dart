import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/models/shared/rating_store.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/core/responsive/responsive_layout.dart';
import 'package:z_ecommerce/presentation/widgets/common/product_card.dart';

class TopReviewsSection extends StatelessWidget {
  const TopReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveLayout.horizontalPadding(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final businessProvider = context.watch<BusinessProvider>();
    final storeRatings = businessProvider.selectedBusiness.ratings;

    // Fallback sample top reviews if business has no user ratings yet
    final List<RatedUser> reviewsToShow = storeRatings.isNotEmpty
        ? storeRatings
        : [
            RatedUser(
              id: 'r1',
              userId: 'u1',
              userName: 'سارة الأحمد',
              rating: 5.0,
              comment:
                  'منتجات رائعة وجودة ممتازة جداً! التوصيل كان سريع والتغليف أنيق ومحترف. سأكرر التجربة حتماً.',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
            RatedUser(
              id: 'r2',
              userId: 'u2',
              userName: 'أحمد محمود',
              rating: 5.0,
              comment:
                  'من أفضل المتاجر التي تعاملت معها، خدمة العملاء سريعة في الرد والمنتج يطابق الوصف تماماً.',
              createdAt: DateTime.now().subtract(const Duration(days: 5)),
            ),
            RatedUser(
              id: 'r3',
              userId: 'u3',
              userName: 'ريم الخالد',
              rating: 5.0,
              comment:
                  'أسعار مناسبة وعروض حقيقية. تجربة التسوق سلسة جداً من إضافة السلة حتى استلام الطلب.',
              createdAt: DateTime.now().subtract(const Duration(days: 9)),
            ),
          ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: hPad),
      padding: EdgeInsets.all(isMobile ? 24 : 48),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'أفضل التعليقات'),
          const SizedBox(height: 32),
          isMobile
              ? Column(
                  children: reviewsToShow
                      .map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ReviewCard(review: review),
                        ),
                      )
                      .toList(),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: reviewsToShow
                      .map(
                        (review) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: _ReviewCard(review: review),
                          ),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final RatedUser review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? theme.scaffoldBackgroundColor
            : theme.scaffoldBackgroundColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: AppColors.star,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                review.userName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${review.comment ?? 'خدمة ممتازة وتجربة شرائية رائعة!'}"',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}
