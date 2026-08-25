import 'package:flutter/material.dart';
import 'package:z_ecommerce/data/models/common/address_model.dart';
import 'package:z_ecommerce/data/models/common/social_media.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/services/address_service.dart';
import 'package:z_ecommerce/presentation/global/core/constants/enum_data.dart';
import 'package:z_ecommerce/presentation/global/core/constants/payment_methods_constant.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_addresses_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_payment_methods_page.dart';
import 'package:z_ecommerce/presentation/pages/business/store_manage_socials_page.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/create_business_page.dart';

class OverviewTab extends StatelessWidget {
  final BusinessModel store;

  const OverviewTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final totalOrders = store.orders;
    final totalFollowers = store.followersUsers.length;
    final totalVisitors = store.visits.length;

    final hasRatings = store.ratings.isNotEmpty;
    final double avgRating = store.averageRating;
    final String ratingDisplay = hasRatings ? avgRating.toStringAsFixed(1) : (isAr ? 'جديد' : 'New');

    final ownerName = store.ownerName?.isNotEmpty == true ? store.ownerName! : (isAr ? 'غير محدد' : 'Not set');
    final ownerEmail = store.ownerEmail?.isNotEmpty == true ? store.ownerEmail! : (isAr ? 'غير محدد' : 'Not set');
    final ownerPhone = store.ownerPhone?.isNotEmpty == true ? store.ownerPhone! : (isAr ? 'غير محدد' : 'Not set');
    final regDate = store.createdAt != null
        ? store.createdAt!.toLocal().toString().split(' ')[0]
        : (isAr ? 'غير محدد' : 'Not set');

    final storeName = store.localization.name.get(context);
    final storeDesc = store.localization.description.get(context);
    final storeSlogan = store.localization.slogan.get(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TranslationKeys.overviewTab.tr(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),

          // SECTION 1: 📊 الإحصائيات والأداء (Analytics & Performance Metrics)
          Row(
            children: [
              _buildMetricCard(
                context,
                TranslationKeys.ordersCount.tr(context),
                '$totalOrders',
                Icons.shopping_bag_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                TranslationKeys.visits.tr(context),
                '$totalVisitors',
                Icons.visibility_rounded,
                Colors.purple,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                isAr ? 'المتابعون' : 'Followers',
                '$totalFollowers',
                Icons.people_rounded,
                AppColors.green,
              ),
              const SizedBox(width: 16),
              _buildMetricCard(
                context,
                TranslationKeys.rating.tr(context),
                '⭐ $ratingDisplay',
                Icons.star_rounded,
                AppColors.star,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Analytics Overview Chart Container
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        TranslationKeys.salesOverview.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.analytics_rounded, color: theme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.08),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 44,
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isAr ? 'مخطط تحليل أداء المبيعات والزيارات اليومية' : 'Sales performance & daily visits chart',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 2: 🏪 معلومات المتجر والمالك (Store & Owner Information)
          _buildSectionCard(
            context: context,
            title: isAr ? 'معلومات المتجر والمالك' : 'Store & Owner Information',
            icon: Icons.storefront_outlined,
            actionWidget: ButtonApp(
              format: FormatButtonApp.outline,
              label: isAr ? 'تعديل بيانات البزنس والمالك' : 'Edit Business & Owner',
              icon: Icons.edit_outlined,
              fontSize: 12,
              onPressed: () {
                changeScreen(context, CreateBusinessPage(businessToEdit: store));
              },
            ),
            children: [
              _buildInfoRow(isAr ? 'اسم المتجر:' : 'Store Name:', storeName.isNotEmpty ? storeName : '---'),
              _buildInfoRow(isAr ? 'نوع النشاط:' : 'Business Type:', store.businessType.name),
              _buildInfoRow(isAr ? 'اسم المالك:' : 'Owner Name:', ownerName),
              _buildInfoRow(isAr ? 'البريد الإلكتروني:' : 'Owner Email:', ownerEmail),
              _buildInfoRow(isAr ? 'رقم الهاتف:' : 'Phone Number:', ownerPhone),
              _buildInfoRow(isAr ? 'تاريخ التسجيل:' : 'Reg Date:', regDate),
              _buildInfoRow(isAr ? 'العملة الرسمية:' : 'Currency:', '${store.currency.name} (${store.currency.symbol})'),
              _buildInfoRow(isAr ? 'الشعار (Slogan):' : 'Slogan:', storeSlogan.isNotEmpty ? storeSlogan : (isAr ? 'لم يدرج شعار بعد' : 'No slogan')),
              _buildInfoRow(isAr ? 'الوصف:' : 'Description:', storeDesc.isNotEmpty ? storeDesc : (isAr ? 'لم يدرج وصف بعد' : 'No description')),
            ],
          ),
          const SizedBox(height: 24),

          // SECTION 3: 📍 عناوين المواقع والفروع (Locations & Branches)
          StreamBuilder<List<AddressModel>>(
            stream: AddressService().streamAddressesByUserId(store.id),
            builder: (context, snapshot) {
              final addresses = snapshot.data ?? [];
              return _buildSectionCard(
                context: context,
                title: isAr ? 'عناوين المواقع والفروع (${addresses.length})' : 'Locations & Branches (${addresses.length})',
                icon: Icons.location_on_outlined,
                actionWidget: ButtonApp(
                  format: FormatButtonApp.outline,
                  label: isAr ? 'إدارة وتعديل العناوين' : 'Manage & Edit Addresses',
                  icon: Icons.map_outlined,
                  fontSize: 12,
                  onPressed: () {
                    changeScreen(context, StoreManageAddressesPage(store: store));
                  },
                ),
                children: addresses.isEmpty
                    ? [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            isAr ? 'لا توجد عناوين مضافة بعد للمتجر' : 'No branch locations added yet',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ]
                    : addresses.map((addr) {
                        final fullFormatted = addr.getFormattedAddress(langCode: isAr ? 'ar' : 'en');
                        return _buildInfoRow(
                          addr.title.isNotEmpty ? addr.title : (isAr ? 'عنوان فرعي' : 'Branch Address'),
                          fullFormatted.isNotEmpty ? fullFormatted : addr.street,
                        );
                      }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          // SECTION 4: 📲 وسائل وقنوات التواصل (Social Media Channels)
          _buildSectionCard(
            context: context,
            title: isAr ? 'وسائل وقنوات التواصل' : 'Social Media Channels',
            icon: Icons.share_outlined,
            actionWidget: ButtonApp(
              format: FormatButtonApp.outline,
              label: isAr ? 'إدارة وتعديل وسائل التواصل' : 'Manage Social Media',
              icon: Icons.alternate_email_outlined,
              fontSize: 12,
              onPressed: () {
                changeScreen(context, StoreManageSocialsPage(store: store));
              },
            ),
            children: store.socials.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isAr ? 'لم يدرج المتجر وسائل تواصل بعد' : 'No social media channels added yet',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ]
                : store.socials.map((SocialModel social) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.link, size: 18, color: social.color),
                          const SizedBox(width: 8),
                          Text(
                            social.title.get(context),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              social.url,
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
          ),
          const SizedBox(height: 24),

          // SECTION 5: 💳 وسائل وطرق الدفع المعتمدة (Payment Methods)
          _buildSectionCard(
            context: context,
            title: isAr ? 'طرق ووسائل الدفع المعتمدة' : 'Accepted Payment Methods',
            icon: Icons.credit_card_outlined,
            actionWidget: ButtonApp(
              format: FormatButtonApp.outline,
              label: isAr ? 'إدارة وطرق الدفع' : 'Manage Payment Methods',
              icon: Icons.payments_outlined,
              fontSize: 12,
              onPressed: () {
                changeScreen(context, StoreManagePaymentMethodsPage(store: store));
              },
            ),
            children: store.paymentMethods.isEmpty
                ? [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isAr ? 'لم يحدد المتجر طرق الدفع بعد' : 'No payment methods selected yet',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  ]
                : [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: store.paymentMethods.map((PaymentMethodType pm) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: theme.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                pm.name,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    Widget? actionWidget,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: theme.primaryColor),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ?actionWidget,
              ],
            ),
            const Divider(height: 28),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
