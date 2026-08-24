import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/translate/localized_string.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_addresses_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_payment_methods_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_socials_page.dart';
import '../create_business_page.dart';

class PermissionsTab extends StatelessWidget {
  final BusinessModel store;

  const PermissionsTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businessProvider = context.watch<BusinessProvider>();

    final currentStore = businessProvider.businesses.firstWhere(
      (b) => b.id == store.id,
      orElse: () => store,
    );

    // Calculate launch readiness
    int readinessScore = 0;
    final hasOwner = currentStore.hasOwner;
    final hasAddress = currentStore.addAddress.isNotEmpty;
    final hasArabicName = currentStore.localization.name.ar.isNotEmpty;
    final hasSocials = currentStore.socials.isNotEmpty;
    final hasPayments = currentStore.paymentMethods.isNotEmpty;

    if (hasOwner) readinessScore += 20;
    if (hasAddress) readinessScore += 20;
    if (hasArabicName) readinessScore += 20;
    if (hasSocials) readinessScore += 20;
    if (hasPayments) readinessScore += 20;

    final bool isBelowLaunchThreshold = readinessScore < 60;
    final String readinessText = isBelowLaunchThreshold
        ? 'غير جاهز للإطلاق ($readinessScore% - إيقاف تلقائي تحت 60%)'
        : (readinessScore == 100 ? 'جاهز بالكامل للإطلاق (100%)' : 'جاهز للإطلاق ($readinessScore%)');

    final Color readinessColor = isBelowLaunchThreshold
        ? Colors.red
        : (readinessScore == 100 ? Colors.green : Colors.orange);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.admin_panel_settings_rounded, color: theme.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'لوحة التحكم المركزية بصلاحيات وإعدادات البزنس (السوبر أدمن)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'التحكم الشامل في حالة المتجر والاعتماد والشارة الزرقاء وتفعيل أو تعطيل التفاعلات.',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  /// 🚀 SECTION 0: شيب وتفاصيل نسبة الجهوزية للإطلاق
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: readinessColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: readinessColor.withOpacity(0.2), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isBelowLaunchThreshold ? Icons.warning_amber_rounded : Icons.rocket_launch_rounded,
                                  color: readinessColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'مؤشر ونسبة جهوزية البزنس للإطلاق',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),

                            /// شيب الجهوزية الرسمي (Readiness Chip)
                            Chip(
                              avatar: Icon(
                                isBelowLaunchThreshold ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                                color: readinessColor,
                                size: 16,
                              ),
                              label: Text(
                                readinessText,
                                style: TextStyle(color: readinessColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: readinessColor.withOpacity(0.12),
                              side: BorderSide(color: readinessColor.withOpacity(0.3)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: readinessScore / 100,
                            minHeight: 10,
                            backgroundColor: theme.dividerColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(readinessColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isBelowLaunchThreshold
                              ? '⚠️ تنبيه: نسبة الجهوزية الحالية أقل من 60%. يتم إيقاف حالة المتجر تلقائياً لحين تكتمل النسبة إلى 60% أو أكثر.'
                              : '✅ المتجر مستوفي لنسبة الجهوزية المطلوبة للإطلاق ومتاح للنشر.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: readinessColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'تفاصيل بنود الجهوزية الخمسة (اضغط على أي بند غير مكتمل لإكماله فوراً):',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            _buildReadinessItem(
                              'حساب المالك (20%)',
                              hasOwner,
                              onTap: () => changeScreen(context, CreateBusinessPage(businessToEdit: currentStore)),
                            ),
                            _buildReadinessItem(
                              'عناوين المتجر (20%)',
                              hasAddress,
                              onTap: () => changeScreen(context, StoreManageAddressesPage(store: currentStore)),
                            ),
                            _buildReadinessItem(
                              'الاسم العربي (20%)',
                              hasArabicName,
                              onTap: () => changeScreen(context, CreateBusinessPage(businessToEdit: currentStore)),
                            ),
                            _buildReadinessItem(
                              'وسائط التواصل (20%)',
                              hasSocials,
                              onTap: () => changeScreen(context, StoreManageSocialsPage(store: currentStore)),
                            ),
                            _buildReadinessItem(
                              'طرق الدفع (20%)',
                              hasPayments,
                              onTap: () => changeScreen(context, StoreManagePaymentMethodsPage(store: currentStore)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  /// SECTION 1: حالة النشاط والاعتماد
                  const Text(
                    '1. حالة النشاط والتوثيق الرسمي',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  /// 1.1 حالة النشاط (Active / Inactive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (currentStore.isActive ? Colors.green : Colors.grey).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          currentStore.isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                          color: currentStore.isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: const Text(
                        'حالة البزنس (نشط / غير نشط)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        currentStore.isActive
                            ? 'البزنس نشط حالياً ومعروض للزبائن'
                            : 'البزنس غير نشط ومخفي من العرض والتصفح',
                      ),
                      value: currentStore.isActive,
                      onChanged: (val) async {
                        final newStatus = val ? 'Active' : 'Inactive';
                        await businessProvider.updateStoreStatus(currentStore.id, newStatus);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم تفعيل المتجر ونشره للعملاء' : 'تم إيقاف المتجر عن العرض'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  /// 1.2 الاعتماد الرسمي بالشارة الزرقاء (Verified Store)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.blueAccent),
                      ),
                      title: const Text(
                        'اعتماد البزنس (وضع الشارة الزرقاء 🔵)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('وضع أيقونة التوثيق الزرقاء المعتمدة بجانب اسم البزنس في الهيرو'),
                      value: currentStore.isVerified,
                      onChanged: (val) async {
                        final newStatus = val ? 'Active & Verified' : 'Active';
                        await businessProvider.updateStoreStatus(currentStore.id, newStatus);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم اعتماد البزنس وإضافة الشارة الزرقاء' : 'تم إلغاء الشارة الزرقاء للمتجر'),
                              backgroundColor: val ? Colors.blue : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  /// 1.3 التوصية بالبزنس (Recommended Store)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star_rounded, color: Colors.amber),
                      ),
                      title: const Text(
                        'البزنس الموصى به (Recommended Store 🌟)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('إبراز البزنس ضمن قائمة المتاجر الأكثر توصية في الرئيسية'),
                      value: currentStore.isRecommended,
                      onChanged: (val) async {
                        await businessProvider.updatePermissions(currentStore.id, isRecommended: val);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم إدراج المتجر في قائمة الموصى بها' : 'تم إزالة المتجر من قائمة الموصى بها'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  const Divider(height: 24),

                  /// SECTION 2: خصائص وصلاحيات التفاعل
                  const Text(
                    '2. صلاحيات تفاعل الزبائن (Interaction Permissions)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  /// 2.1 المتابعة
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
                      ),
                      title: const Text(
                        'السماح بالمتابعة وعداد المتابعين',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('إظهار/إخفاء زر المتابعة وعداد المتابعين للبزنس في كافة الواجهات'),
                      value: currentStore.allowFollow,
                      onChanged: (val) async {
                        await businessProvider.updatePermissions(currentStore.id, allowFollow: val);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم تفعيل خاصية المتابعة للمتجر' : 'تم تعطيل خاصية المتابعة للمتجر'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  /// 2.2 الإعجابات
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                      ),
                      title: const Text(
                        'السماح بالإعجاب وعداد الإعجابات',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('إظهار/إخفاء أزرار وعدادات الإعجاب للبزنس والمنتجات في الكروت والتفاصيل'),
                      value: currentStore.allowLikes,
                      onChanged: (val) async {
                        await businessProvider.updatePermissions(currentStore.id, allowLikes: val);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم تفعيل خاصية الإعجاب للمتجر والمنتجات' : 'تم تعطيل خاصية الإعجاب للمتجر والمنتجات'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),

                  /// 2.3 التعليقات والتقييمات
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.rate_review_rounded, color: Colors.amber),
                      ),
                      title: const Text(
                        'السماح بالتعليقات والتقييمات',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('إظهار/إخفاء سكشن التعليقات والتقييمات وإمكانية إضافة ردود وتعلبقات'),
                      value: currentStore.allowReviews,
                      onChanged: (val) async {
                        await businessProvider.updatePermissions(currentStore.id, allowReviews: val);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم تفعيل خاصية التعليقات والتقييمات للمتجر والمنتجات' : 'تم تعطيل خاصية التعليقات والتقييمات للمتجر والمنتجات'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  /// 2.4 العروض (Offers)
                  Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      secondary: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.local_offer_rounded, color: Colors.purple),
                      ),
                      title: const Text(
                        'السماح بإنشاء العروض',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text('إظهار/إخفاء نظام العروض الترويجية في المتجر والمنتجات'),
                      value: currentStore.allowOffers,
                      onChanged: (val) async {
                        await businessProvider.updatePermissions(currentStore.id, allowOffers: val);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(val ? 'تم تفعيل خاصية العروض للمتجر والمنتجات' : 'تم تعطيل خاصية العروض للمتجر والمنتجات'),
                              backgroundColor: val ? Colors.green : Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadinessItem(String title, bool isCompleted, {VoidCallback? onTap}) {
    final color = isCompleted ? Colors.green : Colors.red;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: color,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isCompleted ? title : '$title ✏️',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }




}
