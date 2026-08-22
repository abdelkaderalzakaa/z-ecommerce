import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

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
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: const Text(
              'التقييمات والإعجابات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),

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
                      backgroundImage: item.userAvatar != null
                          ? NetworkImage(item.userAvatar!)
                          : null,
                      child: item.userAvatar == null
                          ? const Icon(Icons.person)
                          : null,
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
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.reply,
                          color: Colors.green,
                          label: 'إضافة تعليق يمثل الموقع',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('زر: رد كمدير للموقع'),
                              ),
                            );
                          },
                        ),
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.edit,
                          color: Colors.blue,
                          label: 'تعديل التقييم',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('زر: تعديل التقييم'),
                              ),
                            );
                          },
                        ),
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.delete,
                          color: Colors.red,
                          label: 'حذف التقييم',
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
