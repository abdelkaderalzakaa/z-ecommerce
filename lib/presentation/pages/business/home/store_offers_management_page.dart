import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/models/product/product_offer_model.dart';
import 'package:z_ecommerce/data/models/product/product_model.dart';
import 'package:z_ecommerce/data/providers/product_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/offers/create_edit_offer_page.dart';
import 'package:z_ecommerce/presentation/pages/business/products/pages_create_edit_product/create_edit_product_offer_page.dart'; 
class UnifiedOffer {
  final String id;
  final String title;
  final String typeLabel;
  final String discountLabel;
  final String validityLabel;
  final bool isActive;
  final String? couponCode;
  final String source; // 'general' or 'product'

  final OfferModel? storeOffer;
  final ProductOfferModel? productOffer;
  final ProductModel? associatedProduct;

  UnifiedOffer({
    required this.id,
    required this.title,
    required this.typeLabel,
    required this.discountLabel,
    required this.validityLabel,
    required this.isActive,
    this.couponCode,
    required this.source,
    this.storeOffer,
    this.productOffer,
    this.associatedProduct,
  });
}

class StoreOffersManagementPage extends StatefulWidget {
  final String businessId;

  const StoreOffersManagementPage({super.key, required this.businessId});

  @override
  State<StoreOffersManagementPage> createState() =>
      _StoreOffersManagementPageState();
}

class _StoreOffersManagementPageState extends State<StoreOffersManagementPage> {
  String _selectedFilterType = 'all'; // 'all', 'general', 'product'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().listenToAllProducts();
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(TranslationKeys.filter.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('جميع العروض'),
              value: 'all',
              groupValue: _selectedFilterType,
              onChanged: (val) {
                setState(() => _selectedFilterType = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('عروض المتجر العامة'),
              value: 'general',
              groupValue: _selectedFilterType,
              onChanged: (val) {
                setState(() => _selectedFilterType = val!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('عروض المنتجات الخاصة'),
              value: 'product',
              groupValue: _selectedFilterType,
              onChanged: (val) {
                setState(() => _selectedFilterType = val!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer2<OfferProvider, ProductProvider>(
        builder: (context, offerProvider, productProvider, child) {
          final List<UnifiedOffer> unifiedList = [];

          // 1. Gather general store offers
          final generalOffers = offerProvider.activeOffers.where((o) => o.businessId == widget.businessId);
          for (var go in generalOffers) {
            String typeLabel = go.type;
            if (go.type == 'percentage_discount') typeLabel = 'خصم مئوي (%)';
            if (go.type == 'fixed_discount') typeLabel = 'خصم بمبلغ ثابت (\$)';
            if (go.type == 'coupon') typeLabel = 'كوبون خصم (Coupon)';
            if (go.type == 'free_shipping') typeLabel = 'شحن مجاني';

            String discount = go.discountPercent != null
                ? '${go.discountPercent}%'
                : (go.discountAmount != null ? '\$${go.discountAmount}' : 'خصم');

            unifiedList.add(UnifiedOffer(
              id: go.id,
              title: go.name.get(context),
              typeLabel: typeLabel,
              discountLabel: discount,
              validityLabel: '${go.endDate.year}-${go.endDate.month}-${go.endDate.day}',
              isActive: go.isActive,
              couponCode: go.couponCode,
              source: 'general',
              storeOffer: go,
            ));
          }

          // 2. Gather product-specific offers
          final storeProducts = productProvider.allProducts.where((p) => p.businessId == widget.businessId);
          for (var product in storeProducts) {
            for (var po in product.offers) {
              String typeLabel = po.type;
              if (po.type == 'buy_x_get_y') typeLabel = 'اشتر X واحصل على Y';
              if (po.type == 'gift') typeLabel = 'هدية ترويجية';
              if (po.type == 'free_shipping') typeLabel = 'شحن مجاني للمنتج';

              unifiedList.add(UnifiedOffer(
                id: po.id,
                title: '${po.name} (${product.name})',
                typeLabel: typeLabel,
                discountLabel: po.type == 'buy_x_get_y' ? 'اشتر ${po.buyQuantity} احصل على ${po.getQuantity}' : 'عرض منتج',
                validityLabel: po.endDate != null ? '${po.endDate!.year}-${po.endDate!.month}-${po.endDate!.day}' : 'مستمر',
                isActive: po.isActive,
                couponCode: po.couponCode,
                source: 'product',
                productOffer: po,
                associatedProduct: product,
              ));
            }
          }

          // 3. Filter list
          final filteredList = unifiedList.where((item) {
            if (_selectedFilterType == 'general') return item.source == 'general';
            if (_selectedFilterType == 'product') return item.source == 'product';
            return true;
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TranslationKeys.offersManagement.tr(context),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: AppDataTable<UnifiedOffer>(
                    items: filteredList,
                    selectable: true,
                    showIndexColumn: true,
                    primaryActionButton: ButtonApp(
                      onPressed: () => changeScreen(
                        context,
                        CreateEditOfferPage(businessId: widget.businessId),
                      ),
                      icon: Icons.add,
                      label: TranslationKeys.addNewOffer.tr(context),
                    ),
                    onBulkDelete: (selected) async {
                      for (var item in selected) {
                        if (item.source == 'general') {
                          await offerProvider.deleteOffer(item.storeOffer!.id);
                        } else if (item.source == 'product' && item.associatedProduct != null) {
                          final updatedList = item.associatedProduct!.offers
                              .where((o) => o.id != item.productOffer!.id)
                              .toList();
                          final updatedProduct = item.associatedProduct!.copyWith(offers: updatedList);
                          await productProvider.updateProduct(updatedProduct);
                        }
                      }
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${TranslationKeys.deleteSelected.tr(context)} (${selected.length})',
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    searchMatcher: (o, q) =>
                        o.title.toLowerCase().contains(q.toLowerCase()) ||
                        o.id.toLowerCase().contains(q.toLowerCase()) ||
                        (o.couponCode != null && o.couponCode!.toLowerCase().contains(q.toLowerCase())),
                    onFilterTap: () => _showFilterDialog(context),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    columns: [
                      AppTableColumn<UnifiedOffer>(
                        title: TranslationKeys.offerMarketing.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (o) => o.title,
                        cellBuilder: (o) => TableImageTextCell(
                          title: o.title,
                          subtitle: isAr ? 'كود: ${o.couponCode ?? "بدون كود"}' : 'Code: ${o.couponCode ?? "No Code"}',
                          fallbackIcon: o.source == 'general' ? Icons.local_offer_rounded : Icons.shopping_bag_rounded,
                        ),
                      ),
                      AppTableColumn<UnifiedOffer>(
                        title: 'النوع والمصدر',
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.typeLabel,
                        cellBuilder: (o) => TableTextCell(
                          title: o.typeLabel,
                          subtitle: o.source == 'general' ? 'عرض عام للمتجر' : 'عرض خاص بالمنتج',
                        ),
                      ),
                      AppTableColumn<UnifiedOffer>(
                        title: TranslationKeys.discountRate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.discountLabel,
                        cellBuilder: (o) => TableTextCell(
                          title: o.discountLabel,
                          isBold: true,
                        ),
                      ),
                      AppTableColumn<UnifiedOffer>(
                        title: TranslationKeys.validityDate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.validityLabel,
                        cellBuilder: (o) => TableTextCell(title: o.validityLabel),
                      ),
                      AppTableColumn<UnifiedOffer>(
                        title: TranslationKeys.statusActive.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.isActive ? 1 : 0,
                        cellBuilder: (o) => TableStatusBadge.fromStatus(
                          o.isActive
                              ? TranslationKeys.statusActive.tr(context)
                              : TranslationKeys.statusInactive.tr(context),
                        ),
                      ),
                      AppTableColumn<UnifiedOffer>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (o) => TablePopupMenuActions(
                          onView: () {
                            if (o.source == 'general') {
                              changeScreen(
                                context,
                                CreateEditOfferPage(offer: o.storeOffer, businessId: widget.businessId),
                              );
                            } else {
                              changeScreen(
                                context,
                                CreateEditProductOfferPage(product: o.associatedProduct!, offer: o.productOffer),
                              );
                            }
                          },
                          onEdit: () {
                            if (o.source == 'general') {
                              changeScreen(
                                context,
                                CreateEditOfferPage(offer: o.storeOffer, businessId: widget.businessId),
                              );
                            } else {
                              changeScreen(
                                context,
                                CreateEditProductOfferPage(product: o.associatedProduct!, offer: o.productOffer),
                              );
                            }
                          },
                          onDelete: () async {
                            if (o.source == 'general') {
                              await offerProvider.deleteOffer(o.storeOffer!.id);
                            } else if (o.source == 'product' && o.associatedProduct != null) {
                              final updatedList = o.associatedProduct!.offers
                                  .where((po) => po.id != o.productOffer!.id)
                                  .toList();
                              final updatedProduct = o.associatedProduct!.copyWith(offers: updatedList);
                              await productProvider.updateProduct(updatedProduct);
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تم حذف العرض "${o.title}" بنجاح'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
