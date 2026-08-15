import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/category_provider.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/business/store_create_edit_category_page.dart';

class CategoryTab extends StatelessWidget {
  final BusinessModel store;

  const CategoryTab({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    final storeCategories = categoryProvider.categories
        .where((c) => c.businessId == null || c.businessId == store.id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأقسام والفئات للمتجر',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ButtonApp(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoreCreateEditCategoryPage(businessId: store.id),
                    ),
                  );
                },
                icon: Icons.add,
                label: 'إضافة فئة',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Platform Category
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: Colors.indigo,
              ),
              title: const Text('تصنيف المنصة الرئيسي للمتجر'),
              subtitle: Text(store.businessType.name),
            ),
          ),
          const SizedBox(height: 24),

          // Sub Categories / Departments
          const Text(
            'أقسام وفئات المتجر الخاصة (Categories & Departments)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (storeCategories.isEmpty)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'لا توجد أقسام فرعية مضافة خصيصاً لهذا المتجر بعد',
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: storeCategories.length,
              itemBuilder: (context, index) {
                final cat = storeCategories[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cat.bgColor.withOpacity(0.2),
                      child: Icon(
                        cat.icon ?? Icons.category_rounded,
                        color: cat.bgColor,
                      ),
                    ),
                    title: Text(cat.label),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.compare_arrows,
                          color: Colors.orange,
                          label: 'نقل المنتجات من هذا القسم لقسم آخر',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('زر: نقل المنتجات')),
                            );
                          },
                        ),
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.edit,
                          color: Colors.blue,
                          label: 'تعديل',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StoreCreateEditCategoryPage(
                                      businessId: store.id,
                                      category: cat,
                                    ),
                              ),
                            );
                          },
                        ),
                        ButtonApp(
                          format: FormatButtonApp.icon,
                          icon: Icons.delete,
                          color: Colors.red,
                          label: 'حذف',
                          onPressed: () {
                            Provider.of<CategoryProvider>(
                              context,
                              listen: false,
                            ).deleteCategory(cat.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم حذف الفئة بنجاح'),
                                backgroundColor: Colors.green,
                              ),
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
