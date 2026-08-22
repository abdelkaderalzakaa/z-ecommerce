import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/brand_provider.dart';
import 'package:z_ecommerce/presentation/global/core/constants/app_constants.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/pages/business/store_create_edit_brand_page.dart';

class BrandTab extends StatefulWidget {
  final BusinessModel store;

  const BrandTab({super.key, required this.store});

  @override
  State<BrandTab> createState() => _BrandTabState();
}

class _BrandTabState extends State<BrandTab> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BrandProvider>().listenToAllBrands();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Consumer<BrandProvider>(
      builder: (context, brandProvider, child) {
        final allBrands = brandProvider.brands;
        final filteredBrands = allBrands.where((b) {
          final matchesStore = b.businessIds.contains(widget.store.id);
          final matchesSearch = b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (b.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          return matchesStore && matchesSearch;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Action Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'العلامات التجارية والبراندات' : 'Store Brands & Manufacturers',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isAr
                            ? 'إجمالي الماركات المتاحة للمتجر: (${filteredBrands.length} ماركة)'
                            : 'Total available store brands: (${filteredBrands.length})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  ButtonApp(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StoreCreateEditBrandPage(
                            businessId: widget.store.id,
                          ),
                        ),
                      );
                    },
                    icon: Icons.add,
                    label: isAr ? 'إضافة ماركة جديدة' : 'Add New Brand',
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Search Input Field
              TextField(
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: isAr ? 'البحث عن ماركة أو علامة تجارية...' : 'Search brand by name...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),

              // Brands Grid View
              if (filteredBrands.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.branding_watermark_outlined, size: 56, color: theme.primaryColor.withOpacity(0.4)),
                      const SizedBox(height: 14),
                      Text(
                        isAr ? 'لا توجد علامات تجارية مطابقة للبحث' : 'No brands matched your search',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 140,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredBrands.length,
                  itemBuilder: (context, index) {
                    final brand = filteredBrands[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Brand Logo
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: brand.logoUrl != null && brand.logoUrl!.isNotEmpty
                                      ? Image.network(
                                          brand.logoUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => Icon(
                                            Icons.branding_watermark,
                                            color: theme.primaryColor,
                                          ),
                                        )
                                      : Icon(Icons.branding_watermark, color: theme.primaryColor),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      brand.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: brand.isGlobal ? Colors.blue.withOpacity(0.12) : AppColors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        brand.isGlobal ? (isAr ? 'ماركة عالمية' : 'Global Brand') : (isAr ? 'ماركة المتجر' : 'Store Brand'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: brand.isGlobal ? Colors.blue : AppColors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            brand.description ?? (isAr ? 'بدون وصف تفصيلي' : 'No description provided'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
