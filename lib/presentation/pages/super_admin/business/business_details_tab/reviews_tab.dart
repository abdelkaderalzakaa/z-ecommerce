import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

class ReviewsTab extends StatelessWidget {
  final BusinessModel store;

  const ReviewsTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratings = store.ratingStore ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقييمات والمتابعات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Chip(
                avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                label: Text('${store.rate.toStringAsFixed(1)} / 5.0'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating Summary List
          if (ratings.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('لا توجد تقييمات مسجلة للمتجر حالياً'),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ratings.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = ratings[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.dividerColor.withOpacity(0.12),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Text('${index + 1}'),
                    ),
                    title: Row(
                      children: List.generate(
                        5,
                        (starIndex) => Icon(
                          starIndex < item.rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: Colors.amber,
                          size: 18,
                        ),
                      ),
                    ),
                    subtitle: Text(item.comment),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
