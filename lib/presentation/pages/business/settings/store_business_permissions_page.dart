import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';

class StoreBusinessPermissionsPage extends StatelessWidget {
  const StoreBusinessPermissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final business = context.watch<BusinessProvider>().selectedBusiness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('صلاحيات البزنس'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'للقراءة فقط',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'هذه الصلاحيات تم تحديدها من قبل الإدارة العامة (Super Admin) ولا يمكن تعديلها من هنا.',
                            style: TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
                ),
                child: Column(
                  children: [
                    _buildPermissionItem(
                      title: 'السماح بالمتابعة (Follow)',
                      subtitle: 'تمكين العملاء من متابعة المتجر الخاص بك',
                      isActive: business.allowFollow,
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                    _buildPermissionItem(
                      title: 'السماح بالإعجابات (Likes)',
                      subtitle: 'إمكانية إعجاب العملاء بالمتجر',
                      isActive: business.allowLikes,
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                    _buildPermissionItem(
                      title: 'السماح بالمراجعات (Reviews)',
                      subtitle: 'السماح بترك تقييمات ومراجعات على مستوى المتجر',
                      isActive: business.allowReviews,
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                    _buildPermissionItem(
                      title: 'السماح بالعروض (Offers)',
                      subtitle: 'السماح بإنشاء عروض ترويجية',
                      isActive: business.allowOffers,
                      theme: theme,
                    ),
                    Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                    _buildPermissionItem(
                      title: 'متجر موصى به (Recommended)',
                      subtitle: 'يتم عرض المتجر في قسم التوصيات',
                      isActive: business.isRecommended,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem({
    required String title,
    required String subtitle,
    required bool isActive,
    required ThemeData theme,
  }) {
    final color = isActive ? Colors.green : Colors.grey;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(isActive ? Icons.check_circle_outline : Icons.cancel_outlined, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'مفعل' : 'غير مفعل',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
