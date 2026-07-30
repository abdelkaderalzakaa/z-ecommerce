import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/product/offer_model.dart';
import 'package:z_ecommerce/data/providers/company_provider.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/navigation.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';
import 'package:z_ecommerce/presentation/pages/super_admin/offers/create_edit_offer_page.dart';

class StoreOffersManagementPage extends StatefulWidget {
  final String businessId;

  const StoreOffersManagementPage({super.key, this.businessId});

  @override
  State<StoreOffersManagementPage> createState() =>
      _StoreOffersManagementPageState();
}

class _StoreOffersManagementPageState extends State<StoreOffersManagementPage> {
  String _searchQuery = '';
  List<OfferModel> _selectedOffers = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<OfferProvider>(
        builder: (context, provider, child) {
          final filteredOffers = provider.offers.where((offer) {
            final matchesStore =
                offer.businessId == widget.businessId ||
                offer.businessId == 'cmp_001';
            final titleStr = offer.name.get(context).toLowerCase();
            final matchesQuery =
                _searchQuery.isEmpty ||
                titleStr.contains(_searchQuery.toLowerCase()) ||
                offer.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (offer.couponCode != null &&
                    offer.couponCode!.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ));
            return matchesStore && matchesQuery;
          }).toList();

          final totalItems = filteredOffers.length;
          final totalPages = (totalItems / _itemsPerPage).ceil();
          final startIndex = (_currentPage - 1) * _itemsPerPage;
          final endIndex = (startIndex + _itemsPerPage).clamp(0, totalItems);
          final paginatedOffers = (startIndex < totalItems)
              ? filteredOffers.sublist(startIndex, endIndex)
              : <OfferModel>[];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TranslationKeys.offersManagement.tr(context),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TranslationKeys.offersSubtitle.tr(context),
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          changeScreen(context, const CreateEditOfferPage()),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(TranslationKeys.addNewOffer.tr(context)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 11,
                        ),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // AppDataTable for Store Offers
                Expanded(
                  child: AppDataTable<OfferModel>(
                    items: paginatedOffers,
                    selectable: true,
                    showIndexColumn: true,
                    selectedItems: _selectedOffers,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedOffers = selected;
                      });
                    },
                    onBulkDelete: () {
                      setState(() {
                        for (var o in _selectedOffers) {
                          provider.offers.removeWhere(
                            (item) => item.id == o.id,
                          );
                        }
                        _selectedOffers.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${TranslationKeys.deleteSelected.tr(context)} (${_selectedOffers.length})',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    searchQuery: _searchQuery,
                    onSearchChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _currentPage = 1;
                      });
                    },
                    currentPage: _currentPage,
                    totalPages: totalPages > 0 ? totalPages : 1,
                    totalItems: totalItems,
                    itemsPerPage: _itemsPerPage,
                    onPageChanged: (page) =>
                        setState(() => _currentPage = page),
                    onItemsPerPageChanged: (rows) {
                      setState(() {
                        _itemsPerPage = rows;
                        _currentPage = 1;
                      });
                    },
                    emptyMessage: _searchQuery.isNotEmpty
                        ? TranslationKeys.noMatchingResults.tr(context)
                        : TranslationKeys.noDataAvailable.tr(context),
                    columns: [
                      AppTableColumn<OfferModel>(
                        title: TranslationKeys.offerMarketing.tr(context),
                        flex: 2,
                        sortable: true,
                        sortKey: (o) => o.name.get(context),
                        cellBuilder: (o) => TableImageTextCell(
                          title: o.name.get(context),
                          subtitle:
                              Localizations.localeOf(context).languageCode ==
                                  'ar'
                              ? 'كود: ${o.couponCode ?? "بدون كود"}'
                              : 'Code: ${o.couponCode ?? "No Code"}',
                          fallbackIcon: Icons.local_offer_rounded,
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
                                    : (Localizations.localeOf(
                                                context,
                                              ).languageCode ==
                                              'ar'
                                          ? 'خصم خاص'
                                          : 'Special Discount')),
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
                          onDelete: () {
                            setState(() {
                              provider.offers.removeWhere(
                                (item) => item.id == o.id,
                              );
                            });
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
          );
        },
      ),
    );
  }
}
