import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

class ReviewsTab extends StatefulWidget {
  final BusinessModel store;

  const ReviewsTab({super.key, required this.store});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  bool reviewsEnabled = true;
  bool likesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratings = widget.store.ratings;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'التقييمات والإعجابات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Text('التقييمات:'),
                  Switch(
                    value: reviewsEnabled,
                    onChanged: (val) {
                      setState(() {
                        reviewsEnabled = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'تم تفعيل التقييمات' : 'تم إيقاف التقييمات')),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  const Text('الإعجابات:'),
                  Switch(
                    value: likesEnabled,
                    onChanged: (val) {
                      setState(() {
                        likesEnabled = val;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(val ? 'تم تفعيل الإعجابات' : 'تم إيقاف الإعجابات')),
                      );
                    },
                  ),
                ],
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
                      backgroundImage: item.userAvatar != null ? NetworkImage(item.userAvatar!) : null,
                      child: item.userAvatar == null ? const Icon(Icons.person) : null,
                    ),
                    title: Row(
                      children: [
                        Text(item.userName),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(
                            5,
                            (starIndex) => Icon(
                              starIndex < item.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.comment ?? 'بدون تعليق'),
                        const SizedBox(height: 4),
                        Text(
                          item.createdAt.toLocal().toString().split(' ')[0],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.reply, color: Colors.green),
                          tooltip: 'إضافة تعليق يمثل الموقع',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('زر: رد كمدير للموقع')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          tooltip: 'تعديل التقييم',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('زر: تعديل التقييم')),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          tooltip: 'حذف التقييم',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('زر: حذف التقييم')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
