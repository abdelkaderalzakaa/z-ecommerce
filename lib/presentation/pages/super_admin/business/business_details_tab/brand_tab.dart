import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/business/business_details_tab/store_create_edit_brand_page.dart';

class BrandTab extends StatefulWidget {
  final BusinessModel store;

  const BrandTab({super.key, required this.store});

  @override
  State<BrandTab> createState() => _BrandTabState();
}

class _BrandTabState extends State<BrandTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BrandProvider>(
      builder: (context, brandProvider, child) {
        final storeBrands = brandProvider.brands.where((b) => b.businessId == widget.store.id).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'العلامات التجارية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreCreateEditBrandPage(businessId: widget.store.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة براند'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (storeBrands.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('لا توجد علامات تجارية مخصصة لهذا المتجر حتى الآن.'),
              ))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: storeBrands.length,
                itemBuilder: (context, index) {
                  final brand = storeBrands[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      leading: brand.logoUrl != null 
                        ? Image.network(brand.logoUrl!, width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.branding_watermark, size: 40),
                      title: Text(brand.name),
                      subtitle: Text(brand.description ?? 'بدون وصف'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.compare_arrows, color: Colors.orange),
                            tooltip: 'نقل منتجات هذا البراند لبراند آخر',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ميزة نقل المنتجات')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreCreateEditBrandPage(
                                    businessId: widget.store.id,
                                    brand: brand,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<BrandProvider>(context, listen: false).deleteBrand(brand.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('تم حذف البراند بنجاح'), backgroundColor: Colors.green),
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
        );
      },
    );
  }
}
