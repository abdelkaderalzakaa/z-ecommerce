import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/models/store/business_model.dart';
import 'package:z_ecommerce/data/providers/business_provider.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';

class ProductOverviewTab extends StatelessWidget {
  final ProductModel product;

  const ProductOverviewTab({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final businesses = context.watch<BusinessProvider>().businesses;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    BusinessModel? store;
    if (product.businessId.isNotEmpty) {
      try {
        store = businesses.firstWhere((b) => b.id == product.businessId);
      } catch (_) {
        store = null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "نظرة عامة",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Store Info or Warning Section
          if (store != null)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      backgroundImage: store.theme.logoUrl != null
                          ? NetworkImage(store.theme.logoUrl!)
                          : null,
                      child: store.theme.logoUrl == null
                          ? Icon(Icons.storefront_rounded, color: theme.primaryColor, size: 26)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المتجر المالك للمنتج',
                            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic ? store.localization.name.ar : store.localization.name.en,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isArabic ? store.localization.description.ar : store.localization.description.en,
                            style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.amber),
              ),
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تحذير الربط',
                            style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'هذا المنتج غير مرتبط بمتجر صالح حالياً! يرجى تعديل المنتج وربطه بمتجر.',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          
          // Product Properties / Status Section
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'حالات وخصائص المنتج',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            color: theme.cardColor,
            child: Column(
              children: [
                _buildStatusItem(
                  context,
                  title: 'المنتج نشط',
                  subtitle: product.isActive 
                    ? 'المنتج يظهر للعملاء في نتائج البحث والتصنيفات' 
                    : 'المنتج مخفي بالكامل ولن يظهر للعملاء',
                  isActive: product.isActive,
                  icon: Icons.visibility_rounded,
                  onChanged: (val) {
                    if (val) {
                      // عند التنشيط، تأكد أن المنتج مسعر أو مجاني
                      final hasPrices = product.variants.isNotEmpty && product.variants.any((v) => v.price > 0);
                      if (!hasPrices && !product.isFreeProduct) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('يجب تسعير المنتج أولاً قبل تنشيطه، إما بإضافة تسعير أو تعيينه كمنتج مجاني بالكامل.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    context.read<ProductProvider>().updateProduct(product.copyWith(isActive: val));
                  },
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                _buildStatusItem(
                  context,
                  title: 'منتج مميز',
                  subtitle: product.isFeatured
                    ? 'سيظهر في قسم المنتجات المميزة بالصفحة الرئيسية'
                    : 'غير معروض في قسم المنتجات المميزة',
                  isActive: product.isFeatured,
                  icon: Icons.star_rounded,
                  onChanged: (val) {
                    context.read<ProductProvider>().updateProduct(product.copyWith(isFeatured: val));
                  },
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                _buildStatusItem(
                  context,
                  title: 'الأكثر مبيعاً',
                  subtitle: product.isTopSelling
                    ? 'يحمل شارة الأكثر مبيعاً ويظهر في الأقسام الخاصة به'
                    : 'منتج اعتيادي',
                  isActive: product.isTopSelling,
                  icon: Icons.trending_up_rounded,
                  onChanged: (val) {
                    context.read<ProductProvider>().updateProduct(product.copyWith(isTopSelling: val));
                  },
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                _buildStatusItem(
                  context,
                  title: 'منتج مجاني بالكامل',
                  subtitle: product.isFreeProduct
                    ? 'المنتج مجاني للعميل، لن يتم الدفع عند الشراء'
                    : 'منتج مدفوع يخضع لتسعير الخيارات المتاحة',
                  isActive: product.isFreeProduct,
                  icon: Icons.card_giftcard_rounded,
                  onChanged: (val) {
                    if (!val && product.isActive) {
                      final hasPrices = product.variants.isNotEmpty && product.variants.any((v) => v.price > 0);
                      if (!hasPrices) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('لا يمكن إلغاء المجانية عن منتج نشط ليس له سعر. يرجى تسعيره أولاً أو إيقاف تنشيطه.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                    }
                    context.read<ProductProvider>().updateProduct(product.copyWith(isFreeProduct: val));
                  },
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                _buildStatusItem(
                  context,
                  title: 'شحن مجاني',
                  subtitle: product.isFreeShipping
                    ? 'سيتم إلغاء تكاليف الشحن على هذا المنتج أثناء الدفع'
                    : 'يخضع لرسوم الشحن الاعتيادية',
                  isActive: product.isFreeShipping,
                  icon: Icons.local_shipping_rounded,
                  onChanged: (val) {
                    context.read<ProductProvider>().updateProduct(product.copyWith(isFreeShipping: val));
                  },
                ),
                Divider(height: 1, color: theme.dividerColor.withOpacity(0.1)),
                _buildStatusItem(
                  context,
                  title: 'تفعيل التقييمات',
                  subtitle: product.isActiveRatings
                    ? 'العملاء يستطيعون رؤية التقييمات وكتابة تقييم جديد'
                    : 'قسم التقييمات مخفي ولن تظهر المراجعات للعميل',
                  isActive: product.isActiveRatings,
                  icon: Icons.reviews_rounded,
                  onChanged: (val) {
                    context.read<ProductProvider>().updateProduct(product.copyWith(isActiveRatings: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Description Section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'وصف المنتج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Images Section
          const Row(
            children: [
              Icon(Icons.image_outlined, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'معاينة الصور والوسائط',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: product.images.isEmpty
                ? const Center(child: Text("لا توجد صور مضافة للمنتج"))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.images.length,
                    separatorBuilder: (context, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final img = product.images[index];
                      return Container(
                        width: 150,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.12),
                          ),
                          image: img.startsWith('http')
                              ? DecorationImage(
                                  image: NetworkImage(img),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !img.startsWith('http')
                            ? const Center(
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  color: Colors.grey,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isActive,
    required IconData icon,
    required Function(bool)? onChanged,
  }) {
    final theme = Theme.of(context);
    final color = isActive ? Colors.green : Colors.grey;

    return SwitchListTile(
      value: isActive,
      onChanged: onChanged,
      activeColor: Colors.green,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
        ),
      ),
    );
  }
}
