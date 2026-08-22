import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

/// 🏬 كارت قراءة فقط مخصص لأدمن البزنس لعرض حالة الصلاحيات المفعلة لمتجره من قبل السوبر أدمن
class BusinessPermissionsStatusWidget extends StatelessWidget {
  final BusinessModel business;

  const BusinessPermissionsStatusWidget({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security_rounded, color: theme.primaryColor, size: 22),
                const SizedBox(width: 10),
                const Text(
                  'حالة الاعتماد وصلاحيات البزنس (من قبل السوبر أدمن)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'توضيح لحالة النشاط الرسمية والتوثيق والخصائص المفعلة لمتجرك.',
              style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                /// حالة النشاط
                _StatusBadge(
                  label: business.isActive ? 'المتجر نشط' : 'المتجر غير نشط',
                  icon: business.isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                  color: business.isActive ? Colors.green : Colors.grey,
                ),

                /// الاعتماد بالشارة الزرقاء
                _StatusBadge(
                  label: business.isVerified ? 'موثق ومعتمد 🔵' : 'غير معتمد',
                  icon: Icons.verified_rounded,
                  color: business.isVerified ? Colors.blueAccent : Colors.grey,
                ),

                /// البزنس الموصى به
                if (business.isRecommended)
                  const _StatusBadge(
                    label: 'موصى به 🌟',
                    icon: Icons.star_rounded,
                    color: Colors.amber,
                  ),

                /// المتابعة
                _StatusBadge(
                  label: business.allowFollow ? 'المتابعات مفعلة' : 'المتابعات معطلة',
                  icon: Icons.person_add_alt_1_rounded,
                  color: business.allowFollow ? Colors.blue : Colors.red,
                ),

                /// الإعجابات
                _StatusBadge(
                  label: business.allowLikes ? 'الإعجابات مفعلة' : 'الإعجابات معطلة',
                  icon: Icons.favorite_rounded,
                  color: business.allowLikes ? Colors.redAccent : Colors.red,
                ),

                /// التقييمات
                _StatusBadge(
                  label: business.allowReviews ? 'التقييمات مفعلة' : 'التقييمات معطلة',
                  icon: Icons.rate_review_rounded,
                  color: business.allowReviews ? Colors.amber : Colors.red,
                ),

                /// العروض
                _StatusBadge(
                  label: business.allowOffers ? 'العروض مفعلة' : 'العروض معطلة',
                  icon: Icons.local_offer_rounded,
                  color: business.allowOffers ? Colors.purple : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
