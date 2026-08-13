import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/widgets/templates/details_template.dart';
import 'package:z_ecommerce/core/services/excel_export_service.dart';
import 'package:z_ecommerce/core/services/excel_import_service.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';

import 'business_details_tab/overview_tab.dart';
import 'business_details_tab/products_tab.dart';
import 'business_details_tab/offers_tab.dart';
import 'business_details_tab/category_tab.dart';
import 'business_details_tab/brand_tab.dart';
import 'business_details_tab/followers_tab.dart';
import 'business_details_tab/reviews_tab.dart';

class BusinessDetailsPage extends StatelessWidget {
  final String storeId;

  const BusinessDetailsPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusinessProvider>(
      builder: (context, provider, child) {
        final store = provider.businesses.firstWhere(
          (s) => s.id == storeId,
          orElse: () => provider.businesses.first,
        );

        // Calculate readiness based on filled fields
        int readinessScore = 0;
        if (store.owner != null) readinessScore += 20;
        if (store.addAddress.isNotEmpty) readinessScore += 20;
        if (store.localization.name.ar.isNotEmpty) readinessScore += 20;
        if (store.socials.isNotEmpty) readinessScore += 20;
        if (store.paymentMethods.isNotEmpty) readinessScore += 20;

        String readinessText = readinessScore == 100
            ? 'جاهز بالكامل'
            : 'قيد التجهيز ($readinessScore%)';
        Color readinessColor = readinessScore == 100
            ? Colors.green
            : Colors.orange;

        return DetailsTemplate(
          title: TranslationKeys.storeDetailsTitle.tr(context),
          name: store.localization.name.get(context),
          subtitle:
              '${TranslationKeys.category.tr(context)}: ${store.businessType.name} • ${store.id}',
          avatarUrl: store.theme.logoUrl,
          fallbackIcon: Icons.storefront_rounded,
          statusBadge: TableStatusBadge.fromStatus(store.status ?? 'Active'),
          headerMetrics: [
            // Readiness Level
            Chip(
              avatar: Icon(
                Icons.check_circle_outline,
                color: readinessColor,
                size: 16,
              ),
              label: Text(
                readinessText,
                style: TextStyle(color: readinessColor, fontSize: 12),
              ),
              backgroundColor: readinessColor.withOpacity(0.1),
              side: BorderSide.none,
            ),
            const SizedBox(width: 8),
            // Import Button
            ButtonApp(
              onPressed: () async {
                await ExcelImportService.importData(context, store.id);
              },
              icon: Icons.upload_rounded,
              label: 'استيراد بيانات',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            // Export Button
            ButtonApp(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('جاري تجهيز الملف للتصدير...')),
                );
                try {
                  await ExcelExportService.exportBusinessData(
                    context,
                    store.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تصدير البيانات بنجاح!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ أثناء التصدير: \$e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: Icons.download_rounded,
              color: Colors.amber,
              label: 'تصدير بيانات المتجر',
            ),
            const SizedBox(width: 8),
            // Status Menu
            PopupMenuButton<String>(
              child: ButtonApp(
                onPressed: null,
                icon: Icons.edit_note,
                label: 'تغيير الحالة',
              ),
              onSelected: (val) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم تغيير حالة المتجر إلى: \$val')),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Active', child: Text('نشط')),
                const PopupMenuItem(
                  value: 'Active & Verified',
                  child: Text('نشط ومعتمد'),
                ),
                const PopupMenuItem(
                  value: 'Pending',
                  child: Text('معلق (قيد الانتظار)'),
                ),
                const PopupMenuItem(value: 'Inactive', child: Text('غير نشط')),
              ],
            ),
            const SizedBox(width: 8),
            // Pause / Close
            ButtonApp(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إيقاف المتجر مؤقتاً.')),
                );
              },
              icon: Icons.pause_circle_filled,
              label: 'إيقاف مؤقت',
            ),
          ],
          onEdit: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${TranslationKeys.editAddress.tr(context)} "${store.localization.name.get(context)}"',
                ),
              ),
            );
          },
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'المنتجات'),
            Tab(text: 'العروض'),
            Tab(text: 'الفئات'),
            Tab(text: 'العلامات التجارية'),
            Tab(text: 'المتابعات'),
            Tab(text: 'التقييمات والإعجابات'),
          ],
          tabViews: [
            OverviewTab(store: store),
            ProductsTab(store: store),
            OffersTab(store: store),
            CategoryTab(store: store),
            BrandTab(store: store),
            FollowersTab(store: store),
            ReviewsTab(store: store),
          ],
        );
      },
    );
  }
}
