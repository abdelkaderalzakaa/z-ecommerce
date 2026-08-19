import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/category_model.dart';
import 'package:z_ecommerce/data/providers/auth_provider.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/store_create_edit_category_page.dart';
 
class StoreCategoriesPage extends StatefulWidget {
  final bool isSuperAdmin;
  const StoreCategoriesPage({super.key, this.isSuperAdmin = false});

  @override
  State<StoreCategoriesPage> createState() => _StoreCategoriesPageState();
}

class _StoreCategoriesPageState extends State<StoreCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businessProvider = Provider.of<BusinessProvider>(context);
    final currentStoreId =
        businessProvider.selectedBusiness.id;

    final headerTitle = widget.isSuperAdmin
        ? 'إدارة الفئات العامة'
        : 'إدارة الفئات';

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
            const SizedBox(height: 10),

            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, catProvider, child) {
                  final categories = catProvider.categories.where((c) {
                    if (widget.isSuperAdmin) {
                      return true;
                    } else {
                      return c.businessIds.contains(currentStoreId);
                    }
                  }).toList();

                  return AppDataTable<CategoryModel>(
                      items: categories,
                      selectable: false,
                      showIndexColumn: true,
                      searchMatcher: (c, q) =>
                          c.label.toLowerCase().contains(q.toLowerCase()),
                      primaryActionButton: ButtonApp(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StoreCreateEditCategoryPage(
                                isSuperAdmin: widget.isSuperAdmin,
                                businessId: currentStoreId,
                              ),
                            ),
                          );
                        },
                        icon: Icons.add_rounded,
                        label: widget.isSuperAdmin
                            ? 'إضافة فئة عامة جديدة'
                            : 'إضافة فئة جديدة',
                      ),
                      emptyMessage: 'لا توجد فئات حالياً',
                      columns: [
                        AppTableColumn<CategoryModel>(
                          title: 'الفئة',
                          flex: 2,
                          sortable: true,
                          sortKey: (c) => c.label,
                          cellBuilder: (c) => TableImageTextCell(
                            title: c.label,
                            subtitle: 'ID: ${c.id}',
                            fallbackIcon: c.icon ?? Icons.category_rounded,
                          ),
                        ),
                        if (widget.isSuperAdmin) ...[
                          AppTableColumn<CategoryModel>(
                            title: 'نوع الفئة',
                            flex: 1,
                            cellBuilder: (c) => TableStatusBadge(
                              statusText: c.isGlobal
                                  ? 'عامة للمنصة'
                                  : 'مخصصة لمتجر',
                              backgroundColor: c.isGlobal
                                  ? const Color(0xFFE6F4EA)
                                  : const Color(0xFFEEF2FF),
                              textColor: c.isGlobal
                                  ? const Color(0xFF137333)
                                  : const Color(0xFF4F46E5),
                            ),
                          ),
                          AppTableColumn<CategoryModel>(
                            title: 'المتاجر المفعلة',
                            flex: 1,
                            cellBuilder: (c) => TableTextCell(
                              title: c.isGlobal
                                  ? '${c.businessIds.length} متاجر'
                                  : 'متجر مالك',
                            ),
                          ),
                        ],
                        AppTableColumn<CategoryModel>(
                          title: 'لون التمييز',
                          flex: 1,
                          cellBuilder: (c) => Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: c.bgColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '#${c.bgColor.value.toRadixString(16).substring(2).toUpperCase()}',
                              ),
                            ],
                          ),
                        ),
                        AppTableColumn<CategoryModel>(
                          title: TranslationKeys.actions.tr(context),
                          width: widget.isSuperAdmin ? 70 : 140,
                          alignment: Alignment.center,
                          cellBuilder: (c) {
                            if (widget.isSuperAdmin) {
                              return TablePopupMenuActions(
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          StoreCreateEditCategoryPage(
                                            isSuperAdmin: true,
                                            category: c,
                                          ),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  await catProvider.deleteCategory(c.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم حذف الفئة "${c.label}" بنجاح',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                            if (c.isGlobal) {
                              final isEnabled =
                                  c.businessIds.contains(currentStoreId);
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
                                      await catProvider.toggleCategoryStatus(
                                        c,
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
                                                  ? 'تم تفعيل الفئة "${c.label}" لمتجرك'
                                                  : 'تم تعطيل الفئة "${c.label}" لمتجرك',
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
                                        StoreCreateEditCategoryPage(
                                          isSuperAdmin: false,
                                          businessId: currentStoreId,
                                          category: c,
                                        ),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await catProvider.deleteCategory(c.id);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم حذف الفئة "${c.label}" بنجاح',
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
