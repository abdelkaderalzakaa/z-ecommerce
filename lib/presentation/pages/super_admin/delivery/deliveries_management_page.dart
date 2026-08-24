import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../data/models/delivery/delivery_model.dart';
import '../../../global/core/constants/app_constants.dart';
import '../../../global/translate/app_localizations.dart';
import '../../../global/translate/translation_keys.dart';
import '../../../global/tables/app_data_table.dart';
import '../../../global/tables/app_table_column.dart';
import '../../../global/tables/table_cell_helpers.dart';
import '../../../global/navigation.dart';
import 'create_delivery_page.dart';
import 'delivery_details_page.dart';

class DeliveriesManagementPage extends StatefulWidget {
  const DeliveriesManagementPage({super.key});

  @override
  State<DeliveriesManagementPage> createState() => _DeliveriesManagementPageState();
}

class _DeliveriesManagementPageState extends State<DeliveriesManagementPage> {

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, child) {
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppDataTable<DeliveryModel>(
                    items: provider.deliveries,
                    isLoading: provider.isLoading,
                    selectable: true,
                    showIndexColumn: true,
                    onBulkDelete: (selected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${TranslationKeys.deleteSelected.tr(context)} (${selected.length})'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // TODO: Implement bulk delete
                    },
                    searchMatcher: (delivery, query) {
                      return delivery.name.toLowerCase().contains(query) ||
                             delivery.phone.toLowerCase().contains(query) ||
                             (delivery.email?.toLowerCase().contains(query) ?? false);
                    },
                    primaryActionButton: ElevatedButton.icon(
                      onPressed: () {
                        changeScreen(context, const CreateDeliveryPage());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة جهة توصيل'), // Or localized
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
                      ),
                    ),
                    columns: [
                      AppTableColumn<DeliveryModel>(
                        title: 'الاسم',
                        width: 250,
                        sortable: true,
                        cellBuilder: (delivery) => TableImageTextCell(
                          title: delivery.name,
                          subtitle: delivery.phone,
                          imageUrl: delivery.logo,
                          fallbackIcon: Icons.local_shipping_rounded,
                        ),
                        sortKey: (delivery) => delivery.name,
                      ),
                      AppTableColumn<DeliveryModel>(
                        title: 'النوع', // Type
                        width: 150,
                        cellBuilder: (delivery) => Text(
                          delivery.type.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      AppTableColumn<DeliveryModel>(
                        title: 'الحالة',
                        width: 120,
                        cellBuilder: (delivery) => TableStatusBadge.fromStatus(delivery.status),
                      ),
                      AppTableColumn<DeliveryModel>(
                        title: 'رسوم التوصيل', // Base Fee
                        width: 120,
                        cellBuilder: (delivery) => Text(
                          '\$${delivery.baseFee.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                    onRowTap: (delivery) {
                      changeScreen(context, DeliveryDetailsPage(deliveryId: delivery.id));
                    },
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
