import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/brand_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/store_create_edit_brand_page.dart';
 
class StoreBrandsPage extends StatefulWidget {
  final bool isSuperAdmin;
  const StoreBrandsPage({super.key, this.isSuperAdmin = false});

  @override
  State<StoreBrandsPage> createState() => _StoreBrandsPageState();
}

class _StoreBrandsPageState extends State<StoreBrandsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final currentStoreId =
        businessProvider.selectedBusiness.id;

    final headerTitle = widget.isSuperAdmin
        ? 'إدارة العلامات التجارية العامة'
        : 'إدارة العلامات التجارية';
    final headerSubtitle = widget.isSuperAdmin
        ? 'إضافة وتعديل العلامات التجارية العامة المتاحة لكافة المتاجر في المنصة'
        : 'إضافة وإدارة العلامات التجارية لمتجرك المعروضة للعملاء';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerTitle,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              headerSubtitle,
              style: TextStyle(
                fontSize: 13,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Consumer<BrandProvider>(
                builder: (context, brandProvider, child) {
                  final brands = brandProvider.brands.where((b) {
                    if (widget.isSuperAdmin) {
                      return true;
                    } else {
                      return b.businessIds.contains(currentStoreId);
                    }
                  }).toList();

                  return AppDataTable<BrandModel>(
                      items: brands,
                      selectable: false,
                      showIndexColumn: true,
                      searchMatcher: (b, q) =>
                          b.name.toLowerCase().contains(q.toLowerCase()),
                      primaryActionButton: ButtonApp(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreCreateEditBrandPage(
                                isSuperAdmin: widget.isSuperAdmin,
                                businessId: currentStoreId,
                              ),
                            ),
                          );
                        },
                        icon: Icons.add_rounded,
                        label: widget.isSuperAdmin
                            ? 'إضافة علامة تجارية عامة'
                            : 'إضافة علامة تجارية جديدة',
                      ),
                      emptyMessage: 'لا توجد علامات تجارية حالياً',
                      columns: [
                        AppTableColumn<BrandModel>(
                          title: 'العلامة التجارية',
                          flex: 2,
                          sortable: true,
                          sortKey: (b) => b.name,
                          cellBuilder: (b) => TableImageTextCell(
                            title: b.name,
                            subtitle: b.description ?? 'ID: ${b.id}',
                            imageUrl: b.logoUrl,
                            fallbackIcon: Icons.branding_watermark_rounded,
                          ),
                        ),
                        if (widget.isSuperAdmin) ...[
                          AppTableColumn<BrandModel>(
                            title: 'نوع العلامة',
                            flex: 1,
                            cellBuilder: (b) => TableStatusBadge(
                              statusText: b.isGlobal
                                  ? 'عامة للمنصة'
                                  : 'مخصصة لمتجر',
                              backgroundColor: b.isGlobal
                                  ? const Color(0xFFE6F4EA)
                                  : const Color(0xFFEEF2FF),
                              textColor: b.isGlobal
                                  ? const Color(0xFF137333)
                                  : const Color(0xFF4F46E5),
                            ),
                          ),
                          AppTableColumn<BrandModel>(
                            title: 'المتاجر المفعلة',
                            flex: 1,
                            cellBuilder: (b) => TableTextCell(
                              title: b.isGlobal
                                  ? '${b.businessIds.length} متاجر'
                                  : 'متجر مالك',
                            ),
                          ),
                        ],
                        AppTableColumn<BrandModel>(
                          title: TranslationKeys.actions.tr(context),
                          width: widget.isSuperAdmin ? 70 : 140,
                          alignment: Alignment.center,
                          cellBuilder: (b) {
                            if (widget.isSuperAdmin) {
                              return TablePopupMenuActions(
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StoreCreateEditBrandPage(
                                            isSuperAdmin: true,
                                            brand: b,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await brandProvider.deleteBrand(b.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم حذف العلامة التجارية "${b.name}" بنجاح',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                            if (b.isGlobal) {
                              final isEnabled =
                                  b.businessIds.contains(currentStoreId);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'تفعيل للمتجر',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Switch(
                                    value: isEnabled,
                                    onChanged: (val) async {
                                      await brandProvider.toggleBrandStatus(
                                        b,
                                        currentStoreId,
                                        val,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              val
                                                  ? 'تم تفعيل العلامة "${b.name}" لمتجرك'
                                                  : 'تم تعطيل العلامة "${b.name}" لمتجرك',
                                            ),
                                          ),
                                        );
                                      }
                                                                        },
                                  ),
                                ],
                              );
                            }
                            return TablePopupMenuActions(
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        StoreCreateEditBrandPage(
                                          isSuperAdmin: false,
                                          businessId: currentStoreId,
                                          brand: b,
                                        ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await brandProvider.deleteBrand(b.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم حذف العلامة التجارية "${b.name}" بنجاح',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
