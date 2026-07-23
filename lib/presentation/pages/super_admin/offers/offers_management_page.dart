import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:z_ecommerce/data/models/offer_model.dart';
import 'package:z_ecommerce/data/providers/offer_provider.dart';
import 'package:z_ecommerce/presentation/global/tables/app_data_table.dart';
import 'package:z_ecommerce/presentation/global/tables/app_table_column.dart';
import 'package:z_ecommerce/presentation/global/tables/table_cell_helpers.dart';
import 'package:z_ecommerce/presentation/global/translate/app_localizations.dart';
import 'package:z_ecommerce/presentation/global/translate/translation_keys.dart';

class OffersManagementPage extends StatefulWidget {
  const OffersManagementPage({super.key});

  @override
  State<OffersManagementPage> createState() => _OffersManagementPageState();
}

class _OffersManagementPageState extends State<OffersManagementPage> {
  String _searchQuery = '';
  List<OfferModel> _selectedOffers = [];
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {

    return Consumer<OfferProvider>(
      builder: (context, provider, child) {
        final filteredOffers = provider.allOffers.where((offer) {
          final titleStr = offer.name.get(context).toLowerCase();
          final matchesQuery = _searchQuery.isEmpty ||
              titleStr.contains(_searchQuery.toLowerCase()) ||
              offer.id.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesQuery;
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
                  Text(
                        TranslationKeys.offersManagement.tr(context),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(TranslationKeys.addNewOffer.tr(context))),
                      );
                    },
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

              // Full Height Expanded AppDataTable for OfferModel
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${TranslationKeys.deleteSelected.tr(context)} (${_selectedOffers.length})'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() {
                      _selectedOffers.clear();
                    });
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
                  onPageChanged: (page) => setState(() => _currentPage = page),
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
                        subtitle: '${TranslationKeys.couponCode.tr(context)}: ${o.couponCode ?? '-'}',
                        imageUrl: o.imageUrl,
                        fallbackIcon: Icons.local_offer_rounded,
                      ),
                    ),
                    AppTableColumn<OfferModel>(
                      title: TranslationKeys.associatedStore.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (o) => o.companyId,
                      cellBuilder: (o) => TableTextCell(
                        title: '${TranslationKeys.store.tr(context)} ${o.companyId}',
                      ),
                    ),
                    AppTableColumn<OfferModel>(
                      title: TranslationKeys.discountRate.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (o) => o.discountPercent ?? o.discountAmount ?? 0,
                      cellBuilder: (o) => TableTextCell(
                        title: o.discountPercent != null
                            ? '${o.discountPercent}% ${TranslationKeys.discount.tr(context)}'
                            : (o.discountAmount != null
                                ? '\$${o.discountAmount!.toStringAsFixed(2)} ${TranslationKeys.discount.tr(context)}'
                                : TranslationKeys.specialOffers.tr(context)),
                        isBold: true,
                      ),
                    ),
                    AppTableColumn<OfferModel>(
                      title: TranslationKeys.validityDate.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (o) => o.endDate,
                      cellBuilder: (o) => TableTextCell(
                        title: '${o.endDate.year}-${o.endDate.month.toString().padLeft(2, '0')}-${o.endDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    AppTableColumn<OfferModel>(
                      title: TranslationKeys.statusActive.tr(context),
                      flex: 1,
                      sortable: true,
                      sortKey: (o) => o.isValid ? 'Active' : 'Inactive',
                      cellBuilder: (o) => TableStatusBadge.fromStatus(
                        o.isValid
                            ? TranslationKeys.statusActive.tr(context)
                            : TranslationKeys.statusInactive.tr(context),
                      ),
                    ),
                    AppTableColumn<OfferModel>(
                      title: TranslationKeys.actions.tr(context),
                      width: 70,
                      alignment: Alignment.center,
                      cellBuilder: (o) => TablePopupMenuActions(
                        onView: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${TranslationKeys.viewDetails.tr(context)} "${o.name.get(context)}"')),
                          );
                        },
                        onEdit: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${TranslationKeys.editAddress.tr(context)} "${o.name.get(context)}"')),
                          );
                        },
                        onDelete: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${TranslationKeys.deleteSelected.tr(context)} "${o.name.get(context)}"'),
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
    );
  }
}
