import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/theme/app_button.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/business/offers/create_edit_offer_page.dart';

class OffersManagementPage extends StatefulWidget {
  const OffersManagementPage({super.key});

  @override
  State<OffersManagementPage> createState() => _OffersManagementPageState();
}

class _OffersManagementPageState extends State<OffersManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full Height Expanded AppDataTable for OfferModel
                Expanded(
                  child: AppDataTable<OfferModel>(
                    items: provider.activeOffers,
                    selectable: true,
                    showIndexColumn: true,
                    primaryActionButton: ButtonApp(
                      onPressed: () =>
                          changeScreen(context, const CreateEditOfferPage()),
                      icon: Icons.add,
                      label: TranslationKeys.addNewOffer.tr(context),
                    ),
                    onBulkDelete: (selected) async {
                      final count = selected.length;
                      for (var o in selected) {
                        await provider.deleteOffer(o.id);
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} ($count)',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchMatcher: (o, q) =>
                        o.name.get(context).toLowerCase().contains(q.toLowerCase()) ||
                        o.id.toLowerCase().contains(q.toLowerCase()) ||
                        (o.couponCode != null &&
                            o.couponCode!.toLowerCase().contains(q.toLowerCase())),
                    emptyMessage: TranslationKeys.noDataAvailable.tr(context),
                    columns: [
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.offerMarketing.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (o) => o.name.get(context),
                        cellBuilder: (o) => TableImageTextCell(
                          title: o.name.get(context),
                          subtitle: 'كود: ${o.couponCode ?? "بدون كود"}',
                          fallbackIcon: Icons.local_offer_rounded,
                        ),
                      ),
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.associatedStore.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.businessId,
                        cellBuilder: (o) => TableTextCell(
                          title:
                              '${TranslationKeys.store.tr(context)} ${o.businessId}',
                        ),
                      ),
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.discountRate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.discountPercent ?? 0.0,
                        cellBuilder: (o) => TableTextCell(
                          title: o.discountPercent != null
                              ? '${o.discountPercent}%'
                              : (o.discountAmount != null
                                    ? '\$${o.discountAmount}'
                                    : 'خصم خاص'),
                          isBold: true,
                        ),
                      ),
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.validityDate.tr(context),
                        flex: 1,
                        sortable: true,
                        sortKey: (o) => o.endDate,
                        cellBuilder: (o) => TableTextCell(
                          title:
                              '${o.endDate.year}-${o.endDate.month.toString().padLeft(2, '0')}-${o.endDate.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                      AppTableColumn<OfferModel>(
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
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.actions.tr(context),
                        width: 70,
                        alignment: Alignment.center,
                        cellBuilder: (o) => TablePopupMenuActions(
                          onView: () => changeScreen(
                            context,
                            CreateEditOfferPage(offer: o),
                          ),
                          onEdit: () => changeScreen(
                            context,
                            CreateEditOfferPage(offer: o),
                          ),
                          onDelete: () async {
                            await provider.deleteOffer(o.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم حذف العرض "${o.name.get(context)}" بنجاح',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
